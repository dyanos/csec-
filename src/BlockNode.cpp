#include "codegen.h"
#include "BlockNode.h"
#include "ASTVisitor.h"


void BlockNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* BlockNode::codegen() {
    CodeGenerator::getInstance().symbolTable.enterScope();

    llvm::Value* last = nullptr;
    for (auto& stmt : statements) {
        last = stmt->codegen();
    }

    CodeGenerator::getInstance().symbolTable.exitScope();

    return last;
}