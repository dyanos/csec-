#include "codegen.h"
#include "BlockNode.h"
#include "ASTVisitor.h"


void BlockNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* BlockNode::codegen() {
    auto& cg = CodeGenerator::getInstance();
    cg.symbolTable.enterScope();
    cg.enterCleanupScope();

    llvm::Value* last = nullptr;
    for (auto& stmt : statements) {
        last = stmt->codegen();
    }

    auto* currentBlock = cg.builder.GetInsertBlock();
    if (currentBlock && !currentBlock->getTerminator()) {
        cg.emitCurrentScopeCleanups();
    }
    cg.exitCleanupScope();
    cg.symbolTable.exitScope();

    return last;
}
