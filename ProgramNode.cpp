#include "ProgramNode.h"
#include "ASTVisitor.h"

void ProgramNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ProgramNode::codegen() {
    llvm::Value* last = nullptr;
    for (auto& stmt : statements) {
        last = stmt->codegen();
    }
    return last;
}
