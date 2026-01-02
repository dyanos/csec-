#pragma once
#include "ast.h"

#include "ExpressionNode.h"

// TODO: 나중에 이 노드는 new operator 사용법 때문에 ClassInstanceCreationNode로 통합될 예정
class ArrayCreationExpressionNode : public ExpressionNode {
public:
    std::string typeName;
    std::vector<std::unique_ptr<ASTNode>> sizes;

    ArrayCreationExpressionNode() {
        typeName = "";
        sizes.clear();
        nodeType = ASTNodeType::ARRAY_CREATION_EXPRESSION;
    }
    ArrayCreationExpressionNode(ArrayCreationExpressionNode* other) {
		this->typeName = other->typeName;
        for (const auto& size : other->sizes) {
            this->sizes.push_back(size->clone());
        }
        nodeType = ASTNodeType::ARRAY_CREATION_EXPRESSION;
	}
    ArrayCreationExpressionNode(const std::string& typeName)
        : typeName(typeName) {
        nodeType = ASTNodeType::ARRAY_CREATION_EXPRESSION;
	}

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override;
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<ArrayCreationExpressionNode>(this);
	}
};