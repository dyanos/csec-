#pragma once
#include "ast.h"

class AttributeNode : public ASTNode {
public:
    AttributeNode() {
        nodeType = ASTNodeType::ATTRIBUTE; // 적절한 노드 타입으로 변경 필요
    }
    AttributeNode(AttributeNode* other)
        : expr(std::move(other->expr)),
        target(std::move(other->target)) {
        nodeType = ASTNodeType::ATTRIBUTE;
    }
    AttributeNode(std::unique_ptr<ASTNode> expr, std::unique_ptr<ASTNode> target)
        : expr(std::move(expr)), target(std::move(target)) {
        nodeType = ASTNodeType::ATTRIBUTE;
	}

    std::unique_ptr<ASTNode> expr;
    std::unique_ptr<ASTNode> target; // attribute를 적용할 대상

    void accept(ASTVisitor& visitor) override;

    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override {
        return std::make_unique<UnknownType>();
    }
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<AttributeNode>(this);
	}
};