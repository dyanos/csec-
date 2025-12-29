#pragma once
#include "ast.h"

class LambdaExpressionNode : public ASTNode {
public:
    LambdaExpressionNode() {
        nodeType = ASTNodeType::EXPRESSION; // 적절한 노드 타입으로 변경 필요
    }

    bool capturesByReference;
    std::vector<std::string> captureVariables;
    /// @brief
    std::vector<std::shared_ptr<ASTNode>> arguments;
    std::shared_ptr<ASTNode> body;

    void accept(ASTVisitor& visitor) override;

    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override {
        return nullptr;
    }
};