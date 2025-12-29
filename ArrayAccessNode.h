#pragma once
#include "ast.h"

class ArrayAccessNode : public ASTNode {
public:
    ArrayAccessNode() {
        nodeType = ASTNodeType::ARRAY_ACCESS;
    }

    std::shared_ptr<ASTNode> array;
    std::shared_ptr<ASTNode> index;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override {
        // 배열의 요소 타입 반환
        auto arrayType = std::dynamic_pointer_cast<GenericType>(array->getType());
        if (arrayType && arrayType->typeArguments.size() == 1) {
            return arrayType->typeArguments[0];
        }
        else {
            return std::make_shared<UnknownType>();
        }
    }
};