#pragma once
#include "ast.h"

class BlockNode : public ASTNode {
public:
    BlockNode() {
        nodeType = ASTNodeType::BLOCK;
    }

    std::vector<std::shared_ptr<ASTNode>> statements;

    void accept(ASTVisitor& visitor) override;

    llvm::Value* codegen() override;

    std::unique_ptr<Type> getType() override {
		return std::unique_ptr<UnknownType>();
    }
};