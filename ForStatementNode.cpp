#include "ForStatementNode.h"
#include "ASTVisitor.h"

#include <llvm/IR/Function.h>
#include <llvm/IR/Constants.h>

// ForStatementNode
void ForStatementNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ForStatementNode::codegen() {
    llvm::Function* function = codeGenerator->builder.GetInsertBlock()->getParent();

    // for ���� �� ó�� iteration ������ �ʱ�ȭ�ϰ�,
    llvm::BasicBlock* beforeLoopBB = codeGenerator->builder.GetInsertBlock();

    llvm::Value* startValue;
    llvm::Value* endValue;

    llvm::Value* value_ptr = nullptr;

    if (this->isRange) {
        //
        auto rangeExpr = std::dynamic_pointer_cast<RangeExpressionNode>(this->iterableExpr);
        startValue = rangeExpr->startExpr->codegen();
        endValue = rangeExpr->endExpr->codegen();
        if (!startValue || !endValue) {
            return nullptr;
        }

        if (!rangeExpr->isInclusive) {
            endValue = codeGenerator->builder.CreateSub(endValue, llvm::ConstantInt::get(llvm::Type::getInt32Ty(codeGenerator->context), 1), "untilEnd");
        }

        // ���ο� integer type�� value�� ���� �߰�
        value_ptr = codeGenerator->builder.CreateAlloca(startValue->getType(), nullptr, this->variable + "_ptr");
        // �ʱ�ȭ: startValue�� ���� value�� assign��
        codeGenerator->builder.CreateStore(startValue, value_ptr);

        // iteration ������ symbol table�� �߰� : VARIABLE�� ptr��
        auto varSymbol = new Symbol(this->variable, rangeExpr->startExpr->getType(), value_ptr, false, SymbolType::VARIABLE);
        codeGenerator->symbolTable.addSymbol(this->variable, varSymbol);
    }
    else {
        startValue = llvm::ConstantInt::get(llvm::Type::getInt32Ty(codeGenerator->context), 0);
        endValue = llvm::ConstantInt::get(llvm::Type::getInt32Ty(codeGenerator->context), 10);

        // ���ο� value�� ���� �߰�
        value_ptr = codeGenerator->builder.CreateAlloca(startValue->getType(), nullptr, this->variable + "_ptr");
        codeGenerator->builder.CreateStore(startValue, value_ptr);

        // iteration ������ symbol table�� �߰�
        auto varSymbol = new Symbol(this->variable, std::make_shared<BasicType>("Int"), value_ptr, false, SymbolType::VARIABLE);
        codeGenerator->symbolTable.addSymbol(this->variable, varSymbol);
    }

    llvm::BasicBlock* loopBB = llvm::BasicBlock::Create(codeGenerator->context, "loop", function);
    llvm::BasicBlock* afterBB = llvm::BasicBlock::Create(codeGenerator->context, "afterloop", function);

    codeGenerator->builder.SetInsertPoint(loopBB);
    this->body->codegen();

    // i�� �ϳ� ���� ��Ŵ
    // next value�� �������� �Լ��� ȣ���ؾ�������, ���⼭�� �ϴ� �ܼ��� 1 ������Ŵ
    auto* value = codeGenerator->builder.CreateLoad(startValue->getType(), value_ptr, this->variable.c_str());
    auto* next_value = codeGenerator->builder.CreateAdd(value, codeGenerator->builder.getInt32(1), "next_i");
    codeGenerator->builder.CreateStore(next_value, value_ptr);

    auto* cond = codeGenerator->builder.CreateICmpSLE(value, endValue, "cond");
    codeGenerator->builder.CreateCondBr(cond, loopBB /*body and increment*/, afterBB);

    // jump back to loop
    codeGenerator->builder.SetInsertPoint(afterBB);

    return nullptr;
}