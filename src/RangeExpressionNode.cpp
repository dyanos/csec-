#include "RangeExpressionNode.h"
#include "ASTVisitor.h"


void RangeExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* RangeExpressionNode::codegen() {
    // RangeExpressionNode ForStatementNode  o ? nullptr ?
    return nullptr;
}