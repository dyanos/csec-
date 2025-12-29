#pragma once
#include "ast.h"
#include "ParameterNode.h"
#include "ClassBodyNode.h"

class ClassDeclarationNode : public ASTNode {
public:
    ClassDeclarationNode() {
        nodeType = ASTNodeType::CLASS_DECLARATION;
    }

    std::string name;
    std::vector<std::shared_ptr<ParameterNode>> constructorParams;
    std::string superClassName;
    std::shared_ptr<ClassBodyNode> body;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;

    void declareMethod(FunctionDeclarationNode* method, ClassSymbol* classSymbol);

    std::shared_ptr<Type> getType() override {
        return nullptr;
    }
};