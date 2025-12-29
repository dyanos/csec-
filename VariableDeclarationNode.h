#pragma once
#include "ast.h"

class VariableDeclarationNode : public ASTNode {
public:
    VariableDeclarationNode() {
        nodeType = ASTNodeType::VARIABLE_DECLARATION;
    }

    std::string name;
    std::shared_ptr<Type> type;
    std::shared_ptr<ASTNode> initializer;
    bool isMutable;
    bool isField = false;   // 클래스 필드인지 여부

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::shared_ptr<Type> getType() override {
        return nullptr;
    }
};
