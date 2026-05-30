#pragma once
#include "ast.h"

class PrefixExpressionNode : public ASTNode {
public:
    std::string op;
    std::unique_ptr<ASTNode> expression;

    PrefixExpressionNode() {
        this->nodeType = ASTNodeType::PREFIX_EXPRESSION;
        this->op = "";
        this->expression = nullptr;
    }
    PrefixExpressionNode(const std::string& op, std::unique_ptr<ASTNode> expression) {
		this->op = op;
		this->expression = std::move(expression);
        this->nodeType = ASTNodeType::PREFIX_EXPRESSION;
    }
    PrefixExpressionNode(const PrefixExpressionNode& other) {
        this->nodeType = other.nodeType;
        this->op = other.op;
        this->expression = other.expression ? other.expression->clone() : nullptr;
	}
    PrefixExpressionNode& operator=(const PrefixExpressionNode& other) {
        if (this != &other) {
            this->nodeType = other.nodeType;
            this->op = other.op;
            this->expression = other.expression ? other.expression->clone() : nullptr;
        }
        return *this;
	}

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override;
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<PrefixExpressionNode>(*this);
    }
};

