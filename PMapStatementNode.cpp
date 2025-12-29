#include "PMapStatementNode.h"

void PMapStatementNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* PMapStatementNode::codegen() {
    // PMapStatement狼 内靛 积己 肺流 备泅
    return nullptr;
}

std::shared_ptr<Type> PMapStatementNode::getType() {
    return std::shared_ptr<Type>();
}