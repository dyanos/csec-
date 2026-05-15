#pragma once
#include "ast.h"

class LambdaExpressionNode : public ASTNode {
public:
    LambdaExpressionNode() {
        nodeType = ASTNodeType::EXPRESSION;
    }
    LambdaExpressionNode(const LambdaExpressionNode& other) {
        this->capturesByReference = other.capturesByReference;
        for (const auto& v : other.captureVariables) {
            this->captureVariables.push_back(v);
        }
        for (const auto& arg : other.arguments) {
            this->arguments.push_back(arg ? arg->clone() : nullptr);
        }
        this->body = other.body ? other.body->clone() : nullptr;
        nodeType = ASTNodeType::EXPRESSION;
    }
    LambdaExpressionNode& operator=(const LambdaExpressionNode& other) {
        if (this != &other) {
            capturesByReference = other.capturesByReference;
            captureVariables = other.captureVariables;
            arguments.clear();
            arguments.reserve(other.arguments.size());
            for (const auto& arg : other.arguments) {
                arguments.push_back(arg ? arg->clone() : nullptr);
            }
            body = other.body ? other.body->clone() : nullptr;
            nodeType = ASTNodeType::EXPRESSION;
        }
        return *this;
    }

    bool capturesByReference = false;
    std::vector<std::string> captureVariables;
    std::vector<std::unique_ptr<ASTNode>> arguments;
    std::unique_ptr<ASTNode> body;

    void accept(ASTVisitor& visitor) override;

    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override {
        if (body) return body->getType();
        return std::make_unique<UnknownType>();
    }
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<LambdaExpressionNode>(*this);
    }
};
