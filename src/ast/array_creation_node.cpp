#include "../../include/ast/array_creation_node.h"
#include "../../include/ast/ast_visitor.h"

ArrayCreationNode::ArrayCreationNode() {
    nodeType = ASTNodeType::ARRAY_CREATION;
}

void ArrayCreationNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ArrayCreationNode::codegen() {
    return nullptr;
}

std::shared_ptr<Type> ArrayCreationNode::getType() {
    return arrayType;
} 