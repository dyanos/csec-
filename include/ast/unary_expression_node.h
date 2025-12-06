#pragma once
#include "ast_node.h"
#include <string>

class UnaryExpressionNode : public ASTNode {
public:
    UnaryExpressionNode();
    UnaryExpressionNode(const std::string& op, std::shared_ptr<ASTNode> expression);
    
    std::string op;
    std::shared_ptr<ASTNode> expression;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
}; 