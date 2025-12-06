#include "../../include/ast/return_statement_node.h"
#include "../../include/ast/ast_visitor.h"

ReturnStatementNode::ReturnStatementNode() {
    nodeType = ASTNodeType::RETURN_STATEMENT;
}

void ReturnStatementNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ReturnStatementNode::codegen() {
    return nullptr;
}

std::shared_ptr<Type> ReturnStatementNode::getType() {
    return nullptr;
} 