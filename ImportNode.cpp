#include "codegen.h"

#include "ImportNode.h"
#include "ASTVisitor.h"

#include "module_loader.h"
#include <iostream>


void ImportNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ImportNode::codegen() {
	ModuleLoader moduleLoader;
    auto moduleSymbols = moduleLoader.loadModule(path);
    if (moduleSymbols) {
        //  ?  ? ?
        CodeGenerator::getInstance().symbolTable.merge(*moduleSymbols);
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
