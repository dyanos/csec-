#include "codegen.h"

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
    auto functionSymbolOpt = CodeGenerator::getInstance().symbolTable.lookupFunction(functionName, argTypes);
    if (functionSymbolOpt) {
        auto functionSymbol = *functionSymbolOpt;
        // 함수 타입과 LLVM 함수 가져오기
        auto funcType = (FunctionType*)(functionSymbol->type.get());
        llvm::Function* function = static_cast<llvm::Function*>(functionSymbol->value);
        if (!funcType || !function) {
            std::cerr << "Error: Invalid function '" << functionName << "'" << std::endl;
            return nullptr;
        }

        // 함수 호출 생성
        llvm::Value* result = CodeGenerator::getInstance().builder.CreateCall(function, argValues, "calltmp");

        // 타입 설정
        type = std::make_unique<Type>(*funcType->returnType);
        return result;
    }
    else {
        llvm::Function* function = CodeGenerator::getInstance().module->getFunction(functionName);
        if (function) {
            llvm::Value* result = CodeGenerator::getInstance().builder.CreateCall(function, argValues, "calltmp");
            return result;
        }
        else {
            std::cerr << "Error: Not found function name '" << functionName << "'" << std::endl;
            return nullptr;
        }
    }
}

std::unique_ptr<Type> FunctionCallNode::getType() {
    if (type) return std::make_unique<Type>(type.get());

    // 함수 심볼 찾기
    std::vector<std::shared_ptr<Type>> argTypes;
    for (auto& arg : arguments) {
        argTypes.push_back(arg->getType());
    }

    auto functionSymbolOpt = CodeGenerator::getInstance().symbolTable.lookupFunction(functionName, argTypes);
    if (!functionSymbolOpt) {
        printf("functionSymbolOpt is nullopt");
        return std::make_unique<UnknownType>();
    }

    auto functionSymbol = (FunctionSymbol*)*functionSymbolOpt;

    auto funcType = (FunctionType*)(functionSymbol->type.get());
    if (funcType) {
        return std::make_unique<Type>(funcType->returnType.get());
    }

    return std::make_unique<UnknownType>();
}