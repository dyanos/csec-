#pragma once
#include "ast.h"


class BlockNode;

class WhileStatementNode : public ASTNode {
public:
	std::shared_ptr<ASTNode> condition;
	std::shared_ptr<BlockNode> body;
	WhileStatementNode() {
		nodeType = ASTNodeType::FOR_STATEMENT;
	}
	void accept(ASTVisitor& visitor) override;
	llvm::Value* codegen() override;
	std::shared_ptr<Type> getType() override;
};