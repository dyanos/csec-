#pragma once
#include "ast.h"
#include "ASTVisitor.h"

class ProgramNode : public ASTNode {
public:
    ProgramNode() {
        nodeType = ASTNodeType::PROGRAM;
    }
    ProgramNode(ProgramNode* other) {
        nodeType = other->nodeType;
        // 깊은 복사 수행
        for (const auto& stmt : other->statements) {
            statements.push_back(stmt->clone());
        }
	}
    ProgramNode(const std::vector<std::unique_ptr<ASTNode>>& stmts) {
        for (const auto& stmt : stmts) {
            statements.push_back(stmt->clone());
		}
        nodeType = ASTNodeType::PROGRAM;
	}

    std::vector<std::unique_ptr<ASTNode>> statements;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::unique_ptr<Type> getType() override {
        return std::make_unique<UnknownType>();
    }
    std::unique_ptr<ASTNode> clone() override {
        return std::make_unique<ProgramNode>(this);
	}
};