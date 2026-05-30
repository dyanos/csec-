#pragma once
#include "ast.h"

class ExpressionNode : public ASTNode {
public:
    ExpressionNode() {
        nodeType = ASTNodeType::EXPRESSION;
    }
    ExpressionNode(const ExpressionNode& other) {
        nodeType = other.nodeType;
        value = other.value;
    }
    ExpressionNode& operator=(const ExpressionNode& other) {
        if (this != &other) {
            nodeType = other.nodeType;
            value = other.value;
        }
        return *this;
    }
    ExpressionNode(ASTNodeType type, std::string& value) {
        this->nodeType = type;
        this->value = value;
    }

    std::string value;

    void accept(ASTVisitor& visitor) override;

    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override;
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<ExpressionNode>(*this);
    }
};
