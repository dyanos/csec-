#pragma once
#include "ast.h"

class ReturnStatementNode : public ASTNode {
public:
    ReturnStatementNode() {
        nodeType = ASTNodeType::RETURN_STATEMENT;
    }
    ReturnStatementNode(ReturnStatementNode* other) {
        nodeType = ASTNodeType::RETURN_STATEMENT;
        if (other->expression) {
            expression = std::move(other->expression);
		}
    }

    std::unique_ptr<ASTNode> expression;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::unique_ptr<Type> getType() override {
        return std::make_unique<UnknownType>();
    }
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<ReturnStatementNode>(this);
	}
};