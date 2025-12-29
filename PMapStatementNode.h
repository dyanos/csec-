#pragma once

#include "ast.h"

class PMapStatementNode : public ASTNode {
public:
    PMapStatementNode() {
        nodeType = ASTNodeType::EXPRESSION; // 적절한 노드 타입으로 변경 필요
    }

    std::string variable;
    std::shared_ptr<ASTNode> iterableExpr;
    std::shared_ptr<ASTNode> body;

    void accept(ASTVisitor& visitor) override;

    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override {
        return nullptr;
    }
};