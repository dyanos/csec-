#pragma once
#include "ast.h"


class RangeExpressionNode : public ASTNode {
public:
    RangeExpressionNode() {
        nodeType = ASTNodeType::RANGE_EXPRESSION;
    }
    RangeExpressionNode(const RangeExpressionNode& other) {
        nodeType = other.nodeType;
        if (other.startExpr) {
            startExpr = other.startExpr->clone();
        }
        if (other.endExpr) {
            endExpr = other.endExpr->clone();
        }
        isInclusive = other.isInclusive;
    }
    RangeExpressionNode& operator=(const RangeExpressionNode& other) {
        if (this != &other) {
            nodeType = other.nodeType;
            startExpr = other.startExpr ? other.startExpr->clone() : nullptr;
            endExpr = other.endExpr ? other.endExpr->clone() : nullptr;
            isInclusive = other.isInclusive;
        }
        return *this;
    }
    RangeExpressionNode(std::unique_ptr<ASTNode> start,
                         std::unique_ptr<ASTNode> end,
                         bool inclusive)
        : startExpr(std::move(start)),
          endExpr(std::move(end)),
          isInclusive(inclusive) {
        nodeType = ASTNodeType::RANGE_EXPRESSION;
    }

    std::unique_ptr<ASTNode> startExpr;
    std::unique_ptr<ASTNode> endExpr;
    bool isInclusive = true;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::unique_ptr<Type> getType() override {
        return std::make_unique<UnknownType>();
    }
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<RangeExpressionNode>(*this);
    }
};
