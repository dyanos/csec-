#include "../../include/ast/if_statement_node.h"
#include "../../include/ast/ast_visitor.h"
#include <iostream>

IfStatementNode::IfStatementNode() {
    nodeType = ASTNodeType::IF_STATEMENT;
}

void IfStatementNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* IfStatementNode::codegen() {
    llvm::Value* conditionValue = condition->codegen();
    if (!conditionValue) {
        return nullptr;
    }

    if (conditionValue->getType()->isIntegerTy(32)) {
        conditionValue = codeGenerator->builder.CreateICmpNE(
            conditionValue, 
            llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(32, 0)), 
            "ifcond");
    }
    else if (!conditionValue->getType()->isIntegerTy(1)) {
        std::cerr << "Error: Condition is not a boolean expression." << std::endl;
        return nullptr;
    }

    llvm::Function* function = codeGenerator->builder.GetInsertBlock()->getParent();
    bool hasElse = elseBlock != nullptr;

    llvm::BasicBlock* thenBB = llvm::BasicBlock::Create(codeGenerator->context, "then", function);
    llvm::BasicBlock* elseBB = nullptr;
    llvm::BasicBlock* mergeBB = llvm::BasicBlock::Create(codeGenerator->context, "ifcont", function);

    if (hasElse) {
        elseBB = llvm::BasicBlock::Create(codeGenerator->context, "else", function);
        codeGenerator->builder.CreateCondBr(conditionValue, thenBB, elseBB);
    }
    else {
        codeGenerator->builder.CreateCondBr(conditionValue, thenBB, mergeBB);
    }

    codeGenerator->builder.SetInsertPoint(thenBB);
    llvm::Value* thenValue = thenBlock->codegen();
    if (!thenValue) {
        return nullptr;
    }

    codeGenerator->builder.CreateBr(mergeBB);
    thenBB = codeGenerator->builder.GetInsertBlock();

    if (hasElse) {
        codeGenerator->builder.SetInsertPoint(elseBB);
        llvm::Value* elseValue = elseBlock->codegen();
        if (!elseValue) {
            return nullptr;
        }
        codeGenerator->builder.CreateBr(mergeBB);
        elseBB = codeGenerator->builder.GetInsertBlock();
    }

    codeGenerator->builder.SetInsertPoint(mergeBB);
    return llvm::Constant::getNullValue(llvm::Type::getInt32Ty(codeGenerator->context));
}

std::shared_ptr<Type> IfStatementNode::getType() {
    return nullptr;
} 