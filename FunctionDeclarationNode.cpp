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

    std::vector<llvm::Type*> paramTypes;

    for (auto& param : this->parameters) {
        paramTypes.push_back(CodeGenerator::getInstance().getLLVMType(param->getType().get()));
    }

    llvm::Type* returnType = CodeGenerator::getInstance().getLLVMType(this->returnType.get());
    if (!returnType) {
        std::cerr << "Error: Not supported the return type of '" << this->name << "'" << std::endl;
        return nullptr;
    }
    llvm::FunctionType* funcType = llvm::FunctionType::get(returnType, paramTypes, false);
    // ????? ?????? ??? ????????? ???? ??? ??????? ???λ? ???
    std::string funcName = [&]() {
        if (CodeGenerator::getInstance().scopes.empty()) {
            return "_" + this->name;
        }
        else {
            return join(CodeGenerator::getInstance().scopes, "#") + "#" + this->name;
        }
        }();

    llvm::Function* function = llvm::Function::Create(funcType, llvm::Function::ExternalLinkage, funcName, CodeGenerator::getInstance().module.get());

    // TODO: ??? ?????? ??? ??? ???
    // TODO: ??????? symboltable?? ??? ????? ??????, ???? ??? ??????? ?????? ??¹?? ???ο? ??? ??????? ?????, ??? ??? ???? ???????? ?????? ??????? ??
    auto functionType = this->getType();
    auto functionSymbol = std::make_unique<FunctionSymbol>(this->name, std::move(functionType), function, false, SymbolType::FUNCTION);
    auto* functionSymbolRaw = functionSymbol.get();
    if (!CodeGenerator::getInstance().symbolTable.addSymbol(this->name, std::move(functionSymbol))) {
        std::cerr << "Error: Failed to register function symbol '" << this->name << "'" << std::endl;
        return nullptr;
    }
    CodeGenerator::getInstance().symbolTable.setCurrentSymbol(functionSymbolRaw);
    CodeGenerator::getInstance().symbolTable.enterScope();

    // ??? ???? ??? ???
    int cnt = 0;
    for (auto& arg : this->parameters) {
        auto paramType = arg->getType();
        auto paramSymbol = std::make_unique<Symbol>((static_cast<ParameterNode*>(arg.get()))->name, std::move(paramType), function->getArg(cnt), false, SymbolType::VARIABLE);
        CodeGenerator::getInstance().symbolTable.addSymbol((static_cast<ParameterNode*>(arg.get()))->name, std::move(paramSymbol));
        cnt += 1;
    }

    // block start
    llvm::BasicBlock* bb = llvm::BasicBlock::Create(CodeGenerator::getInstance().context, "entry", function);
    CodeGenerator::getInstance().builder.SetInsertPoint(bb);
    this->body->codegen();
    // block end
    // body?? return?? ???? ?????? ???? ???? ??? ??????? ????

    llvm::BasicBlock* currentBlock = CodeGenerator::getInstance().builder.GetInsertBlock();
    if (currentBlock && !currentBlock->getTerminator()) {
        if (returnType->isVoidTy()) {
            CodeGenerator::getInstance().builder.CreateRetVoid();
        }
        else if (returnType->isIntegerTy()) {
            CodeGenerator::getInstance().builder.CreateRet(llvm::ConstantInt::get(returnType, 0));
        }
        else if (returnType->isFloatTy()) {
            CodeGenerator::getInstance().builder.CreateRet(llvm::ConstantFP::get(returnType, 0.0));
        }
        else if (returnType->isDoubleTy()) {
            CodeGenerator::getInstance().builder.CreateRet(llvm::ConstantFP::get(returnType, 0.0));
        }
        else {
            CodeGenerator::getInstance().builder.CreateRet(llvm::Constant::getNullValue(returnType));
        }
    }

    CodeGenerator::getInstance().symbolTable.exitScope();

    return function;
}
