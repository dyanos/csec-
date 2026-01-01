#pragma once
#include "ast.h"


class UnitNode : public ASTNode {
public:
    UnitNode() {
        nodeType = ASTNodeType::UNIT;
    }

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override {
        return nullptr;
    }

    std::unique_ptr<Type> getType() override {
        return std::make_unique<UnknownType>();
    }
};