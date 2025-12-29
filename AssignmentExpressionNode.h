#pragma once
#include "ast.h"


class AssignmentExpressionNode : public ASTNode {
public:
    std::shared_ptr<ASTNode> left;
    std::shared_ptr<ASTNode> right;

    AssignmentExpressionNode() {
        nodeType = ASTNodeType::ASSIGNMENT_EXPRESSION;
    }
    AssignmentExpressionNode(std::shared_ptr<ASTNode> left, std::shared_ptr<ASTNode> right)
        : left(left), right(right) {
        nodeType = ASTNodeType::ASSIGNMENT_EXPRESSION;
    }

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
};