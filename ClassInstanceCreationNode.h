#pragma once
#include "ast.h"


class ClassInstanceCreationNode : public ASTNode {
public:
    std::string className;
    std::vector<std::unique_ptr<ASTNode>> arguments;

    ClassInstanceCreationNode() {
        nodeType = ASTNodeType::CLASS_INSTANCE_CREATION;
		arguments.clear();
        className = "";
    }
    ClassInstanceCreationNode(const std::string& className, std::vector<std::unique_ptr<ASTNode>> arguments) {
        this->className = className;
        for (const auto& arg : arguments) {
            this->arguments.push_back(arg->clone());
        }
        nodeType = ASTNodeType::CLASS_INSTANCE_CREATION;
    }
    ClassInstanceCreationNode(const std::string& className) {
        this->className = className;
        arguments.clear();
        nodeType = ASTNodeType::CLASS_INSTANCE_CREATION;
    }
    ClassInstanceCreationNode(ClassInstanceCreationNode* other) {
        nodeType = other->nodeType;
        className = other->className;
        for (const auto& arg : other->arguments) {
            arguments.push_back(arg->clone());
		}
    }

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override;
    std::unique_ptr<ASTNode> clone() override {
		return std::make_unique<ClassInstanceCreationNode>(this);
    }
};