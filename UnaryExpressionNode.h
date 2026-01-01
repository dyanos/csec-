#pragma once
#include "ast.h"

class UnaryExpressionNode : public ASTNode {
public:
	std::string op;
	std::shared_ptr<ASTNode> expression;

	UnaryExpressionNode() {
		nodeType = ASTNodeType::UNARY_EXPRESSION;
	}
	UnaryExpressionNode(const std::string& op, std::shared_ptr<ASTNode> expression)
		: op(op), expression(expression) {
		nodeType = ASTNodeType::UNARY_EXPRESSION;
	}

	void accept(ASTVisitor& visitor) override;
	llvm::Value* codegen() override;
	std::unique_ptr<Type> getType() override;
};