#include "../../include/ast/unit_node.h"
#include "../../include/ast/ast_visitor.h"

UnitNode::UnitNode() {
    nodeType = ASTNodeType::UNIT;
}

void UnitNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* UnitNode::codegen() {
    return nullptr;
}

std::shared_ptr<Type> UnitNode::getType() {
    return nullptr;
} 