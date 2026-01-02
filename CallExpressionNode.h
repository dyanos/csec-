#pragma once
#include "ast.h"

class CallExpressionNode : public ASTNode {
public:
	CallExpressionNode() {
		nodeType = ASTNodeType::CALL_EXPRESSION;
	}
	CallExpressionNode(std::unique_ptr<ASTNode> callee,
					   std::vector<std::unique_ptr<ASTNode>> arguments)
		: callee(std::move(callee)), arguments(std::move(arguments)) {
		nodeType = ASTNodeType::CALL_EXPRESSION;
	}
	CallExpressionNode(CallExpressionNode* other) {
		callee = std::move(other->callee);
		for (auto& arg : other->arguments) {
			arguments.push_back(arg->clone());
		}
		nodeType = ASTNodeType::CALL_EXPRESSION;
	}

	std::unique_ptr<ASTNode> callee;
	std::vector<std::unique_ptr<ASTNode>> arguments;

	void accept(ASTVisitor& visitor) override;
	llvm::Value* codegen() override;
	std::unique_ptr<Type> getType() override;
	std::unique_ptr<ASTNode> clone() override {
		return std::make_unique<CallExpressionNode>(this);
	}
};
