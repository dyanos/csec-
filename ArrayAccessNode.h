#pragma once
#include "ast.h"

class ArrayAccessNode : public ASTNode {
public:
    ArrayAccessNode() {
        nodeType = ASTNodeType::ARRAY_ACCESS;
    }
    ArrayAccessNode(const ArrayAccessNode& other) {
        nodeType = ASTNodeType::ARRAY_ACCESS;
        array = other.array ? other.array->clone() : nullptr;
        index = other.index ? other.index->clone() : nullptr;
    }
    ArrayAccessNode& operator=(const ArrayAccessNode& other) {
        if (this != &other) {
            nodeType = ASTNodeType::ARRAY_ACCESS;
            array = other.array ? other.array->clone() : nullptr;
            index = other.index ? other.index->clone() : nullptr;
        }
        return *this;
    }

    std::unique_ptr<ASTNode> array;
    std::unique_ptr<ASTNode> index;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override {
        // 배열의 요소 타입 반환
        auto arrayType = dynamic_cast<GenericType*>(array->getType().get());
        if (arrayType && arrayType->typeArguments.size() == 1) {
            return arrayType->typeArguments[0] ? arrayType->typeArguments[0]->clone() : std::make_unique<UnknownType>();
        }
        else {
            return std::make_unique<UnknownType>();
        }
    }
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<ArrayAccessNode>(*this);
    }
};

