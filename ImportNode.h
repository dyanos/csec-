#pragma once
#include "ast.h"

class ImportNode : public ASTNode {
public:
    ImportNode() {
        nodeType = ASTNodeType::IMPORT;
    }

    std::vector<std::string> path;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::shared_ptr<Type> getType() override {
        return nullptr;
    }
};