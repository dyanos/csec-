#pragma once
#include "ast.h"

class IdentifierNode : public ASTNode {
public:
	IdentifierNode(const std::string& value) : value(value) {
		nodeType = ASTNodeType::IDENTIFIER;
	}

	std::string value;

	void accept(ASTVisitor& visitor) override;
	llvm::Value* codegen() override;
	std::shared_ptr<Type> getType() override;
};