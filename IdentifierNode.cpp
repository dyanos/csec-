#include "codegen.h"

#include "IdentifierNode.h"
#include "ASTVisitor.h"

#include <iostream>

void IdentifierNode::accept(ASTVisitor& visitor) {
	visitor.visit(*this);
}

llvm::Value* IdentifierNode::codegen() {
	auto symbolOpt = CodeGenerator::getInstance().symbolTable.lookup(value);
	if (!symbolOpt) {
		std::cerr << "Undefined variable: " << value << std::endl;
		return nullptr;
	}

	auto* symbol = symbolOpt;
	if (!symbol->value) {
		return nullptr;
	}

	if ((symbol->symbolType == SymbolType::VARIABLE || symbol->symbolType == SymbolType::FIELD) &&
		symbol->value->getType()->isPointerTy()) {
		auto valueType = CodeGenerator::getInstance().getLLVMType(symbol->type.get());
		if (!valueType) {
			return nullptr;
		}
		return CodeGenerator::getInstance().builder.CreateLoad(valueType, symbol->value, value + ".load");
	}

	return symbol->value;
}

std::unique_ptr<Type> IdentifierNode::getType() {
	if (type) return type->clone();

	auto symbolOpt = CodeGenerator::getInstance().symbolTable.lookup(value);
	if (symbolOpt) {
		return symbolOpt->type->clone();
	}

	return std::make_unique<UnknownType>();
}
