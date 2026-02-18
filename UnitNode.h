#pragma once
#include "ast.h"


class UnitNode : public ASTNode {
public:
    UnitNode() {
        nodeType = ASTNodeType::UNIT;
    }
    UnitNode(const UnitNode& other) {
        nodeType = other.nodeType;
    }
    UnitNode& operator=(const UnitNode& other) {
        if (this != &other) {
            nodeType = other.nodeType;
        }
        return *this;
    }

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override {
        return nullptr;
    }

    std::unique_ptr<Type> getType() override {
        return std::make_unique<UnknownType>();
    }
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<UnitNode>(*this);
    }
};
