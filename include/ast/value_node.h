#pragma once
#include "ast_node.h"
#include "../token.h"
#include <string>

class ValueNode : public ASTNode {
public:
    ValueNode();
    ValueNode(const std::string& value, TokenType type);
    
    std::string value;
    TokenType valueType;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
}; 