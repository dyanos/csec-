#include "FilterStatementNode.h"
#include "ASTVisitor.h"

void FilterStatementNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* FilterStatementNode::codegen() {
    // FilterStatement의 코드 생성 로직 구현
    return nullptr;
}