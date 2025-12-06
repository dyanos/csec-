#include "../../include/ast/call_expression_node.h"
#include "../../include/ast/ast_visitor.h"

CallExpressionNode::CallExpressionNode() {
    nodeType = ASTNodeType::CALL_EXPRESSION;
}

void CallExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* CallExpressionNode::codegen() {
    return nullptr;
}

std::shared_ptr<Type> CallExpressionNode::getType() {
    return type;
} 