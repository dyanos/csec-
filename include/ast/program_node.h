#pragma once
#include "ast_node.h"
#include <vector>

class ProgramNode : public ASTNode {
public:
    ProgramNode();
    std::vector<std::shared_ptr<ASTNode>> statements;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
}; 