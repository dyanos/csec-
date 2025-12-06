#include "../../include/ast/array_creation_expression_node.h"
#include "../../include/ast/ast_visitor.h"

ArrayCreationExpressionNode::ArrayCreationExpressionNode() {
    nodeType = ASTNodeType::ARRAY_CREATION_EXPRESSION;
}

ArrayCreationExpressionNode::ArrayCreationExpressionNode(const std::string& typeName, const std::vector<std::shared_ptr<ASTNode>>& sizes)
    : typeName(typeName), sizes(sizes) {
    nodeType = ASTNodeType::ARRAY_CREATION_EXPRESSION;
}

void ArrayCreationExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ArrayCreationExpressionNode::codegen() {
    return nullptr;
}

std::shared_ptr<Type> ArrayCreationExpressionNode::getType() {
    return type;
} 