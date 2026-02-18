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
    IfStatementNode(const IfStatementNode& other) {
        if (other.condition) {
            condition = other.condition->clone();
        }
        if (other.thenBlock) {
            thenBlock = std::make_unique<BlockNode>(*other.thenBlock);
        }
        if (other.elseBlock) {
            elseBlock = std::make_unique<BlockNode>(*other.elseBlock);
        }
        nodeType = ASTNodeType::IF_STATEMENT;
	}
    IfStatementNode& operator=(const IfStatementNode& other) {
        if (this != &other) {
            condition = other.condition ? other.condition->clone() : nullptr;
            thenBlock = other.thenBlock ? std::make_unique<BlockNode>(*other.thenBlock) : nullptr;
            elseBlock = other.elseBlock ? std::make_unique<BlockNode>(*other.elseBlock) : nullptr;
            nodeType = ASTNodeType::IF_STATEMENT;
        }
        return *this;
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
        return std::make_unique<IfStatementNode>(*this);
	}
};
