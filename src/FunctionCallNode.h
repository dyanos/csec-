#pragma once
#include "ast.h"

class FunctionCallNode : public ASTNode {
public:
    FunctionCallNode() {
        this->nodeType = ASTNodeType::FUNCTION_CALL;
        this->functionName = "";
    }
    FunctionCallNode(const FunctionCallNode& other) {
        this->nodeType = other.nodeType;
        this->functionName = other.functionName;
        for (const auto& arg : other.arguments) {
            this->arguments.push_back(arg ? arg->clone() : nullptr);
        }
        for (const auto& t : other.explicitTypeArgs) {
            this->explicitTypeArgs.push_back(t ? t->clone() : nullptr);
        }
	}
    FunctionCallNode& operator=(const FunctionCallNode& other) {
        if (this != &other) {
            this->nodeType = other.nodeType;
            this->functionName = other.functionName;
            this->arguments.clear();
            this->arguments.reserve(other.arguments.size());
            for (const auto& arg : other.arguments) {
                this->arguments.push_back(arg ? arg->clone() : nullptr);
            }
            this->explicitTypeArgs.clear();
            for (const auto& t : other.explicitTypeArgs) {
                this->explicitTypeArgs.push_back(t ? t->clone() : nullptr);
            }
        }
        return *this;
    }

    std::string functionName;
    std::vector<std::unique_ptr<ASTNode>> arguments;
    std::vector<std::unique_ptr<Type>> explicitTypeArgs;  // e.g. identity<Int>(42)

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override;
    std::unique_ptr<ASTNode> clone() override {
		return std::make_unique<FunctionCallNode>(*this);
    }
};
