#include "codegen.h"

#include "WhileStatementNode.h"
#include "ASTVisitor.h"

#include <iostream>

void WhileStatementNode::accept(ASTVisitor& visitor) {
	visitor.visit(*this);
}

llvm::Value* WhileStatementNode::codegen() {
	// WhileStatement狼 内靛 积己 肺流 备泅
	return nullptr;
}

std::unique_ptr<Type> WhileStatementNode::getType() {
	return std::unique_ptr<UnknownType>();
}
