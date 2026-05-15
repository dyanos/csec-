#include "codegen.h"

#include "WhileStatementNode.h"
#include "ASTVisitor.h"

#include <iostream>

void WhileStatementNode::accept(ASTVisitor& visitor) {
	visitor.visit(*this);
}

llvm::Value* WhileStatementNode::codegen() {
	// WhileStatement의 코드 생성 로직 구현
	return nullptr;
}

std::unique_ptr<Type> WhileStatementNode::getType() {
	return std::unique_ptr<UnknownType>();
}
