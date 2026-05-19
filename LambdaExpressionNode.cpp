#include "codegen.h"
#include "LambdaExpressionNode.h"
#include "ASTVisitor.h"
#include "ParameterNode.h"

#include <iostream>
#include <llvm/IR/Function.h>
#include <llvm/IR/Constants.h>

namespace {
std::unique_ptr<Type> usableLambdaType(std::unique_ptr<Type> type) {
    if (!type || type->getKind() == Type::Kind::UNKNOWN) {
        return std::make_unique<BasicType>("Int");
    }
    return type;
}

llvm::Value* defaultReturnValue(llvm::Type* type) {
    auto& cg = CodeGenerator::getInstance();
    if (!type || type->isVoidTy()) {
        return nullptr;
    }
    if (type->isIntegerTy()) {
        return llvm::ConstantInt::get(type, 0, true);
    }
    if (type->isFloatingPointTy()) {
        return llvm::ConstantFP::get(type, 0.0);
    }
    if (type->isPointerTy()) {
        return llvm::ConstantPointerNull::get(llvm::cast<llvm::PointerType>(type));
    }
    return llvm::Constant::getNullValue(type);
}
}

void LambdaExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* LambdaExpressionNode::codegen() {
    auto& cg = CodeGenerator::getInstance();
    std::vector<llvm::Type*> paramTypes;

    // Add regular arguments
    for (auto& arg : arguments) {
        auto paramType = usableLambdaType(arg ? arg->getType() : nullptr);
        auto* argType = cg.getLLVMType(paramType.get());
        if (!argType) {
            std::cerr << "Error: Invalid lambda parameter type" << std::endl;
            return nullptr;
        }
        paramTypes.push_back(argType);
    }

    // Determine return type
    auto bodyType = usableLambdaType(body ? body->getType() : nullptr);
    llvm::Type* returnType = bodyType ? cg.getLLVMType(bodyType.get()) : nullptr;
    if (!returnType) returnType = llvm::Type::getInt32Ty(cg.context);

    // Create anonymous function
    llvm::FunctionType* funcType = llvm::FunctionType::get(returnType, paramTypes, false);

    static int lambdaCount = 0;
    std::string lambdaName = "__lambda_" + std::to_string(lambdaCount++);

    llvm::Function* lambdaFunc = llvm::Function::Create(
        funcType, llvm::Function::InternalLinkage, lambdaName, cg.module.get());

    // Save current insert point
    llvm::BasicBlock* savedBB = cg.builder.GetInsertBlock();

    // Create entry block
    llvm::BasicBlock* entry = llvm::BasicBlock::Create(cg.context, "entry", lambdaFunc);
    cg.builder.SetInsertPoint(entry);

    cg.symbolTable.enterScope();

    int argIdx = 0;
    // Bind arguments
    for (size_t i = 0; i < arguments.size(); ++i) {
        auto* paramNode = static_cast<ParameterNode*>(arguments[i].get());
        auto paramType = usableLambdaType(arguments[i] ? arguments[i]->getType() : nullptr);
        cg.symbolTable.addSymbol(paramNode->name, std::make_unique<Symbol>(
            paramNode->name, std::move(paramType), lambdaFunc->getArg(argIdx), false, SymbolType::VARIABLE));
        argIdx++;
    }

    // Generate body
    llvm::Value* bodyValue = nullptr;
    if (captureVariables.empty()) {
        bodyValue = body->codegen();
    }

    // Add return if block has no terminator
    if (!cg.builder.GetInsertBlock()->getTerminator()) {
        if (bodyValue && !returnType->isVoidTy()) {
            cg.builder.CreateRet(bodyValue);
        }
        else if (!returnType->isVoidTy()) {
            cg.builder.CreateRet(defaultReturnValue(returnType));
        }
        else {
            cg.builder.CreateRetVoid();
        }
    }

    cg.symbolTable.exitScope();

    // Restore insert point
    cg.builder.SetInsertPoint(savedBB);

    return lambdaFunc;
}
