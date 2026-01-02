#pragma once
#include "ast.h"

#include "token.h"

enum class ValueType {
	NONE, INT, FLOAT, STRING
};

class ValueNode : public ASTNode {
public:
	ValueNode() {
		nodeType = ASTNodeType::VALUE;
	}
	ValueNode(ValueNode* other) {
		this->nodeType = other->nodeType;
		this->type = other->type ? std::move(other->type) : nullptr;
		this->value = other->value;
		this->valueType = other->valueType;
	}

	std::string value;
	TokenType valueType = TokenType::UNKNOWN;

	ValueNode(const std::string& value, TokenType type) : value(value), valueType(type) {}

	void accept(ASTVisitor& visitor) override;
	llvm::Value* codegen() override;
	std::unique_ptr<Type> getType() override;
	std::unique_ptr<ASTNode> clone() override {
		return std::make_unique<ValueNode>(this);
	}
};