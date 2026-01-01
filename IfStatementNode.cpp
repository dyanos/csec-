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

    // conditionValue�� ���� Ÿ���� ��� 0�� ���Ͽ� boolean���� ��ȯ �� �б� ó��
    if (conditionValue->getType()->isIntegerTy()) {
        conditionValue = CodeGenerator::getInstance().builder.CreateICmpNE(
            conditionValue, llvm::ConstantInt::get(CodeGenerator::getInstance().context, llvm::APInt(conditionValue->getType()->getIntegerBitWidth(), 0)), "ifcond");
    }
    // conditionValue�� pointer Ÿ���� ��� null�� ���Ͽ� boolean���� ��ȯ �� �б� ó��
    else if (conditionValue->getType()->isPointerTy()) {
        conditionValue = CodeGenerator::getInstance().builder.CreateICmpNE(
            conditionValue, llvm::ConstantPointerNull::get(static_cast<llvm::PointerType*>(conditionValue->getType())), "ifcond");
    }
    // conditionValue�� boolean Ÿ���� �ƴ� ��� ���� ó��
    else if (!conditionValue->getType()->isIntegerTy(1)) {
        std::cerr << "Error: Condition is not a boolean expression." << std::endl;
        return nullptr;
    }

    // ���� current block�� ����
    auto* currentFunction = CodeGenerator::getInstance().builder.GetInsertBlock()->getParent();
    auto* currBlock = CodeGenerator::getInstance().builder.GetInsertBlock();

    // then ���ϰ� else ������ ���� �� �� ���� ���� current block���� ���ǿ� ���� �б�
    llvm::BasicBlock* thenBB = llvm::BasicBlock::Create(CodeGenerator::getInstance().context, "then", currentFunction);
    llvm::BasicBlock* elseBB = nullptr;
    if (this->elseBlock != nullptr) {
        elseBB = llvm::BasicBlock::Create(CodeGenerator::getInstance().context, "else", currentFunction);
    }
    llvm::BasicBlock* mergeBB = llvm::BasicBlock::Create(CodeGenerator::getInstance().context, "ifcont", currentFunction);

    // if else �϶� ������ expression(�Ǵ� statement)�� ���� ���� instruction���� ����� �� �ֵ��� PHI ��� ����
    if (this->elseBlock != nullptr) {
        CodeGenerator::getInstance().builder.CreateCondBr(conditionValue, thenBB, elseBB);
        // then ���� �ڵ� ����
        CodeGenerator::getInstance().builder.SetInsertPoint(thenBB);
        llvm::Value* thenValue = thenBlock->codegen();
        if (!thenValue) {
            return nullptr;
        }
        CodeGenerator::getInstance().builder.CreateBr(mergeBB);
        thenBB = CodeGenerator::getInstance().builder.GetInsertBlock();
        // else ���� �ڵ� ����
        CodeGenerator::getInstance().builder.SetInsertPoint(elseBB);
        llvm::Value* elseValue = elseBlock->codegen();
        if (!elseValue) {
            return nullptr;
        }
        CodeGenerator::getInstance().builder.CreateBr(mergeBB);
        elseBB = CodeGenerator::getInstance().builder.GetInsertBlock();

        CodeGenerator::getInstance().builder.SetInsertPoint(mergeBB);

        auto* phi = CodeGenerator::getInstance().builder.CreatePHI(llvm::Type::getInt32Ty(CodeGenerator::getInstance().context), 2, "result");
        // then �� else ��� ����
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
        // then �� else ��� ����
        phi->addIncoming(thenValue, thenBB);
        phi->addIncoming(elseValue, elseBB);*/
        // null ��ȯ
        return nullptr;
    }

    //return llvm::Constant::getNullValue(llvm::Type::getInt32Ty(CodeGenerator::getInstance().context));
}