#include "codegen.h"

#include "IfStatementNode.h"
#include "ASTVisitor.h"

#include <iostream>
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>

// IfStatementNode
void IfStatementNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* IfStatementNode::codegen() {
    auto& cg = CodeGenerator::getInstance();

    llvm::Value* conditionValue = this->condition->codegen();
    if (!conditionValue) {
        return nullptr;
    }

    // if constexpr: evaluate condition at compile-time
    if (isConstexpr) {
        auto* constCond = llvm::dyn_cast<llvm::ConstantInt>(conditionValue);
        if (constCond) {
            bool condTrue = !constCond->isZero();
            llvm::Value* result = nullptr;
            if (condTrue && thenBlock) {
                result = thenBlock->codegen();
            } else if (!condTrue && elseBlock) {
                result = elseBlock->codegen();
            }
            // If the block added a terminator (e.g. return), create unreachable block for subsequent code
            llvm::BasicBlock* currentBB = cg.builder.GetInsertBlock();
            if (currentBB && currentBB->getTerminator()) {
                auto* parentFunc = currentBB->getParent();
                auto* deadBB = llvm::BasicBlock::Create(cg.context, "constexpr.dead", parentFunc);
                cg.builder.SetInsertPoint(deadBB);
            }
            return result ? result : llvm::Constant::getNullValue(llvm::Type::getInt32Ty(cg.context));
        }
        // Fall through to runtime branch if not a compile-time constant
        std::cerr << "Warning: if constexpr condition is not a compile-time constant, falling back to runtime branch" << std::endl;
    }

    if (!conditionValue->getType()->isIntegerTy(1) && conditionValue->getType()->isIntegerTy()) {
        conditionValue = cg.builder.CreateICmpNE(
            conditionValue, llvm::ConstantInt::get(cg.context, llvm::APInt(conditionValue->getType()->getIntegerBitWidth(), 0)), "ifcond");
    }
    else if (conditionValue->getType()->isPointerTy()) {
        conditionValue = cg.builder.CreateICmpNE(
            conditionValue, llvm::ConstantPointerNull::get(static_cast<llvm::PointerType*>(conditionValue->getType())), "ifcond");
    }
    else if (!conditionValue->getType()->isIntegerTy(1)) {
        std::cerr << "Error: Condition is not a boolean expression." << std::endl;
        return nullptr;
    }

    auto* currentFunction = cg.builder.GetInsertBlock()->getParent();

    llvm::BasicBlock* thenBB = llvm::BasicBlock::Create(cg.context, "then", currentFunction);
    llvm::BasicBlock* elseBB = nullptr;
    if (this->elseBlock != nullptr) {
        elseBB = llvm::BasicBlock::Create(cg.context, "else", currentFunction);
    }
    llvm::BasicBlock* mergeBB = llvm::BasicBlock::Create(cg.context, "ifcont", currentFunction);

    if (this->elseBlock != nullptr) {
        cg.builder.CreateCondBr(conditionValue, thenBB, elseBB);
        cg.builder.SetInsertPoint(thenBB);
        llvm::Value* thenValue = thenBlock->codegen();
        if (!thenValue) {
            thenValue = llvm::UndefValue::get(llvm::Type::getInt32Ty(cg.context));
        }
        const bool thenTerminated = cg.builder.GetInsertBlock()->getTerminator() != nullptr;
        if (!thenTerminated) {
            cg.builder.CreateBr(mergeBB);
        }
        thenBB = cg.builder.GetInsertBlock();
        cg.builder.SetInsertPoint(elseBB);
        llvm::Value* elseValue = elseBlock->codegen();
        if (!elseValue) {
            elseValue = llvm::UndefValue::get(llvm::Type::getInt32Ty(cg.context));
        }
        const bool elseTerminated = cg.builder.GetInsertBlock()->getTerminator() != nullptr;
        if (!elseTerminated) {
            cg.builder.CreateBr(mergeBB);
        }
        elseBB = cg.builder.GetInsertBlock();

        cg.builder.SetInsertPoint(mergeBB);

        if (thenTerminated && elseTerminated) {
            return nullptr;
        }

        if (!thenTerminated && !elseTerminated && thenValue->getType() == elseValue->getType()) {
            auto* phi = cg.builder.CreatePHI(thenValue->getType(), 2, "result");
            phi->addIncoming(thenValue, thenBB);
            phi->addIncoming(elseValue, elseBB);
            return phi;
        }

        return nullptr;
    }
    else {
        cg.builder.CreateCondBr(conditionValue, thenBB, mergeBB);
        cg.builder.SetInsertPoint(thenBB);
        llvm::Value* thenValue = thenBlock->codegen();
        if (!thenValue) {
            thenValue = llvm::UndefValue::get(llvm::Type::getInt32Ty(cg.context));
        }
        if (!cg.builder.GetInsertBlock()->getTerminator()) {
            cg.builder.CreateBr(mergeBB);
        }

        cg.builder.SetInsertPoint(mergeBB);

        return nullptr;
    }
}
