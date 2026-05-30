#include "ClassBodyNode.h"
#include "ASTVisitor.h"


void ClassBodyNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ClassBodyNode::codegen() {
    return nullptr;
}