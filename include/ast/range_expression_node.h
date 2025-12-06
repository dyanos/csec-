#pragma once
#include "ast_node.h"

class RangeExpressionNode : public ASTNode {
public:
    RangeExpressionNode();
    
    std::shared_ptr<ASTNode> startExpr;
    std::shared_ptr<ASTNode> endExpr;
    bool isInclusive;  // true for 'to', false for 'until'

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
}; 