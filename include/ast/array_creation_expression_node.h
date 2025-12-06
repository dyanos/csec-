#pragma once
#include "ast_node.h"
#include <string>
#include <vector>

class ArrayCreationExpressionNode : public ExpressionNode {
public:
    ArrayCreationExpressionNode();
    ArrayCreationExpressionNode(const std::string& typeName, const std::vector<std::shared_ptr<ASTNode>>& sizes);
    
    std::string typeName;
    std::vector<std::shared_ptr<ASTNode>> sizes;

    void accept(ASTVisitor& visitor) override;
    llvm::Value* codegen() override;
    std::shared_ptr<Type> getType() override;
}; 