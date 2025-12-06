#include "../../include/ast/variable_declaration_node.h"
#include "../../include/ast/ast_visitor.h"
#include <iostream>

VariableDeclarationNode::VariableDeclarationNode() {
    nodeType = ASTNodeType::VARIABLE_DECLARATION;
}

void VariableDeclarationNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* VariableDeclarationNode::codegen() {
    llvm::Value* initValue = nullptr;
    if (initializer) {
        initValue = initializer->codegen();
        if (!initValue) {
            return nullptr;
        }
    }
    else {
        initValue = llvm::Constant::getNullValue(codeGenerator->getLLVMType(type));
    }

    llvm::Type* varType = codeGenerator->getLLVMType(type);
    if (!varType) {
        std::cerr << "Error: Unsupported variable type '" << type->name << "'" << std::endl;
        return nullptr;
    }

    llvm::AllocaInst* alloc = codeGenerator->builder.CreateAlloca(varType, nullptr, name.c_str());
    codeGenerator->builder.CreateStore(initValue, alloc);

    Symbol symbol(name, type, alloc, isMutable, SymbolType::VARIABLE);
    codeGenerator->symbolTable.addSymbol(name, symbol);

    return alloc;
}

std::shared_ptr<Type> VariableDeclarationNode::getType() {
    return type;
} 