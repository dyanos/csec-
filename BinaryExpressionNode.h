#pragma once
#include "ast.h"

class BinaryExpressionNode : public ASTNode {
public:
    BinaryExpressionNode() {
        nodeType = ASTNodeType::BINARY_EXPRESSION;
    }

    std::shared_ptr<ASTNode> left;
    std::string op;
    std::shared_ptr<ASTNode> right;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override;
};