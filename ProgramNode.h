#pragma once
#include "ast.h"
#include "ASTVisitor.h"

class ProgramNode : public ASTNode {
public:
    ProgramNode() {
        nodeType = ASTNodeType::PROGRAM;
    }

    std::vector<std::shared_ptr<ASTNode>> statements;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override {
        return nullptr;
    }
};