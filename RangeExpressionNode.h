#pragma once
#include "ast.h"


class RangeExpressionNode : public ASTNode {
public:
    RangeExpressionNode() {
        nodeType = ASTNodeType::RANGE_EXPRESSION;
    }

    std::shared_ptr<ASTNode> startExpr;
    std::shared_ptr<ASTNode> endExpr;
    bool isInclusive;  // `to`̸ true, `until`̸ false

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::shared_ptr<Type> getType() override {
        return nullptr;
    }
};