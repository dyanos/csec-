#pragma once
#include "ast.h"

#include "ExpressionNode.h"

class ArrayCreationNode : public ASTNode {
public:
    ArrayCreationNode() {
        nodeType = ASTNodeType::ARRAY_CREATION;
    }

    std::unique_ptr<GenericType> arrayType;
    std::vector<std::unique_ptr<ASTNode>> elements;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override {
        return std::make_unique<Type>(arrayType.get());
    }
};