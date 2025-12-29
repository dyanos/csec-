#include "MapStatementNode.h"
#include "ASTVisitor.h"

void MapStatementNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* MapStatementNode::codegen() {
    // MapStatement狼 内靛 积己 肺流 备泅
    return nullptr;
}
