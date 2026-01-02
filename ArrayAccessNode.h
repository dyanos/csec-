#pragma once
#include "ast.h"

class ArrayAccessNode : public ASTNode {
public:
    ArrayAccessNode() {
        nodeType = ASTNodeType::ARRAY_ACCESS;
    }
    ArrayAccessNode(ArrayAccessNode* other) {
        nodeType = ASTNodeType::ARRAY_ACCESS;
        array = std::move(other->array);
        index = std::move(other->index);
	}

    std::unique_ptr<ASTNode> array;
    std::unique_ptr<ASTNode> index;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override {
        // 배열의 요소 타입 반환
        auto arrayType = (GenericType*)(array->getType().get());
        if (arrayType && arrayType->typeArguments.size() == 1) {
            return std::make_unique<Type>(arrayType->typeArguments[0].get());
        }
        else {
            return std::make_unique<UnknownType>();
        }
    }
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<ArrayAccessNode>(this);
    }
};