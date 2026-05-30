#pragma once
#include "ast.h"

class BinaryExpressionNode : public ASTNode {
public:
    BinaryExpressionNode() {
        nodeType = ASTNodeType::BINARY_EXPRESSION;
    }
    BinaryExpressionNode(std::unique_ptr<ASTNode> left, std::string op, std::unique_ptr<ASTNode> right) {
		this->left = std::move(left);
		this->right = std::move(right);
        this->op = op;
        nodeType = ASTNodeType::BINARY_EXPRESSION;
	}
    BinaryExpressionNode(const BinaryExpressionNode& other)
        : left(other.left ? other.left->clone() : nullptr),
          op(other.op),
          right(other.right ? other.right->clone() : nullptr) {
        nodeType = ASTNodeType::BINARY_EXPRESSION;
	}
    BinaryExpressionNode& operator=(const BinaryExpressionNode& other) {
        if (this != &other) {
            left = other.left ? other.left->clone() : nullptr;
            op = other.op;
            right = other.right ? other.right->clone() : nullptr;
            nodeType = ASTNodeType::BINARY_EXPRESSION;
        }
        return *this;
    }

    std::unique_ptr<ASTNode> left;
    std::string op;
    std::unique_ptr<ASTNode> right;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override;
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<BinaryExpressionNode>(*this);
	}
};

