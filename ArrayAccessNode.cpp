#include "ArrayAccessNode.h"
#include "ASTVisitor.h"

#include <iostream>

void ArrayAccessNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ArrayAccessNode::codegen() {
    llvm::Value* arrayValue = array->codegen();
    llvm::Value* indexValue = index->codegen();
    if (!arrayValue || !indexValue) {
        return nullptr;
    }

    llvm::Type* elementType = codeGenerator->getLLVMType(getType().get());
    if (!elementType) {
        std::cerr << "Error: Invalid array element type" << std::endl;
        return nullptr;
    }

    // 요소 포인터 계산
    llvm::Value* elemPtr = codeGenerator->builder.CreateGEP(elementType, arrayValue, indexValue, "arrayelem");
    // 요소 로드
    return codeGenerator->builder.CreateLoad(elementType, elemPtr, "arrayload");
}
