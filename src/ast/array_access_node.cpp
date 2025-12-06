#include "../../include/ast/array_access_node.h"
#include "../../include/ast/ast_visitor.h"

ArrayAccessNode::ArrayAccessNode() {
    nodeType = ASTNodeType::ARRAY_ACCESS;
}

void ArrayAccessNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ArrayAccessNode::codegen() {
    return nullptr;
}

std::shared_ptr<Type> ArrayAccessNode::getType() {
    auto arrayType = std::dynamic_pointer_cast<GenericType>(array->getType());
    if (arrayType && arrayType->typeArguments.size() == 1) {
        return arrayType->typeArguments[0];
    }
    return std::make_shared<UnknownType>();
} 