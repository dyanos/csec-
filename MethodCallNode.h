#pragma once
#include "ast.h"


class MethodCallNode : public ASTNode {
public:
    MethodCallNode() {
        nodeType = ASTNodeType::METHOD_CALL;
    }

    std::shared_ptr<ASTNode> object;  // 메서드를 호출하는 객체
    std::string methodName;
    std::vector<std::shared_ptr<ASTNode>> arguments;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
};