#include "../../include/ast/for_statement_node.h"
#include "../../include/ast/ast_visitor.h"
#include <iostream>

ForStatementNode::ForStatementNode() {
    nodeType = ASTNodeType::FOR_STATEMENT;
    isRange = false;
    isInclusive = true;
}

void ForStatementNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ForStatementNode::codegen() {
    llvm::Function* function = codeGenerator->builder.GetInsertBlock()->getParent();

    llvm::Value* startValue;
    llvm::Value* endValue;

    if (isRange) {
        auto rangeExpr = std::dynamic_pointer_cast<RangeExpressionNode>(iterableExpr);
        startValue = rangeExpr->startExpr->codegen();
        endValue = rangeExpr->endExpr->codegen();
        if (!startValue || !endValue) {
            return nullptr;
        }

        if (!rangeExpr->isInclusive) {
            endValue = codeGenerator->builder.CreateSub(endValue, 
                llvm::ConstantInt::get(llvm::Type::getInt32Ty(codeGenerator->context), 1), 
                "untilEnd");
        }
    }
    else {
        startValue = llvm::ConstantInt::get(llvm::Type::getInt32Ty(codeGenerator->context), 0);
        endValue = llvm::ConstantInt::get(llvm::Type::getInt32Ty(codeGenerator->context), 10);
    }

    llvm::BasicBlock* preheaderBB = codeGenerator->builder.GetInsertBlock();
    llvm::BasicBlock* loopBB = llvm::BasicBlock::Create(codeGenerator->context, "loop", function);
    llvm::BasicBlock* afterBB = llvm::BasicBlock::Create(codeGenerator->context, "afterloop", function);

    codeGenerator->builder.CreateBr(loopBB);
    codeGenerator->builder.SetInsertPoint(loopBB);

    llvm::PHINode* variableNode = codeGenerator->builder.CreatePHI(
        llvm::Type::getInt32Ty(codeGenerator->context), 2, variable.c_str());
    variableNode->addIncoming(startValue, preheaderBB);

    if (!body->codegen()) {
        return nullptr;
    }

    llvm::Value* nextValue = codeGenerator->builder.CreateAdd(
        variableNode, 
        llvm::ConstantInt::get(llvm::Type::getInt32Ty(codeGenerator->context), 1), 
        "nextvar");

    llvm::Value* endCond = codeGenerator->builder.CreateICmpSLE(variableNode, endValue, "loopcond");
    codeGenerator->builder.CreateCondBr(endCond, loopBB, afterBB);

    variableNode->addIncoming(nextValue, codeGenerator->builder.GetInsertBlock());
    codeGenerator->builder.SetInsertPoint(afterBB);

    return llvm::Constant::getNullValue(llvm::Type::getInt32Ty(codeGenerator->context));
}

std::shared_ptr<Type> ForStatementNode::getType() {
    return nullptr;
} 