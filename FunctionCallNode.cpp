#include "codegen.h"

#include "FunctionCallNode.h"
#include "ASTVisitor.h"

#include <iostream>
#include <llvm/IR/Function.h>

void FunctionCallNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* FunctionCallNode::codegen() {
    // ���� �� ���� �� Ÿ�� ����
    std::vector<llvm::Value*> argValues;
    std::vector<std::unique_ptr<Type>> argTypes;
    for (auto& arg : arguments) {
        llvm::Value* argValue = arg->codegen();
        if (!argValue) {
            return nullptr;
        }
        argValues.push_back(argValue);
        argTypes.push_back(arg->getType()->clone());
    }

    // �Լ� �ɺ� ã��
    auto functionSymbolOpt = CodeGenerator::getInstance().symbolTable.lookupFunction(functionName, argTypes);
    if (functionSymbolOpt) {
        auto* functionSymbol = functionSymbolOpt;
        // �Լ� Ÿ�԰� LLVM �Լ� ��������
        auto* funcType = dynamic_cast<FunctionType*>(functionSymbol->type.get());
        llvm::Function* function = static_cast<llvm::Function*>(functionSymbol->value);
        if (!funcType || !function) {
            std::cerr << "Error: Invalid function '" << functionName << "'" << std::endl;
            return nullptr;
        }

        // �Լ� ȣ�� ����
        llvm::Value* result = CodeGenerator::getInstance().builder.CreateCall(function, argValues, "calltmp");

        // Ÿ�� ����
        type = funcType->returnType ? funcType->returnType->clone() : std::make_unique<UnknownType>();
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
    if (type) return type->clone();

    // �Լ� �ɺ� ã��
    std::vector<std::unique_ptr<Type>> argTypes;
    for (auto& arg : arguments) {
        argTypes.push_back(arg->getType()->clone());
    }

    auto functionSymbolOpt = CodeGenerator::getInstance().symbolTable.lookupFunction(functionName, argTypes);
    if (!functionSymbolOpt) {
        std::cerr << "Error: Function '" << functionName << "' not found" << std::endl;
        return std::make_unique<UnknownType>();
    }

    auto* functionSymbol = functionSymbolOpt;

    auto* funcType = dynamic_cast<FunctionType*>(functionSymbol->type.get());
    if (funcType && funcType->returnType) {
        return funcType->returnType->clone();
    }

    return std::make_unique<UnknownType>();
}
