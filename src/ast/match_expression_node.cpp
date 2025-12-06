#include "../../include/ast/match_expression_node.h"
#include "../../include/ast/ast_visitor.h"
#include <iostream>

MatchExpressionNode::MatchExpressionNode() {
    nodeType = ASTNodeType::MATCH_EXPRESSION;
}

void MatchExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* MatchExpressionNode::codegen() {
    llvm::Value* matchValue = expression->codegen();
    if (!matchValue) {
        return nullptr;
    }

    llvm::Function* function = codeGenerator->builder.GetInsertBlock()->getParent();
    llvm::BasicBlock* afterBB = llvm::BasicBlock::Create(codeGenerator->context, "afterMatch", function);
    llvm::Value* result = nullptr;

    for (size_t i = 0; i < cases.size(); ++i) {
        auto& casePair = cases[i];
        llvm::BasicBlock* caseBB = llvm::BasicBlock::Create(codeGenerator->context, "case", function);
        llvm::BasicBlock* nextCaseBB = (i == cases.size() - 1) ? 
            afterBB : llvm::BasicBlock::Create(codeGenerator->context, "nextCase", function);

        codeGenerator->builder.SetInsertPoint(codeGenerator->builder.GetInsertBlock());

        llvm::Value* caseValue = casePair.first->codegen();
        if (!caseValue) {
            return nullptr;
        }

        llvm::Value* condition = codeGenerator->builder.CreateICmpEQ(matchValue, caseValue, "matchCond");
        codeGenerator->builder.CreateCondBr(condition, caseBB, nextCaseBB);

        codeGenerator->builder.SetInsertPoint(caseBB);
        llvm::Value* caseResult = casePair.second->codegen();
        if (!caseResult) {
            return nullptr;
        }
        result = caseResult;

        codeGenerator->builder.CreateBr(afterBB);

        if (nextCaseBB != afterBB) {
            codeGenerator->builder.SetInsertPoint(nextCaseBB);
        }
    }

    codeGenerator->builder.SetInsertPoint(afterBB);
    return result ? result : llvm::Constant::getNullValue(llvm::Type::getInt32Ty(codeGenerator->context));
}

std::shared_ptr<Type> MatchExpressionNode::getType() {
    return nullptr;
} 