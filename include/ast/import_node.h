#pragma once
#include "ast_node.h"
#include <string>
#include <vector>

class ImportNode : public ASTNode {
public:
    ImportNode();
    std::vector<std::string> path;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
}; 