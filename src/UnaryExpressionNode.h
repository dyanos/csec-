#pragma once
#include "ast.h"

class UnaryExpressionNode : public ASTNode {
public:
	std::string op;
	std::unique_ptr<ASTNode> expression;

	UnaryExpressionNode() {
		nodeType = ASTNodeType::UNARY_EXPRESSION;
	}
	UnaryExpressionNode(const std::string& op, std::unique_ptr<ASTNode> expression)
		: op(op), expression(std::move(expression)) {
		nodeType = ASTNodeType::UNARY_EXPRESSION;
	}
	UnaryExpressionNode(const UnaryExpressionNode& other) {
		this->nodeType = other.nodeType;
		this->op = other.op;
		this->expression = other.expression ? other.expression->clone() : nullptr;
	}
	UnaryExpressionNode& operator=(const UnaryExpressionNode& other) {
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
		return std::make_unique<UnaryExpressionNode>(*this);
	}
};

