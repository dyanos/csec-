#include "MethodCallNode.h"
#include "ASTVisitor.h"

#include <iostream>

#include "FunctionDeclarationNode.h"

void MethodCallNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* MethodCallNode::codegen() {
    // 객체의 값을 생성
    llvm::Value* objectValue = object->codegen();
    if (!objectValue) {
        return nullptr;
    }

    // 객체의 타입 가져오기
    std::shared_ptr<Type> objectType = object->getType();
    if (!objectType || objectType->getKind() != Type::Kind::CLASS) {
        std::cerr << "Error: Method call on non-class type" << std::endl;
        return nullptr;
    }

    // 클래스 심볼 가져오기
    auto symbol = codeGenerator->symbolTable.lookupClass(objectType->getName());
    if (!symbol) {
        std::cerr << "Error: Undefined class type '" << objectType->getName() << "'" << std::endl;
        return nullptr;
    }

    ClassSymbol* classSymbol = (*symbol);

    // 메서드 룩업
    auto methodSymbolOpt = codeGenerator->symbolTable.lookupMethod(*classSymbol, methodName);
    if (!methodSymbolOpt) {
        std::cerr << "Error: Method '" << methodName << "' not found in class '" << objectType->getName() << "'" << std::endl;
        return nullptr;
    }

    auto methodSymbol = (*methodSymbolOpt);

    // 함수 타입과 LLVM 함수 가져오기
    auto funcType = std::dynamic_pointer_cast<FunctionType>(methodSymbol->type);
    llvm::Function* function = static_cast<llvm::Function*>(methodSymbol->value);
    if (!function) {
        auto symbol = codeGenerator->symbolTable.lookupClass(objectType->getName());
        if (!symbol) {
            std::cerr << "Error: Undefined class type '" << objectType->getName() << "'" << std::endl;
            return nullptr;
        }

        ClassSymbol* classSymbol = *symbol;
        if (classSymbol->methodBodies.find(methodName) == classSymbol->methodBodies.end()) {
            std::cerr << "Error: Method '" << methodName << "' not found in class '" << objectType->getName() << "'" << std::endl;
            return nullptr;
        }
        // 해당 method가 구현되어 있지 않다면, 구한다.
        auto method = classSymbol->methodBodies[methodName];
        method->codegen();
        function = codeGenerator->module->getFunction(methodName);
        methodSymbol->value = function;
        codeGenerator->symbolTable.addSymbol(methodName, methodSymbol);
    }

    if (!funcType || !function) {
        std::cerr << "Error: Invalid method '" << methodName << "' in class '" << objectType->getName() << "'" << std::endl;
        return nullptr;
    }

    // 인자 값 생성
    std::vector<llvm::Value*> argValues;
    // 첫 번째 인자로 객체 포인터 전달 (this 포인터)
    argValues.push_back(objectValue);

    if (arguments.size() + 1 != funcType->parameterTypes.size()) {
        std::cerr << "Error: Argument count mismatch in method call '" << methodName << "'" << std::endl;
        return nullptr;
    }

    for (size_t i = 0; i < arguments.size(); ++i) {
        llvm::Value* argValue = arguments[i]->codegen();
        if (!argValue) {
            return nullptr;
        }

        // 인자의 타입 검사
        auto expectedType = funcType->parameterTypes[i];
        std::shared_ptr<Type> actualType = arguments[i]->getType();
        if (!actualType->equals(expectedType)) {
            std::cerr << "Type error: Argument type mismatch in method call '" << methodName << "'" << std::endl;
            return nullptr;
        }

        argValues.push_back(argValue);
    }

    // 함수 호출 생성
    llvm::Value* result = codeGenerator->builder.CreateCall(function, argValues);
    return result;
}

std::shared_ptr<Type> MethodCallNode::getType() {
    // 메서드의 반환 타입을 반환
    if (type) return type;

    // 객체의 타입 가져오기
    std::shared_ptr<Type> objectType = object->getType();
    if (!objectType || objectType->getKind() != Type::Kind::CLASS) {
        type = std::make_shared<UnknownType>();
        return type;
    }

    // 클래스 심볼 가져오기
    auto classSymbolOpt = codeGenerator->symbolTable.lookupClass(objectType->getName());
    if (!classSymbolOpt) {
        type = std::make_shared<UnknownType>();
        return type;
    }

    auto classSymbol = *classSymbolOpt;

    // 메서드 룩업
    auto methodSymbolOpt = codeGenerator->symbolTable.lookupMethod(*classSymbol, methodName);
    if (!methodSymbolOpt) {
        type = std::make_shared<UnknownType>();
        return type;
    }

    auto methodSymbol = *methodSymbolOpt;

    // 함수 타입 가져오기
    auto funcType = std::dynamic_pointer_cast<FunctionType>(methodSymbol->type);
    if (funcType) {
        type = std::make_shared<Type>(*funcType->returnType);
        return type;
    }

    type = std::make_shared<UnknownType>();
    return type;
}