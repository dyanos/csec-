#include "codegen.h"
#include "AccessFieldNode.h"
#include "ASTVisitor.h"
#include "utils.h"

#include "IdentifierNode.h"

#include <iostream>

namespace {
llvm::Function* getOrCreateRuntimeFunction(const std::string& name, llvm::Type* returnType, const std::vector<llvm::Type*>& paramTypes) {
    auto& cg = CodeGenerator::getInstance();
    if (auto* function = cg.module->getFunction(name)) return function;
    auto* functionTy = llvm::FunctionType::get(returnType, paramTypes, false);
    return llvm::Function::Create(functionTy, llvm::Function::ExternalLinkage, name, cg.module.get());
}
}

void AccessFieldNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* AccessFieldNode::codegen() {
    if (!this->base || !this->field) {
        return nullptr;
    }

    auto* baseIdentifier = dynamic_cast<IdentifierNode*>(this->base.get());
    if (!baseIdentifier) {
        std::cerr << "Error: Base must be an identifier" << std::endl;
        return nullptr;
    }

    auto* fieldIdentifier = dynamic_cast<IdentifierNode*>(this->field.get());
    if (!fieldIdentifier) {
        std::cerr << "Error: Field must be an identifier" << std::endl;
        return nullptr;
    }

    auto baseType = baseIdentifier->getType();
    auto targetName = fieldIdentifier->value;
    if (baseType && baseType->isStringTy()) {
        llvm::Value* stringValue = baseIdentifier->codegen();
        if (!stringValue) {
            return nullptr;
        }
        if (targetName == "length" || targetName == "size" || targetName == "count") {
            auto& cg = CodeGenerator::getInstance();
            auto* i8PtrTy = llvm::PointerType::getUnqual(llvm::Type::getInt8Ty(cg.context));
            auto* i64Ty = llvm::Type::getInt64Ty(cg.context);
            return cg.builder.CreateCall(
                getOrCreateRuntimeFunction("csec_string_length", i64Ty, {i8PtrTy}),
                {stringValue},
                "str.length");
        }
        if (targetName == "isEmpty") {
            auto& cg = CodeGenerator::getInstance();
            auto* i8PtrTy = llvm::PointerType::getUnqual(llvm::Type::getInt8Ty(cg.context));
            auto* i32Ty = llvm::Type::getInt32Ty(cg.context);
            auto* result = cg.builder.CreateCall(
                getOrCreateRuntimeFunction("csec_string_is_empty", i32Ty, {i8PtrTy}),
                {stringValue},
                "str.empty.i32");
            return cg.builder.CreateICmpNE(result, llvm::ConstantInt::get(i32Ty, 0), "str.empty");
        }
        std::cerr << "Error: String property '" << targetName << "' not found" << std::endl;
        return nullptr;
    }

    // Reading a field yields its value. The address is produced by codegenFieldPointer(); load it.
    llvm::Value* fieldPtr = codegenFieldPointer();
    if (!fieldPtr) {
        return nullptr;
    }
    auto& cg = CodeGenerator::getInstance();
    llvm::Type* fieldLLVMType = cg.getLLVMType(getType().get());
    if (!fieldLLVMType) {
        std::cerr << "Error: Field '" << targetName << "' has an unsupported type" << std::endl;
        return nullptr;
    }
    return cg.builder.CreateLoad(fieldLLVMType, fieldPtr, targetName + ".value");
}

llvm::Value* AccessFieldNode::codegenFieldPointer() {
    auto* baseIdentifier = dynamic_cast<IdentifierNode*>(this->base.get());
    if (!baseIdentifier) {
        std::cerr << "Error: Base must be an identifier" << std::endl;
        return nullptr;
    }
    auto* fieldIdentifier = dynamic_cast<IdentifierNode*>(this->field.get());
    if (!fieldIdentifier) {
        std::cerr << "Error: Field must be an identifier" << std::endl;
        return nullptr;
    }
    auto baseType = baseIdentifier->getType();
    const auto targetName = fieldIdentifier->value;

    if (!baseType || baseType->getKind() != Type::Kind::CLASS) {
        std::cerr << "Error: Base must be a class type" << std::endl;
        return nullptr;
    }

    auto* classSymbol = CodeGenerator::getInstance().symbolTable.lookupClass(baseType->getName());
    if (!classSymbol) {
        std::cerr << "Error: Class '" << baseType->getName() << "' not found" << std::endl;
        return nullptr;
    }

    auto* thisSymbol = CodeGenerator::getInstance().symbolTable.lookup(baseIdentifier->value);
    if (!thisSymbol) {
        std::cerr << "Error: Base object not found" << std::endl;
        return nullptr;
    }

    auto* structType = llvm::dyn_cast<llvm::StructType>(classSymbol->classType);
    if (!structType) {
        std::cerr << "Error: Class '" << baseType->getName() << "' has invalid LLVM struct type" << std::endl;
        return nullptr;
    }

    llvm::Value* basePtr = thisSymbol->value;
    if (!basePtr || !basePtr->getType()->isPointerTy()) {
        std::cerr << "Error: Base object value is not a pointer" << std::endl;
        return nullptr;
    }

    auto* targetPtrType = llvm::PointerType::getUnqual(structType);
    if (basePtr->getType() != targetPtrType) {
        basePtr = CodeGenerator::getInstance().builder.CreateBitCast(basePtr, targetPtrType, "obj.cast");
    }

    int fieldIndex = findFieldIndex(classSymbol, targetName);
    if (fieldIndex == -1) {
        std::cerr << "Error: Field '" << targetName << "' not found in class '"
            << baseType->getName() << "'" << std::endl;
        return nullptr;
    }

    return CodeGenerator::getInstance().builder.CreateStructGEP(
        structType,
        basePtr,
        static_cast<unsigned>(fieldIndex),
        targetName
    );
}

int AccessFieldNode::findFieldIndex(ClassSymbol* classSymbol, const std::string& fieldName) {
    int idx = 0;

    for (const auto& field : classSymbol->constructorParamOrder) {
        if (field == fieldName) {
            return idx;
        }
        idx++;
    }

    for (const auto& field : classSymbol->fieldOrder) {
        if (field == fieldName) {
            return idx;
        }
        idx++;
    }

    return -1;
}

std::unique_ptr<Type> AccessFieldNode::getType() {
    auto baseType = base ? base->getType() : nullptr;
    auto* fieldIdentifier = dynamic_cast<IdentifierNode*>(field.get());
    if (baseType && baseType->isStringTy() && fieldIdentifier) {
        const std::string& targetName = fieldIdentifier->value;
        if (targetName == "length" || targetName == "size" || targetName == "count") {
            return std::make_unique<BasicType>("Long");
        }
        if (targetName == "isEmpty") {
            return std::make_unique<BasicType>("Boolean");
        }
    }
    if (!field) return std::make_unique<UnknownType>();
    return field->getType();
}
