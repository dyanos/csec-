#include "../../include/ast/identifier_node.h"
#include "../../include/ast/ast_visitor.h"

IdentifierNode::IdentifierNode(const std::string& value) : value(value) {
    nodeType = ASTNodeType::IDENTIFIER;
}

void IdentifierNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* IdentifierNode::codegen() {
    return nullptr;
}

std::shared_ptr<Type> IdentifierNode::getType() {
    return type;
} 