#include "codegen.h"

#include "ParameterNode.h"
#include "ASTVisitor.h"

#include <iostream>


void ParameterNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ParameterNode::codegen() {
    // 함수의 Parameter는 local변수로 처리
    if (!type) {
        std::cerr << "Error: Parameter type is null for '" << name << "'" << std::endl;
        return nullptr;
    }

    llvm::Type* paramType = CodeGenerator::getInstance().getLLVMType(type.get());
    if (!paramType) {
        std::cerr << "Error: Unsupported parameter type '" << type->getName() << "' in parameter '" << name << "'" << std::endl;
        return nullptr;
    }

    auto symbol = CodeGenerator::getInstance().symbolTable.lookup(name);
    if (!symbol) {
        std::cerr << "Error: Symbol not found for parameter '" << name << "'" << std::endl;
        return nullptr;
    }

    return symbol ? symbol->value : nullptr;
}