#pragma once
#include "ast.h"
#include "symbol.h"

class AccessFieldNode : public ASTNode {
public:
    std::shared_ptr<ASTNode> base;
    std::shared_ptr<ASTNode> field;

    AccessFieldNode() {
        nodeType = ASTNodeType::ACCESS_FIELD;
    }
    AccessFieldNode(std::shared_ptr<ASTNode> base, std::shared_ptr<ASTNode> field)
        : base(base), field(field) {
        nodeType = ASTNodeType::ACCESS_FIELD;
    }

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override;

    int findFieldIndex(ClassSymbol* classSymbol, const std::string& fieldName);
};