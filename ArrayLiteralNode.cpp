#include "ArrayLiteralNode.h"
#include "ASTVisitor.h"

void ArrayLiteralNode::accept(ASTVisitor& visitor) {
	visitor.visit(*this);
}

llvm::Value* ArrayLiteralNode::codegen() {
	return nullptr;
}

std::shared_ptr<Type> ArrayLiteralNode::getType() {
	return type;
}