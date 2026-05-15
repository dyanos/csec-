#include "codegen.h"

#include "FunctionDeclarationNode.h"
#include "ASTVisitor.h"
#include "utils.h"

#include <iostream>
#include <llvm/IR/Function.h>

#include "ParameterNode.h"
#include "BlockNode.h"

void FunctionDeclarationNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* FunctionDeclarationNode::codegen() {
    if (this->isExternal) {
        std::vector<llvm::Type*> paramTypes;
        for (auto& param : this->parameters) {
            auto* paramType = CodeGenerator::getInstance().getLLVMType(param->getType().get());
            if (!paramType) {
                std::cerr << "Error: Not supported parameter type in external function '" << this->name << "'" << std::endl;
                return nullptr;
            }
            paramTypes.push_back(paramType);
        }

        llvm::FunctionType* funcType = llvm::FunctionType::get(
            CodeGenerator::getInstance().getLLVMType(this->returnType.get()),
            paramTypes,
            false);
        llvm::Function * function = llvm::Function::Create(
            funcType,
            llvm::Function::ExternalLinkage,
            this->name,
            CodeGenerator::getInstance().module.get()
		);

        auto functionType = std::make_unique<FunctionType>();
        functionType->returnType = this->returnType ? this->returnType->clone() : std::make_unique<UnknownType>();
        for (auto& param : this->parameters) {
            functionType->parameterTypes.push_back(param->getType()->clone());
        }
        auto functionSymbol = std::make_unique<FunctionSymbol>(this->name, std::move(functionType), function, true, SymbolType::FUNCTION);
        if (!CodeGenerator::getInstance().symbolTable.addSymbol(this->name, std::move(functionSymbol))) {
            std::cerr << "Error: Failed to register external function symbol '" << this->name << "'" << std::endl;
            return nullptr;
        }

		return function;
	}

    auto& cg = CodeGenerator::getInstance();

    std::vector<llvm::Type*> paramTypes;

    for (auto& param : this->parameters) {
        auto* paramType = cg.getLLVMType(param->getType().get());
        if (!paramType) {
            std::cerr << "Error: Not supported parameter type in function '" << this->name << "'" << std::endl;
            return nullptr;
        }
        paramTypes.push_back(paramType);
    }

    llvm::Type* returnType = cg.getLLVMType(this->returnType.get());
    if (!returnType) {
        std::cerr << "Error: Not supported the return type of '" << this->name << "'" << std::endl;
        return nullptr;
    }
    llvm::FunctionType* funcType = llvm::FunctionType::get(returnType, paramTypes, false);
    std::string funcName = [&]() {
        if (cg.scopes.empty()) {
            return "_" + this->name;
        }
        else {
            return join(cg.scopes, "#") + "#" + this->name;
        }
        }();

    llvm::Function* function = llvm::Function::Create(funcType, llvm::Function::ExternalLinkage, funcName, cg.module.get());

    if (this->isConstexpr) {
        function->addFnAttr(llvm::Attribute::AlwaysInline);
    }

    auto functionType = this->getType();
    auto functionSymbol = std::make_unique<FunctionSymbol>(this->name, std::move(functionType), function, false, SymbolType::FUNCTION);
    auto* functionSymbolRaw = functionSymbol.get();
    if (!cg.symbolTable.addSymbol(this->name, std::move(functionSymbol))) {
        std::cerr << "Error: Failed to register function symbol '" << this->name << "'" << std::endl;
        return nullptr;
    }
    cg.symbolTable.setCurrentSymbol(functionSymbolRaw);
    cg.symbolTable.enterScope();

    int cnt = 0;
    for (auto& arg : this->parameters) {
        auto paramType = arg->getType();
        auto paramSymbol = std::make_unique<Symbol>((static_cast<ParameterNode*>(arg.get()))->name, std::move(paramType), function->getArg(cnt), false, SymbolType::VARIABLE);
        cg.symbolTable.addSymbol((static_cast<ParameterNode*>(arg.get()))->name, std::move(paramSymbol));
        cnt += 1;
    }

    llvm::BasicBlock* bb = llvm::BasicBlock::Create(cg.context, "entry", function);
    cg.builder.SetInsertPoint(bb);
    this->body->codegen();

    llvm::BasicBlock* currentBlock = cg.builder.GetInsertBlock();
    if (currentBlock && !currentBlock->getTerminator()) {
        if (returnType->isVoidTy()) {
            cg.builder.CreateRetVoid();
        }
        else if (returnType->isIntegerTy()) {
            cg.builder.CreateRet(llvm::ConstantInt::get(returnType, 0));
        }
        else if (returnType->isFloatTy()) {
            cg.builder.CreateRet(llvm::ConstantFP::get(returnType, 0.0));
        }
        else if (returnType->isDoubleTy()) {
            cg.builder.CreateRet(llvm::ConstantFP::get(returnType, 0.0));
        }
        else {
            cg.builder.CreateRet(llvm::Constant::getNullValue(returnType));
        }
    }

    cg.symbolTable.exitScope();
    cg.symbolTable.setCurrentSymbol(nullptr);

    return function;
}
