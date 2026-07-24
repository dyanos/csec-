#include "codegen.h"

#include "VariableDeclarationNode.h"
#include "ASTVisitor.h"
#include "ClassInstanceCreationNode.h"
#include "ArrayCreationExpressionNode.h"
#include "ArrayLiteralNode.h"
#include "CallExpressionNode.h"
#include "FunctionCallNode.h"
#include "LambdaExpressionNode.h"
#include "type_utils.h"

#include <iostream>
#include <llvm/IR/Value.h>
#include <llvm/IR/Constants.h>
#include <llvm/IR/DataLayout.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/GlobalVariable.h>

namespace {
llvm::Value* coerceBoxValue(llvm::Value* value, llvm::Type* targetType) {
    if (!value || !targetType || value->getType() == targetType) {
        return value;
    }

    auto& cg = CodeGenerator::getInstance();
    llvm::Type* sourceType = value->getType();
    if (sourceType->isIntegerTy() && targetType->isIntegerTy()) {
        unsigned sourceBits = sourceType->getIntegerBitWidth();
        unsigned targetBits = targetType->getIntegerBitWidth();
        if (sourceBits < targetBits) {
            return cg.builder.CreateSExt(value, targetType, "box.sext");
        }
        return cg.builder.CreateTrunc(value, targetType, "box.trunc");
    }

    if (sourceType->isFloatingPointTy() && targetType->isFloatingPointTy()) {
        return cg.builder.CreateFPCast(value, targetType, "box.fpcast");
    }

    if (sourceType->isIntegerTy() && targetType->isFloatingPointTy()) {
        return cg.builder.CreateSIToFP(value, targetType, "box.sitofp");
    }

    if (sourceType->isFloatingPointTy() && targetType->isIntegerTy()) {
        return cg.builder.CreateFPToSI(value, targetType, "box.fptosi");
    }

    return value;
}
}

void VariableDeclarationNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* VariableDeclarationNode::codegen() {
    auto& cg = CodeGenerator::getInstance();

    llvm::Value* initValue = nullptr;
    if (this->initializer) {
        initValue = this->initializer->codegen();
        if (!initValue) {
            return nullptr;
        }
    }
    else {
        initValue = llvm::Constant::getNullValue(cg.getLLVMType(type.get()));
    }

    if (this->type->getKind() == Type::Kind::UNKNOWN && initValue != nullptr) {
        if (auto* lambda = dynamic_cast<LambdaExpressionNode*>(initializer.get())) {
            this->type = lambda->getType();
        }
        else if (initValue->getType()->isIntegerTy(32)) {
            this->type = std::make_unique<BasicType>("Int");
        }
        else if (initValue->getType()->isFloatTy()) {
            this->type = std::make_unique<BasicType>("Float");
        }
        else if (initValue->getType()->isDoubleTy()) {
            this->type = std::make_unique<BasicType>("Double");
        }
        else if (initValue->getType()->isStructTy()) {
            std::string structName = initValue->getType()->getStructName().str();
            this->type = std::make_unique<ClassType>(structName);
        }
        else if (auto* classCreation = dynamic_cast<ClassInstanceCreationNode*>(initializer.get())) {
            this->type = classCreation->getType();
        }
        else if (auto* arrayCreation = dynamic_cast<ArrayCreationExpressionNode*>(initializer.get())) {
            this->type = arrayCreation->getType();
        }
        // string type (opaque pointer)
        else if (initValue->getType()->isPointerTy()) {
            this->type = std::make_unique<BasicType>("String");
        }
        else {
            std::cerr << "Error: Unable to infer variable type for '" << name << "'" << std::endl;
            return nullptr;
        }
    }

    if (type && type->getKind() == Type::Kind::BOX && initValue && !initValue->getType()->isPointerTy()) {
        auto* boxType = dynamic_cast<BoxType*>(type.get());
        llvm::Type* baseType = boxType && boxType->baseType ? cg.getLLVMType(boxType->baseType.get()) : nullptr;
        if (!baseType) {
            std::cerr << "Error: Unsupported box base type for '" << name << "'" << std::endl;
            return nullptr;
        }

        initValue = coerceBoxValue(initValue, baseType);
        if (!initValue || initValue->getType() != baseType) {
            std::cerr << "Error: Box initializer for '" << name << "' has incompatible type" << std::endl;
            return nullptr;
        }

        const llvm::DataLayout& dl = cg.module->getDataLayout();
        uint64_t typeSize = dl.getTypeAllocSize(baseType);
        llvm::Value* allocSize = llvm::ConstantInt::get(llvm::Type::getInt64Ty(cg.context), typeSize);
        llvm::Value* rawPtr = cg.builder.CreateCall(cg.mallocFunction, allocSize, "box.malloc");
        llvm::Value* boxPtr = cg.builder.CreateBitCast(rawPtr, llvm::PointerType::getUnqual(baseType), "box.ptr");
        cg.builder.CreateStore(initValue, boxPtr);
        initValue = boxPtr;
    }

    const bool declaredStructClass = isStructClassType(type.get());
    if (declaredStructClass && initValue && initValue->getType()->isPointerTy() &&
        dynamic_cast<ClassInstanceCreationNode*>(initializer.get()) == nullptr) {
        llvm::Type* valueType = cg.getLLVMType(type.get());
        initValue = coerceValueToLLVMType(initValue, valueType);
    }

    // An array or vector local initialized from a function call holds the returned array pointer.
    // Bind it directly (rather than into a pointer slot) so indexing can GEP on the pointer
    // without an intervening load, the same representation a `new T[n]` initializer produces.
    // This is restricted to call initializers so that array literals, which the parallel
    // collection lowering re-evaluates through their own node, keep their existing representation.
    const bool arrayVectorFromCall = type &&
        (type->getKind() == Type::Kind::ARRAY ||
         (type->getKind() == Type::Kind::GENERIC &&
          (type->getName() == "Array" || type->getName() == "Vector"))) &&
        (dynamic_cast<CallExpressionNode*>(initializer.get()) != nullptr ||
         dynamic_cast<FunctionCallNode*>(initializer.get()) != nullptr);

    const bool bindPointerBackedValueDirectly =
        initValue &&
        initValue->getType()->isPointerTy() &&
        !(isMutable && type && type->getName() == "Tensor") &&
        (dynamic_cast<ClassInstanceCreationNode*>(initializer.get()) != nullptr ||
         dynamic_cast<ArrayCreationExpressionNode*>(initializer.get()) != nullptr ||
         dynamic_cast<ArrayLiteralNode*>(initializer.get()) != nullptr ||
         dynamic_cast<FunctionType*>(type.get()) != nullptr ||
         (type->getKind() == Type::Kind::CLASS && !declaredStructClass) ||
         type->getKind() == Type::Kind::BOX ||
         arrayVectorFromCall);

    if (bindPointerBackedValueDirectly) {
        cg.symbolTable.addSymbol(
            name,
            std::make_unique<Symbol>(name, type->clone(), initValue, isMutable, SymbolType::VARIABLE));
        if (type->getKind() == Type::Kind::BOX) {
            cg.registerCleanup(initValue);
        }
        return initValue;
    }

    // constexpr: use constant value directly, no alloca
    if (this->isConstexpr) {
        auto* constVal = llvm::dyn_cast<llvm::Constant>(initValue);
        if (!constVal) {
            std::cerr << "Error: constexpr variable '" << name << "' must have a constant initializer" << std::endl;
            return nullptr;
        }
        cg.symbolTable.addSymbol(
            name,
            std::make_unique<Symbol>(name, type->clone(), constVal, false, SymbolType::VARIABLE));
        return constVal;
    }

    llvm::Type* varType = cg.getLLVMType(type.get());
    if (!varType) {
        std::cerr << "Error: Unsupported variable type '" << type->getName() << "'" << std::endl;
        return nullptr;
    }
    if (varType->isVoidTy()) {
        cg.symbolTable.addSymbol(
            name,
            std::make_unique<Symbol>(name, type->clone(), nullptr, isMutable, SymbolType::VARIABLE));
        return nullptr;
    }

    initValue = coerceBoxValue(initValue, varType);
    if (!initValue || initValue->getType() != varType) {
        std::cerr << "Error: Variable initializer for '" << name << "' has incompatible LLVM type" << std::endl;
        return nullptr;
    }

    auto* currentSymbol = cg.symbolTable.getCurrentSymbol();
    if (currentSymbol && currentSymbol->symbolType == SymbolType::NAMESPACE) {
        llvm::Constant* globalInit = llvm::dyn_cast<llvm::Constant>(initValue);
        if (!globalInit) {
            globalInit = llvm::Constant::getNullValue(varType);
        }
        auto* global = new llvm::GlobalVariable(
            *cg.module,
            varType,
            !isMutable,
            llvm::GlobalValue::PrivateLinkage,
            globalInit,
            name);
        cg.symbolTable.addSymbol(
            name,
            std::make_unique<Symbol>(name, type->clone(), global, isMutable, SymbolType::VARIABLE));
        return global;
    }

    llvm::AllocaInst* alloc = cg.builder.CreateAlloca(varType, nullptr, name.c_str());

    cg.builder.CreateStore(initValue, alloc);

    cg.symbolTable.addSymbol(
        name,
        std::make_unique<Symbol>(name, type->clone(), alloc, isMutable, SymbolType::VARIABLE));

    return alloc;
}
