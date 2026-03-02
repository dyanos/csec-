#include "codegen.h"
#include "LambdaExpressionNode.h"
#include "ASTVisitor.h"
#include "ParameterNode.h"

#include <iostream>
#include <llvm/IR/Function.h>

void LambdaExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* LambdaExpressionNode::codegen() {
    auto& cg = CodeGenerator::getInstance();
    std::vector<llvm::Type*> paramTypes;
    if (!captureVariables.empty()) {
        std::cerr << "Error: Lambda captures are not supported yet" << std::endl;
        return nullptr;
    }

    // Add regular arguments
    for (auto& arg : arguments) {
        auto* argType = cg.getLLVMType(arg->getType().get());
        if (!argType) {
            std::cerr << "Error: Invalid lambda parameter type" << std::endl;
            return nullptr;
        }
        paramTypes.push_back(argType);
    }

    // Determine return type
    auto bodyType = body ? body->getType() : nullptr;
    llvm::Type* returnType = bodyType ? cg.getLLVMType(bodyType.get()) : nullptr;
    if (!returnType) returnType = llvm::Type::getVoidTy(cg.context);

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
        cg.symbolTable.addSymbol(paramNode->name, std::make_unique<Symbol>(
            paramNode->name, arguments[i]->getType(), lambdaFunc->getArg(argIdx), false, SymbolType::VARIABLE));
        argIdx++;
    }

    // Generate body
    llvm::Value* bodyValue = body->codegen();

    // Add return if block has no terminator
    if (!cg.builder.GetInsertBlock()->getTerminator()) {
        if (bodyValue && !returnType->isVoidTy()) {
            cg.builder.CreateRet(bodyValue);
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
