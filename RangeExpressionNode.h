#pragma once
#include "ast.h"


class RangeExpressionNode : public ASTNode {
public:
    RangeExpressionNode() {
        nodeType = ASTNodeType::RANGE_EXPRESSION;
    }
    RangeExpressionNode(RangeExpressionNode* other) {
        nodeType = other->nodeType;
        if (other->startExpr) {
            startExpr = std::move(other->startExpr);
        }
        if (other->endExpr) {
            endExpr = std::move(other->endExpr);
        }
        isInclusive = other->isInclusive;
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
    bool isInclusive = true;  // `to`̸ true, `until`̸ false

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::unique_ptr<Type> getType() override {
        return std::make_unique<UnknownType>();
    }
    std::unique_ptr<ASTNode> clone() override {
		return std::make_unique<RangeExpressionNode>(this);
    }
};