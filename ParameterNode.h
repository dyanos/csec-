#pragma once
#include "ast.h"

class ParameterNode : public ASTNode {
public:
    ParameterNode() {
        nodeType = ASTNodeType::PARAMETER;
    }

    std::string name;
    std::shared_ptr<Type> type;

    void accept(ASTVisitor& visitor) override;

    llvm::Value* codegen() override;

    std::shared_ptr<Type> getType() override {
        return type;
    }
};