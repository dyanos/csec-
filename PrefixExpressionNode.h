#pragma once
#include "ast.h"

class PrefixExpressionNode : public ASTNode {
public:
    std::string op;
    std::shared_ptr<ASTNode> expression;

    PrefixExpressionNode() {
        this->nodeType = ASTNodeType::PREFIX_EXPRESSION;
        this->op = "";
        this->expression = nullptr;
    }
    PrefixExpressionNode(const std::string& op, std::shared_ptr<ASTNode> expression)
        : op(op), expression(expression) {
        this->nodeType = ASTNodeType::PREFIX_EXPRESSION;
    }

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override;
};