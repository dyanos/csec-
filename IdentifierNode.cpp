#include "codegen.h"

#include "IdentifierNode.h"
#include "ASTVisitor.h"

#include <iostream>
#include <llvm/IR/GlobalVariable.h>
#include <llvm/IR/Instructions.h>

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

    const bool isAddressLike =
        llvm::isa<llvm::AllocaInst>(symbol->value) ||
        llvm::isa<llvm::GlobalVariable>(symbol->value) ||
        llvm::isa<llvm::GetElementPtrInst>(symbol->value);

    if ((symbol->symbolType == SymbolType::VARIABLE || symbol->symbolType == SymbolType::FIELD) &&
        symbol->value->getType()->isPointerTy() &&
        isAddressLike) {
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
	if (symbolOpt && symbolOpt->type) {
		return symbolOpt->type->clone();
	}

	return std::make_unique<UnknownType>();
}
