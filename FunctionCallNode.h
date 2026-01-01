#pragma once
#include "ast.h"

class FunctionCallNode : public ASTNode {
public:
    FunctionCallNode() {
        this->nodeType = ASTNodeType::FUNCTION_CALL;
        this->functionName = "";
        this->arguments = {};
    }

    std::string functionName;
    std::vector<std::shared_ptr<ASTNode>> arguments;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override;
};