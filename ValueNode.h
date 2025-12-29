#pragma once
#include "ast.h"


enum class ValueType {
	NONE, INT, FLOAT, STRING
};

class ValueNode : public ASTNode {
public:
	ValueNode() {
		nodeType = ASTNodeType::VALUE;
	}

	std::string value;
	TokenType valueType = TokenType::UNKNOWN;

	ValueNode(const std::string& value, TokenType type) : value(value), valueType(type) {}

	void accept(ASTVisitor& visitor) override;
	llvm::Value* codegen() override;
	std::shared_ptr<Type> getType() override;
};