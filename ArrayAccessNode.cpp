#include "codegen.h"
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

    llvm::Type* elementType = CodeGenerator::getInstance().getLLVMType(getType().get());
    if (!elementType) {
        std::cerr << "Error: Invalid array element type" << std::endl;
        return nullptr;
    }

    // 요소 포인터 계산
    llvm::Value* elemPtr = CodeGenerator::getInstance().builder.CreateGEP(elementType, arrayValue, indexValue, "arrayelem");
    // 요소 로드
    return CodeGenerator::getInstance().builder.CreateLoad(elementType, elemPtr, "arrayload");
}
