#pragma once
#include "ast.h"


class MatchExpressionNode : public ASTNode {
public:
    MatchExpressionNode() {
        nodeType = ASTNodeType::MATCH_EXPRESSION;
    }

    std::shared_ptr<ASTNode> expression;
    std::vector<std::pair<std::shared_ptr<ASTNode>, std::shared_ptr<ASTNode>>> cases;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::unique_ptr<Type> getType() override {
        return std::make_unique<UnknownType>();
    }
};