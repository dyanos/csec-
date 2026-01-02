#pragma once
#include "ast.h"


class MethodCallNode : public ASTNode {
public:
    MethodCallNode() {
        nodeType = ASTNodeType::METHOD_CALL;
    }
    MethodCallNode(MethodCallNode* other) {
        nodeType = ASTNodeType::METHOD_CALL;
        if (other->object) {
            object = other->object->clone();
        }
        methodName = other->methodName;
        for (const auto& arg : other->arguments) {
            arguments.push_back(arg->clone());
        }
	}
    MethodCallNode(std::unique_ptr<ASTNode>& object,
                   const std::string& methodName,
                   const std::vector<std::unique_ptr<ASTNode>>& arguments)
        : object(std::move(object)), methodName(methodName) {
        nodeType = ASTNodeType::METHOD_CALL;
        for (const auto& arg : arguments) {
            this->arguments.push_back(arg->clone());
        }
	}

    std::unique_ptr<ASTNode> object;  // 메서드를 호출하는 객체
    std::string methodName;
    std::vector<std::unique_ptr<ASTNode>> arguments;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override;
    std::unique_ptr<ASTNode> clone() override {
		return std::make_unique<MethodCallNode>(this);
	}
};