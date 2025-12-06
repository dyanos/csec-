#pragma once
#include "ast_node.h"
#include "../type.h"
#include <vector>

class ArrayCreationNode : public ASTNode {
public:
    ArrayCreationNode();
    
    std::shared_ptr<GenericType> arrayType;
    std::vector<std::shared_ptr<ASTNode>> elements;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
}; 