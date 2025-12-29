#pragma once
#include "ast.h"

class AttributeNode : public ASTNode {
public:
    AttributeNode() {
        nodeType = ASTNodeType::ATTRIBUTE; // 적절한 노드 타입으로 변경 필요
    }

    std::shared_ptr<ASTNode> expr;
    std::shared_ptr<ASTNode> target; // attribute를 적용할 대상

    void accept(ASTVisitor& visitor) override;

    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override {
        return nullptr;
    }
};