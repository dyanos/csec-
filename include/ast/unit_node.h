#pragma once
#include "ast_node.h"

class UnitNode : public ASTNode {
public:
    UnitNode();

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
}; 