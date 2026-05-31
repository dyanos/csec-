#include "codegen.h"

#include "MethodCallNode.h"
#include "ASTVisitor.h"
#include "IdentifierNode.h"

#include <iostream>
#include <sstream>
#include <llvm/IR/Constants.h>

#include "FunctionDeclarationNode.h"

namespace {
llvm::Value* defaultValueForType(llvm::Type* type) {
    auto& cg = CodeGenerator::getInstance();
    if (!type || type->isVoidTy()) {
        return nullptr;
    }
    if (type->isIntegerTy()) {
        return llvm::ConstantInt::get(type, 0, true);
    }
    if (type->isFloatingPointTy()) {
        return llvm::ConstantFP::get(type, 0.0);
    }
    if (type->isPointerTy()) {
        return llvm::ConstantPointerNull::get(llvm::cast<llvm::PointerType>(type));
    }
    return llvm::Constant::getNullValue(type);
}

llvm::Value* coerceArgumentValue(llvm::Value* value, llvm::Type* targetType) {
    if (!value || !targetType) {
        return value;
    }

    auto& cg = CodeGenerator::getInstance();
    llvm::Type* sourceType = value->getType();
    if (sourceType == targetType) {
        return value;
    }

    if (sourceType->isIntegerTy() && targetType->isIntegerTy()) {
        unsigned srcBits = sourceType->getIntegerBitWidth();
        unsigned dstBits = targetType->getIntegerBitWidth();
        if (srcBits < dstBits) {
            return cg.builder.CreateSExt(value, targetType, "method.arg.sext");
        }
        return cg.builder.CreateTrunc(value, targetType, "method.arg.trunc");
    }

    if (sourceType->isFloatingPointTy() && targetType->isFloatingPointTy()) {
        return cg.builder.CreateFPCast(value, targetType, "method.arg.fpcast");
    }

    if (sourceType->isIntegerTy() && targetType->isFloatingPointTy()) {
        return cg.builder.CreateSIToFP(value, targetType, "method.arg.sitofp");
    }

    if (sourceType->isFloatingPointTy() && targetType->isIntegerTy()) {
        return cg.builder.CreateFPToSI(value, targetType, "method.arg.fptosi");
    }

    if (sourceType->isPointerTy() && targetType->isPointerTy()) {
        return cg.builder.CreateBitCast(value, targetType, "method.arg.bitcast");
    }

    return value;
}

llvm::Value* createMethodCallOrDefault(llvm::Function* function, std::vector<llvm::Value*> argValues) {
    auto& cg = CodeGenerator::getInstance();
    if (!function || argValues.size() != function->arg_size()) {
        return function ? defaultValueForType(function->getReturnType()) : nullptr;
    }

    std::vector<llvm::Value*> adjustedArgs;
    adjustedArgs.reserve(argValues.size());
    for (size_t i = 0; i < argValues.size(); ++i) {
        adjustedArgs.push_back(coerceArgumentValue(
            argValues[i],
            function->getFunctionType()->getParamType(static_cast<unsigned>(i))));
        if (adjustedArgs.back()->getType() != function->getFunctionType()->getParamType(static_cast<unsigned>(i))) {
            return defaultValueForType(function->getReturnType());
        }
    }

    return cg.builder.CreateCall(function, adjustedArgs, function->getReturnType()->isVoidTy() ? "" : "calltmp");
}

bool canPassValueToParameter(llvm::Value* value, llvm::Type* parameterType) {
    if (!value || !parameterType) {
        return false;
    }
    llvm::Type* valueType = value->getType();
    if (valueType == parameterType) {
        return true;
    }
    if (valueType->isIntegerTy() && parameterType->isIntegerTy()) {
        return true;
    }
    if (valueType->isFloatingPointTy() && parameterType->isFloatingPointTy()) {
        return true;
    }
    if (valueType->isIntegerTy() && parameterType->isFloatingPointTy()) {
        return true;
    }
    if (valueType->isFloatingPointTy() && parameterType->isIntegerTy()) {
        return true;
    }
    if (valueType->isPointerTy() && parameterType->isPointerTy()) {
        return true;
    }
    return false;
}

llvm::Function* findNamespacedFunctionByArgs(CodeGenerator& cg, const std::string& namespaceName, const std::string& methodName, const std::vector<llvm::Value*>& argValues) {
    const std::string baseName = namespaceName + "#" + methodName;
    llvm::Function* coercibleMatch = nullptr;
    for (auto& function : cg.module->functions()) {
        std::string functionName = function.getName().str();
        if (functionName != baseName && functionName.rfind(baseName + ".", 0) != 0) {
            continue;
        }
        if (function.arg_size() != argValues.size()) {
            continue;
        }

        bool exact = true;
        bool matches = true;
        for (size_t i = 0; i < argValues.size(); ++i) {
            auto* parameterType = function.getFunctionType()->getParamType(static_cast<unsigned>(i));
            if (argValues[i]->getType() != parameterType) {
                exact = false;
            }
            if (!canPassValueToParameter(argValues[i], parameterType)) {
                matches = false;
                break;
            }
        }
        if (matches && exact) {
            return &function;
        }
        if (matches && !coercibleMatch) {
            coercibleMatch = &function;
        }
    }
    return coercibleMatch;
}

std::string methodStorageKey(const std::string& methodName, const std::vector<std::unique_ptr<Type>>& argTypes) {
    if (argTypes.empty()) {
        return methodName;
    }

    std::ostringstream key;
    key << methodName;
    for (const auto& argType : argTypes) {
        key << "@" << (argType ? argType->getName() : "Unknown");
    }
    return key.str();
}
}

void MethodCallNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* MethodCallNode::codegen() {
    auto& cg = CodeGenerator::getInstance();

    if (auto* objectId = dynamic_cast<IdentifierNode*>(object.get())) {
        std::string qualifiedName = objectId->value + "." + methodName;
        std::vector<std::unique_ptr<Type>> argTypes;
        argTypes.reserve(arguments.size());
        for (auto& argument : arguments) {
            auto argType = argument->getType();
            argTypes.push_back(argType ? argType->clone() : std::make_unique<UnknownType>());
        }

        auto* functionSymbol = cg.symbolTable.lookupFunctionInNamespace(objectId->value, methodName, argTypes);
        Symbol* memberSymbol = functionSymbol ? static_cast<Symbol*>(functionSymbol) : cg.symbolTable.lookup(qualifiedName);
        if (memberSymbol && memberSymbol->symbolType == SymbolType::FUNCTION) {
            auto* funcType = dynamic_cast<FunctionType*>(memberSymbol->type.get());
            llvm::Function* function = static_cast<llvm::Function*>(memberSymbol->value);
            if (!function) {
                function = cg.module->getFunction(objectId->value + "#" + methodName);
            }
            if (!function) {
                function = cg.module->getFunction("_" + methodName);
            }
            if (!funcType || !function) {
                std::cerr << "Error: Invalid namespaced function '" << qualifiedName << "'" << std::endl;
                return nullptr;
            }

            std::vector<llvm::Value*> argValues;
            for (size_t i = 0; i < arguments.size(); ++i) {
                llvm::Value* argValue = arguments[i]->codegen();
                if (!argValue) {
                    return nullptr;
                }
                if (functionSymbol && i < funcType->parameterTypes.size()) {
                    if (argTypes[i] && !argTypes[i]->equals(funcType->parameterTypes[i]) &&
                        !argTypes[i]->isSubtypeOf(funcType->parameterTypes[i])) {
                        std::cerr << "Type error: Argument type mismatch in method call '" << methodName << "'" << std::endl;
                        return nullptr;
                    }
                }
                argValues.push_back(argValue);
            }

            if (!functionSymbol) {
                if (auto* overloadedFunction = findNamespacedFunctionByArgs(cg, objectId->value, methodName, argValues)) {
                    function = overloadedFunction;
                }
            }

            return createMethodCallOrDefault(function, std::move(argValues));
        }
    }

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

    auto symbol = cg.symbolTable.lookupClass(objectType->getName());
    if (!symbol) {
        std::cerr << "Error: Undefined class type '" << objectType->getName() << "'" << std::endl;
        return nullptr;
    }

    ClassSymbol* classSymbol = symbol;

    std::vector<std::unique_ptr<Type>> callArgTypes;
    callArgTypes.reserve(arguments.size());
    for (auto& argument : arguments) {
        auto argType = argument->getType();
        callArgTypes.push_back(argType ? argType->clone() : std::make_unique<UnknownType>());
    }

    auto methodSymbolOpt = cg.symbolTable.lookupMethod(*classSymbol, methodName, callArgTypes);
    if (!methodSymbolOpt) {
        std::cerr << "Error: Method '" << methodName << "' not found in class '" << objectType->getName() << "'" << std::endl;
        return nullptr;
    }

    auto* methodSymbol = methodSymbolOpt;

    auto* funcType = dynamic_cast<FunctionType*>(methodSymbol->type.get());
    llvm::Function* function = static_cast<llvm::Function*>(methodSymbol->value);
    if (!function) {
        auto symbol = cg.symbolTable.lookupClass(objectType->getName());
        if (!symbol) {
            std::cerr << "Error: Undefined class type '" << objectType->getName() << "'" << std::endl;
            return nullptr;
        }

        ClassSymbol* classSymbol = symbol;
        std::string storageKey = methodStorageKey(methodName, callArgTypes);
        if (classSymbol->methodBodies.find(storageKey) == classSymbol->methodBodies.end()) {
            std::cerr << "Error: Method '" << methodName << "' not found in class '" << objectType->getName() << "'" << std::endl;
            return nullptr;
        }

        llvm::BasicBlock* savedBB = cg.builder.GetInsertBlock();
        classSymbol->methodBodies[storageKey]->codegen();
        cg.builder.SetInsertPoint(savedBB);
        function = cg.module->getFunction(objectType->getName() + "_" + methodName);
        methodSymbol->value = function;
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
        if (!argType || (!argType->equals(funcType->parameterTypes[i + 1]) && !argType->isSubtypeOf(funcType->parameterTypes[i + 1]))) {
            std::cerr << "Type error: Argument type mismatch in method call '" << methodName << "'" << std::endl;
            return nullptr;
        }

        argValues.push_back(argValue);
    }

    llvm::Value* result = createMethodCallOrDefault(function, std::move(argValues));
    return result;
}

std::unique_ptr<Type> MethodCallNode::getType() {
    if (type) return type->clone();

    if (auto* objectId = dynamic_cast<IdentifierNode*>(object.get())) {
        std::vector<std::unique_ptr<Type>> argTypes;
        argTypes.reserve(arguments.size());
        for (auto& argument : arguments) {
            auto argType = argument->getType();
            argTypes.push_back(argType ? argType->clone() : std::make_unique<UnknownType>());
        }

        auto* functionSymbol = CodeGenerator::getInstance().symbolTable.lookupFunctionInNamespace(objectId->value, methodName, argTypes);
        Symbol* memberSymbol = functionSymbol ? static_cast<Symbol*>(functionSymbol) :
            CodeGenerator::getInstance().symbolTable.lookup(objectId->value + "." + methodName);
        if (memberSymbol && memberSymbol->symbolType == SymbolType::FUNCTION) {
            auto* funcType = dynamic_cast<FunctionType*>(memberSymbol->type.get());
            if (funcType && funcType->returnType) {
                return funcType->returnType->clone();
            }
        }
    }

    auto trueObject = object->getType();
    auto* objectType = trueObject.get();
    if (!objectType || objectType->getKind() != Type::Kind::CLASS) {
        return std::make_unique<BasicType>("Real");
    }

    auto classSymbolOpt = CodeGenerator::getInstance().symbolTable.lookupClass(objectType->getName());
    if (!classSymbolOpt) {
        return std::make_unique<BasicType>("Real");
    }

    auto* classSymbol = classSymbolOpt;

    std::vector<std::unique_ptr<Type>> callArgTypes;
    callArgTypes.reserve(arguments.size());
    for (auto& argument : arguments) {
        auto argType = argument->getType();
        callArgTypes.push_back(argType ? argType->clone() : std::make_unique<UnknownType>());
    }

    auto methodSymbolOpt = CodeGenerator::getInstance().symbolTable.lookupMethod(*classSymbol, methodName, callArgTypes);
    if (!methodSymbolOpt) {
        return std::make_unique<BasicType>("Real");
    }

    auto* methodSymbol = methodSymbolOpt;

    auto* funcType = dynamic_cast<FunctionType*>(methodSymbol->type.get());
    if (funcType && funcType->returnType) {
        return funcType->returnType->clone();
    }

    return std::make_unique<BasicType>("Real");
}
