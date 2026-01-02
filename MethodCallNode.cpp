#include "codegen.h"

#include "MethodCallNode.h"
#include "ASTVisitor.h"

#include <iostream>

#include "FunctionDeclarationNode.h"

void MethodCallNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* MethodCallNode::codegen() {
    // ��ü�� ���� ����
    llvm::Value* objectValue = object->codegen();
    if (!objectValue) {
        return nullptr;
    }

    // ��ü�� Ÿ�� ��������
    auto* objectType = object->getType().get();
    if (!objectType || objectType->getKind() != Type::Kind::CLASS) {
        std::cerr << "Error: Method call on non-class type" << std::endl;
        return nullptr;
    }

    // Ŭ���� �ɺ� ��������
    auto symbol = CodeGenerator::getInstance().symbolTable.lookupClass(objectType->getName());
    if (!symbol) {
        std::cerr << "Error: Undefined class type '" << objectType->getName() << "'" << std::endl;
        return nullptr;
    }

    ClassSymbol* classSymbol = (*symbol);

    // �޼��� ���
    auto methodSymbolOpt = CodeGenerator::getInstance().symbolTable.lookupMethod(*classSymbol, methodName);
    if (!methodSymbolOpt) {
        std::cerr << "Error: Method '" << methodName << "' not found in class '" << objectType->getName() << "'" << std::endl;
        return nullptr;
    }

    auto methodSymbol = (*methodSymbolOpt);

    // �Լ� Ÿ�԰� LLVM �Լ� ��������
    auto funcType = (FunctionType*)(methodSymbol->type.get());
    llvm::Function* function = static_cast<llvm::Function*>(methodSymbol->value);
    if (!function) {
        auto symbol = CodeGenerator::getInstance().symbolTable.lookupClass(objectType->getName());
        if (!symbol) {
            std::cerr << "Error: Undefined class type '" << objectType->getName() << "'" << std::endl;
            return nullptr;
        }

        ClassSymbol* classSymbol = *symbol;
        if (classSymbol->methodBodies.find(methodName) == classSymbol->methodBodies.end()) {
            std::cerr << "Error: Method '" << methodName << "' not found in class '" << objectType->getName() << "'" << std::endl;
            return nullptr;
        }
        // �ش� method�� �����Ǿ� ���� �ʴٸ�, ���Ѵ�.
        classSymbol->methodBodies[methodName]->codegen();
        function = CodeGenerator::getInstance().module->getFunction(methodName);
        methodSymbol->value = function;
        CodeGenerator::getInstance().symbolTable.addSymbol(methodName, methodSymbol);
    }

    if (!funcType || !function) {
        std::cerr << "Error: Invalid method '" << methodName << "' in class '" << objectType->getName() << "'" << std::endl;
        return nullptr;
    }

    // ���� �� ����
    std::vector<llvm::Value*> argValues;
    // ù ��° ���ڷ� ��ü ������ ���� (this ������)
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

        // ������ Ÿ�� �˻�
        if (!arguments[i]->getType()->equals(funcType->parameterTypes[i])) {
            std::cerr << "Type error: Argument type mismatch in method call '" << methodName << "'" << std::endl;
            return nullptr;
        }

        argValues.push_back(argValue);
    }

    // �Լ� ȣ�� ����
    llvm::Value* result = CodeGenerator::getInstance().builder.CreateCall(function, argValues);
    return result;
}

std::unique_ptr<Type> MethodCallNode::getType() {
    // �޼����� ��ȯ Ÿ���� ��ȯ
    if (type) return type->clone();

    // ��ü�� Ÿ�� ��������
    auto* objectType = object->getType().get();
    if (!objectType || objectType->getKind() != Type::Kind::CLASS) {
        return std::make_unique<UnknownType>();
    }

    // Ŭ���� �ɺ� ��������
    auto classSymbolOpt = CodeGenerator::getInstance().symbolTable.lookupClass(objectType->getName());
    if (!classSymbolOpt) {
        return std::make_unique<UnknownType>();
    }

    auto classSymbol = *classSymbolOpt;

    // �޼��� ���
    auto methodSymbolOpt = CodeGenerator::getInstance().symbolTable.lookupMethod(*classSymbol, methodName);
    if (!methodSymbolOpt) {
        return std::make_unique<UnknownType>();
    }

    auto methodSymbol = *methodSymbolOpt;

    // �Լ� Ÿ�� ��������
    auto funcType = (FunctionType*)(methodSymbol->type.get());
    if (funcType) {
        return funcType->returnType->clone();
    }

    return std::make_unique<UnknownType>();
}