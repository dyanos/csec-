#include "../../include/ast/program_node.h"
#include "../../include/ast/ast_visitor.h"

ProgramNode::ProgramNode() {
    nodeType = ASTNodeType::PROGRAM;
}

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

std::shared_ptr<Type> ProgramNode::getType() {
    return nullptr;
} 