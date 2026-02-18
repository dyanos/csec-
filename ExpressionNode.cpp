#include "codegen.h"

#include "ExpressionNode.h"
#include "ASTVisitor.h"

#include <iostream>

void ExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ExpressionNode::codegen() {
    auto symbolOpt = CodeGenerator::getInstance().symbolTable.lookup(value);
    if (symbolOpt) {
        Symbol* symbol = symbolOpt;
        return CodeGenerator::getInstance().builder.CreateLoad(CodeGenerator::getInstance().getLLVMType(symbol->type.get()), symbol->value, value.c_str());
    }
    if (value.find('"') != std::string::npos) {
        std::string str = value.substr(1, value.length() - 2);
        return CodeGenerator::getInstance().builder.CreateGlobalString(str);
    }

    if (value.front() == '"' && value.back() == '"') {
        std::string str = value.substr(1, value.length() - 2);
        return CodeGenerator::getInstance().builder.CreateGlobalString(str);
    }

    if (std::all_of(value.begin(), value.end(), ::isdigit)) {
        return llvm::ConstantInt::get(CodeGenerator::getInstance().context, llvm::APInt(32, std::stoi(value)));
    }

    std::cerr << "Undefined variable or invalid expression: " << value << std::endl;
    return nullptr;
}

std::unique_ptr<Type> ExpressionNode::getType() {
    if (type) return type->clone();

    auto symbolOpt = CodeGenerator::getInstance().symbolTable.lookup(value);
    if (symbolOpt) {
        Symbol* symbol = symbolOpt;
		return symbol->type->clone();
    }

    if (value.front() == '"' && value.back() == '"') {
        return std::make_unique<ClassType>(std::string("String"));
    }

    if (std::all_of(value.begin(), value.end(), ::isdigit)) {
        return std::make_unique<BasicType>(std::string("Int"));
    }

    return std::make_unique<UnknownType>();
}