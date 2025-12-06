#pragma once
#include "ast_node.h"
#include "parameter_node.h"
#include "class_body_node.h"
#include "../symbol.h"
#include <string>
#include <vector>

class ClassDeclarationNode : public ASTNode {
public:
    ClassDeclarationNode();
    
    std::string name;
    std::vector<std::shared_ptr<ParameterNode>> constructorParams;
    std::string superClassName;
    std::shared_ptr<ClassBodyNode> body;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    void declareMethod(FunctionDeclarationNode* method, ClassSymbol* classSymbol);
    std::shared_ptr<Type> getType() override;
}; 