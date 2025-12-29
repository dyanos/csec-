#pragma once
#include "ast.h"

#include "BlockNode.h"

class ForStatementNode : public ASTNode {
public:
    ForStatementNode() {
        nodeType = ASTNodeType::FOR_STATEMENT;
    }

    std::string variable;
    std::shared_ptr<ASTNode> iterableExpr;
    bool isRange = false;
    bool isInclusive = true;  // `to`̸ true, `until`̸ false
    std::shared_ptr<BlockNode> body;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::shared_ptr<Type> getType() override {
        return nullptr;
    }
};