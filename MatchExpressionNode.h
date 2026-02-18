#pragma once
#include "ast.h"


class MatchExpressionNode : public ASTNode {
public:
    MatchExpressionNode() {
        nodeType = ASTNodeType::MATCH_EXPRESSION;
    }
    MatchExpressionNode(std::unique_ptr<ASTNode> expr,
        const std::vector<std::pair<std::unique_ptr<ASTNode>, std::unique_ptr<ASTNode>>>& caseList) {
        nodeType = ASTNodeType::MATCH_EXPRESSION;
        expression = std::move(expr);
        for (const auto& casePair : caseList) {
            cases.push_back({ casePair.first->clone(), casePair.second->clone()});
        }
    }
    MatchExpressionNode(const MatchExpressionNode& other) {
        nodeType = ASTNodeType::MATCH_EXPRESSION;
        expression = other.expression ? other.expression->clone() : nullptr;
        for (const auto& casePair : other.cases) {
            cases.push_back({ casePair.first ? casePair.first->clone() : nullptr, casePair.second ? casePair.second->clone() : nullptr });
        }
    }
    MatchExpressionNode& operator=(const MatchExpressionNode& other) {
        if (this != &other) {
            nodeType = ASTNodeType::MATCH_EXPRESSION;
            expression = other.expression ? other.expression->clone() : nullptr;
            cases.clear();
            cases.reserve(other.cases.size());
            for (const auto& casePair : other.cases) {
                cases.push_back({ casePair.first ? casePair.first->clone() : nullptr, casePair.second ? casePair.second->clone() : nullptr });
            }
        }
        return *this;
    }

    std::unique_ptr<ASTNode> expression;
    std::vector<std::pair<std::unique_ptr<ASTNode>, std::unique_ptr<ASTNode>>> cases;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::unique_ptr<Type> getType() override {
        return std::make_unique<UnknownType>();
    }
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<MatchExpressionNode>(*this);
    }
};

