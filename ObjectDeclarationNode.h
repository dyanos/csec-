#pragma once
#include "ast.h"

class ObjectDeclarationNode : public ASTNode {
public:
    ObjectDeclarationNode() {
        nodeType = ASTNodeType::OBJECT_DECLARATION;
    }

    std::string name;
    std::shared_ptr<ASTNode> body;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override {
        return nullptr;
    }
};