#include "ImportNode.h"
#include "ASTVisitor.h"

#include <iostream>


void ImportNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ImportNode::codegen() {
    auto moduleSymbols = codeGenerator->moduleLoader.loadModule(path);
    if (moduleSymbols) {
        //  ɺ  ɺ ̺
        codeGenerator->symbolTable.merge(*moduleSymbols);
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