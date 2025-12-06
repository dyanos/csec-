#pragma once
#include "ast_node.h"
#include <string>

class ParameterNode : public ASTNode {
public:
    ParameterNode();
    
    std::string name;
    std::shared_ptr<Type> type;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
}; 