#include "codegen.h"

#include "FunctionDeclarationNode.h"
#include "ASTVisitor.h"
#include "utils.h"
#include "type_utils.h"

#include <iostream>
#include <llvm/IR/Function.h>

#include "ParameterNode.h"
#include "BlockNode.h"

void FunctionDeclarationNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

namespace {
FunctionSymbol* updateOrRegisterFunctionSymbolNamed(
    const std::string& name, std::unique_ptr<Type> functionType, llvm::Function* function, bool isExternalSymbol) {
    auto& symbolTable = CodeGenerator::getInstance().symbolTable;
    FunctionSymbol* existingFunction = nullptr;
    if (auto* concreteFunctionType = dynamic_cast<FunctionType*>(functionType.get())) {
        existingFunction = symbolTable.lookupFunction(name, concreteFunctionType->parameterTypes);
    }
    auto* existingSymbol = existingFunction ? static_cast<Symbol*>(existingFunction) : nullptr;
    if (existingSymbol && existingSymbol->symbolType == SymbolType::FUNCTION) {
        existingSymbol->type = functionType ? functionType->clone() : std::make_unique<UnknownType>();
        existingSymbol->value = function;
        existingSymbol->function = function;
        existingSymbol->isMutable = isExternalSymbol;
        return dynamic_cast<FunctionSymbol*>(existingSymbol);
    }

    auto functionSymbol = std::make_unique<FunctionSymbol>(name, std::move(functionType), function, isExternalSymbol, SymbolType::FUNCTION);
    auto* functionSymbolRaw = functionSymbol.get();
    if (!symbolTable.addSymbol(name, std::move(functionSymbol))) {
        std::cerr << "Error: Failed to register function symbol '" << name << "'" << std::endl;
        return nullptr;
    }
    return functionSymbolRaw;
}

std::string mangledFunctionName(CodeGenerator& cg, const std::string& name) {
    return cg.scopes.empty() ? "_" + name : join(cg.scopes, "#") + "#" + name;
}
}

llvm::Function* FunctionDeclarationNode::declarePrototype() {
    if (this->isExternal) return nullptr;
    auto& cg = CodeGenerator::getInstance();

    std::vector<llvm::Type*> paramTypes;
    for (auto& param : this->parameters) {
        auto* paramType = getABIStorageType(param->getType().get());
        if (!paramType) return nullptr;
        paramTypes.push_back(paramType);
    }
    llvm::Type* returnType = getABIStorageType(this->returnType.get());
    if (!returnType) return nullptr;

    const std::string funcName = mangledFunctionName(cg, this->name);
    llvm::Function* function = cg.module->getFunction(funcName);
    if (!function) {
        llvm::FunctionType* funcType = llvm::FunctionType::get(returnType, paramTypes, false);
        function = llvm::Function::Create(funcType, llvm::Function::ExternalLinkage, funcName, cg.module.get());
        if (this->isConstexpr) {
            function->addFnAttr(llvm::Attribute::AlwaysInline);
        }
    }
    updateOrRegisterFunctionSymbolNamed(this->name, this->getType(), function, false);
    return function;
}

llvm::Value* FunctionDeclarationNode::codegen() {
    auto updateOrRegisterFunctionSymbol = [&](std::unique_ptr<Type> functionType, llvm::Function* function, bool isExternalSymbol) -> FunctionSymbol* {
        return updateOrRegisterFunctionSymbolNamed(this->name, std::move(functionType), function, isExternalSymbol);
    };

    if (this->isExternal) {
        std::vector<llvm::Type*> paramTypes;
        for (auto& param : this->parameters) {
            auto* paramType = getABIStorageType(param->getType().get());
            if (!paramType) {
                std::cerr << "Error: Not supported parameter type in external function '" << this->name << "'" << std::endl;
                return nullptr;
            }
            paramTypes.push_back(paramType);
        }

        llvm::FunctionType* funcType = llvm::FunctionType::get(
            getABIStorageType(this->returnType.get()),
            paramTypes,
            false);
        const std::string llvmName = this->externalSymbolName.empty() ? this->name : this->externalSymbolName;
        llvm::Function * function = llvm::Function::Create(
            funcType,
            llvm::Function::ExternalLinkage,
            llvmName,
            CodeGenerator::getInstance().module.get()
		);

        auto functionType = std::make_unique<FunctionType>();
        functionType->returnType = this->returnType ? this->returnType->clone() : std::make_unique<UnknownType>();
        for (auto& param : this->parameters) {
            functionType->parameterTypes.push_back(param->getType()->clone());
        }
        if (!updateOrRegisterFunctionSymbol(std::move(functionType), function, true)) {
            return nullptr;
        }

		return function;
	}

    auto& cg = CodeGenerator::getInstance();

    std::vector<llvm::Type*> paramTypes;

    for (auto& param : this->parameters) {
        auto* paramType = getABIStorageType(param->getType().get());
        if (!paramType) {
            std::cerr << "Error: Not supported parameter type in function '" << this->name << "'" << std::endl;
            return nullptr;
        }
        paramTypes.push_back(paramType);
    }

    llvm::Type* returnType = getABIStorageType(this->returnType.get());
    if (!returnType) {
        std::cerr << "Error: Not supported the return type of '" << this->name << "'" << std::endl;
        return nullptr;
    }
    llvm::FunctionType* funcType = llvm::FunctionType::get(returnType, paramTypes, false);
    std::string funcName = mangledFunctionName(cg, this->name);

    // Reuse the prototype if one was already declared (for example by the pre-declaration pass
    // that enables forward references), so the body attaches to the function the callers resolved
    // against rather than a renamed duplicate.
    llvm::Function* function = cg.module->getFunction(funcName);
    if (!function) {
        function = llvm::Function::Create(funcType, llvm::Function::ExternalLinkage, funcName, cg.module.get());
    }

    if (this->isConstexpr) {
        function->addFnAttr(llvm::Attribute::AlwaysInline);
    }

    auto* functionSymbolRaw = updateOrRegisterFunctionSymbol(this->getType(), function, false);
    if (!functionSymbolRaw) {
        return nullptr;
    }
    auto* savedCurrentSymbol = cg.symbolTable.getCurrentSymbol();
    cg.symbolTable.saveCurrentSymbol();
    cg.symbolTable.setCurrentSymbol(functionSymbolRaw);
    cg.symbolTable.enterScope();

    llvm::BasicBlock* bb = llvm::BasicBlock::Create(cg.context, "entry", function);
    cg.builder.SetInsertPoint(bb);

    int cnt = 0;
    for (auto& arg : this->parameters) {
        auto* paramNode = dynamic_cast<ParameterNode*>(arg.get());
        if (!paramNode) {
            std::cerr << "Error: Non-parameter node in parameters list of '" << this->name << "'" << std::endl;
            cnt += 1;
            continue;
        }
        auto paramType = arg->getType();
        llvm::Value* paramValue = function->getArg(cnt);
        if (isStructClassType(paramType.get())) {
            llvm::Type* storageType = cg.getLLVMType(paramType.get());
            auto* paramSlot = cg.builder.CreateAlloca(storageType, nullptr, (paramNode->name + ".addr").c_str());
            cg.builder.CreateStore(paramValue, paramSlot);
            paramValue = paramSlot;
        }
        auto paramSymbol = std::make_unique<Symbol>(paramNode->name, std::move(paramType), paramValue, false, SymbolType::VARIABLE);
        cg.symbolTable.addSymbol(paramNode->name, std::move(paramSymbol));
        cnt += 1;
    }

    if (this->body) {
        this->body->codegen();
    }

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
    cg.symbolTable.popCurrentSymbol();
    cg.symbolTable.setCurrentSymbol(savedCurrentSymbol);

    return function;
}
