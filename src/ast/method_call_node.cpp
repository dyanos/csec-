#include "../../include/ast/method_call_node.h"
#include "../../include/ast/ast_visitor.h"

MethodCallNode::MethodCallNode() {
    nodeType = ASTNodeType::METHOD_CALL;
}

void MethodCallNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* MethodCallNode::codegen() {
    return nullptr;
}

std::shared_ptr<Type> MethodCallNode::getType() {
    return type;
} 