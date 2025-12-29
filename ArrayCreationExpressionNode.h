#pragma once
#include "ast.h"

#include "ExpressionNode.h"

// TODO: 나중에 이 노드는 new operator 사용법 때문에 ClassInstanceCreationNode로 통합될 예정
class ArrayCreationExpressionNode : public ExpressionNode {
public:
    std::string typeName;
    std::vector<std::shared_ptr<ASTNode>> sizes;

    ArrayCreationExpressionNode() {
        nodeType = ASTNodeType::ARRAY_CREATION_EXPRESSION;
    }
    ArrayCreationExpressionNode(const std::string& typeName, const std::vector<std::shared_ptr<ASTNode>>& sizes)
        : typeName(typeName), sizes(sizes) {
        nodeType = ASTNodeType::ARRAY_CREATION_EXPRESSION;
    }

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
};