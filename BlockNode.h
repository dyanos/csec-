#pragma once
#include "ast.h"

class BlockNode : public ASTNode {
public:
    BlockNode() {
		statements.clear();
        nodeType = ASTNodeType::BLOCK;
    }
    BlockNode(const BlockNode& other) {
		for (const auto& stmt : other.statements) {
			statements.push_back(stmt->clone());
        }
		nodeType = ASTNodeType::BLOCK;
	}
    BlockNode& operator=(const BlockNode& other) {
        if (this != &other) {
            statements.clear();
            statements.reserve(other.statements.size());
            for (const auto& stmt : other.statements) {
                statements.push_back(stmt ? stmt->clone() : nullptr);
            }
            nodeType = ASTNodeType::BLOCK;
        }
        return *this;
    }

    std::vector<std::unique_ptr<ASTNode>> statements;

    void accept(ASTVisitor& visitor) override;

    llvm::Value* codegen() override;

    std::unique_ptr<Type> getType() override {
		return std::make_unique<UnknownType>();
    }
	std::unique_ptr<ASTNode> clone() override {
		return std::make_unique<BlockNode>(*this);
	}
};
