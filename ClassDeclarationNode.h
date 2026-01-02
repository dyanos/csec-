#pragma once
#include "ast.h"
#include "symbol.h"

#include "FunctionDeclarationNode.h"
#include "ParameterNode.h"
#include "ClassBodyNode.h"

class ClassDeclarationNode : public ASTNode {
public:
    ClassDeclarationNode() {
        nodeType = ASTNodeType::CLASS_DECLARATION;
    }
    ClassDeclarationNode(const std::string& name,
        const std::vector<std::unique_ptr<ParameterNode>>& constructorParams,
        const std::string& superClassName,
        std::unique_ptr<ClassBodyNode>& body)
        : name(name), superClassName(superClassName) {
        for (const auto& param : constructorParams) {
            this->constructorParams.push_back(param->clone());
        }
        this->body = std::move(body);
        nodeType = ASTNodeType::CLASS_DECLARATION;
    }
    ClassDeclarationNode(ClassDeclarationNode* other) {
        nodeType = ASTNodeType::CLASS_DECLARATION;
        name = other->name;
        for (auto& param : other->constructorParams) {
            constructorParams.push_back(param->clone());
        }
        superClassName = other->superClassName;
        body = std::move(other->body);
	}

    std::string name;
    std::vector<std::unique_ptr<ASTNode>> constructorParams;
    std::string superClassName;
    std::unique_ptr<ASTNode> body;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    void declareMethod(FunctionDeclarationNode* method, ClassSymbol* classSymbol);

    std::unique_ptr<Type> getType() override {
        return std::make_unique<UnknownType>();
    }
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<ClassDeclarationNode>(this);
    }
};