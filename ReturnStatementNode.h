#pragma once
#include "ast.h"

class ReturnStatementNode : public ASTNode {
public:
    ReturnStatementNode() {
        nodeType = ASTNodeType::RETURN_STATEMENT;
    }
    ReturnStatementNode(const ReturnStatementNode& other) {
        nodeType = ASTNodeType::RETURN_STATEMENT;
        if (other.expression) {
            expression = other.expression->clone();
		}
    }
    ReturnStatementNode& operator=(const ReturnStatementNode& other) {
        if (this != &other) {
            nodeType = ASTNodeType::RETURN_STATEMENT;
            expression = other.expression ? other.expression->clone() : nullptr;
        }
        return *this;
    }

    std::unique_ptr<ASTNode> expression;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::unique_ptr<Type> getType() override {
        return std::make_unique<UnknownType>();
    }
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<ReturnStatementNode>(*this);
	}
};
