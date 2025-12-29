#include "CastingExpressionNode.h"
#include "ASTVisitor.h"

void CastingExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* CastingExpressionNode::codegen() {
    return nullptr;
}

std::shared_ptr<Type> CastingExpressionNode::getType() {
    return std::shared_ptr<Type>();
}