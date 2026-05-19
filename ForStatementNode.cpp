#include "codegen.h"

#include "ForStatementNode.h"
#include "ASTVisitor.h"

#include <llvm/IR/Function.h>
#include <llvm/IR/Constants.h>

#include "RangeExpressionNode.h"
#include "symbol.h"

#include <iostream>

namespace {
llvm::Value* coerceRangeBound(llvm::Value* value, llvm::Type* targetType) {
    if (!value || !targetType) {
        return value;
    }

    auto& cg = CodeGenerator::getInstance();
    llvm::Type* sourceType = value->getType();
    if (sourceType == targetType) {
        return value;
    }

    if (sourceType->isIntegerTy() && targetType->isIntegerTy()) {
        unsigned srcBits = sourceType->getIntegerBitWidth();
        unsigned dstBits = targetType->getIntegerBitWidth();
        if (srcBits < dstBits) {
            return cg.builder.CreateSExt(value, targetType, "range.sext");
        }
        return cg.builder.CreateTrunc(value, targetType, "range.trunc");
    }

    if (sourceType->isFloatingPointTy() && targetType->isIntegerTy()) {
        return cg.builder.CreateFPToSI(value, targetType, "range.fptosi");
    }

    if (sourceType->isIntegerTy() && targetType->isFloatingPointTy()) {
        return cg.builder.CreateSIToFP(value, targetType, "range.sitofp");
    }

    return value;
}
}


// ForStatementNode
void ForStatementNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ForStatementNode::codegen() {
    auto& cg = CodeGenerator::getInstance();

    llvm::Function* function = cg.builder.GetInsertBlock()->getParent();
    llvm::BasicBlock* beforeLoopBB = cg.builder.GetInsertBlock();

    llvm::Value* startValue;
    llvm::Value* endValue;

    llvm::Value* value_ptr = nullptr;

    cg.symbolTable.enterScope();

    if (this->isRange) {
        auto* rangeExpr = dynamic_cast<RangeExpressionNode*>(this->iterableExpr.get());
        if (!rangeExpr) {
            cg.symbolTable.exitScope();
            return nullptr;
        }
        startValue = rangeExpr->startExpr->codegen();
        endValue = rangeExpr->endExpr->codegen();
        if (!startValue || !endValue) {
            cg.symbolTable.exitScope();
            return nullptr;
        }

        llvm::Type* rangeValueType = startValue->getType()->isIntegerTy()
            ? startValue->getType()
            : llvm::Type::getInt32Ty(cg.context);
        startValue = coerceRangeBound(startValue, rangeValueType);
        endValue = coerceRangeBound(endValue, rangeValueType);

        if (!rangeExpr->isInclusive) {
            endValue = cg.builder.CreateSub(endValue, llvm::ConstantInt::get(rangeValueType, 1, true), "untilEnd");
        }

        value_ptr = cg.builder.CreateAlloca(rangeValueType, nullptr, this->variable + "_ptr");
        cg.builder.CreateStore(startValue, value_ptr);

        auto rangeType = rangeExpr->startExpr->getType();
        cg.symbolTable.addSymbol(
            this->variable,
            std::make_unique<Symbol>(
                this->variable,
                std::move(rangeType),
                value_ptr,
                false,
                SymbolType::VARIABLE));
    }
    else {
        std::cerr << "Error: non-range for-each loops are not yet implemented." << std::endl;
        cg.symbolTable.exitScope();
        return nullptr;
    }

    llvm::BasicBlock* condBB = llvm::BasicBlock::Create(cg.context, "forcond", function);
    llvm::BasicBlock* loopBB = llvm::BasicBlock::Create(cg.context, "loop", function);
    llvm::BasicBlock* afterBB = llvm::BasicBlock::Create(cg.context, "afterloop", function);

    if (beforeLoopBB && !beforeLoopBB->getTerminator()) {
        cg.builder.CreateBr(condBB);
    }

    // Condition block: check i <= endValue before each iteration
    cg.builder.SetInsertPoint(condBB);
    auto* condValue = cg.builder.CreateLoad(startValue->getType(), value_ptr, this->variable.c_str());
    if (!condValue->getType()->isIntegerTy()) {
        std::cerr << "Type error: range bounds in for-loop must be the same integer type" << std::endl;
        cg.symbolTable.exitScope();
        return nullptr;
    }
    auto* cond = cg.builder.CreateICmpSLE(condValue, endValue, "cond");
    cg.builder.CreateCondBr(cond, loopBB, afterBB);

    // Loop body
    cg.builder.SetInsertPoint(loopBB);
    this->body->codegen();

    // Increment and branch back to condition
    if (!cg.builder.GetInsertBlock()->getTerminator()) {
        auto* value = cg.builder.CreateLoad(startValue->getType(), value_ptr, this->variable.c_str());
        auto* one = llvm::ConstantInt::get(startValue->getType(), 1, true);
        auto* next_value = cg.builder.CreateAdd(value, one, "next_i");
        cg.builder.CreateStore(next_value, value_ptr);
        cg.builder.CreateBr(condBB);
    }

    cg.builder.SetInsertPoint(afterBB);
    cg.symbolTable.exitScope();

    return nullptr;
}

