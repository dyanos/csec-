#pragma once
#include "ast.h"

#include "BlockNode.h"

class ForStatementNode : public ASTNode {
public:
    ForStatementNode() {
        nodeType = ASTNodeType::FOR_STATEMENT;
    }
    ForStatementNode(const ForStatementNode& other)
        : variable(other.variable),
          iterableExpr(other.iterableExpr ? other.iterableExpr->clone() : nullptr),
          isRange(other.isRange),
          isInclusive(other.isInclusive),
          body(other.body ? std::make_unique<BlockNode>(*other.body) : nullptr) {
        nodeType = ASTNodeType::FOR_STATEMENT;
    }
    ForStatementNode& operator=(const ForStatementNode& other) {
        if (this != &other) {
            variable = other.variable;
            iterableExpr = other.iterableExpr ? other.iterableExpr->clone() : nullptr;
            isRange = other.isRange;
            isInclusive = other.isInclusive;
            body = other.body ? std::make_unique<BlockNode>(*other.body) : nullptr;
            nodeType = ASTNodeType::FOR_STATEMENT;
        }
        return *this;
    }
    ForStatementNode(const std::string& var,
        std::unique_ptr<ASTNode> iterable,
        bool rangeFlag,
        bool inclusiveFlag,
        std::unique_ptr<BlockNode> bodyStmt)
        : variable(var),
        iterableExpr(std::move(iterable)),
        isRange(rangeFlag),
        isInclusive(inclusiveFlag),
        body(std::move(bodyStmt)) {
        nodeType = ASTNodeType::FOR_STATEMENT;
    }

    std::string variable;
    std::unique_ptr<ASTNode> iterableExpr;
    bool isRange = false;
    bool isInclusive = true;
    std::unique_ptr<BlockNode> body;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::unique_ptr<Type> getType() override {
        return std::make_unique<UnknownType>();
    }
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<ForStatementNode>(*this);
    }
};
