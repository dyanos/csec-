#include "FilterStatementNode.h"
#include "ASTVisitor.h"

void FilterStatementNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* FilterStatementNode::codegen() {
    // FilterStatement狼 内靛 积己 肺流 备泅
    return nullptr;
}