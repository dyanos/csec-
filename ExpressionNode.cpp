#include "ExpressionNode.h"
#include "ASTVisitor.h"

#include <iostream>

void ExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ExpressionNode::codegen() {
    auto symbolOpt = codeGenerator->symbolTable.lookup(value);
    if (symbolOpt) {
        Symbol* symbol = (*symbolOpt);
        return codeGenerator->builder.CreateLoad(codeGenerator->getLLVMType(symbol->type.get()), symbol->value, value.c_str());
    }
    if (value.find('"') != std::string::npos) {
        std::string str = value.substr(1, value.length() - 2);
        return codeGenerator->builder.CreateGlobalStringPtr(str);
    }

    if (value.front() == '"' && value.back() == '"') {
        std::string str = value.substr(1, value.length() - 2);
        return codeGenerator->builder.CreateGlobalStringPtr(str);
    }

    if (std::all_of(value.begin(), value.end(), ::isdigit)) {
        return llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(32, std::stoi(value)));
    }

    std::cerr << "Undefined variable or invalid expression: " << value << std::endl;
    return nullptr;
}

std::shared_ptr<Type> ExpressionNode::getType() {
    if (type) return type;

    auto symbolOpt = codeGenerator->symbolTable.lookup(value);
    if (symbolOpt) {
        Symbol* symbol = (*symbolOpt);
        type = symbol->type;
        return type;
    }

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