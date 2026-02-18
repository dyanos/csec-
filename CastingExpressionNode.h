#pragma once
#include "ast.h"


class CastingExpressionNode : public ASTNode {
public:
	std::unique_ptr<ASTNode> expression;
	std::unique_ptr<ASTNode> typeNode;

	CastingExpressionNode() {
		nodeType = ASTNodeType::CASTING_EXPRESSION;
	}
	CastingExpressionNode(std::unique_ptr<ASTNode> expression, std::unique_ptr<ASTNode> type) {
		this->expression = std::move(expression);
		this->typeNode = std::move(type);
		nodeType = ASTNodeType::CASTING_EXPRESSION;
	}
	CastingExpressionNode(const CastingExpressionNode& other) {
		this->expression = other.expression ? other.expression->clone() : nullptr;
		this->typeNode = other.typeNode ? other.typeNode->clone() : nullptr;
		this->nodeType = other.nodeType;
	}
	CastingExpressionNode& operator=(const CastingExpressionNode& other) {
		if (this != &other) {
			this->expression = other.expression ? other.expression->clone() : nullptr;
			this->typeNode = other.typeNode ? other.typeNode->clone() : nullptr;
			this->nodeType = other.nodeType;
		}
		return *this;
	}

	void accept(ASTVisitor& visitor) override;
	llvm::Value* codegen() override;
	std::unique_ptr<Type> getType() override;
	std::unique_ptr<ASTNode> clone() override {
		return std::make_unique<CastingExpressionNode>(*this);
	}
};

