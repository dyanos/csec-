// codegen.cpp
#include "codegen.h"
#include <llvm/IR/Verifier.h>
#include <llvm/IR/Type.h>
#include <llvm/Support/raw_ostream.h>

#include <iostream>


CodeGenerator::CodeGenerator() : builder(context) {
    module = std::make_unique<llvm::Module>("main", context);

    llvm::FunctionType* funcType = llvm::FunctionType::get(builder.getInt32Ty(), false);
    mainFunction = llvm::Function::Create(funcType, llvm::Function::ExternalLinkage, "main", module.get());

    llvm::BasicBlock* entry = llvm::BasicBlock::Create(context, "entry", mainFunction);
    builder.SetInsertPoint(entry);

    symbolTable.initializeBuiltInTypes(context);
}

void CodeGenerator::generateCode(std::shared_ptr<ProgramNode> program) {
    program->codegen();

    builder.CreateRet(builder.getInt32(0));
}

void CodeGenerator::dumpIR() {
    module->print(llvm::outs(), nullptr);
}

llvm::Type* CodeGenerator::getLLVMType(std::shared_ptr<Type> type) {
    if (type->kind == TypeKind::BASIC) {
        if (type == symbolTable.lookupType("Int")) {
            return llvm::Type::getInt32Ty(context);
        }
        else if (type == symbolTable.lookupType("Float")) {
            return llvm::Type::getFloatTy(context);
        }
        else if (type == symbolTable.lookupType("Double")) {
            return llvm::Type::getDoubleTy(context);
        }
        else if (type == symbolTable.lookupType("Char")) {
            return llvm::Type::getInt8Ty(context);
        }
        else if (type == symbolTable.lookupType("String")) {
			return llvm::PointerType::getUnqual(llvm::Type::getInt8Ty(context));
        }
        else if (type.get()->equals(symbolTable.lookupType("Unit"))) {
            return llvm::Type::getVoidTy(context);
        }
    }
    else if (type->kind == TypeKind::CLASS) {
        // 클래스 타입 처리
        ClassSymbol* classSymbol = symbolTable.lookupClass(type->name);
        if (classSymbol) {
            return classSymbol->classType->getPointerTo();
        }
        else {
            std::cerr << "Error: Undefined class type '" << type->name << "'" << std::endl;
            return nullptr;
        }
    }
    else if (type->kind == TypeKind::GENERIC) {
        auto genericType = std::dynamic_pointer_cast<GenericType>(type);
        if (genericType->baseType->name == "Array") {
            if (genericType->typeArguments.size() != 1) {
                std::cerr << "Error: Array type must have exactly one type argument" << std::endl;
                return nullptr;
            }
            auto elementType = getLLVMType(genericType->typeArguments[0]);
            if (!elementType) {
                std::cerr << "Error: Invalid element type in Array" << std::endl;
                return nullptr;
            }
            return llvm::PointerType::getUnqual(elementType);
        }
        std::cerr << "Error: Unsupported generic type '" << genericType->baseType->name << "'" << std::endl;
        return nullptr;
    }
    else if (type->kind == TypeKind::UNKNOWN) {
        std::cerr << "Error: Unknown type '" << type->name << "'" << std::endl;
        return nullptr;
    }
    return nullptr;
}