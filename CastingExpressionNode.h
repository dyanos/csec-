#pragma once
#include "ast.h"


class CastingExpressionNode : public ASTNode {
public:
	std::shared_ptr<ASTNode> expression;
	std::shared_ptr<ASTNode> type;

	CastingExpressionNode() {
		nodeType = ASTNodeType::CASTING_EXPRESSION;
	}
	CastingExpressionNode(std::shared_ptr<ASTNode> expression, std::shared_ptr<ASTNode> type)
		: expression(expression), type(type) {
		nodeType = ASTNodeType::CASTING_EXPRESSION;
	}

	void accept(ASTVisitor& visitor) override;
	llvm::Value* codegen() override;
	std::unique_ptr<Type> getType() override;
};