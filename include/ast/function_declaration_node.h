#pragma once
#include "ast_node.h"
#include "parameter_node.h"
#include "block_node.h"
#include <string>
#include <vector>

class FunctionDeclarationNode : public ASTNode {
public:
    FunctionDeclarationNode();
    
    std::string name;
    std::vector<std::shared_ptr<ParameterNode>> parameters;
    std::shared_ptr<Type> returnType;
    std::shared_ptr<BlockNode> body;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
}; 