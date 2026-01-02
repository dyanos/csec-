#pragma once
#include "ast.h"

class UnaryExpressionNode : public ASTNode {
public:
	std::string op;
	std::unique_ptr<ASTNode> expression;

	UnaryExpressionNode() {
		nodeType = ASTNodeType::UNARY_EXPRESSION;
	}
	UnaryExpressionNode(const std::string& op, std::unique_ptr<ASTNode>& expression)
		: op(op), expression(std::move(expression)) {
		nodeType = ASTNodeType::UNARY_EXPRESSION;
	}
	UnaryExpressionNode(UnaryExpressionNode* other) {
		this->nodeType = other->nodeType;
		this->op = other->op;
		this->expression = std::move(other->expression);
	}

	void accept(ASTVisitor& visitor) override;
	llvm::Value* codegen() override;
	std::unique_ptr<Type> getType() override;
	std::unique_ptr<ASTNode> clone() override {
		return std::make_unique<UnaryExpressionNode>(this);
	}
};