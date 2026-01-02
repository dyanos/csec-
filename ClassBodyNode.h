#pragma once
#include "ast.h"

#include "VariableDeclarationNode.h"
#include "FunctionDeclarationNode.h"

class ClassBodyNode : public ASTNode {
public:
    ClassBodyNode() {
        nodeType = ASTNodeType::CLASS_BODY;
    }
    ClassBodyNode(const ClassBodyNode* other) {
        nodeType = ASTNodeType::CLASS_BODY;
        for (auto& field : other->fields) {
            fields.push_back(field->clone());
        }
        for (auto& method : other->methods) {
            methods.push_back(method->clone());
        }
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
				return std::make_unique<FunctionDeclarationNode>(md);
            }
        }
        return nullptr;
    }
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<ClassBodyNode>(this);
	}
};