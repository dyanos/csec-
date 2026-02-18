#pragma once
#include "ast.h"

#include "ExpressionNode.h"

class ArrayCreationExpressionNode : public ExpressionNode {
public:
    std::string typeName;
    std::vector<std::unique_ptr<ASTNode>> sizes;

    ArrayCreationExpressionNode() {
        typeName = "";
        sizes.clear();
        nodeType = ASTNodeType::ARRAY_CREATION_EXPRESSION;
    }
    ArrayCreationExpressionNode(const ArrayCreationExpressionNode& other) {
        this->typeName = other.typeName;
        for (const auto& size : other.sizes) {
            this->sizes.push_back(size ? size->clone() : nullptr);
        }
        nodeType = ASTNodeType::ARRAY_CREATION_EXPRESSION;
    }
    ArrayCreationExpressionNode& operator=(const ArrayCreationExpressionNode& other) {
        if (this != &other) {
            typeName = other.typeName;
            sizes.clear();
            sizes.reserve(other.sizes.size());
            for (const auto& size : other.sizes) {
                sizes.push_back(size ? size->clone() : nullptr);
            }
            nodeType = ASTNodeType::ARRAY_CREATION_EXPRESSION;
        }
        return *this;
    }
    ArrayCreationExpressionNode(const std::string& typeName)
        : typeName(typeName) {
        nodeType = ASTNodeType::ARRAY_CREATION_EXPRESSION;
    }

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override;
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<ArrayCreationExpressionNode>(*this);
    }
};
