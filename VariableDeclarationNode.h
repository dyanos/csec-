#pragma once
#include "ast.h"

class VariableDeclarationNode : public ASTNode {
public:
    VariableDeclarationNode() {
        this->nodeType = ASTNodeType::VARIABLE_DECLARATION;
    }

    std::string name;
    std::unique_ptr<Type> type;
    std::unique_ptr<ASTNode> initializer;
    bool isMutable = false;
    bool isField = false;   // 클래스 필드인지 여부

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::unique_ptr<Type> getType() override {
        return std::make_unique<UnknownType>();
    }
};
