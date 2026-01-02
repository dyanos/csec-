#pragma once

#include "ast.h"

class PMapStatementNode : public ASTNode {
public:
    PMapStatementNode() {
        nodeType = ASTNodeType::EXPRESSION; // 적절한 노드 타입으로 변경 필요
    }
    PMapStatementNode(PMapStatementNode* other) {
        this->variable = other->variable;
        this->iterableExpr = std::move(other->iterableExpr);
        this->body = std::move(other->body);
        nodeType = ASTNodeType::EXPRESSION; // 적절한 노드 타입으로 변경 필요
    }
    PMapStatementNode(std::string variable, std::unique_ptr<ASTNode>& iterableExpr, std::unique_ptr<ASTNode>& body) {
        this->variable = variable;
        this->iterableExpr = std::move(iterableExpr);
        this->body = std::move(body);
        nodeType = ASTNodeType::EXPRESSION; // 적절한 노드 타입으로 변경 필요
    }

    std::string variable;
    std::unique_ptr<ASTNode> iterableExpr;
    std::unique_ptr<ASTNode> body;

    void accept(ASTVisitor& visitor) override;

    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override {
        return std::make_unique<UnknownType>();
    }
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<PMapStatementNode>(this);
	}
};