#pragma once
#include "ast.h"

class BinaryExpressionNode : public ASTNode {
public:
    BinaryExpressionNode() {
        nodeType = ASTNodeType::BINARY_EXPRESSION;
    }
    BinaryExpressionNode(std::unique_ptr<ASTNode>& left, std::string op, std::unique_ptr<ASTNode>& right) {
		this->left = std::move(left);
		this->right = std::move(right);
        this->op = op;
        nodeType = ASTNodeType::BINARY_EXPRESSION;
	}
    BinaryExpressionNode(BinaryExpressionNode* other)
        : left(other->left ? std::move(other->left) : nullptr),
          op(other->op),
          right(other->right ? std::move(other->right) : nullptr) {
        nodeType = ASTNodeType::BINARY_EXPRESSION;
	}

    std::unique_ptr<ASTNode> left;
    std::string op;
    std::unique_ptr<ASTNode> right;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override;
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<BinaryExpressionNode>(this);
	}
};