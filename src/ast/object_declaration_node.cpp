#include "../../include/ast/object_declaration_node.h"
#include "../../include/ast/ast_visitor.h"

ObjectDeclarationNode::ObjectDeclarationNode() {
    nodeType = ASTNodeType::OBJECT_DECLARATION;
}

void ObjectDeclarationNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ObjectDeclarationNode::codegen() {
    if (body) {
        return body->codegen();
    }
    return nullptr;
}

std::shared_ptr<Type> ObjectDeclarationNode::getType() {
    return nullptr;
} 