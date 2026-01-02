#include "codegen.h"

#include "IdentifierNode.h"
#include "ASTVisitor.h"

#include <iostream>

void IdentifierNode::accept(ASTVisitor& visitor) {
	visitor.visit(*this);
}

llvm::Value* IdentifierNode::codegen() {
	// symbolTable������ symbol �˻��� symbolTable�� scopes�� �������� �ؼ� ���󰡸鼭 symbol�� lookup�Ѵ�.
	auto symbolOpt = CodeGenerator::getInstance().symbolTable.lookup(value);
	if (!symbolOpt) {
		std::cerr << "Undefined variable: " << value << std::endl;
		return nullptr;
	}

	auto symbol = (*symbolOpt);

	// this ������ �Ǵ� parameter, class�� field�� ���� CreateLoad�� ���� �ʾƾ� ��. llvm::Value�� �ֱ� ������
	// local ������?
	return symbol->value;
}

std::unique_ptr<Type> IdentifierNode::getType() {
	if (type) return type->clone();

	auto symbolOpt = CodeGenerator::getInstance().symbolTable.lookup(value);
	if (symbolOpt) {
		return (*symbolOpt)->type->clone();
	}

	return std::make_unique<UnknownType>();
}