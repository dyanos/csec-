#include "MapStatementNode.h"
#include "ASTVisitor.h"

void MapStatementNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* MapStatementNode::codegen() {
    // MapStatement의 코드 생성 로직 구현
    return nullptr;
}
