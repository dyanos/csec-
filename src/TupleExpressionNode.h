#pragma once

#include <vector>
#include <memory>
#include "ast.h"

// `e1, e2, …, en` used as a multiple-return value (`return a, b, c`). Lowers to an LLVM struct
// `{T1, …, Tn}`. Ownership of each owned element transfers into the tuple.
class TupleExpressionNode : public ASTNode {
public:
    std::vector<std::unique_ptr<ASTNode>> elements;

    TupleExpressionNode() {
        nodeType = ASTNodeType::TUPLE_EXPRESSION;
    }
    TupleExpressionNode(const TupleExpressionNode& other) {
        for (const auto& e : other.elements) {
            elements.push_back(e ? e->clone() : nullptr);
        }
        nodeType = ASTNodeType::TUPLE_EXPRESSION;
    }
    virtual ~TupleExpressionNode() = default;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override;
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<TupleExpressionNode>(*this);
    }
};
