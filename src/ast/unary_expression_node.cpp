#include "../../include/ast/unary_expression_node.h"
#include "../../include/ast/ast_visitor.h"

UnaryExpressionNode::UnaryExpressionNode() {
    nodeType = ASTNodeType::UNARY_EXPRESSION;
}

UnaryExpressionNode::UnaryExpressionNode(const std::string& op, std::shared_ptr<ASTNode> expression)
    : op(op), expression(expression) {
    nodeType = ASTNodeType::UNARY_EXPRESSION;
}

void UnaryExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* UnaryExpressionNode::codegen() {
    return nullptr;
}

std::shared_ptr<Type> UnaryExpressionNode::getType() {
    return expression->getType();
} 