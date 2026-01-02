#pragma once
#include "ast.h"

#include "ParameterNode.h"
#include "BlockNode.h"

class FunctionDeclarationNode : public ASTNode {
public:
    FunctionDeclarationNode() {
        nodeType = ASTNodeType::FUNCTION_DECLARATION;
        name = "";
        parameters.clear();
		returnType = nullptr;
		body = nullptr;
    }
    FunctionDeclarationNode(const std::string& name,
        const std::vector<std::unique_ptr<ParameterNode>>& parameters,
        std::unique_ptr<Type>& returnType,
        std::unique_ptr<BlockNode>& body)
        : name(name) {
        nodeType = ASTNodeType::FUNCTION_DECLARATION;
        this->returnType = std::move(returnType);
        this->body = std::move(body);
        for (auto & param : parameters) {
            this->parameters.push_back(param->clone());
		}
    }
    FunctionDeclarationNode(FunctionDeclarationNode* other) {
        nodeType = ASTNodeType::FUNCTION_DECLARATION;
        name = other->name;
        for (auto& param : other->parameters) {
            parameters.push_back(param->clone());
        }
        returnType = std::move(other->returnType);
		body = std::move(other->body);
    }

    std::string name;
    std::vector<std::unique_ptr<ASTNode>> parameters;
    std::unique_ptr<Type> returnType;
    std::unique_ptr<BlockNode> body;

    void accept(ASTVisitor& visitor) override;

    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override {
        return std::make_unique<UnknownType>();
    }
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<FunctionDeclarationNode>(this);
    }
};