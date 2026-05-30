#pragma once
#include "ast.h"

#include "VariableDeclarationNode.h"
#include "FunctionDeclarationNode.h"

class ClassBodyNode : public ASTNode {
public:
    ClassBodyNode() {
        nodeType = ASTNodeType::CLASS_BODY;
    }
    ClassBodyNode(const ClassBodyNode& other) {
        nodeType = ASTNodeType::CLASS_BODY;
        for (const auto& field : other.fields) {
            fields.push_back(field ? field->clone() : nullptr);
        }
        for (const auto& method : other.methods) {
            methods.push_back(method ? method->clone() : nullptr);
        }
    }
    ClassBodyNode& operator=(const ClassBodyNode& other) {
        if (this != &other) {
            nodeType = ASTNodeType::CLASS_BODY;
            fields.clear();
            fields.reserve(other.fields.size());
            for (const auto& field : other.fields) {
                fields.push_back(field ? field->clone() : nullptr);
            }
            methods.clear();
            methods.reserve(other.methods.size());
            for (const auto& method : other.methods) {
                methods.push_back(method ? method->clone() : nullptr);
            }
        }
        return *this;
    }

    std::vector<std::unique_ptr<ASTNode>> fields;
    std::vector<std::unique_ptr<ASTNode>> methods;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::unique_ptr<Type> getType() override {
        return nullptr;
    }

    std::unique_ptr<FunctionDeclarationNode> getMethod(const std::string& name) {
        for (auto& method : this->methods) {
            auto md = dynamic_cast<FunctionDeclarationNode*>(method.get());
            if (md->name == name) {
                return std::make_unique<FunctionDeclarationNode>(*md);
            }
        }
        return nullptr;
    }
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<ClassBodyNode>(*this);
    }
};
