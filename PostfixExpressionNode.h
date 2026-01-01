#pragma once
#include "ast.h"

class PostfixExpressionNode : public ASTNode {
public:
    std::string op;
    std::shared_ptr<ASTNode> expression;

    PostfixExpressionNode() {
        nodeType = ASTNodeType::POSTFIX_EXPRESSION;
    }
    PostfixExpressionNode(const std::string& op, std::shared_ptr<ASTNode> expression)
        : op(op), expression(expression) {
        nodeType = ASTNodeType::POSTFIX_EXPRESSION;
    }

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override;
};