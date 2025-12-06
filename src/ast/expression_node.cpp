#include "../../include/ast/expression_node.h"
#include "../../include/ast/ast_visitor.h"
#include <iostream>
#include <algorithm>

ExpressionNode::ExpressionNode() {
    nodeType = ASTNodeType::EXPRESSION;
}

void ExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ExpressionNode::codegen() {
    Symbol* symbol = codeGenerator->symbolTable.lookup(value);
    if (symbol) {
        return codeGenerator->builder.CreateLoad(codeGenerator->getLLVMType(symbol->type), 
                                               symbol->value, value.c_str());
    }

    if (value.front() == '"' && value.back() == '"') {
        std::string str = value.substr(1, value.length() - 2);
        return codeGenerator->builder.CreateGlobalStringPtr(str);
    }

    if (std::all_of(value.begin(), value.end(), ::isdigit)) {
        return llvm::ConstantInt::get(codeGenerator->context, 
                                    llvm::APInt(32, std::stoi(value)));
    }

    std::cerr << "Undefined variable or invalid expression: " << value << std::endl;
    return nullptr;
}

std::shared_ptr<Type> ExpressionNode::getType() {
    if (type) return type;

    Symbol* symbol = codeGenerator->symbolTable.lookup(value);
    if (symbol) {
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