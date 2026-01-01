#pragma once
#include "ast.h"

class ParameterNode : public ASTNode {
public:
    ParameterNode() {
        nodeType = ASTNodeType::PARAMETER;
    }
    ParameterNode(ParameterNode* other) {
        nodeType = ASTNodeType::PARAMETER;
        name = other->name;
        type = std::make_unique<Type>(other->type.get());
	}

    std::string name;
    std::unique_ptr<Type> type;

    void accept(ASTVisitor& visitor) override;

    llvm::Value* codegen() override;

    std::unique_ptr<Type> getType() override {
        return std::make_unique<Type>(type.get());
    }
};