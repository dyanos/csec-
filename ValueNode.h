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
	ValueNode(const ValueNode& other) {
		this->nodeType = other.nodeType;
		this->type = other.type ? other.type->clone() : nullptr;
		this->value = other.value;
		this->valueType = other.valueType;
	}
	ValueNode& operator=(const ValueNode& other) {
		if (this != &other) {
			this->nodeType = other.nodeType;
			this->type = other.type ? other.type->clone() : nullptr;
			this->value = other.value;
			this->valueType = other.valueType;
		}
		return *this;
	}

	std::string value;
	TokenType valueType = TokenType::UNKNOWN;

	ValueNode(const std::string& value, TokenType type) : value(value), valueType(type) {
		nodeType = ASTNodeType::VALUE;
	}

	void accept(ASTVisitor& visitor) override;
	llvm::Value* codegen() override;
	std::unique_ptr<Type> getType() override;
	std::unique_ptr<ASTNode> clone() override {
		return std::make_unique<ValueNode>(*this);
	}
};
