#pragma once
#include "ast_node.h"
#include <string>
#include <vector>

class MethodCallNode : public ASTNode {
public:
    MethodCallNode();
    
    std::shared_ptr<ASTNode> object;
    std::string methodName;
    std::vector<std::shared_ptr<ASTNode>> arguments;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
}; 