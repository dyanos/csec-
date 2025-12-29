#pragma once
#include "ast.h"

#include "VariableDeclarationNode.h"
#include "FunctionDeclarationNode.h"

class ClassBodyNode : public ASTNode {
public:
    ClassBodyNode() {
        nodeType = ASTNodeType::CLASS_BODY;
    }

    std::vector<std::shared_ptr<VariableDeclarationNode>> fields;
    std::vector<std::shared_ptr<FunctionDeclarationNode>> methods;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::shared_ptr<Type> getType() override {
        return nullptr;
    }

    std::shared_ptr<FunctionDeclarationNode> getMethod(const std::string& name) {
        for (auto method : methods) {
            if (method->name == name) {
                return method;
            }
        }
        return nullptr;
    }
};