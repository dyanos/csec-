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
    ImportNode(const ImportNode& other) : path(other.path) {
        nodeType = ASTNodeType::IMPORT;
    }
    ImportNode& operator=(const ImportNode& other) {
        if (this != &other) {
            path = other.path;
            nodeType = ASTNodeType::IMPORT;
        }
        return *this;
    }

    std::vector<std::string> path;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    std::unique_ptr<Type> getType() override {
        return std::make_unique<UnknownType>();
    }
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<ImportNode>(*this);
    }
};
