#include "codegen.h"

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

    llvm::Function* function = CodeGenerator::getInstance().builder.GetInsertBlock()->getParent();
    llvm::BasicBlock* afterBB = llvm::BasicBlock::Create(CodeGenerator::getInstance().context, "afterMatch", function);

    llvm::Value* result = nullptr;

    for (size_t i = 0; i < cases.size(); ++i) {
        auto& casePair = cases[i];

        llvm::BasicBlock* caseBB = llvm::BasicBlock::Create(CodeGenerator::getInstance().context, "case", function);
        llvm::BasicBlock* nextCaseBB = (i == cases.size() - 1) ? afterBB : llvm::BasicBlock::Create(CodeGenerator::getInstance().context, "nextCase", function);

        CodeGenerator::getInstance().builder.SetInsertPoint(CodeGenerator::getInstance().builder.GetInsertBlock());

        llvm::Value* caseValue = casePair.first->codegen();
        if (!caseValue) {
            return nullptr;
        }

        llvm::Value* condition = CodeGenerator::getInstance().builder.CreateICmpEQ(matchValue, caseValue, "matchCond");

        CodeGenerator::getInstance().builder.CreateCondBr(condition, caseBB, nextCaseBB);

        CodeGenerator::getInstance().builder.SetInsertPoint(caseBB);
        llvm::Value* caseResult = casePair.second->codegen();
        if (!caseResult) {
            return nullptr;
        }
        result = caseResult;

        CodeGenerator::getInstance().builder.CreateBr(afterBB);

        //  ?
        if (nextCaseBB != afterBB) {
            CodeGenerator::getInstance().builder.SetInsertPoint(nextCaseBB);
        }
    }

    // afterBB
    CodeGenerator::getInstance().builder.SetInsertPoint(afterBB);

    return result ? result : llvm::Constant::getNullValue(llvm::Type::getInt32Ty(CodeGenerator::getInstance().context));
}