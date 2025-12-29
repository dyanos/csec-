#include "BlockNode.h"
#include "ASTVisitor.h"


void BlockNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* BlockNode::codegen() {
    codeGenerator->symbolTable.enterScope();

    llvm::Value* last = nullptr;
    for (auto& stmt : statements) {
        last = stmt->codegen();
    }

    codeGenerator->symbolTable.exitScope();

    return last;
}