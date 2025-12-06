#include "../../include/ast/class_instance_creation_node.h"
#include "../../include/ast/ast_visitor.h"

ClassInstanceCreationNode::ClassInstanceCreationNode() {
    nodeType = ASTNodeType::CLASS_INSTANCE_CREATION;
}

ClassInstanceCreationNode::ClassInstanceCreationNode(const std::string& className, std::vector<std::shared_ptr<ASTNode>> arguments)
    : className(className), arguments(arguments) {
    nodeType = ASTNodeType::CLASS_INSTANCE_CREATION;
}

void ClassInstanceCreationNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ClassInstanceCreationNode::codegen() {
    return nullptr;
}

std::shared_ptr<Type> ClassInstanceCreationNode::getType() {
    return type;
} 