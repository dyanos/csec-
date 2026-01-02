#pragma once
#include "ast.h"

class VariableDeclarationNode : public ASTNode {
public:
    VariableDeclarationNode() {
        this->nodeType = ASTNodeType::VARIABLE_DECLARATION;
    }
    VariableDeclarationNode(const std::string& name,
                            std::unique_ptr<Type> type,
                            std::unique_ptr<ASTNode> initializer,
                            bool isMutable = false,
                            bool isField = false)
        : name(name),
          type(std::move(type)),
          initializer(std::move(initializer)),
          isMutable(isMutable),
          isField(isField) {
        this->nodeType = ASTNodeType::VARIABLE_DECLARATION;
	}
    VariableDeclarationNode(VariableDeclarationNode* other) {
        this->nodeType = ASTNodeType::VARIABLE_DECLARATION;
        this->name = other->name;
		if (other->type) {
            this->type = std::move(other->type);
		}
        if (other->initializer) {
            this->initializer = std::move(other->initializer);
        }
        this->isMutable = other->isMutable;
        this->isField = other->isField;
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
    std::unique_ptr<ASTNode> clone() override {
		return std::make_unique<VariableDeclarationNode>(this);
	}
};
