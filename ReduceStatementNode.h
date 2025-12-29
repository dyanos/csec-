#pragma once
#include "ast.h"

class ReduceStatementNode : public ASTNode {
public:
    ReduceStatementNode() {
        nodeType = ASTNodeType::EXPRESSION; // 적절한 노드 타입으로 변경 필요
    }

    std::string variable;
    std::shared_ptr<ASTNode> iterableExpr;
    std::shared_ptr<ASTNode> body;
    std::shared_ptr<ASTNode> initialValue;

    void accept(ASTVisitor& visitor) override;

    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override {
        return nullptr;
    }
};