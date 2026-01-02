#pragma once
#include "ast.h"

class ParameterNode : public ASTNode {
public:
    ParameterNode() {
        nodeType = ASTNodeType::PARAMETER;
    }
    ParameterNode(const std::string& name, std::unique_ptr<Type> type)
        : name(name) {
        nodeType = ASTNodeType::PARAMETER;
		this->type = std::move(type);
	}
    ParameterNode(ParameterNode* other) {
        nodeType = ASTNodeType::PARAMETER;
        name = other->name;
        type = std::move(other->type);
	}
	~ParameterNode() = default;

    std::string name;
    std::unique_ptr<Type> type;

    void accept(ASTVisitor& visitor) override;

    llvm::Value* codegen() override;

    std::unique_ptr<Type> getType() override {
        return type->clone();
    }

    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<ParameterNode>(this);
	}
};