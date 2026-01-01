#include "ArrayLiteralNode.h"
#include "ASTVisitor.h"

void ArrayLiteralNode::accept(ASTVisitor& visitor) {
	visitor.visit(*this);
}

llvm::Value* ArrayLiteralNode::codegen() {
	return nullptr;
}

std::unique_ptr<Type> ArrayLiteralNode::getType() {
	return std::make_unique<Type>(type.get());
}