#pragma once
#include "ast_node.h"
#include <string>

class IdentifierNode : public ASTNode {
public:
    IdentifierNode(const std::string& value);
    
    std::string value;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
}; 