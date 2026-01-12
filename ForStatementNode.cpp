#include "codegen.h"

#include "ForStatementNode.h"
#include "ASTVisitor.h"

#include <llvm/IR/Function.h>
#include <llvm/IR/Constants.h>

#include "RangeExpressionNode.h"
#include "symbol.h"


// ForStatementNode
void ForStatementNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ForStatementNode::codegen() {
    llvm::Function* function = CodeGenerator::getInstance().builder.GetInsertBlock()->getParent();

    //llvm::BasicBlock* beforeLoopBB = CodeGenerator::getInstance().builder.GetInsertBlock();

    llvm::Value* startValue;
    llvm::Value* endValue;

    llvm::Value* value_ptr = nullptr;

    if (this->isRange) {
        //
        auto rangeExpr = (RangeExpressionNode*)(this->iterableExpr.get());
        startValue = rangeExpr->startExpr->codegen();
        endValue = rangeExpr->endExpr->codegen();
        if (!startValue || !endValue) {
            return nullptr;
        }

        if (!rangeExpr->isInclusive) {
            endValue = CodeGenerator::getInstance().builder.CreateSub(endValue, llvm::ConstantInt::get(llvm::Type::getInt32Ty(CodeGenerator::getInstance().context), 1), "untilEnd");
        }

        value_ptr = CodeGenerator::getInstance().builder.CreateAlloca(startValue->getType(), nullptr, this->variable + "_ptr");
        CodeGenerator::getInstance().builder.CreateStore(startValue, value_ptr);

        auto varSymbol = new Symbol(this->variable, rangeExpr->startExpr->getType().get(), value_ptr, false, SymbolType::VARIABLE);
        CodeGenerator::getInstance().symbolTable.addSymbol(this->variable, varSymbol);
    }
    else {
        startValue = llvm::ConstantInt::get(llvm::Type::getInt32Ty(CodeGenerator::getInstance().context), 0);
        endValue = llvm::ConstantInt::get(llvm::Type::getInt32Ty(CodeGenerator::getInstance().context), 10);

        value_ptr = CodeGenerator::getInstance().builder.CreateAlloca(startValue->getType(), nullptr, this->variable + "_ptr");
        CodeGenerator::getInstance().builder.CreateStore(startValue, value_ptr);

        auto varSymbol = new Symbol(this->variable, new BasicType(std::string("Int")), value_ptr, false, SymbolType::VARIABLE);
        CodeGenerator::getInstance().symbolTable.addSymbol(this->variable, varSymbol);
    }

    llvm::BasicBlock* loopBB = llvm::BasicBlock::Create(CodeGenerator::getInstance().context, "loop", function);
    llvm::BasicBlock* afterBB = llvm::BasicBlock::Create(CodeGenerator::getInstance().context, "afterloop", function);

    CodeGenerator::getInstance().builder.SetInsertPoint(loopBB);
    this->body->codegen();

    auto* value = CodeGenerator::getInstance().builder.CreateLoad(startValue->getType(), value_ptr, this->variable.c_str());
    auto* next_value = CodeGenerator::getInstance().builder.CreateAdd(value, CodeGenerator::getInstance().builder.getInt32(1), "next_i");
    CodeGenerator::getInstance().builder.CreateStore(next_value, value_ptr);

    auto* cond = CodeGenerator::getInstance().builder.CreateICmpSLE(value, endValue, "cond");
    CodeGenerator::getInstance().builder.CreateCondBr(cond, loopBB /*body and increment*/, afterBB);

    // jump back to loop
    CodeGenerator::getInstance().builder.SetInsertPoint(afterBB);

    return nullptr;
}