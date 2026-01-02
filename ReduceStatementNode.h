#pragma once
#include "ast.h"

class ReduceStatementNode : public ASTNode {
public:
    ReduceStatementNode() {
        nodeType = ASTNodeType::EXPRESSION; // 적절한 노드 타입으로 변경 필요
    }
    ReduceStatementNode(ReduceStatementNode* other) {
        nodeType = other->nodeType;
        variable = other->variable;
        if (other->iterableExpr) {
            iterableExpr = std::move(other->iterableExpr);
        }
        if (other->body) {
            body = std::move(other->body);
        }
        if (other->initialValue) {
            initialValue = std::move(other->initialValue);
        }
	}
    ReduceStatementNode(const std::string& var,
        std::unique_ptr<ASTNode> iterable,
        std::unique_ptr<ASTNode> body,
        std::unique_ptr<ASTNode> initialValue)
        : variable(var),
        iterableExpr(std::move(iterable)),
        body(std::move(body)),
        initialValue(std::move(initialValue)) {
        nodeType = ASTNodeType::EXPRESSION; // 적절한 노드 타입으로 변경 필요
    }

    std::string variable;
    std::unique_ptr<ASTNode> iterableExpr;
    std::unique_ptr<ASTNode> body;
    std::unique_ptr<ASTNode> initialValue;

    void accept(ASTVisitor& visitor) override;

    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override {
        return std::make_unique<UnknownType>();
    }
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<ReduceStatementNode>(this);
	}
};