#include "LambdaExpressionNode.h"
#include "ASTVisitor.h"

#include <iostream>
#include <llvm/IR/Function.h>

void LambdaExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* LambdaExpressionNode::codegen() {
    return nullptr;
}

std::shared_ptr<Type> LambdaExpressionNode::getType() {
    return nullptr;
}