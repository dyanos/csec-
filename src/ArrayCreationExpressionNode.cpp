#include "codegen.h"
#include "ArrayCreationExpressionNode.h"
#include "ASTVisitor.h"

#include <iostream>
#include "utils.h"

void ArrayCreationExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ArrayCreationExpressionNode::codegen() {
    // sizes로 배열 크기를 받아서 처리하는데 이들은 4차원이 최대이므로, 이들을 곱한다.
    llvm::Value* array_size = sizes[0]->codegen();
    for (int i = 1; i < sizes.size(); i++) {
        array_size = CodeGenerator::getInstance().builder.CreateMul(array_size, sizes[i]->codegen());
    }

    // primitive type인지, class type인지 확인, template type인지 확인
    if (isPrimitiveType(typeName)) {
		BasicType basicType(typeName);
        llvm::Type* type = CodeGenerator::getInstance().getLLVMType(&basicType);
        return CodeGenerator::getInstance().builder.CreateAlloca(type, array_size, typeName);
    }

    // Template Class인지 확인은 나중에 코드 추가되면...

    // 클래스 심볼 찾기
    auto classSymbolOpt = CodeGenerator::getInstance().symbolTable.lookupClass(typeName);
    if (!classSymbolOpt) {
        std::cerr << "Error: Class '" << typeName << "' not found" << std::endl;
        return nullptr;
    }

    auto* classSymbol = classSymbolOpt;

    // 클래스 타입 가져오기
    auto* classType = static_cast<llvm::StructType*>(classSymbol->classType);

    // 메모리 할당
    llvm::Value* allocatedMemory = CodeGenerator::getInstance().builder.CreateAlloca(classType, array_size, typeName);

    // 객체 초기화 (생성자 호출)
    std::string constructorName = typeName + "_constructor";
    llvm::Function* constructorFunc = CodeGenerator::getInstance().module->getFunction(constructorName);
    if (constructorFunc) {
        std::vector<llvm::Value*> constructorArgs = { allocatedMemory };
        for (auto& arg : sizes) {
            constructorArgs.push_back(arg->codegen());
        }
        CodeGenerator::getInstance().builder.CreateCall(constructorFunc, constructorArgs);
    }
    else {
        std::cerr << "Warning: Constructor for class '" << typeName << "' not found" << std::endl;
    }

    return allocatedMemory;
}

std::unique_ptr<Type> ArrayCreationExpressionNode::getType() {
    std::vector<std::unique_ptr<Type>> typeArgs;
    typeArgs.push_back(std::make_unique<BasicType>(typeName));
    std::unique_ptr<Type> baseType = std::make_unique<ClassType>("Array");
    return std::make_unique<GenericType>(baseType, typeArgs);
}
