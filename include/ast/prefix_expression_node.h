#pragma once
#include "ast_node.h"
#include <string>

class PrefixExpressionNode : public ASTNode {
public:
    PrefixExpressionNode();
    PrefixExpressionNode(const std::string& op, std::shared_ptr<ASTNode> expression);
    
    std::string op;
    std::shared_ptr<ASTNode> expression;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
}; 