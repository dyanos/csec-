#pragma once
#include "ast_node.h"

class AssignmentExpressionNode : public ASTNode {
public:
    AssignmentExpressionNode();
    AssignmentExpressionNode(std::shared_ptr<ASTNode> left, std::shared_ptr<ASTNode> right);
    
    std::shared_ptr<ASTNode> left;
    std::shared_ptr<ASTNode> right;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
}; 