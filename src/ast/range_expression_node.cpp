#include "../../include/ast/range_expression_node.h"
#include "../../include/ast/ast_visitor.h"

RangeExpressionNode::RangeExpressionNode() {
    nodeType = ASTNodeType::RANGE_EXPRESSION;
    isInclusive = true;
}

void RangeExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* RangeExpressionNode::codegen() {
    return nullptr;
}

std::shared_ptr<Type> RangeExpressionNode::getType() {
    return nullptr;
} 