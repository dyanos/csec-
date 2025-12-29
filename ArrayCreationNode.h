#pragma once
#include "ast.h"

#include "ExpressionNode.h"

class ArrayCreationNode : public ASTNode {
public:
    ArrayCreationNode() {
        nodeType = ASTNodeType::ARRAY_CREATION;
    }

    std::shared_ptr<GenericType> arrayType;
    std::vector<std::shared_ptr<ASTNode>> elements;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override {
        return arrayType;
    }
};