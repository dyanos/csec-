#pragma once
#include "ast.h"

class CallExpressionNode : public ASTNode {
public:
	CallExpressionNode() {
		nodeType = ASTNodeType::CALL_EXPRESSION;
	}

	std::shared_ptr<ASTNode> callee;
	std::vector<std::shared_ptr<ASTNode>> arguments;

	void accept(ASTVisitor& visitor) override;
	llvm::Value* codegen() override;
	std::unique_ptr<Type> getType() override;
};
