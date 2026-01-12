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
    llvm::Value* conditionValue = this->condition->codegen();
    if (!conditionValue) {
        return nullptr;
    }

    if (conditionValue->getType()->isIntegerTy()) {
        conditionValue = CodeGenerator::getInstance().builder.CreateICmpNE(
            conditionValue, llvm::ConstantInt::get(CodeGenerator::getInstance().context, llvm::APInt(conditionValue->getType()->getIntegerBitWidth(), 0)), "ifcond");
    }
    else if (conditionValue->getType()->isPointerTy()) {
        conditionValue = CodeGenerator::getInstance().builder.CreateICmpNE(
            conditionValue, llvm::ConstantPointerNull::get(static_cast<llvm::PointerType*>(conditionValue->getType())), "ifcond");
    }
    else if (!conditionValue->getType()->isIntegerTy(1)) {
        std::cerr << "Error: Condition is not a boolean expression." << std::endl;
        return nullptr;
    }

    auto* currentFunction = CodeGenerator::getInstance().builder.GetInsertBlock()->getParent();
    //auto* currBlock = CodeGenerator::getInstance().builder.GetInsertBlock();

    llvm::BasicBlock* thenBB = llvm::BasicBlock::Create(CodeGenerator::getInstance().context, "then", currentFunction);
    llvm::BasicBlock* elseBB = nullptr;
    if (this->elseBlock != nullptr) {
        elseBB = llvm::BasicBlock::Create(CodeGenerator::getInstance().context, "else", currentFunction);
    }
    llvm::BasicBlock* mergeBB = llvm::BasicBlock::Create(CodeGenerator::getInstance().context, "ifcont", currentFunction);

    if (this->elseBlock != nullptr) {
        CodeGenerator::getInstance().builder.CreateCondBr(conditionValue, thenBB, elseBB);
        CodeGenerator::getInstance().builder.SetInsertPoint(thenBB);
        llvm::Value* thenValue = thenBlock->codegen();
        if (!thenValue) {
            return nullptr;
        }
        CodeGenerator::getInstance().builder.CreateBr(mergeBB);
        thenBB = CodeGenerator::getInstance().builder.GetInsertBlock();
        CodeGenerator::getInstance().builder.SetInsertPoint(elseBB);
        llvm::Value* elseValue = elseBlock->codegen();
        if (!elseValue) {
            return nullptr;
        }
        CodeGenerator::getInstance().builder.CreateBr(mergeBB);
        elseBB = CodeGenerator::getInstance().builder.GetInsertBlock();

        CodeGenerator::getInstance().builder.SetInsertPoint(mergeBB);

        auto* phi = CodeGenerator::getInstance().builder.CreatePHI(llvm::Type::getInt32Ty(CodeGenerator::getInstance().context), 2, "result");
        phi->addIncoming(thenValue, thenBB);
        phi->addIncoming(elseValue, elseBB);

        return phi;
    }
    else {
        CodeGenerator::getInstance().builder.CreateCondBr(conditionValue, thenBB, mergeBB);
        // then ���� �ڵ� ����
        CodeGenerator::getInstance().builder.SetInsertPoint(thenBB);
        llvm::Value* thenValue = thenBlock->codegen();
        if (!thenValue) {
            return nullptr;
        }
        CodeGenerator::getInstance().builder.CreateBr(mergeBB);

        CodeGenerator::getInstance().builder.SetInsertPoint(mergeBB);

        /*auto* phi = CodeGenerator::getInstance().builder.CreatePHI(llvm::Type::getInt32Ty(CodeGenerator::getInstance().context), 2, "result");
        phi->addIncoming(thenValue, thenBB);
        phi->addIncoming(elseValue, elseBB);*/
        // null ��ȯ
        return nullptr;
    }

    //return llvm::Constant::getNullValue(llvm::Type::getInt32Ty(CodeGenerator::getInstance().context));
}