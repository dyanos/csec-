#pragma once
#include "ast.h"

#include "ParameterNode.h"

class FunctionDeclarationNode : public ASTNode {
public:
    FunctionDeclarationNode() {
        nodeType = ASTNodeType::FUNCTION_DECLARATION;
    }
    FunctionDeclarationNode(FunctionDeclarationNode* other) {
        this->name = other->name;
        this->returnType = other->returnType;
        this->body = other->body;
        for (auto& param : other->parameters) {
            this->parameters.push_back(std::make_shared<ParameterNode>(param.get()));
        }
	}

    std::string name;
    std::vector<std::shared_ptr<ParameterNode>> parameters;
    std::shared_ptr<Type> returnType;
    std::shared_ptr<class BlockNode> body;

    void accept(ASTVisitor& visitor) override;

    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override {
        return std::make_unique<UnknownType>();
    }
};