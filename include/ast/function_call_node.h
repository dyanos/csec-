#pragma once
#include "ast_node.h"
#include <string>
#include <vector>

class FunctionCallNode : public ASTNode {
public:
    FunctionCallNode();
    
    std::string functionName;
    std::vector<std::shared_ptr<ASTNode>> arguments;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
}; 