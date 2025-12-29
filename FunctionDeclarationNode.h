#pragma once
#include "ast.h"

class FunctionDeclarationNode : public ASTNode {
public:
    FunctionDeclarationNode() {
        nodeType = ASTNodeType::FUNCTION_DECLARATION;
    }

    std::string name;
    std::vector<std::shared_ptr<class ParameterNode>> parameters;
    std::shared_ptr<Type> returnType;
    std::shared_ptr<class BlockNode> body;

    void accept(ASTVisitor& visitor) override;

    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override {
        return nullptr;
    }
};