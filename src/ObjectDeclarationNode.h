#pragma once
#include "ast.h"

class ObjectDeclarationNode : public ASTNode {
public:
    ObjectDeclarationNode() {
        nodeType = ASTNodeType::OBJECT_DECLARATION;
    }
    ObjectDeclarationNode(const ObjectDeclarationNode& other) {
        nodeType = other.nodeType;
        name = other.name;
        body = other.body ? other.body->clone() : nullptr;
	}
    ObjectDeclarationNode& operator=(const ObjectDeclarationNode& other) {
        if (this != &other) {
            nodeType = other.nodeType;
            name = other.name;
            body = other.body ? other.body->clone() : nullptr;
            isExternal = other.isExternal;
        }
        return *this;
    }
    ObjectDeclarationNode(const std::string& name, std::unique_ptr<ASTNode> body)
        : name(name), body(std::move(body)) {
        nodeType = ASTNodeType::OBJECT_DECLARATION;
	}

	bool isExternal = false;

    std::string name;
    std::unique_ptr<ASTNode> body;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override {
        return std::make_unique<UnknownType>();
    }
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<ObjectDeclarationNode>(*this);
	}
};
