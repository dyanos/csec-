#pragma once
#include "ast.h"

class PostfixExpressionNode : public ASTNode {
public:
    std::string op;
    std::unique_ptr<ASTNode> expression;

    PostfixExpressionNode() {
        nodeType = ASTNodeType::POSTFIX_EXPRESSION;
    }
    PostfixExpressionNode(const std::string& op, std::unique_ptr<ASTNode> expression) {
		this->op = op;
		this->expression = std::move(expression);
        nodeType = ASTNodeType::POSTFIX_EXPRESSION;
    }
    PostfixExpressionNode(const PostfixExpressionNode& other) {
        nodeType = other.nodeType;
        op = other.op;
		expression = other.expression ? other.expression->clone() : nullptr;
    }
    PostfixExpressionNode& operator=(const PostfixExpressionNode& other) {
        if (this != &other) {
            nodeType = other.nodeType;
            op = other.op;
            expression = other.expression ? other.expression->clone() : nullptr;
        }
        return *this;
    }

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override;
    std::unique_ptr<ASTNode> clone() override {
		return std::make_unique<PostfixExpressionNode>(*this);
    }
};

