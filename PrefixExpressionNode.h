#pragma once
#include "ast.h"

class PrefixExpressionNode : public ASTNode {
public:
    std::string op;
    std::unique_ptr<ASTNode> expression;

    PrefixExpressionNode() {
        this->nodeType = ASTNodeType::PREFIX_EXPRESSION;
        this->op = "";
        this->expression = nullptr;
    }
    PrefixExpressionNode(const std::string& op, std::unique_ptr<ASTNode>& expression) {
		this->op = op;
		this->expression = std::move(expression);
        this->nodeType = ASTNodeType::PREFIX_EXPRESSION;
    }
    PrefixExpressionNode(PrefixExpressionNode* other) {
        this->nodeType = other->nodeType;
        this->op = other->op;
        this->expression = std::move(other->expression); // shallow copy
	}

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override;
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<PrefixExpressionNode>(this);
    }
};