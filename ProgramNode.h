#pragma once
#include "ast.h"
#include "ASTVisitor.h"

class ProgramNode : public ASTNode {
public:
    ProgramNode() {
        nodeType = ASTNodeType::PROGRAM;
    }
    ProgramNode(const ProgramNode& other) {
        nodeType = other.nodeType;
        for (const auto& stmt : other.statements) {
            statements.push_back(stmt ? stmt->clone() : nullptr);
        }
    }
    ProgramNode& operator=(const ProgramNode& other) {
        if (this != &other) {
            nodeType = other.nodeType;
            statements.clear();
            statements.reserve(other.statements.size());
            for (const auto& stmt : other.statements) {
                statements.push_back(stmt ? stmt->clone() : nullptr);
            }
        }
        return *this;
    }
    ProgramNode(const std::vector<std::unique_ptr<ASTNode>>& stmts) {
        for (const auto& stmt : stmts) {
            statements.push_back(stmt ? stmt->clone() : nullptr);
        }
        nodeType = ASTNodeType::PROGRAM;
    }

    std::vector<std::unique_ptr<ASTNode>> statements;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override {
        return std::make_unique<UnknownType>();
    }
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<ProgramNode>(*this);
    }
};
