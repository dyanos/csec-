#pragma once
#include "ast_node.h"
#include <string>

class ExpressionNode : public ASTNode {
public:
    ExpressionNode();
    
    std::string value;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
}; 