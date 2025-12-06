#include "../../include/ast/function_call_node.h"
#include "../../include/ast/ast_visitor.h"

FunctionCallNode::FunctionCallNode() {
    nodeType = ASTNodeType::FUNCTION_CALL;
}

void FunctionCallNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* FunctionCallNode::codegen() {
    return nullptr;
}

std::shared_ptr<Type> FunctionCallNode::getType() {
    return type;
} 