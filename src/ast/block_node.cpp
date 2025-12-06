#include "../../include/ast/block_node.h"
#include "../../include/ast/ast_visitor.h"

BlockNode::BlockNode() {
    nodeType = ASTNodeType::BLOCK;
}

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

std::shared_ptr<Type> BlockNode::getType() {
    return nullptr;
} 