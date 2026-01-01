#pragma once
#include "ast.h"

#include "BlockNode.h"


class IfStatementNode : public ASTNode {
public:
    IfStatementNode() {
        nodeType = ASTNodeType::IF_STATEMENT;
    }

    std::shared_ptr<ASTNode> condition;
    std::shared_ptr<BlockNode> thenBlock;
    std::shared_ptr<BlockNode> elseBlock;  // else

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::unique_ptr<Type> getType() override {
        return std::make_unique<UnknownType>();
    }
};