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
	CallExpressionNode(const CallExpressionNode& other) {
		callee = other.callee ? other.callee->clone() : nullptr;
		for (const auto& arg : other.arguments) {
			arguments.push_back(arg ? arg->clone() : nullptr);
		}
		nodeType = ASTNodeType::CALL_EXPRESSION;
	}
	CallExpressionNode& operator=(const CallExpressionNode& other) {
		if (this != &other) {
			callee = other.callee ? other.callee->clone() : nullptr;
			arguments.clear();
			arguments.reserve(other.arguments.size());
			for (const auto& arg : other.arguments) {
				arguments.push_back(arg ? arg->clone() : nullptr);
			}
			nodeType = ASTNodeType::CALL_EXPRESSION;
		}
		return *this;
	}

	std::unique_ptr<ASTNode> callee;
	std::vector<std::unique_ptr<ASTNode>> arguments;

	void accept(ASTVisitor& visitor) override;
	llvm::Value* codegen() override;
	std::unique_ptr<Type> getType() override;
	std::unique_ptr<ASTNode> clone() override {
		return std::make_unique<CallExpressionNode>(*this);
	}
};
