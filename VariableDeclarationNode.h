#pragma once
#include "ast.h"

class VariableDeclarationNode : public ASTNode {
public:
    VariableDeclarationNode() {
        this->nodeType = ASTNodeType::VARIABLE_DECLARATION;
    }
    VariableDeclarationNode(const std::string& name,
                            std::unique_ptr<Type> type,
                            std::unique_ptr<ASTNode> initializer,
                            bool isMutable = false,
                            bool isField = false)
        : name(name),
          type(std::move(type)),
          initializer(std::move(initializer)),
          isMutable(isMutable),
          isField(isField) {
        this->nodeType = ASTNodeType::VARIABLE_DECLARATION;
    }
    VariableDeclarationNode(const VariableDeclarationNode& other) {
        this->nodeType = ASTNodeType::VARIABLE_DECLARATION;
        this->name = other.name;
        this->type = other.type ? other.type->clone() : nullptr;
        this->initializer = other.initializer ? other.initializer->clone() : nullptr;
        this->isMutable = other.isMutable;
        this->isField = other.isField;
    }
    VariableDeclarationNode& operator=(const VariableDeclarationNode& other) {
        if (this != &other) {
            this->nodeType = ASTNodeType::VARIABLE_DECLARATION;
            this->name = other.name;
            this->type = other.type ? other.type->clone() : nullptr;
            this->initializer = other.initializer ? other.initializer->clone() : nullptr;
            this->isMutable = other.isMutable;
            this->isField = other.isField;
        }
        return *this;
    }

    std::string name;
    std::unique_ptr<Type> type;
    std::unique_ptr<ASTNode> initializer;
    bool isMutable = false;
    bool isField = false;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::unique_ptr<Type> getType() override {
        return std::make_unique<UnknownType>();
    }
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<VariableDeclarationNode>(*this);
    }
};
