#include "../../include/ast/prefix_expression_node.h"
#include "../../include/ast/ast_visitor.h"

PrefixExpressionNode::PrefixExpressionNode() {
    nodeType = ASTNodeType::PREFIX_EXPRESSION;
}

PrefixExpressionNode::PrefixExpressionNode(const std::string& op, std::shared_ptr<ASTNode> expression)
    : op(op), expression(expression) {
    nodeType = ASTNodeType::PREFIX_EXPRESSION;
}

void PrefixExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* PrefixExpressionNode::codegen() {
    return nullptr;
}

std::shared_ptr<Type> PrefixExpressionNode::getType() {
    return expression->getType();
} 