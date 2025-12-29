#include "ObjectDeclarationNode.h"
#include "ASTVisitor.h"

#include <iostream>

void ObjectDeclarationNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ObjectDeclarationNode::codegen() {
    if (body) {
        return body->codegen();
    }
    return nullptr;
}