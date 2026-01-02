#pragma once
#include "ast.h"

class AssignmentNode : public ASTNode {
public:
    AssignmentNode() {
        nodeType = ASTNodeType::ASSIGNMENT;
    }
    AssignmentNode(AssignmentNode* other)
        : name(other->name),
          expression(std::move(other->expression)) {
        nodeType = ASTNodeType::ASSIGNMENT;
	}
    AssignmentNode(const std::string& name, std::unique_ptr<ASTNode> expression)
        : name(name), expression(std::move(expression)) {
        nodeType = ASTNodeType::ASSIGNMENT;
	}
    std::string name;
    std::unique_ptr<ASTNode> expression;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::unique_ptr<Type> getType() override {
        return std::make_unique<UnknownType>();
    }
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<AssignmentNode>(this);
    }
};