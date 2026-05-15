#include "codegen.h"

#include "ValueNode.h"
#include "ASTVisitor.h"

#include "token.h"

#include <iostream>

#include <llvm/IR/Constants.h>

void ValueNode::accept(ASTVisitor& visitor) {
	visitor.visit(*this);
}

llvm::Value* ValueNode::codegen() {
	if (valueType == TokenType::INTEGER_LITERAL) {
		// long, short, int, char, byte ���� Ÿ�� ó���� �ʿ�
		return llvm::ConstantInt::get(llvm::Type::getInt32Ty(CodeGenerator::getInstance().context), std::stoi(value));
	}
	else if (valueType == TokenType::FLOAT_LITERAL) {
		return llvm::ConstantFP::get(llvm::Type::getFloatTy(CodeGenerator::getInstance().context), std::stof(value));
	}
	else if (valueType == TokenType::EXPONENTIAL_LITERAL) {
		return llvm::ConstantFP::get(llvm::Type::getDoubleTy(CodeGenerator::getInstance().context), std::stod(value));
	}
	else if (valueType == TokenType::BINARY_LITERAL) {
		return llvm::ConstantInt::get(llvm::Type::getInt32Ty(CodeGenerator::getInstance().context), std::stoi(value.substr(2), nullptr, 2));
	}
	else if (valueType == TokenType::HEX_LITERAL) {
		return llvm::ConstantInt::get(llvm::Type::getInt32Ty(CodeGenerator::getInstance().context), std::stoi(value.substr(2), nullptr, 16));
	}
	else if (valueType == TokenType::OCTAL_LITERAL) {
		return llvm::ConstantInt::get(llvm::Type::getInt32Ty(CodeGenerator::getInstance().context), std::stoi(value.substr(2), nullptr, 8));
	}
	else if (valueType == TokenType::STRING_LITERAL) {
		return CodeGenerator::getInstance().builder.CreateGlobalString(value);
	}
	else if (valueType == TokenType::BOOLEAN_LITERAL) {
		if (value == "true") {
			return llvm::ConstantInt::get(llvm::Type::getInt1Ty(CodeGenerator::getInstance().context), 1);
		}
		else {
			return llvm::ConstantInt::get(llvm::Type::getInt1Ty(CodeGenerator::getInstance().context), 0);
		}
	}
	else {
		std::cerr << "Invalid value type: " << value << std::endl;
		return nullptr;
	}
}

std::unique_ptr<Type> ValueNode::getType() {
	if (type) return type->clone();

	switch (valueType) {
	case TokenType::INTEGER_LITERAL:
	case TokenType::HEX_LITERAL:
	case TokenType::BINARY_LITERAL:
	case TokenType::OCTAL_LITERAL:
		type = std::make_unique<BasicType>(std::string("Int"));
		break;
	case TokenType::FLOAT_LITERAL:
		type = std::make_unique<BasicType>(std::string("Float"));
		break;
	case TokenType::EXPONENTIAL_LITERAL:
		type = std::make_unique<BasicType>(std::string("Double"));
		break;
	case TokenType::BOOLEAN_LITERAL:
		type = std::make_unique<BasicType>(std::string("Boolean"));
		break;
	case TokenType::STRING_LITERAL:
		type = std::make_unique<BasicType>(std::string("String"));
		break;
	default:
		type = std::make_unique<UnknownType>();
		break;
	}

	return type->clone();
}
