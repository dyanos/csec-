#pragma once
#include "ast_node.h"

class ReturnStatementNode : public ASTNode {
public:
    ReturnStatementNode();
    
    std::shared_ptr<ASTNode> expression;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
}; 