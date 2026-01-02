#pragma once
#include "ast.h"


class CastingExpressionNode : public ASTNode {
public:
	std::unique_ptr<ASTNode> expression;
	std::unique_ptr<ASTNode> type;

	CastingExpressionNode() {
		nodeType = ASTNodeType::CASTING_EXPRESSION;
	}
	CastingExpressionNode(std::unique_ptr<ASTNode>& expression, std::unique_ptr<ASTNode>& type) {
		this->expression = std::move(expression);
		this->type = std::move(type);
		nodeType = ASTNodeType::CASTING_EXPRESSION;
	}
	CastingExpressionNode(CastingExpressionNode* other) {
		this->expression = std::move(other->expression);
		this->type = std::move(other->type);
		this->nodeType = other->nodeType;
	}

	void accept(ASTVisitor& visitor) override;
	llvm::Value* codegen() override;
	std::unique_ptr<Type> getType() override;
	std::unique_ptr<ASTNode> clone() override {
		return std::make_unique<CastingExpressionNode>(this);
	}
};