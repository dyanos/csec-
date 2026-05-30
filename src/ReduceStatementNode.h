#pragma once
#include "ast.h"

class ReduceStatementNode : public ASTNode {
public:
    ReduceStatementNode() {
        nodeType = ASTNodeType::REDUCE_STATEMENT;
    }
    ReduceStatementNode(const ReduceStatementNode& other) {
        nodeType = other.nodeType;
        variable = other.variable;
        accumulatorVariable = other.accumulatorVariable;
        backend = other.backend;
        isParallel = other.isParallel;
        iterableExpr = other.iterableExpr ? other.iterableExpr->clone() : nullptr;
        body = other.body ? other.body->clone() : nullptr;
        initialValue = other.initialValue ? other.initialValue->clone() : nullptr;
    }
    ReduceStatementNode& operator=(const ReduceStatementNode& other) {
        if (this != &other) {
            nodeType = other.nodeType;
            variable = other.variable;
            accumulatorVariable = other.accumulatorVariable;
            backend = other.backend;
            isParallel = other.isParallel;
            iterableExpr = other.iterableExpr ? other.iterableExpr->clone() : nullptr;
            body = other.body ? other.body->clone() : nullptr;
            initialValue = other.initialValue ? other.initialValue->clone() : nullptr;
        }
        return *this;
    }
    ReduceStatementNode(const std::string& var,
        std::unique_ptr<ASTNode> iterable,
        std::unique_ptr<ASTNode> body,
        std::unique_ptr<ASTNode> initialValue)
        : variable(var),
        iterableExpr(std::move(iterable)),
        body(std::move(body)),
        initialValue(std::move(initialValue)) {
        nodeType = ASTNodeType::REDUCE_STATEMENT;
    }

    std::string variable;
    std::string accumulatorVariable = "$acc";
    std::string backend = "cpu";
    bool isParallel = false;
    std::unique_ptr<ASTNode> iterableExpr;
    std::unique_ptr<ASTNode> body;
    std::unique_ptr<ASTNode> initialValue;

    void accept(ASTVisitor& visitor) override;

    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override {
        if (initialValue) return initialValue->getType();
        return std::make_unique<UnknownType>();
    }
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<ReduceStatementNode>(*this);
    }
};
