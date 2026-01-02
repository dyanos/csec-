#pragma once
#include "ast.h"

class LambdaExpressionNode : public ASTNode {
public:
    LambdaExpressionNode() {
        nodeType = ASTNodeType::EXPRESSION; // 적절한 노드 타입으로 변경 필요
    }
    LambdaExpressionNode(LambdaExpressionNode* other) {
        this->capturesByReference = other->capturesByReference;
        for (auto& v : other->captureVariables) {
            this->captureVariables.push_back(v);
        }
        for (auto& arg : other->arguments) {
            this->arguments.push_back(arg->clone());
        }
        this->body = std::move(other->body);
        nodeType = ASTNodeType::EXPRESSION;
    }

    bool capturesByReference = false;
    std::vector<std::string> captureVariables;
    /// @brief
    std::vector<std::unique_ptr<ASTNode>> arguments;
    std::unique_ptr<ASTNode> body;

    void accept(ASTVisitor& visitor) override;

    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override {
        return std::make_unique<UnknownType>();
    }
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<LambdaExpressionNode>(this);
    }
};