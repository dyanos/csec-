#pragma once
#include "ast_node.h"
#include <string>

class ObjectDeclarationNode : public ASTNode {
public:
    ObjectDeclarationNode();
    std::string name;
    std::shared_ptr<ASTNode> body;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
}; 