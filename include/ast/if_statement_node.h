#pragma once
#include "ast_node.h"
#include "block_node.h"

class IfStatementNode : public ASTNode {
public:
    IfStatementNode();
    
    std::shared_ptr<ASTNode> condition;
    std::shared_ptr<BlockNode> thenBlock;
    std::shared_ptr<BlockNode> elseBlock;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
}; 