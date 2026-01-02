#pragma once
#include "ast.h"

class ImportNode : public ASTNode {
public:
    ImportNode() {
        nodeType = ASTNodeType::IMPORT;
    }
    ImportNode(std::vector<std::string> path) {
        this->path.clear();
        for (auto p : path) {
            this->path.push_back(p);
        }
        nodeType = ASTNodeType::IMPORT;
    }
    ImportNode(ImportNode* other) {
        this->path.clear();
        for (auto p : other->path) {
            this->path.push_back(p);
        }
        nodeType = ASTNodeType::IMPORT;
    }

    std::vector<std::string> path;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::unique_ptr<Type> getType() override {
        return std::make_unique<UnknownType>();
    }
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<ImportNode>(this);
    }
};