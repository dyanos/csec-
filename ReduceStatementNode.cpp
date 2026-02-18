#include "ReduceStatementNode.h"
#include "ASTVisitor.h"

void ReduceStatementNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ReduceStatementNode::codegen() {
    // ReduceStatement의 코드 생성 로직 구현
    return nullptr;
}