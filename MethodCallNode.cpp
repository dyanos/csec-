#include "codegen.h"

#include "MethodCallNode.h"
#include "ASTVisitor.h"

#include <iostream>

#include "FunctionDeclarationNode.h"

void MethodCallNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* MethodCallNode::codegen() {
    llvm::Value* objectValue = this->object->codegen();
    if (!objectValue) {
        return nullptr;
    }

    auto typeValue = object->getType();
    auto* objectType = typeValue.get();
    if (!objectType || objectType->getKind() != Type::Kind::CLASS) {
        std::cerr << "Error: Method call on non-class type" << std::endl;
        return nullptr;
    }

    auto symbol = CodeGenerator::getInstance().symbolTable.lookupClass(objectType->getName());
    if (!symbol) {
        std::cerr << "Error: Undefined class type '" << objectType->getName() << "'" << std::endl;
        return nullptr;
    }

    ClassSymbol* classSymbol = symbol;

    auto methodSymbolOpt = CodeGenerator::getInstance().symbolTable.lookupMethod(*classSymbol, methodName);
    if (!methodSymbolOpt) {
        std::cerr << "Error: Method '" << methodName << "' not found in class '" << objectType->getName() << "'" << std::endl;
        return nullptr;
    }

    auto* methodSymbol = methodSymbolOpt;

    auto* funcType = dynamic_cast<FunctionType*>(methodSymbol->type.get());
    llvm::Function* function = static_cast<llvm::Function*>(methodSymbol->value);
    if (!function) {
        auto symbol = CodeGenerator::getInstance().symbolTable.lookupClass(objectType->getName());
        if (!symbol) {
            std::cerr << "Error: Undefined class type '" << objectType->getName() << "'" << std::endl;
            return nullptr;
        }

        ClassSymbol* classSymbol = symbol;
        if (classSymbol->methodBodies.find(methodName) == classSymbol->methodBodies.end()) {
            std::cerr << "Error: Method '" << methodName << "' not found in class '" << objectType->getName() << "'" << std::endl;
            return nullptr;
        }

        llvm::BasicBlock* savedBB = CodeGenerator::getInstance().builder.GetInsertBlock();
        classSymbol->methodBodies[methodName]->codegen();
        CodeGenerator::getInstance().builder.SetInsertPoint(savedBB);
        function = CodeGenerator::getInstance().module->getFunction(objectType->getName() + "_" + methodName);
        methodSymbol->value = function;
        CodeGenerator::getInstance().symbolTable.addSymbol(methodName, methodSymbol ? methodSymbol->clone() : nullptr);
    }

    if (!funcType || !function) {
        std::cerr << "Error: Invalid method '" << methodName << "' in class '" << objectType->getName() << "'" << std::endl;
        return nullptr;
    }

    std::vector<llvm::Value*> argValues;
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

        auto argType = arguments[i]->getType();
        if (!argType || !argType->equals(funcType->parameterTypes[i + 1])) {
            std::cerr << "Type error: Argument type mismatch in method call '" << methodName << "'" << std::endl;
            return nullptr;
        }

        argValues.push_back(argValue);
    }

    llvm::Value* result = CodeGenerator::getInstance().builder.CreateCall(function, argValues);
    return result;
}

std::unique_ptr<Type> MethodCallNode::getType() {
    if (type) return type->clone();

    auto trueObject = object->getType();
    auto* objectType = trueObject.get();
    if (!objectType || objectType->getKind() != Type::Kind::CLASS) {
        return std::make_unique<UnknownType>();
    }

    auto classSymbolOpt = CodeGenerator::getInstance().symbolTable.lookupClass(objectType->getName());
    if (!classSymbolOpt) {
        return std::make_unique<UnknownType>();
    }

    auto* classSymbol = classSymbolOpt;

    auto methodSymbolOpt = CodeGenerator::getInstance().symbolTable.lookupMethod(*classSymbol, methodName);
    if (!methodSymbolOpt) {
        return std::make_unique<UnknownType>();
    }

    auto* methodSymbol = methodSymbolOpt;

    auto* funcType = dynamic_cast<FunctionType*>(methodSymbol->type.get());
    if (funcType && funcType->returnType) {
        return funcType->returnType->clone();
    }

    return std::make_unique<UnknownType>();
}
