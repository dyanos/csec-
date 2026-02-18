#pragma once
#include "ast.h"


class AssignmentExpressionNode : public ASTNode {
public:
    std::unique_ptr<ASTNode> left;
    std::unique_ptr<ASTNode> right;

    AssignmentExpressionNode() {
        nodeType = ASTNodeType::ASSIGNMENT_EXPRESSION;
    }
    AssignmentExpressionNode(std::unique_ptr<ASTNode> left, std::unique_ptr<ASTNode> right) {
        this->left = std::move(left);
        this->right = std::move(right);
        nodeType = ASTNodeType::ASSIGNMENT_EXPRESSION;
    }
    AssignmentExpressionNode(const AssignmentExpressionNode& other)
        : left(other.left ? other.left->clone() : nullptr),
          right(other.right ? other.right->clone() : nullptr) {
        nodeType = ASTNodeType::ASSIGNMENT_EXPRESSION;
	}
    AssignmentExpressionNode& operator=(const AssignmentExpressionNode& other) {
        if (this != &other) {
            left = other.left ? other.left->clone() : nullptr;
            right = other.right ? other.right->clone() : nullptr;
            nodeType = ASTNodeType::ASSIGNMENT_EXPRESSION;
        }
        return *this;
    }

	void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override;
	std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<AssignmentExpressionNode>(*this);
	}
};
