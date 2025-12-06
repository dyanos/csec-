#pragma once
#include "ast_node.h"
#include <string>

class VariableDeclarationNode : public ASTNode {
public:
    VariableDeclarationNode();
    
    std::string name;
    std::shared_ptr<Type> type;
    std::shared_ptr<ASTNode> initializer;
    bool isMutable;
    bool isField;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
}; 