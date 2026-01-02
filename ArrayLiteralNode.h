#pragma once

#include <vector>
#include <memory>
#include "ast.h"

// ArrayLiteralNode: 배열 리터럴을 나타내는 AST 노드 -> 나중에 ArrayCreationExpressionNode로 대체될 수 있음
// 예: [1, 2, x]
class ArrayLiteralNode : public ASTNode {
public:
    std::vector<std::unique_ptr<ASTNode>> elements;

    ArrayLiteralNode() {
        elements.clear();
    }
    ArrayLiteralNode(ArrayLiteralNode* other) {
        for (const auto& elem : other->elements) {
            this->elements.push_back(elem->clone());
        }
        nodeType = ASTNodeType::ARRAY_LITERAL;
    }
    virtual ~ArrayLiteralNode() = default;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override;
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<ArrayLiteralNode>(this);
	}
};
