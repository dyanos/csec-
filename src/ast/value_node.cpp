#include "ast.h"
#include "codegen.h"
#include <iostream>

void ValueNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ValueNode::codegen() {
    if (valueType == TokenType::INTEGER_LITERAL) {
        return llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(32, value, 10));
    }
    else if (valueType == TokenType::FLOAT_LITERAL) {
        return llvm::ConstantFP::get(codeGenerator->context, llvm::APFloat(std::stof(value)));
    }
    else if (valueType == TokenType::BINARY_LITERAL) {
        return llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(32, value.substr(2), 2));
    }
    else if (valueType == TokenType::HEX_LITERAL) {
        return llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(32, value.substr(2), 16));
    }
    else if (valueType == TokenType::OCTAL_LITERAL) {
        return llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(32, value.substr(2), 8));
    }
    else if (valueType == TokenType::STRING_LITERAL) {
        return codeGenerator->builder.CreateGlobalStringPtr(value);
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