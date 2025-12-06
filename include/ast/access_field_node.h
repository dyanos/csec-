#pragma once
#include "ast_node.h"

class AccessFieldNode : public ASTNode {
public:
    AccessFieldNode();
    AccessFieldNode(std::shared_ptr<ASTNode> base, std::shared_ptr<ASTNode> field);
    
    std::shared_ptr<ASTNode> base;
    std::shared_ptr<ASTNode> field;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
}; 