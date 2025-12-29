// codegen.cpp
#include "codegen.h"
#include <llvm/IR/Verifier.h>
#include <llvm/IR/Type.h>
#include <llvm/Support/raw_ostream.h>

#include <iostream>

#include "ProgramNode.h"


CodeGenerator::CodeGenerator() : builder(context) {
    module = std::make_unique<llvm::Module>("main", context);

    llvm::FunctionType* funcType = llvm::FunctionType::get(builder.getInt32Ty(), false);
    mainFunction = llvm::Function::Create(funcType, llvm::Function::ExternalLinkage, "main", module.get());

    llvm::BasicBlock* entry = llvm::BasicBlock::Create(context, "entry", mainFunction);
    builder.SetInsertPoint(entry);

    mallocFunction = module->getFunction("malloc");
    if (!mallocFunction) {
        mallocFunction = llvm::Function::Create(
            llvm::FunctionType::get(llvm::PointerType::getUnqual(llvm::Type::getInt8Ty(context)), { llvm::Type::getInt64Ty(context) }, false),
            llvm::Function::ExternalLinkage,
            "malloc",
            module.get()
        );
    }

    freeFunction = module->getFunction("free");
    if (!freeFunction) {
        freeFunction = llvm::Function::Create(
            llvm::FunctionType::get(llvm::Type::getVoidTy(context), { llvm::PointerType::getUnqual(llvm::Type::getInt8Ty(context)) }, false),
            llvm::Function::ExternalLinkage,
            "free",
            module.get()
        );
    }

    symbolTable.initializeBuiltInTypes(context);

	// int클래스에 추가된 toString메서드의 llvm 코드 생성
	auto initClassSymbolOpt = symbolTable.lookupClass("Int");
    if (!initClassSymbolOpt) {
        std::cerr << "Error: 'Int' class not found in symbol table." << std::endl;
        return;
	}
    auto initClassSymbol = *initClassSymbolOpt;
	auto toStringFunction = llvm::Function::Create(
		llvm::FunctionType::get(llvm::PointerType::getUnqual(llvm::Type::getInt8Ty(context)), { initClassSymbol->classType->getPointerTo() }, false),
		llvm::Function::ExternalLinkage,
		"toString",
		module.get()
	);

    llvm::Function::Create(
		llvm::FunctionType::get(llvm::Type::getInt8Ty(context)->getPointerTo(), { llvm::Type::getInt8Ty(context)->getPointerTo(), llvm::Type::getInt8Ty(context)->getPointerTo() }, false),
		llvm::Function::ExternalLinkage,
		"operator+",
		module.get()
	);

    // print 함수 생성
    llvm::Function::Create(
        llvm::FunctionType::get(llvm::Type::getVoidTy(context), { llvm::Type::getInt8Ty(context)->getPointerTo() }, false),
        llvm::Function::ExternalLinkage,
        "print",
        module.get()
    );

    llvm::Function::Create(
        llvm::FunctionType::get(llvm::Type::getVoidTy(context), { llvm::Type::getInt8Ty(context)->getPointerTo() }, false),
        llvm::Function::ExternalLinkage,
        "println",
        module.get()
    );
}

void CodeGenerator::generateCode(std::shared_ptr<ProgramNode> program) {
    program->codegen();

    builder.CreateRet(builder.getInt32(0));
}

void CodeGenerator::dumpIR() {
    module->print(llvm::outs(), nullptr);
}

llvm::Type* CodeGenerator::getLLVMType(const Type* type) {
    if (type->getKind() == Type::Kind::BASIC) {
        if (type->isIntegerTy()) {
            return llvm::Type::getInt32Ty(context);
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
    }
    else if (type->getKind() == Type::Kind::CLASS) {
        // 클래스 타입 처리
        auto classSymbolOpt = symbolTable.lookup(type->getName());

		// Symbol을 ClassSymbol로 캐스팅하여 classType에 접근
        if (classSymbolOpt) {
            return static_cast<ClassSymbol*>(*classSymbolOpt)->classType;
		}
		else {
			std::cerr << "Error: Undefined class type '" << type->getName() << "'" << std::endl;
			return nullptr;
		}
    }
    else if (type->getKind() == Type::Kind::GENERIC) {
        auto genericType = (GenericType*)(type);
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
        std::cerr << "Error: Unsupported generic type '" << genericType->baseType->getName() << "'" << std::endl;
        return nullptr;
    }
    else if (type->getKind() == Type::Kind::UNKNOWN) {
        std::cerr << "Error: Unknown type '" << type->getName() << "'" << std::endl;
        return nullptr;
    }
    return nullptr;
}