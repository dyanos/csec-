#include "ValueNode.h"
#include "ASTVisitor.h"

#include <iostream>

#include <llvm/IR/Constants.h>

void ValueNode::accept(ASTVisitor& visitor) {
	visitor.visit(*this);
}

llvm::Value* ValueNode::codegen() {
	if (valueType == TokenType::INTEGER_LITERAL) {
		// long, short, int, char, byte ���� Ÿ�� ó���� �ʿ�
		return llvm::ConstantInt::get(llvm::Type::getInt32Ty(codeGenerator->context), std::stoi(value));
	}
	else if (valueType == TokenType::FLOAT_LITERAL) {
		return llvm::ConstantFP::get(llvm::Type::getFloatTy(codeGenerator->context), std::stof(value));
	}
	else if (valueType == TokenType::BINARY_LITERAL) {
		return llvm::ConstantInt::get(llvm::Type::getInt32Ty(codeGenerator->context), std::stoi(value.substr(2), nullptr, 2));
	}
	else if (valueType == TokenType::HEX_LITERAL) {
		return llvm::ConstantInt::get(llvm::Type::getInt32Ty(codeGenerator->context), std::stoi(value.substr(2), nullptr, 16));
	}
	else if (valueType == TokenType::OCTAL_LITERAL) {
		return llvm::ConstantInt::get(llvm::Type::getInt32Ty(codeGenerator->context), std::stoi(value.substr(2), nullptr, 8));
	}
	else if (valueType == TokenType::STRING_LITERAL) {
		return codeGenerator->builder.CreateGlobalStringPtr(value);
	}
	else if (valueType == TokenType::BOOLEAN_LITERAL) {
		if (value == "true") {
			return llvm::ConstantInt::get(llvm::Type::getInt1Ty(codeGenerator->context), 1);
		}
		else {
			return llvm::ConstantInt::get(llvm::Type::getInt1Ty(codeGenerator->context), 0);
		}
	}
	else {
		std::cerr << "Invalid value type: " << value << std::endl;
		return nullptr;
	}
}

std::shared_ptr<Type> ValueNode::getType() {
	if (type) return type;

	if (value.front() == '"' && value.back() == '"') {
		type = std::make_shared<ClassType>("String");
		return type;
	}
	if (std::all_of(value.begin(), value.end(), ::isdigit)) {
		type = std::make_shared<BasicType>("Int");
		return type;
	}

	type = std::make_shared<UnknownType>();
	return type;
}