#include "FilterStatementNode.h"

void FilterStatementNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* FilterStatementNode::codegen() {
    // FilterStatement狼 内靛 积己 肺流 备泅
    return nullptr;
}

std::shared_ptr<Type> FilterStatementNode::getType() {
    return std::shared_ptr<Type>();
}
