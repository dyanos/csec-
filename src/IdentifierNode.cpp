#include "codegen.h"

#include "IdentifierNode.h"
#include "ASTVisitor.h"
#include "type_utils.h"

#include <iostream>
#include <cctype>
#include <llvm/IR/GlobalVariable.h>
#include <llvm/IR/Instructions.h>
#include <llvm/IR/Constants.h>

namespace {
bool isIntegerLiteralText(const std::string& text) {
    if (text.empty()) {
        return false;
    }

    size_t start = 0;
    if (text[0] == '+' || text[0] == '-') {
        start = 1;
    }
    if (start >= text.size()) {
        return false;
    }

    for (size_t i = start; i < text.size(); ++i) {
        if (!std::isdigit(static_cast<unsigned char>(text[i]))) {
            return false;
        }
    }
    return true;
}
}

void IdentifierNode::accept(ASTVisitor& visitor) {
	visitor.visit(*this);
}

llvm::Value* IdentifierNode::codegen() {
	auto symbolOpt = CodeGenerator::getInstance().symbolTable.lookup(value);
	if (!symbolOpt) {
        auto& cg = CodeGenerator::getInstance();
        if (value == "true" || value == "false") {
            return llvm::ConstantInt::get(llvm::Type::getInt1Ty(cg.context), value == "true" ? 1 : 0);
        }
        if (isIntegerLiteralText(value)) {
            return llvm::ConstantInt::get(llvm::Type::getInt32Ty(cg.context), std::stoi(value));
        }
		std::cerr << "Undefined variable: " << value << std::endl;
		return llvm::ConstantFP::get(llvm::Type::getDoubleTy(cg.context), 0.0);
	}

	auto* symbol = symbolOpt;
	if (!symbol->value) {
        auto& cg = CodeGenerator::getInstance();
        if (symbol->type && symbol->type->isIntegerTy()) {
            return llvm::ConstantInt::get(cg.getLLVMType(symbol->type.get()), 0);
        }
        if (symbol->type && (symbol->type->isFloatTy() || symbol->type->isDoubleTy())) {
            return llvm::ConstantFP::get(cg.getLLVMType(symbol->type.get()), 0.0);
        }
        if (symbol->type && (symbol->type->getName() == "Boolean" || symbol->type->getName() == "Bool")) {
            return llvm::ConstantInt::getFalse(cg.context);
        }
		return llvm::ConstantFP::get(llvm::Type::getDoubleTy(cg.context), 0.0);
	}

    const bool isAddressLike =
        llvm::isa<llvm::AllocaInst>(symbol->value) ||
        llvm::isa<llvm::GlobalVariable>(symbol->value) ||
        llvm::isa<llvm::GetElementPtrInst>(symbol->value);

    if ((symbol->symbolType == SymbolType::VARIABLE || symbol->symbolType == SymbolType::FIELD) &&
        symbol->value->getType()->isPointerTy() &&
        isAddressLike) {
        // An array/vector local is bound directly to its element buffer (see
        // VariableDeclarationNode::bindPointerBackedValueDirectly), so return that pointer rather than
        // loading through it. `Array` and `Vector` are aliases: without recognising `Vector`, an
        // annotated `val v: Vector[Int] = [..]` loads a pointer out of the buffer's first element
        // (reading data as an address) and segfaults on the next index.
        if (symbol->type && (symbol->type->getName() == "Array" ||
            symbol->type->getName() == "Vector" ||
            dynamic_cast<ArrayType*>(symbol->type.get()) != nullptr)) {
            return symbol->value;
        }
        // A lambda value is a { code, env } closure pointer bound directly; return the pointer
        // itself rather than loading through it, so the whole closure is passed and called.
        if (symbol->type && symbol->type->getKind() == Type::Kind::FUNCTION) {
            return symbol->value;
        }
        if (symbol->type && symbol->type->getKind() == Type::Kind::CLASS) {
            if (isStructClassType(symbol->type.get())) {
                return symbol->value;
            }
            auto valueType = getABIStorageType(symbol->type.get());
            if (!valueType) {
                return nullptr;
            }
            return CodeGenerator::getInstance().builder.CreateLoad(valueType, symbol->value, value + ".load");
        }
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

    if (value == "true" || value == "false") {
        return std::make_unique<BasicType>("Boolean");
    }
    if (isIntegerLiteralText(value)) {
        return std::make_unique<BasicType>("Int");
    }

	return std::make_unique<BasicType>("Real");
}
