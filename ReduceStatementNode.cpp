#include "ReduceStatementNode.h"
#include "ASTVisitor.h"

void ReduceStatementNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ReduceStatementNode::codegen() {
    // ReduceStatement狼 内靛 积己 肺流 备泅
    return nullptr;
}