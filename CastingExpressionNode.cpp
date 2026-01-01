#include "CastingExpressionNode.h"
#include "ASTVisitor.h"

void CastingExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* CastingExpressionNode::codegen() {
    return nullptr;
}

std::unique_ptr<Type> CastingExpressionNode::getType() {
    return std::unique_ptr<UnknownType>();
}