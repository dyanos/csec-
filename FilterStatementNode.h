#pragma once
#include "ast.h"

class FilterStatementNode : public ASTNode {
public:
    FilterStatementNode() {
        nodeType = ASTNodeType::FILTER_STATEMENT;
    }
    FilterStatementNode(const std::string& var,
                        std::unique_ptr<ASTNode> iterable,
                        std::unique_ptr<ASTNode> bodyStmt)
        : variable(var), iterableExpr(std::move(iterable)), body(std::move(bodyStmt)) {
        nodeType = ASTNodeType::FILTER_STATEMENT;
    }
    FilterStatementNode(const FilterStatementNode& other)
        : variable(other.variable),
          iterableExpr(other.iterableExpr ? other.iterableExpr->clone() : nullptr),
          body(other.body ? other.body->clone() : nullptr) {
        nodeType = ASTNodeType::FILTER_STATEMENT;
    }
    FilterStatementNode& operator=(const FilterStatementNode& other) {
        if (this != &other) {
            variable = other.variable;
            iterableExpr = other.iterableExpr ? other.iterableExpr->clone() : nullptr;
            body = other.body ? other.body->clone() : nullptr;
            nodeType = ASTNodeType::FILTER_STATEMENT;
        }
        return *this;
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
        return std::make_unique<FilterStatementNode>(*this);
    }
};
