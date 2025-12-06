#pragma once
#include "ast_node.h"
#include <string>
#include <vector>

class ClassInstanceCreationNode : public ASTNode {
public:
    ClassInstanceCreationNode();
    ClassInstanceCreationNode(const std::string& className, std::vector<std::shared_ptr<ASTNode>> arguments);
    
    std::string className;
    std::vector<std::shared_ptr<ASTNode>> arguments;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
}; 