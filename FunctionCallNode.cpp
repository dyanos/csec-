#include "FunctionCallNode.h"
#include "ASTVisitor.h"

#include <iostream>
#include <llvm/IR/Function.h>

void FunctionCallNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* FunctionCallNode::codegen() {
    // 인자 값 생성 및 타입 수집
    std::vector<llvm::Value*> argValues;
    std::vector<std::shared_ptr<Type>> argTypes;
    for (auto& arg : arguments) {
        llvm::Value* argValue = arg->codegen();
        if (!argValue) {
            return nullptr;
        }
        argValues.push_back(argValue);
        argTypes.push_back(arg->getType());
    }

    // 함수 심볼 찾기
    auto functionSymbolOpt = codeGenerator->symbolTable.lookupFunction(functionName, argTypes);
    if (functionSymbolOpt) {
        auto functionSymbol = *functionSymbolOpt;
        // 함수 타입과 LLVM 함수 가져오기
        auto funcType = std::dynamic_pointer_cast<FunctionType>(functionSymbol->type);
        llvm::Function* function = static_cast<llvm::Function*>(functionSymbol->value);
        if (!funcType || !function) {
            std::cerr << "Error: Invalid function '" << functionName << "'" << std::endl;
            return nullptr;
        }

        // 함수 호출 생성
        llvm::Value* result = codeGenerator->builder.CreateCall(function, argValues, "calltmp");

        // 타입 설정
        type = std::make_shared<Type>(*funcType->returnType);
        return result;
    }
    else {
        llvm::Function* function = codeGenerator->module->getFunction(functionName);
        if (function) {
            llvm::Value* result = codeGenerator->builder.CreateCall(function, argValues, "calltmp");
            return result;
        }
        else {
            std::cerr << "Error: Not found function name '" << functionName << "'" << std::endl;
            return nullptr;
        }
    }
}

std::shared_ptr<Type> FunctionCallNode::getType() {
    if (type) return type;

    // 함수 심볼 찾기
    std::vector<std::shared_ptr<Type>> argTypes;
    for (auto& arg : arguments) {
        argTypes.push_back(arg->getType());
    }

    auto functionSymbolOpt = codeGenerator->symbolTable.lookupFunction(functionName, argTypes);
    if (!functionSymbolOpt) {
        printf("functionSymbolOpt is nullopt");
        type = std::make_shared<UnknownType>();
        return type;
    }

    auto functionSymbol = *functionSymbolOpt;

    auto funcType = std::dynamic_pointer_cast<FunctionType>(functionSymbol->type);
    if (funcType) {
        type = std::make_shared<Type>(*funcType->returnType);
        return type;
    }

    type = std::make_shared<UnknownType>();
    return type;
}