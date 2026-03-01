#include "codegen.h"

#include "ClassInstanceCreationNode.h"
#include "ClassDeclarationNode.h"
#include "ParameterNode.h"
#include "ASTVisitor.h"

#include <iostream>
#include <llvm/IR/DataLayout.h>
#include <llvm/IR/Function.h>

#include "utils.h"

void ClassInstanceCreationNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ClassInstanceCreationNode::codegen() {
    auto& cg = CodeGenerator::getInstance();

    // Primitive allocation: return typed pointer from malloc.
    if (isPrimitiveType(className)) {
        BasicType basicType(className);
        llvm::Type* type = cg.getLLVMType(&basicType);
        if (!type) {
            std::cerr << "Error: Unsupported primitive type '" << className << "'" << std::endl;
            return nullptr;
        }

        const llvm::DataLayout& dl = cg.module->getDataLayout();
        uint64_t typeSize = dl.getTypeAllocSize(type);
        llvm::Value* allocSize = llvm::ConstantInt::get(llvm::Type::getInt64Ty(cg.context), typeSize);
        llvm::Value* rawPtr = cg.builder.CreateCall(cg.mallocFunction, allocSize, "malloc");
        return cg.builder.CreateBitCast(rawPtr, llvm::PointerType::getUnqual(type), "newptr");
    }

    std::string resolvedClassName = className;

    // Template Class instantiation: new ClassName<Type>(args)
    if (!templateArgs.empty()) {
        auto* symbol = cg.symbolTable.lookup(className);
        if (symbol && symbol->symbolType == SymbolType::TEMPLATE) {
            auto* tmplSymbol = dynamic_cast<TemplateSymbol*>(symbol);
            if (!tmplSymbol) {
                std::cerr << "Error: Invalid template symbol '" << className << "'" << std::endl;
                return nullptr;
            }

            auto* classDecl = dynamic_cast<ClassDeclarationNode*>(tmplSymbol->declaration.get());
            if (!classDecl) {
                std::cerr << "Error: Template '" << className << "' is not a class template" << std::endl;
                return nullptr;
            }

            std::string mangledName = className;
            for (auto& ta : templateArgs) {
                mangledName += "$" + (ta ? ta->getName() : "Unknown");
            }

            auto cacheIt = tmplSymbol->classInstantiations.find(mangledName);
            if (cacheIt != tmplSymbol->classInstantiations.end()) {
                resolvedClassName = mangledName;
            }
            else {
                auto clonedDecl = classDecl->clone();
                auto* clonedClass = dynamic_cast<ClassDeclarationNode*>(clonedDecl.get());
                if (!clonedClass) {
                    std::cerr << "Error: Failed to clone template class" << std::endl;
                    return nullptr;
                }
                clonedClass->name = mangledName;

                // Substitute type variables in constructor parameters.
                for (auto& param : clonedClass->constructorParams) {
                    auto* paramNode = dynamic_cast<ParameterNode*>(param.get());
                    if (paramNode && paramNode->type && paramNode->type->getKind() == Type::Kind::VARIABLE) {
                        for (size_t i = 0; i < tmplSymbol->typeParameters.size(); ++i) {
                            if (paramNode->type->getName() == tmplSymbol->typeParameters[i] && i < templateArgs.size()) {
                                paramNode->type = templateArgs[i]->clone();
                            }
                        }
                    }
                }

                // Preserve insertion point while emitting top-level class metadata.
                auto* savedInsertBlock = cg.builder.GetInsertBlock();
                auto savedInsertPoint = cg.builder.GetInsertPoint();
                auto* savedCurrentSymbol = cg.symbolTable.getCurrentSymbol();
                cg.symbolTable.saveCurrentSymbol();
                cg.symbolTable.setCurrentSymbol(nullptr);
                clonedClass->codegen();
                cg.symbolTable.popCurrentSymbol();
                cg.symbolTable.setCurrentSymbol(savedCurrentSymbol);
                if (savedInsertBlock) {
                    cg.builder.SetInsertPoint(savedInsertBlock, savedInsertPoint);
                }

                auto* instantiatedSymbol = cg.symbolTable.lookupClass(mangledName);
                if (instantiatedSymbol) {
                    tmplSymbol->classInstantiations[mangledName] = instantiatedSymbol;
                }
                resolvedClassName = mangledName;
            }
        }
    }

    auto classSymbolOpt = cg.symbolTable.lookupClass(resolvedClassName);
    if (!classSymbolOpt) {
        std::cerr << "Error: Class '" << resolvedClassName << "' not found" << std::endl;
        return nullptr;
    }

    auto* classSymbol = classSymbolOpt;
    llvm::StructType* classType = llvm::dyn_cast<llvm::StructType>(classSymbol->classType);
    if (!classType) {
        std::cerr << "Error: Unknown type about class '" << resolvedClassName << "'" << std::endl;
        return nullptr;
    }

    if (!arguments.empty()) {
        std::cerr << "Warning: class constructor arguments are not fully supported yet for '" << resolvedClassName
                  << "'. Object is allocated without constructor invocation." << std::endl;
    }

    return cg.builder.CreateAlloca(classType, nullptr, "newobj");
}

std::unique_ptr<Type> ClassInstanceCreationNode::getType() {
    return std::make_unique<ClassType>(className);
}
