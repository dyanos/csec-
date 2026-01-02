#pragma once
#include "ast.h"

#include "BlockNode.h"


class IfStatementNode : public ASTNode {
public:
    IfStatementNode() {
        nodeType = ASTNodeType::IF_STATEMENT;
    }
    IfStatementNode(std::unique_ptr<ASTNode> cond,
                    std::unique_ptr<BlockNode> thenBlk,
                    std::unique_ptr<BlockNode> elseBlk = nullptr)
        : condition(std::move(cond)),
          thenBlock(std::move(thenBlk)),
          elseBlock(std::move(elseBlk)) {
        nodeType = ASTNodeType::IF_STATEMENT;
	}
    IfStatementNode(IfStatementNode* other) {
        if (other->condition) {
            condition = other->condition->clone();
        }
        if (other->thenBlock) {
            thenBlock = std::make_unique<BlockNode>(static_cast<BlockNode*>(other->thenBlock.get()));
        }
        if (other->elseBlock) {
            elseBlock = std::make_unique<BlockNode>(static_cast<BlockNode*>(other->elseBlock.get()));
        }
        nodeType = ASTNodeType::IF_STATEMENT;
	}

    std::unique_ptr<ASTNode> condition;
    std::unique_ptr<BlockNode> thenBlock;
    std::unique_ptr<BlockNode> elseBlock;  // else

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::unique_ptr<Type> getType() override {
        return std::make_unique<UnknownType>();
    }
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<IfStatementNode>(this);
	}
};