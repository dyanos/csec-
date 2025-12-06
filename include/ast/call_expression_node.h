#pragma once
#include "ast_node.h"
#include <vector>

class CallExpressionNode : public ASTNode {
public:
    CallExpressionNode();
    
    std::shared_ptr<ASTNode> callee;
    std::vector<std::shared_ptr<ASTNode>> arguments;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
}; 