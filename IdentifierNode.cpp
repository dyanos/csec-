#include "codegen.h"

#include "IdentifierNode.h"
#include "ASTVisitor.h"

#include <iostream>

void IdentifierNode::accept(ASTVisitor& visitor) {
	visitor.visit(*this);
}

llvm::Value* IdentifierNode::codegen() {
	// symbolTable에서의 symbol 검색은 symbolTable의 scopes를 역순으로 해서 따라가면서 symbol을 lookup한다.
	auto symbolOpt = CodeGenerator::getInstance().symbolTable.lookup(value);
	if (!symbolOpt) {
		std::cerr << "Undefined variable: " << value << std::endl;
		return nullptr;
	}

	auto symbol = (*symbolOpt);

	// this 포인터 또는 parameter, class의 field인 경우는 CreateLoad를 하지 않아야 함. llvm::Value가 있기 때문에
	// local 변수는?
	return symbol->value;
}

std::unique_ptr<Type> IdentifierNode::getType() {
	if (type) return std::make_unique<Type>(type.get());

	auto symbolOpt = CodeGenerator::getInstance().symbolTable.lookup(value);
	if (symbolOpt) {
		return std::make_unique<Type>((*symbolOpt)->type.get());
	}

	return std::make_unique<UnknownType>();
}