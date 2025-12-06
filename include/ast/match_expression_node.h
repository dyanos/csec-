#pragma once
#include "ast_node.h"
#include <vector>
#include <utility>

class MatchExpressionNode : public ASTNode {
public:
    MatchExpressionNode();
    
    std::shared_ptr<ASTNode> expression;
    std::vector<std::pair<std::shared_ptr<ASTNode>, std::shared_ptr<ASTNode>>> cases;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
}; 