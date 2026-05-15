#include "codegen.h"

#include "FunctionCallNode.h"
#include "FunctionDeclarationNode.h"
#include "ParameterNode.h"
#include "ASTVisitor.h"

#include <iostream>
#include <llvm/IR/Function.h>

void FunctionCallNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

// Helper: substitute TypeVariableType in a FunctionDeclarationNode clone
static void substituteTypes(FunctionDeclarationNode* funcDecl,
                           const std::vector<std::string>& typeParams,
                           const std::vector<std::unique_ptr<Type>>& concreteTypes) {
    auto substitute = [&](std::unique_ptr<Type>& t) {
        if (!t) return;
        if (t->getKind() == Type::Kind::VARIABLE) {
            for (size_t i = 0; i < typeParams.size(); ++i) {
                if (t->getName() == typeParams[i]) {
                    t = concreteTypes[i]->clone();
                    return;
                }
            }
        }
    };

    // Substitute parameter types
    for (auto& param : funcDecl->parameters) {
        auto* paramNode = dynamic_cast<ParameterNode*>(param.get());
        if (paramNode) {
            substitute(paramNode->type);
        }
    }

    // Substitute return type
    substitute(funcDecl->returnType);
}

// Helper: infer concrete type from llvm::Value
static std::unique_ptr<Type> inferTypeFromLLVM(llvm::Value* val) {
    if (!val) return std::make_unique<UnknownType>();
    llvm::Type* t = val->getType();
    if (t->isIntegerTy(32)) return std::make_unique<BasicType>("Int");
    if (t->isIntegerTy(64)) return std::make_unique<BasicType>("Long");
    if (t->isIntegerTy(16)) return std::make_unique<BasicType>("Short");
    if (t->isIntegerTy(8)) return std::make_unique<BasicType>("Byte");
    if (t->isIntegerTy(1)) return std::make_unique<BasicType>("Boolean");
    if (t->isFloatTy()) return std::make_unique<BasicType>("Float");
    if (t->isDoubleTy()) return std::make_unique<BasicType>("Double");
    if (t->isPointerTy()) return std::make_unique<BasicType>("String");
    return std::make_unique<UnknownType>();
}

llvm::Value* FunctionCallNode::codegen() {
    auto& cg = CodeGenerator::getInstance();

    // Evaluate arguments first
    std::vector<llvm::Value*> argValues;
    std::vector<std::unique_ptr<Type>> argTypes;
    for (auto& arg : arguments) {
        llvm::Value* argValue = arg->codegen();
        if (!argValue) {
            return nullptr;
        }
        argValues.push_back(argValue);
        auto argType = arg->getType();
        argTypes.push_back(argType ? argType->clone() : std::make_unique<UnknownType>());
    }

    // Check if the function name refers to a template symbol
    auto* symbol = cg.symbolTable.lookup(functionName);
    if (symbol && symbol->symbolType == SymbolType::TEMPLATE) {
        auto* tmplSymbol = dynamic_cast<TemplateSymbol*>(symbol);
        if (!tmplSymbol) {
            std::cerr << "Error: Invalid template symbol '" << functionName << "'" << std::endl;
            return nullptr;
        }

        auto* funcDecl = dynamic_cast<FunctionDeclarationNode*>(tmplSymbol->declaration.get());
        if (!funcDecl) {
            std::cerr << "Error: Template '" << functionName << "' is not a function template" << std::endl;
            return nullptr;
        }

        // Use explicit type arguments if provided, otherwise infer
        std::vector<std::unique_ptr<Type>> concreteTypes(tmplSymbol->typeParameters.size());
        if (!explicitTypeArgs.empty()) {
            // Explicit template arguments: identity<Int>(42)
            for (size_t i = 0; i < explicitTypeArgs.size() && i < concreteTypes.size(); ++i) {
                concreteTypes[i] = explicitTypeArgs[i]->clone();
            }
        } else {
            // Infer type arguments from call argument types
            for (size_t pi = 0; pi < funcDecl->parameters.size() && pi < argValues.size(); ++pi) {
                auto* paramNode = dynamic_cast<ParameterNode*>(funcDecl->parameters[pi].get());
                if (!paramNode || !paramNode->type) continue;
                if (paramNode->type->getKind() == Type::Kind::VARIABLE) {
                    for (size_t ti = 0; ti < tmplSymbol->typeParameters.size(); ++ti) {
                        if (paramNode->type->getName() == tmplSymbol->typeParameters[ti] && !concreteTypes[ti]) {
                            // Prefer AST-level type, fall back to LLVM inference
                            if (argTypes[pi] && argTypes[pi]->getKind() != Type::Kind::UNKNOWN) {
                                concreteTypes[ti] = argTypes[pi]->clone();
                            } else {
                                concreteTypes[ti] = inferTypeFromLLVM(argValues[pi]);
                            }
                        }
                    }
                }
            }
        }

        // Build mangled name
        std::string mangledName = functionName;
        for (auto& ct : concreteTypes) {
            mangledName += "$" + (ct ? ct->getName() : "Unknown");
        }

        // Check instantiation cache
        auto cacheIt = tmplSymbol->instantiations.find(mangledName);
        if (cacheIt != tmplSymbol->instantiations.end()) {
            llvm::Function* function = cacheIt->second;
            llvm::Value* result = cg.builder.CreateCall(
                function, argValues, function->getReturnType()->isVoidTy() ? "" : "calltmp");

            // Set type from the function return
            auto* funcType = dynamic_cast<FunctionType*>(
                cg.symbolTable.lookupFunction(mangledName, concreteTypes) ?
                cg.symbolTable.lookupFunction(mangledName, concreteTypes)->type.get() : nullptr);
            if (funcType && funcType->returnType) {
                type = funcType->returnType->clone();
            }
            return result;
        }

        // Clone the template AST and substitute types
        auto clonedDecl = funcDecl->clone();
        auto* clonedFunc = dynamic_cast<FunctionDeclarationNode*>(clonedDecl.get());
        if (!clonedFunc) {
            std::cerr << "Error: Failed to clone template function" << std::endl;
            return nullptr;
        }

        clonedFunc->name = mangledName;
        substituteTypes(clonedFunc, tmplSymbol->typeParameters, concreteTypes);

        // Save codegen state
        auto* savedBlock = cg.builder.GetInsertBlock();
        auto savedPoint = cg.builder.GetInsertPoint();
        auto* savedCurrentSymbol = cg.symbolTable.getCurrentSymbol();
        cg.symbolTable.saveCurrentSymbol();

        // Codegen the instantiated function (at top level)
        cg.symbolTable.setCurrentSymbol(nullptr);
        llvm::Value* funcVal = clonedFunc->codegen();
        if (!funcVal) {
            std::cerr << "Error: Failed to instantiate template function '" << mangledName << "'" << std::endl;
            cg.symbolTable.popCurrentSymbol();
            cg.symbolTable.setCurrentSymbol(savedCurrentSymbol);
            cg.builder.SetInsertPoint(savedBlock, savedPoint);
            return nullptr;
        }

        // Restore codegen state
        cg.symbolTable.popCurrentSymbol();
        cg.symbolTable.setCurrentSymbol(savedCurrentSymbol);
        cg.builder.SetInsertPoint(savedBlock, savedPoint);

        llvm::Function* function = llvm::dyn_cast<llvm::Function>(funcVal);
        if (!function) {
            std::cerr << "Error: Template instantiation did not produce a function" << std::endl;
            return nullptr;
        }

        // Cache the instantiation
        tmplSymbol->instantiations[mangledName] = function;

        // Call the instantiated function
        llvm::Value* result = cg.builder.CreateCall(
            function, argValues, function->getReturnType()->isVoidTy() ? "" : "calltmp");

        // Infer return type
        if (function->getReturnType()->isIntegerTy(32)) {
            type = std::make_unique<BasicType>("Int");
        } else if (function->getReturnType()->isDoubleTy()) {
            type = std::make_unique<BasicType>("Double");
        } else if (function->getReturnType()->isFloatTy()) {
            type = std::make_unique<BasicType>("Float");
        } else if (function->getReturnType()->isVoidTy()) {
            type = std::make_unique<BasicType>("Unit");
        } else {
            type = std::make_unique<UnknownType>();
        }

        return result;
    }

    // Normal function lookup
    auto functionSymbolOpt = cg.symbolTable.lookupFunction(functionName, argTypes);
    if (functionSymbolOpt) {
        auto* functionSymbol = functionSymbolOpt;
        auto* funcType = dynamic_cast<FunctionType*>(functionSymbol->type.get());
        llvm::Function* function = static_cast<llvm::Function*>(functionSymbol->value);
        if (!funcType || !function) {
            std::cerr << "Error: Invalid function '" << functionName << "'" << std::endl;
            return nullptr;
        }

        // Constexpr function with constant args: try compile-time evaluation
        if (function->hasFnAttribute(llvm::Attribute::AlwaysInline)) {
            bool allConstant = true;
            for (auto& av : argValues) {
                if (!llvm::isa<llvm::Constant>(av)) {
                    allConstant = false;
                    break;
                }
            }
            if (allConstant && !function->getReturnType()->isVoidTy()) {
                // Generate the call with AlwaysInline - LLVM optimizer will constant-fold
                llvm::Value* result = cg.builder.CreateCall(
                    function, argValues, "constexpr_call");
                type = funcType->returnType ? funcType->returnType->clone() : std::make_unique<UnknownType>();
                return result;
            }
        }

        llvm::Value* result = cg.builder.CreateCall(
            function, argValues, function->getReturnType()->isVoidTy() ? "" : "calltmp");

        type = funcType->returnType ? funcType->returnType->clone() : std::make_unique<UnknownType>();
        return result;
    }
    else {
        llvm::Function* function = cg.module->getFunction(functionName);
        if (function) {
            llvm::Value* result = cg.builder.CreateCall(
                function, argValues, function->getReturnType()->isVoidTy() ? "" : "calltmp");
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

    std::vector<std::unique_ptr<Type>> argTypes;
    for (auto& arg : arguments) {
        auto argType = arg->getType();
        argTypes.push_back(argType ? argType->clone() : std::make_unique<UnknownType>());
    }

    // Check if this is a template function - return type is unknown until instantiation
    auto& cg = CodeGenerator::getInstance();
    auto* symbol = cg.symbolTable.lookup(functionName);
    if (symbol && symbol->symbolType == SymbolType::TEMPLATE) {
        return std::make_unique<UnknownType>();
    }

    auto functionSymbolOpt = cg.symbolTable.lookupFunction(functionName, argTypes);
    if (!functionSymbolOpt) {
        // Function not found - may be a template not yet instantiated, or truly missing
        return std::make_unique<UnknownType>();
    }

    auto* functionSymbol = functionSymbolOpt;

    auto* funcType = dynamic_cast<FunctionType*>(functionSymbol->type.get());
    if (funcType && funcType->returnType) {
        return funcType->returnType->clone();
    }

    return std::make_unique<UnknownType>();
}
