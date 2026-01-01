#pragma once
#include "ast.h"

class AssignmentNode : public ASTNode {
public:
    AssignmentNode() {
        nodeType = ASTNodeType::ASSIGNMENT;
    }

    std::string name;
    std::shared_ptr<ASTNode> expression;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::unique_ptr<Type> getType() override {
        return std::make_unique<UnknownType>();
    }
};