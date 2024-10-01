// codegen.cpp
#include "codegen.h"
#include <llvm/IR/Verifier.h>
#include <llvm/IR/Type.h>
#include <llvm/Support/raw_ostream.h>

#include <iostream>


CodeGenerator::CodeGenerator() : builder(context) {
    module = std::make_unique<llvm::Module>("main", context);

    // main �Լ� ����
    llvm::FunctionType* funcType = llvm::FunctionType::get(builder.getInt32Ty(), false);
    mainFunction = llvm::Function::Create(funcType, llvm::Function::ExternalLinkage, "main", module.get());

	// mallocFunction�� freeFunction�� Type�� ���߿��� ���� �ʿ�
    // ������ AddressSpace�� 0�̱� ������, �� �κ��� ���߿� ������ ������ �ִ��� Ȯ�� �ʿ�
	//mallocFunction = llvm::Function::Create(llvm::FunctionType::get(llvm::PointerType::get(context, 0), { llvm::Type::getInt32Ty(context) }, false), llvm::Function::ExternalLinkage, "malloc", module.get());
	//freeFunction = llvm::Function::Create(llvm::FunctionType::get(llvm::Type::getVoidTy(context), { llvm::PointerType::get(context, 0) }, false), llvm::Function::ExternalLinkage, "free", module.get());

    // ��Ʈ�� ���� ����
    llvm::BasicBlock* entry = llvm::BasicBlock::Create(context, "entry", mainFunction);
    builder.SetInsertPoint(entry);

	symbolTable.initializeBuiltInTypes();

    // ��� �δ� �ʱ�ȭ
    moduleLoader = ModuleLoader();
}

void CodeGenerator::generateCode(std::shared_ptr<ProgramNode> program) {
    program->codegen();
    builder.CreateRet(builder.getInt32(0));
}

void CodeGenerator::dumpIR() {
    module->print(llvm::outs(), nullptr);
}

llvm::Type* CodeGenerator::getLLVMType(std::shared_ptr<Type> type) {
    if (type->kind == TypeKind::BASIC || type->kind == TypeKind::FUNCTION || type->kind == TypeKind::CLASS) {
        if (type->name == "Int") {
            return llvm::Type::getInt32Ty(context);
        }
        else if (type->name == "Float") {
            return llvm::Type::getFloatTy(context);
        }
        else if (type->name == "Double") {
            return llvm::Type::getDoubleTy(context);
        }
        else if (type->name == "Unit") {
            return llvm::Type::getVoidTy(context);
        }
        else if (type->name == "String") {
            return llvm::PointerType::getUnqual(llvm::Type::getInt8Ty(context));
        }
		else if (type->name == "Boolean") {
			return llvm::Type::getInt1Ty(context);
		}
		else if (type->name == "Void") {
			return llvm::Type::getVoidTy(context);
		}
		else if (type->name == "Array") {
			return llvm::PointerType::getUnqual(llvm::Type::getInt8Ty(context));
		}
		else if (type->name == "Any") {
			return llvm::PointerType::getUnqual(llvm::Type::getInt8Ty(context));
		}
    }
    else if (type->kind == TypeKind::CLASS) {
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
		auto ty = std::static_pointer_cast<GenericType>(type);

        ClassSymbol* classSymbol = symbolTable.lookupClass(ty->baseType->name);
        if (classSymbol) {
            return classSymbol->classType->getPointerTo();
        }
        else {
            std::cerr << "Error: Undefined class type '" << ty->baseType->name << "'" << std::endl;
            return nullptr;
        }
    }
    else {
        std::cerr << "Undefined type: " << type->name << std::endl;
    }

    return nullptr;
}