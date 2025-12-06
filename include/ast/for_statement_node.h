#pragma once
#include "ast_node.h"
#include "block_node.h"
#include <string>

class ForStatementNode : public ASTNode {
public:
    ForStatementNode();
    
    std::string variable;
    std::shared_ptr<ASTNode> iterableExpr;
    bool isRange;
    bool isInclusive;  // true for 'to', false for 'until'
    std::shared_ptr<BlockNode> body;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
}; 