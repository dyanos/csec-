#include "../../include/ast/assignment_expression_node.h"
#include "../../include/ast/ast_visitor.h"

AssignmentExpressionNode::AssignmentExpressionNode() {
    nodeType = ASTNodeType::ASSIGNMENT_EXPRESSION;
}

AssignmentExpressionNode::AssignmentExpressionNode(std::shared_ptr<ASTNode> left, std::shared_ptr<ASTNode> right)
    : left(left), right(right) {
    nodeType = ASTNodeType::ASSIGNMENT_EXPRESSION;
}

void AssignmentExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* AssignmentExpressionNode::codegen() {
    return nullptr;
}

std::shared_ptr<Type> AssignmentExpressionNode::getType() {
    return left->getType();
} 