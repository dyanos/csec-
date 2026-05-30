#pragma once
#include "ast.h"

class AttributeNode : public ASTNode {
public:
    AttributeNode() {
        nodeType = ASTNodeType::ATTRIBUTE;
    }
    AttributeNode(const AttributeNode& other)
        : expr(other.expr ? other.expr->clone() : nullptr),
          target(other.target ? other.target->clone() : nullptr) {
        nodeType = ASTNodeType::ATTRIBUTE;
    }
    AttributeNode& operator=(const AttributeNode& other) {
        if (this != &other) {
            expr = other.expr ? other.expr->clone() : nullptr;
            target = other.target ? other.target->clone() : nullptr;
            nodeType = ASTNodeType::ATTRIBUTE;
        }
        return *this;
    }
    AttributeNode(std::unique_ptr<ASTNode> expr, std::unique_ptr<ASTNode> target)
        : expr(std::move(expr)), target(std::move(target)) {
        nodeType = ASTNodeType::ATTRIBUTE;
    }

    std::unique_ptr<ASTNode> expr;
    std::unique_ptr<ASTNode> target;

    void accept(ASTVisitor& visitor) override;

    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override {
        return std::make_unique<UnknownType>();
    }
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<AttributeNode>(*this);
    }
};
