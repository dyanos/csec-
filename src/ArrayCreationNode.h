#pragma once
#include "ast.h"

#include "ExpressionNode.h"

class ArrayCreationNode : public ASTNode {
public:
    ArrayCreationNode() {
        nodeType = ASTNodeType::ARRAY_CREATION;
    }
    ArrayCreationNode(const ArrayCreationNode& other) {
        this->arrayType = other.arrayType ? std::make_unique<GenericType>(*other.arrayType) : nullptr;
        for (const auto& element : other.elements) {
            this->elements.push_back(element ? element->clone() : nullptr);
        }
		nodeType = ASTNodeType::ARRAY_CREATION;
    }
    ArrayCreationNode& operator=(const ArrayCreationNode& other) {
        if (this != &other) {
            this->arrayType = other.arrayType ? std::make_unique<GenericType>(*other.arrayType) : nullptr;
            this->elements.clear();
            this->elements.reserve(other.elements.size());
            for (const auto& element : other.elements) {
                this->elements.push_back(element ? element->clone() : nullptr);
            }
            nodeType = ASTNodeType::ARRAY_CREATION;
        }
        return *this;
    }

    std::unique_ptr<GenericType> arrayType;
    std::vector<std::unique_ptr<ASTNode>> elements;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override {
        return arrayType ? arrayType->clone() : std::make_unique<UnknownType>();
    }
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<ArrayCreationNode>(*this);
    }
};
