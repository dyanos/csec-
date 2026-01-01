#pragma once
#include "ast.h"
#include "symbol.h"

#include "FunctionDeclarationNode.h"
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

    std::unique_ptr<Type> getType() override {
        return std::make_unique<UnknownType>();
    }
};