#include "../../include/ast/postfix_expression_node.h"
#include "../../include/ast/ast_visitor.h"

PostfixExpressionNode::PostfixExpressionNode() {
    nodeType = ASTNodeType::POSTFIX_EXPRESSION;
}

PostfixExpressionNode::PostfixExpressionNode(const std::string& op, std::shared_ptr<ASTNode> expression)
    : op(op), expression(expression) {
    nodeType = ASTNodeType::POSTFIX_EXPRESSION;
}

void PostfixExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* PostfixExpressionNode::codegen() {
    return nullptr;
}

std::shared_ptr<Type> PostfixExpressionNode::getType() {
    return expression->getType();
} 