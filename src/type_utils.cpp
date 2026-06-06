#include "type_utils.h"

#include "codegen.h"

#include <llvm/IR/DerivedTypes.h>


bool areTypesCompatible(const std::vector<std::unique_ptr<Type>>& paramTypes, const std::vector<std::unique_ptr<Type>>& argTypes) {
    if (paramTypes.size() != argTypes.size()) {
        return false;
    }

    for (size_t i = 0; i < paramTypes.size(); ++i) {
        if (!argTypes[i]->equals(paramTypes[i])) {
            return false;
        }
    }
    return true;
}

bool isStructClassType(const Type* type) {
    if (!type || type->getKind() != Type::Kind::CLASS) {
        return false;
    }

    auto& cg = CodeGenerator::getInstance();
    auto* classSymbol = cg.symbolTable.lookupClass(type->getName());
    return classSymbol && classSymbol->isStruct;
}

llvm::Type* getABIStorageType(const Type* type) {
    if (!type) {
        return nullptr;
    }

    auto& cg = CodeGenerator::getInstance();
    llvm::Type* llvmType = cg.getLLVMType(type);
    if (!llvmType) {
        return nullptr;
    }

    if (type->getKind() == Type::Kind::CLASS && !isStructClassType(type)) {
        return llvm::PointerType::getUnqual(llvmType);
    }

    return llvmType;
}

llvm::Value* coerceValueToLLVMType(llvm::Value* value, llvm::Type* targetType) {
    if (!value || !targetType || value->getType() == targetType) {
        return value;
    }

    auto& cg = CodeGenerator::getInstance();
    llvm::Type* sourceType = value->getType();
    if (sourceType->isPointerTy() && !targetType->isPointerTy()) {
        return cg.builder.CreateLoad(targetType, value, "abi.load");
    }

    if (sourceType->isIntegerTy() && targetType->isIntegerTy()) {
        unsigned sourceBits = sourceType->getIntegerBitWidth();
        unsigned targetBits = targetType->getIntegerBitWidth();
        if (sourceBits < targetBits) {
            return cg.builder.CreateSExt(value, targetType, "abi.sext");
        }
        if (sourceBits > targetBits) {
            return cg.builder.CreateTrunc(value, targetType, "abi.trunc");
        }
    }

    if (sourceType->isFloatingPointTy() && targetType->isFloatingPointTy()) {
        return cg.builder.CreateFPCast(value, targetType, "abi.fpcast");
    }

    if (sourceType->isIntegerTy() && targetType->isFloatingPointTy()) {
        return cg.builder.CreateSIToFP(value, targetType, "abi.sitofp");
    }

    if (sourceType->isFloatingPointTy() && targetType->isIntegerTy()) {
        return cg.builder.CreateFPToSI(value, targetType, "abi.fptosi");
    }

    if (sourceType->isPointerTy() && targetType->isPointerTy()) {
        return cg.builder.CreateBitCast(value, targetType, "abi.bitcast");
    }

    return value;
}
