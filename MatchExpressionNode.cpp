#include "MatchExpressionNode.h"
#include "ASTVisitor.h"

#include <llvm/IR/Function.h>
#include <llvm/IR/Constants.h>

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
        llvm::BasicBlock* nextCaseBB = (i == cases.size() - 1) ? afterBB : llvm::BasicBlock::Create(codeGenerator->context, "nextCase", function);

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

        //  ̽
        if (nextCaseBB != afterBB) {
            codeGenerator->builder.SetInsertPoint(nextCaseBB);
        }
    }

    // afterBB
    codeGenerator->builder.SetInsertPoint(afterBB);

    return result ? result : llvm::Constant::getNullValue(llvm::Type::getInt32Ty(codeGenerator->context));
}