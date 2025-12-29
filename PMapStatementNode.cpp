#include "PMapStatementNode.h"
#include "ASTVisitor.h"

void PMapStatementNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* PMapStatementNode::codegen() {
    // PMapStatement狼 内靛 积己 肺流 备泅
    return nullptr;
}