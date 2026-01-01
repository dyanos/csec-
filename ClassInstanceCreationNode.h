#pragma once
#include "ast.h"


class ClassInstanceCreationNode : public ASTNode {
public:
    std::string className;
    std::vector<std::shared_ptr<ASTNode>> arguments;

    ClassInstanceCreationNode() {
        nodeType = ASTNodeType::CLASS_INSTANCE_CREATION;
    }
    ClassInstanceCreationNode(const std::string& className, std::vector<std::shared_ptr<ASTNode>> arguments)
        : className(className), arguments(arguments) {
        nodeType = ASTNodeType::CLASS_INSTANCE_CREATION;
    }

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override;
};