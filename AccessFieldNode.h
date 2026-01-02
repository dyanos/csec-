#pragma once
#include "ast.h"
#include "symbol.h"

class AccessFieldNode : public ASTNode {
public:
    std::unique_ptr<ASTNode> base;
    std::unique_ptr<ASTNode> field;

    AccessFieldNode() {
        nodeType = ASTNodeType::ACCESS_FIELD;
    }
    AccessFieldNode(std::unique_ptr<ASTNode> base, std::unique_ptr<ASTNode> field) {
        nodeType = ASTNodeType::ACCESS_FIELD;
		this->base = std::move(base);
		this->field = std::move(field);
    }
    AccessFieldNode(AccessFieldNode* other) {
        nodeType = ASTNodeType::ACCESS_FIELD;
        base = std::move(other->base);
        field = std::move(other->field);
	}

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override;
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<AccessFieldNode>(this);
    }

    int findFieldIndex(ClassSymbol* classSymbol, const std::string& fieldName);
};