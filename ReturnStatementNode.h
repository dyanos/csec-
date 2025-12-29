#pragma once
#include "ast.h"

class ReturnStatementNode : public ASTNode {
public:
    ReturnStatementNode() {
        nodeType = ASTNodeType::RETURN_STATEMENT;
    }

    std::shared_ptr<ASTNode> expression;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::shared_ptr<Type> getType() override {
        return nullptr;
    }
};