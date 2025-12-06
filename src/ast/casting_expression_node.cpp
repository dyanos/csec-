#include "../../include/ast/casting_expression_node.h"
#include "../../include/ast/ast_visitor.h"

CastingExpressionNode::CastingExpressionNode() {
    nodeType = ASTNodeType::CASTING_EXPRESSION;
}

CastingExpressionNode::CastingExpressionNode(std::shared_ptr<ASTNode> expression, std::shared_ptr<ASTNode> type)
    : expression(expression), type(type) {
    nodeType = ASTNodeType::CASTING_EXPRESSION;
}

void CastingExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* CastingExpressionNode::codegen() {
    return nullptr;
}

std::shared_ptr<Type> CastingExpressionNode::getType() {
    return type->getType();
} 