#pragma once
#include "ast.h"

class ExpressionNode : public ASTNode {
public:
    ExpressionNode() {
        nodeType = ASTNodeType::EXPRESSION;
    }

    std::string value;

    void accept(ASTVisitor& visitor) override;

    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override;
};