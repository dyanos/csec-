// codegen.cpp
#include "codegen.h"
#include "TensorRuntime.h"
#include "type_utils.h"
#include <llvm/IR/Verifier.h>
#include <llvm/IR/Type.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/Support/raw_ostream.h>

#include <iostream>

#include "ProgramNode.h"


namespace {
void addUnique(std::vector<std::string>& values, const std::string& value) {
    if (value.empty()) return;
    for (const auto& existing : values) {
        if (existing == value) return;
    }
    values.push_back(value);
}
}

CodeGenerator::CodeGenerator() : builder(context) {
    this->module = std::make_unique<llvm::Module>("main", context);

    auto* i8PtrTy = llvm::PointerType::getUnqual(llvm::Type::getInt8Ty(context));
    auto* argvTy = llvm::PointerType::getUnqual(i8PtrTy);
    llvm::FunctionType* funcType = llvm::FunctionType::get(this->builder.getInt32Ty(), {this->builder.getInt32Ty(), argvTy}, false);
    this->mainFunction = llvm::Function::Create(funcType, llvm::Function::ExternalLinkage, "main", module.get());

    llvm::BasicBlock* entry = llvm::BasicBlock::Create(context, "entry", mainFunction);
    this->builder.SetInsertPoint(entry);
    this->builder.CreateRet(this->builder.getInt32(0));

    this->mallocFunction = module->getFunction("malloc");
    if (!mallocFunction) {
        mallocFunction = llvm::Function::Create(
            llvm::FunctionType::get(llvm::PointerType::getUnqual(llvm::Type::getInt8Ty(context)), { llvm::Type::getInt64Ty(context) }, false),
            llvm::Function::ExternalLinkage,
            "malloc",
            module.get()
        );
    }

    this->freeFunction = module->getFunction("free");
    if (!freeFunction) {
        freeFunction = llvm::Function::Create(
            llvm::FunctionType::get(llvm::Type::getVoidTy(context), { llvm::PointerType::getUnqual(llvm::Type::getInt8Ty(context)) }, false),
            llvm::Function::ExternalLinkage,
            "free",
            module.get()
        );
    }

    this->symbolTable.initializeBuiltInTypes(context);

	// int?대옒?ㅼ뿉 異붽???toString硫붿꽌?쒖쓽 llvm 肄붾뱶 ?앹꽦
	auto initClassSymbolOpt = symbolTable.lookupClass("Int");
    if (!initClassSymbolOpt) {
        throw std::runtime_error("Fatal: 'Int' class not found in symbol table");
	}
    auto* initClassSymbol = initClassSymbolOpt;
	llvm::Function::Create(
		llvm::FunctionType::get(llvm::PointerType::getUnqual(llvm::Type::getInt8Ty(context)), { llvm::PointerType::getUnqual(initClassSymbol->classType) }, false),
		llvm::Function::ExternalLinkage,
		"toString",
		module.get()
	);

    llvm::Function::Create(
		llvm::FunctionType::get(llvm::PointerType::getUnqual(llvm::Type::getInt8Ty(context)), { llvm::PointerType::getUnqual(llvm::Type::getInt8Ty(context)), llvm::PointerType::getUnqual(llvm::Type::getInt8Ty(context)) }, false),
		llvm::Function::ExternalLinkage,
		"operator+",
		module.get()
	);

    // print ?⑥닔 ?앹꽦
    llvm::Function::Create(
        llvm::FunctionType::get(llvm::Type::getVoidTy(context), { llvm::PointerType::getUnqual(llvm::Type::getInt8Ty(context)) }, false),
        llvm::Function::ExternalLinkage,
        "print",
        module.get()
    );

    llvm::Function::Create(
        llvm::FunctionType::get(llvm::Type::getVoidTy(context), { llvm::PointerType::getUnqual(llvm::Type::getInt8Ty(context)) }, false),
        llvm::Function::ExternalLinkage,
        "println",
        module.get()
    );

    this->currentSymbol = nullptr;
}

void CodeGenerator::dumpIR() {
    module->print(llvm::outs(), nullptr);
}

void CodeGenerator::enterCleanupScope() {
    cleanupScopes.emplace_back();
}

void CodeGenerator::exitCleanupScope() {
    if (!cleanupScopes.empty()) {
        cleanupScopes.pop_back();
    }
}

void CodeGenerator::registerCleanup(llvm::Value* pointer) {
    if (!pointer || cleanupScopes.empty()) {
        return;
    }
    cleanupScopes.back().push_back(pointer);
}

void CodeGenerator::emitCurrentScopeCleanups() {
    if (cleanupScopes.empty()) {
        return;
    }

    auto& cleanups = cleanupScopes.back();
    for (auto it = cleanups.rbegin(); it != cleanups.rend(); ++it) {
        llvm::Value* pointer = *it;
        if (!pointer) {
            continue;
        }
        auto* i8PtrTy = llvm::PointerType::getUnqual(llvm::Type::getInt8Ty(context));
        llvm::Value* freePointer = pointer->getType() == i8PtrTy
            ? pointer
            : builder.CreateBitCast(pointer, i8PtrTy, "cleanup.free.ptr");
        builder.CreateCall(freeFunction, { freePointer });
    }
    cleanups.clear();
}

void CodeGenerator::emitAllCleanups() {
    emitAllCleanupsExcept(nullptr);
}

void CodeGenerator::emitAllCleanupsExcept(llvm::Value* retainedPointer) {
    for (auto scopeIt = cleanupScopes.rbegin(); scopeIt != cleanupScopes.rend(); ++scopeIt) {
        auto& cleanups = *scopeIt;
        for (auto it = cleanups.rbegin(); it != cleanups.rend(); ++it) {
            llvm::Value* pointer = *it;
            if (!pointer || pointer == retainedPointer) {
                continue;
            }
            auto* i8PtrTy = llvm::PointerType::getUnqual(llvm::Type::getInt8Ty(context));
            llvm::Value* freePointer = pointer->getType() == i8PtrTy
                ? pointer
                : builder.CreateBitCast(pointer, i8PtrTy, "cleanup.free.ptr");
            builder.CreateCall(freeFunction, { freePointer });
        }
        cleanups.clear();
    }
}

void CodeGenerator::addExternalLinkLibrary(const std::string& library) {
    addUnique(externalLinkLibraries, library);
}

void CodeGenerator::addExternalLinkPath(const std::string& path) {
    addUnique(externalLinkPaths, path);
}

void CodeGenerator::requireSystemNative() {
    addExternalLinkLibrary("System.Native");
}

llvm::Type* CodeGenerator::getLLVMType(const Type* type) {
    if (type->getKind() == Type::Kind::BASIC) {
        const std::string name = type->getName();
        if (name == "Int") {
            return llvm::Type::getInt32Ty(context);
        }
        else if (name == "Short") {
            return llvm::Type::getInt16Ty(context);
        }
        else if (name == "Byte") {
            return llvm::Type::getInt8Ty(context);
        }
        else if (name == "Long") {
            return llvm::Type::getInt64Ty(context);
        }
        else if (name == "Natural" || name == "Integer") {
            return llvm::Type::getInt64Ty(context);
        }
        else if (name == "Real") {
            return llvm::Type::getDoubleTy(context);
        }
        else if (name == "Boolean" || name == "Bool") {
            return llvm::Type::getInt1Ty(context);
        }
        else if (type->isFloatTy()) {
            return llvm::Type::getFloatTy(context);
        }
        else if (type->isDoubleTy()) {
            return llvm::Type::getDoubleTy(context);
        }
        else if (type->isCharTy()) {
            return llvm::Type::getInt8Ty(context);
        }
        else if (type->isStringTy()) {
			return llvm::PointerType::getUnqual(llvm::Type::getInt8Ty(context));
        }
        else if (type->isVoidTy()) {
            return llvm::Type::getVoidTy(context);
        }
        std::cerr << "Error: Unsupported basic type '" << type->getName() << "'" << std::endl;
        return nullptr;
    }
    else if (type->getKind() == Type::Kind::CLASS) {
        if (TensorRuntime::isTensorTypeName(type->getName())) {
            return TensorRuntime::getTensorPointerType(*this);
        }
        auto* classSymbol = symbolTable.lookupClass(type->getName());

		// Symbol??ClassSymbol濡?罹먯뒪?낇븯??classType???묎렐
        if (classSymbol) {
            return classSymbol->classType;
		}
		else {
			std::cerr << "Error: Undefined class type '" << type->getName() << "'" << std::endl;
			return nullptr;
		}
    }
    else if (type->getKind() == Type::Kind::GENERIC) {
        auto* genericType = static_cast<const GenericType*>(type);
        if (genericType->baseType->getName() == "Array") {
            if (genericType->typeArguments.size() != 1) {
                std::cerr << "Error: Array type must have exactly one type argument" << std::endl;
                return nullptr;
            }
            auto elementType = getLLVMType(genericType->typeArguments[0].get());
            if (!elementType) {
                std::cerr << "Error: Invalid element type in Array" << std::endl;
                return nullptr;
            }
            return llvm::PointerType::getUnqual(elementType);
        }
        if (genericType->baseType->getName() == "Tensor") {
            return TensorRuntime::getTensorPointerType(*this);
        }
        // Check if this is a template class instantiation: e.g. Pair<Int, String>
        std::string baseName = genericType->baseType->getName();
        auto* symbol = symbolTable.lookup(baseName);
        if (symbol && symbol->symbolType == SymbolType::TEMPLATE) {
            // Build mangled name
            std::string mangledName = baseName;
            for (auto& ta : genericType->typeArguments) {
                mangledName += "$" + (ta ? ta->getName() : "Unknown");
            }
            // Look up the instantiated class
            auto* classSymbol = symbolTable.lookupClass(mangledName);
            if (classSymbol) {
                return classSymbol->classType;
            }
            std::cerr << "Error: Template class '" << mangledName << "' not instantiated yet" << std::endl;
            return nullptr;
        }
        // Library-defined generic shapes such as Vector[Int] or Matrix[Double]
        // may be declared before their concrete runtime representation exists.
        // Treat them as opaque references so they can appear in signatures.
        return llvm::PointerType::getUnqual(llvm::Type::getInt8Ty(context));
    }
    else if (type->getKind() == Type::Kind::STRUCT) {
        auto* structSymbol = symbolTable.lookupStruct(type->getName());
        if (structSymbol) {
            return static_cast<StructSymbol*>(structSymbol)->structType;
        }
        else {
            std::cerr << "Error: Undefined struct type '" << type->getName() << "'" << std::endl;
            return nullptr;
        }
	}
    else if (type->getKind() == Type::Kind::FUNCTION) {
        auto* functionType = static_cast<const FunctionType*>(type);
        std::vector<llvm::Type*> paramLLVMTypes;
        for (const auto& paramType : functionType->parameterTypes) {
            auto llvmParamType = getLLVMType(paramType.get());
            if (!llvmParamType) {
                std::cerr << "Error: Invalid parameter type in function" << std::endl;
                return nullptr;
            }
            paramLLVMTypes.push_back(llvmParamType);
        }
        auto returnLLVMType = getLLVMType(functionType->returnType.get());
        if (!returnLLVMType) {
            std::cerr << "Error: Invalid return type in function" << std::endl;
            return nullptr;
        }
		auto tp = llvm::FunctionType::get(returnLLVMType, paramLLVMTypes, false);
        return llvm::PointerType::getUnqual(tp);
    }
    else if (type->getKind() == Type::Kind::ARRAY) {
        auto* arrayType = static_cast<const ArrayType*>(type);
        auto elementLLVMType = getLLVMType(arrayType->elementType.get());
        if (!elementLLVMType) {
            std::cerr << "Error: Invalid element type in array" << std::endl;
            return nullptr;
        }
        return llvm::ArrayType::get(elementLLVMType, arrayType->size);
	}
    else if (type->getKind() == Type::Kind::TUPLE) {
        auto* tupleType = static_cast<const TupleType*>(type);
        std::vector<llvm::Type*> elems;
        for (const auto& e : tupleType->elementTypes) {
            llvm::Type* et = getABIStorageType(e.get());
            if (!et) {
                std::cerr << "Error: Invalid element type in tuple" << std::endl;
                return nullptr;
            }
            elems.push_back(et);
        }
        return llvm::StructType::get(context, elems);
    }
    else if (type->getKind() == Type::Kind::POINTER) {
        auto* pointerType = static_cast<const PointerType*>(type);
        auto baseLLVMType = getLLVMType(pointerType->baseType.get());
        if (!baseLLVMType) {
            std::cerr << "Error: Invalid base type for pointer" << std::endl;
            return nullptr;
        }
        return llvm::PointerType::getUnqual(baseLLVMType);
	}
    else if (type->getKind() == Type::Kind::BOX) {
        auto* boxType = static_cast<const BoxType*>(type);
        auto baseLLVMType = getLLVMType(boxType->baseType.get());
        if (!baseLLVMType) {
            std::cerr << "Error: Invalid base type for box" << std::endl;
            return nullptr;
        }
        return llvm::PointerType::getUnqual(baseLLVMType);
    }
    else if (type->getKind() == Type::Kind::BORROW || type->getKind() == Type::Kind::MUTABLE_BORROW) {
        auto* borrowType = static_cast<const BorrowType*>(type);
        auto baseLLVMType = getLLVMType(borrowType->baseType.get());
        if (!baseLLVMType) {
            std::cerr << "Error: Invalid base type for borrow" << std::endl;
            return nullptr;
        }
        return llvm::PointerType::getUnqual(baseLLVMType);
    }
    else if (type->getKind() == Type::Kind::UNSAFE_POINTER) {
        auto* pointerType = static_cast<const UnsafePointerType*>(type);
        auto baseLLVMType = getLLVMType(pointerType->baseType.get());
        if (!baseLLVMType) {
            std::cerr << "Error: Invalid base type for unsafe pointer" << std::endl;
            return nullptr;
        }
        return llvm::PointerType::getUnqual(baseLLVMType);
    }
    else if (type->getKind() == Type::Kind::UNKNOWN) {
        std::cerr << "Error: Unknown type '" << type->getName() << "'" << std::endl;
        return nullptr;
    }
    return nullptr;
}
