#include "PMapStatementNode.h"
#include "ASTVisitor.h"

void PMapStatementNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* PMapStatementNode::codegen() {
    // PMapStatement의 코드 생성 로직 구현
    return nullptr;
}