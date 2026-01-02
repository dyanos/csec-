#pragma once
#include "ast.h"

class FunctionCallNode : public ASTNode {
public:
    FunctionCallNode() {
        this->nodeType = ASTNodeType::FUNCTION_CALL;
        this->functionName = "";
    }
    FunctionCallNode(FunctionCallNode* other) {
        this->nodeType = other->nodeType;
        this->functionName = other->functionName;
        for (const auto& arg : other->arguments) {
            this->arguments.push_back(arg->clone());
        }
	}

    std::string functionName;
    std::vector<std::unique_ptr<ASTNode>> arguments;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override;
    std::unique_ptr<ASTNode> clone() override {
		return std::make_unique<FunctionCallNode>(this);
    }
};