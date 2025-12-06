#include "../../include/ast/parameter_node.h"
#include "../../include/ast/ast_visitor.h"
#include <iostream>

ParameterNode::ParameterNode() {
    nodeType = ASTNodeType::PARAMETER;
}

void ParameterNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ParameterNode::codegen() {
    // 함수의 Parameter는 local변수로 처리
    llvm::Type* paramType = codeGenerator->getLLVMType(type);
    if (!paramType) {
        std::cerr << "Error: Unsupported parameter type '" << type->name << "' in function '" << name << "'" << std::endl;
        return nullptr;
    }

    auto symbol = codeGenerator->symbolTable.lookup(name);
    return symbol->value;
}

std::shared_ptr<Type> ParameterNode::getType() {
    return type;
} 