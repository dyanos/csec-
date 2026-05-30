#pragma once
#include "ast.h"

class IdentifierNode : public ASTNode {
public:
	IdentifierNode(const std::string& value) : value(value) {
		nodeType = ASTNodeType::IDENTIFIER;
	}
	IdentifierNode(const IdentifierNode& other) : value(other.value) {
		nodeType = ASTNodeType::IDENTIFIER;
	}
	IdentifierNode& operator=(const IdentifierNode& other) {
		if (this != &other) {
			value = other.value;
			nodeType = ASTNodeType::IDENTIFIER;
		}
		return *this;
	}

	std::string value;

	void accept(ASTVisitor& visitor) override;
	llvm::Value* codegen() override;
	std::unique_ptr<Type> getType() override;
	std::unique_ptr<ASTNode> clone() override {
		return std::make_unique<IdentifierNode>(*this);
	}
};
