#pragma once

#include <vector>
#include <memory>
#include "ast.h"

// ArrayLiteralNode: 배열 리터럴을 나타내는 AST 노드 -> 나중에 ArrayCreationExpressionNode로 대체될 수 있음
// 예: [1, 2, x]
class ArrayLiteralNode : public ASTNode {
public:
    std::vector<std::shared_ptr<ASTNode>> elements;

    ArrayLiteralNode() = default;
    virtual ~ArrayLiteralNode() = default;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override;
};
