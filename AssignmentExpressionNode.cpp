#include "AssignmentExpressionNode.h"
#include "ASTVisitor.h"

#include <iostream>


void AssignmentExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* AssignmentExpressionNode::codegen() {
    llvm::Value* leftValue = left->codegen();
    llvm::Value* rightValue = right->codegen();
    if (!leftValue || !rightValue) {
        std::cerr << "Error: Assignment failed" << std::endl;
        return nullptr;
    }

    // 메모리 사이의 이동은 CreateStore로
    codeGenerator->builder.CreateStore(rightValue, leftValue);

    return leftValue;
}

std::shared_ptr<Type> AssignmentExpressionNode::getType()
{
    return left->getType();
}