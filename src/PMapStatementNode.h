#pragma once

#include "ast.h"

class PMapStatementNode : public ASTNode {
public:
    PMapStatementNode() {
        nodeType = ASTNodeType::PMAP_STATEMENT;
    }
    PMapStatementNode(const PMapStatementNode& other) {
        this->variable = other.variable;
        this->backend = other.backend;
        this->iterableExpr = other.iterableExpr ? other.iterableExpr->clone() : nullptr;
        this->body = other.body ? other.body->clone() : nullptr;
        nodeType = ASTNodeType::PMAP_STATEMENT;
    }
    PMapStatementNode& operator=(const PMapStatementNode& other) {
        if (this != &other) {
            variable = other.variable;
            backend = other.backend;
            iterableExpr = other.iterableExpr ? other.iterableExpr->clone() : nullptr;
            body = other.body ? other.body->clone() : nullptr;
            nodeType = ASTNodeType::PMAP_STATEMENT;
        }
        return *this;
    }
    PMapStatementNode(std::string variable, std::unique_ptr<ASTNode> iterableExpr, std::unique_ptr<ASTNode> body, std::string backend = "cpu") {
        this->variable = variable;
        this->backend = backend;
        this->iterableExpr = std::move(iterableExpr);
        this->body = std::move(body);
        nodeType = ASTNodeType::PMAP_STATEMENT;
    }

    std::string variable;
    std::string backend = "cpu";
    std::unique_ptr<ASTNode> iterableExpr;
    std::unique_ptr<ASTNode> body;

    void accept(ASTVisitor& visitor) override;

    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override {
        if (!iterableExpr || !body) return std::make_unique<UnknownType>();

        auto iterType = iterableExpr->getType();
        auto bodyType = body->getType();
        if (!iterType || !bodyType) return std::make_unique<UnknownType>();

        if (auto* arrType = dynamic_cast<ArrayType*>(iterType.get())) {
            return std::make_unique<ArrayType>(bodyType, arrType->size);
        }
        if (auto* genType = dynamic_cast<GenericType*>(iterType.get())) {
            if (genType->baseType && genType->baseType->getName() == "Array") {
                std::vector<std::unique_ptr<Type>> typeArgs;
                typeArgs.push_back(bodyType->clone());
                std::unique_ptr<Type> base = std::make_unique<BasicType>("Array");
                return std::make_unique<GenericType>(base, typeArgs);
            }
        }
        return std::make_unique<UnknownType>();
    }
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<PMapStatementNode>(*this);
    }
};
