#pragma once
#include "ast_node.h"

class CastingExpressionNode : public ASTNode {
public:
    CastingExpressionNode();
    CastingExpressionNode(std::shared_ptr<ASTNode> expression, std::shared_ptr<ASTNode> type);
    
    std::shared_ptr<ASTNode> expression;
    std::shared_ptr<ASTNode> type;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
}; 