#pragma once
#include "ast.h"

#include "BlockNode.h"


class WhileStatementNode : public ASTNode {
public:
	std::unique_ptr<ASTNode> condition;
	std::unique_ptr<BlockNode> body;
	WhileStatementNode() {
		condition = nullptr;
		body = nullptr;
		nodeType = ASTNodeType::FOR_STATEMENT;
	}
	WhileStatementNode(std::unique_ptr<ASTNode>& condition, std::unique_ptr<BlockNode>& body) {
		this->condition = std::move(condition);
		this->body = std::move(body);
		nodeType = ASTNodeType::FOR_STATEMENT;
	}
	WhileStatementNode(WhileStatementNode* other) {
		this->nodeType = ASTNodeType::FOR_STATEMENT;
		if (other->condition) {
			this->condition = std::move(other->condition);
		}
		if (other->body) {
			this->body = std::move(other->body);
		}
	}

	void accept(ASTVisitor& visitor) override;
	llvm::Value* codegen() override;
	std::unique_ptr<Type> getType() override;
	std::unique_ptr<ASTNode> clone() override {
		return std::make_unique<WhileStatementNode>(this);
	}
};