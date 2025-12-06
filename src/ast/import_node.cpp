#include "../../include/ast/import_node.h"
#include "../../include/ast/ast_visitor.h"
#include <iostream>

ImportNode::ImportNode() {
    nodeType = ASTNodeType::IMPORT;
}

void ImportNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ImportNode::codegen() {
    auto moduleSymbols = codeGenerator->moduleLoader.loadModule(path);
    if (moduleSymbols) {
        codeGenerator->symbolTable.merge(moduleSymbols);
    }
    else {
        std::cerr << "Error: Failed to import module ";
        for (const auto& p : path) {
            std::cerr << p << ".";
        }
        std::cerr << std::endl;
        return nullptr;
    }
    return nullptr;
}

std::shared_ptr<Type> ImportNode::getType() {
    return nullptr;
} 