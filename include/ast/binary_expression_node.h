#pragma once
#include "ast_node.h"
#include <string>

class BinaryExpressionNode : public ASTNode {
public:
    BinaryExpressionNode();
    
    std::shared_ptr<ASTNode> left;
    std::string op;
    std::shared_ptr<ASTNode> right;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
}; 