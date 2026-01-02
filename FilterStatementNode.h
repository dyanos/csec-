#pragma once
#include "ast.h"

class FilterStatementNode : public ASTNode {
public:
    FilterStatementNode() {
        nodeType = ASTNodeType::EXPRESSION; // 적절한 노드 타입으로 변경 필요
    }
    FilterStatementNode(const std::string& var,
                        std::unique_ptr<ASTNode> iterable,
                        std::unique_ptr<ASTNode> bodyStmt)
        : variable(var), iterableExpr(std::move(iterable)), body(std::move(bodyStmt)) {
        nodeType = ASTNodeType::EXPRESSION; // 적절한 노드 타입으로 변경 필요
	}
    FilterStatementNode(FilterStatementNode* other)
        : variable(other->variable),
        iterableExpr(other->iterableExpr ? std::move(other->iterableExpr) : nullptr),
        body(other->body ? std::move(other->body) : nullptr) {
        nodeType = ASTNodeType::EXPRESSION; // 적절한 노드 타입으로 변경 필요
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
        return std::make_unique<FilterStatementNode>(this);
	}
};