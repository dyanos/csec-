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

    // conditionValue�� ���� Ÿ���� ��� 0�� ���Ͽ� boolean���� ��ȯ �� �б� ó��
    if (conditionValue->getType()->isIntegerTy()) {
        conditionValue = codeGenerator->builder.CreateICmpNE(
            conditionValue, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(conditionValue->getType()->getIntegerBitWidth(), 0)), "ifcond");
    }
    // conditionValue�� pointer Ÿ���� ��� null�� ���Ͽ� boolean���� ��ȯ �� �б� ó��
    else if (conditionValue->getType()->isPointerTy()) {
        conditionValue = codeGenerator->builder.CreateICmpNE(
            conditionValue, llvm::ConstantPointerNull::get(static_cast<llvm::PointerType*>(conditionValue->getType())), "ifcond");
    }
    // conditionValue�� boolean Ÿ���� �ƴ� ��� ���� ó��
    else if (!conditionValue->getType()->isIntegerTy(1)) {
        std::cerr << "Error: Condition is not a boolean expression." << std::endl;
        return nullptr;
    }

    // ���� current block�� ����
    auto* currentFunction = codeGenerator->builder.GetInsertBlock()->getParent();
    auto* currBlock = codeGenerator->builder.GetInsertBlock();

    // then ���ϰ� else ������ ���� �� �� ���� ���� current block���� ���ǿ� ���� �б�
    llvm::BasicBlock* thenBB = llvm::BasicBlock::Create(codeGenerator->context, "then", currentFunction);
    llvm::BasicBlock* elseBB = nullptr;
    if (this->elseBlock != nullptr) {
        elseBB = llvm::BasicBlock::Create(codeGenerator->context, "else", currentFunction);
    }
    llvm::BasicBlock* mergeBB = llvm::BasicBlock::Create(codeGenerator->context, "ifcont", currentFunction);

    // if else �϶� ������ expression(�Ǵ� statement)�� ���� ���� instruction���� ����� �� �ֵ��� PHI ��� ����
    if (this->elseBlock != nullptr) {
        codeGenerator->builder.CreateCondBr(conditionValue, thenBB, elseBB);
        // then ���� �ڵ� ����
        codeGenerator->builder.SetInsertPoint(thenBB);
        llvm::Value* thenValue = thenBlock->codegen();
        if (!thenValue) {
            return nullptr;
        }
        codeGenerator->builder.CreateBr(mergeBB);
        thenBB = codeGenerator->builder.GetInsertBlock();
        // else ���� �ڵ� ����
        codeGenerator->builder.SetInsertPoint(elseBB);
        llvm::Value* elseValue = elseBlock->codegen();
        if (!elseValue) {
            return nullptr;
        }
        codeGenerator->builder.CreateBr(mergeBB);
        elseBB = codeGenerator->builder.GetInsertBlock();

        codeGenerator->builder.SetInsertPoint(mergeBB);

        auto* phi = codeGenerator->builder.CreatePHI(llvm::Type::getInt32Ty(codeGenerator->context), 2, "result");
        // then �� else ��� ����
        phi->addIncoming(thenValue, thenBB);
        phi->addIncoming(elseValue, elseBB);

        return phi;
    }
    else {
        codeGenerator->builder.CreateCondBr(conditionValue, thenBB, mergeBB);
        // then ���� �ڵ� ����
        codeGenerator->builder.SetInsertPoint(thenBB);
        llvm::Value* thenValue = thenBlock->codegen();
        if (!thenValue) {
            return nullptr;
        }
        codeGenerator->builder.CreateBr(mergeBB);

        codeGenerator->builder.SetInsertPoint(mergeBB);

        /*auto* phi = codeGenerator->builder.CreatePHI(llvm::Type::getInt32Ty(codeGenerator->context), 2, "result");
        // then �� else ��� ����
        phi->addIncoming(thenValue, thenBB);
        phi->addIncoming(elseValue, elseBB);*/
        // null ��ȯ
        return nullptr;
    }

    //return llvm::Constant::getNullValue(llvm::Type::getInt32Ty(codeGenerator->context));
}