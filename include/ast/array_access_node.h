#pragma once
#include "ast_node.h"

class ArrayAccessNode : public ASTNode {
public:
    ArrayAccessNode();
    
    std::shared_ptr<ASTNode> array;
    std::shared_ptr<ASTNode> index;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
}; 