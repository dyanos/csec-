#pragma once

#include "ast.h"

class PMapStatementNode : public ASTNode {
public:
    PMapStatementNode() {
        nodeType = ASTNodeType::PMAP_STATEMENT;
    }
    PMapStatementNode(const PMapStatementNode& other) {
        this->variable = other.variable;
        this->iterableExpr = other.iterableExpr ? other.iterableExpr->clone() : nullptr;
        this->body = other.body ? other.body->clone() : nullptr;
        nodeType = ASTNodeType::PMAP_STATEMENT;
    }
    PMapStatementNode& operator=(const PMapStatementNode& other) {
        if (this != &other) {
            variable = other.variable;
            iterableExpr = other.iterableExpr ? other.iterableExpr->clone() : nullptr;
            body = other.body ? other.body->clone() : nullptr;
            nodeType = ASTNodeType::PMAP_STATEMENT;
        }
        return *this;
    }
    PMapStatementNode(std::string variable, std::unique_ptr<ASTNode> iterableExpr, std::unique_ptr<ASTNode> body) {
        this->variable = variable;
        this->iterableExpr = std::move(iterableExpr);
        this->body = std::move(body);
        nodeType = ASTNodeType::PMAP_STATEMENT;
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
        return std::make_unique<PMapStatementNode>(*this);
    }
};

