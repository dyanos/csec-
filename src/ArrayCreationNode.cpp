#include "codegen.h"
#include "ArrayCreationNode.h"
#include "ASTVisitor.h"

#include <iostream>
#include <llvm/IR/Function.h>
#include <llvm/IR/Constants.h>

void ArrayCreationNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ArrayCreationNode::codegen() {
    // 요소 타입의 LLVM 타입 가져오기
    llvm::Type* elementType = CodeGenerator::getInstance().getLLVMType(arrayType->typeArguments[0].get());
    if (!elementType) {
        std::cerr << "Error: Invalid array element type" << std::endl;
        return nullptr;
    }

    // 배열 크기 결정
    llvm::Value* arraySize = CodeGenerator::getInstance().builder.getInt32(elements.size());

    // 메모리 할당 (malloc 등 사용)
    llvm::Function* mallocFunc = llvm::Function::Create(
        llvm::FunctionType::get(
            llvm::PointerType::getUnqual(llvm::Type::getInt8Ty(CodeGenerator::getInstance().context)),
            { llvm::Type::getInt64Ty(CodeGenerator::getInstance().context) },
            false
        ),
        llvm::Function::ExternalLinkage,
        "malloc",
        CodeGenerator::getInstance().module.get()
    );

    llvm::Value* totalSize = CodeGenerator::getInstance().builder.CreateMul(
        CodeGenerator::getInstance().builder.CreateZExt(arraySize, llvm::Type::getInt64Ty(CodeGenerator::getInstance().context)),
        llvm::ConstantInt::get(llvm::Type::getInt64Ty(CodeGenerator::getInstance().context), CodeGenerator::getInstance().module->getDataLayout().getTypeAllocSize(elementType))
    );

    llvm::Value* rawPtr = CodeGenerator::getInstance().builder.CreateCall(mallocFunc, { totalSize }, "malloccall");
    llvm::Value* arrayPtr = CodeGenerator::getInstance().builder.CreateBitCast(rawPtr, llvm::PointerType::getUnqual(elementType));

    // 배열 요소 초기화
    for (size_t i = 0; i < elements.size(); ++i) {
        llvm::Value* elemValue = elements[i]->codegen();
        if (!elemValue) {
            return nullptr;
        }
        llvm::Value* index = llvm::ConstantInt::get(CodeGenerator::getInstance().builder.getInt32Ty(), i);
        llvm::Value* elemPtr = CodeGenerator::getInstance().builder.CreateGEP(elementType, arrayPtr, index);
        CodeGenerator::getInstance().builder.CreateStore(elemValue, elemPtr);
    }

    return arrayPtr;
}