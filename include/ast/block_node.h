#pragma once
#include "ast_node.h"
#include <vector>

class BlockNode : public ASTNode {
public:
    BlockNode();
    
    std::vector<std::shared_ptr<ASTNode>> statements;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
}; 