#include "ClassInstanceCreationNode.h"
#include "ASTVisitor.h"

#include <iostream>
#include <llvm/IR/Function.h>
#include "utils.h"

void ClassInstanceCreationNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ClassInstanceCreationNode::codegen() {
    // primitive type인지, class type인지 확인, template type인지 확인
    // primitive type이면 llvm::CreateAlloca로
    if (isPrimitiveType(className)) {
        // new로 시작한 것이므로, malloc사용
        BasicType basicType(className);

        llvm::Type* type = codeGenerator->getLLVMType(&basicType);

        // type을 메모리 당할때 필요한 메모리 크기를 계산
        llvm::DataLayout dataLayout;
        uint64_t typeSize = dataLayout.getTypeAllocSize(type);
        llvm::Value* allocSize = llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(64, typeSize));

        // malloc함수 호출
        return codeGenerator->builder.CreateCall(codeGenerator->mallocFunction, allocSize, "malloc");
    }

    // Template Class인지 확인은 나중에 코드 추가되면...

    // 클래스 심볼 찾기
    auto classSymbolOpt = codeGenerator->symbolTable.lookupClass(className);
    if (!classSymbolOpt) {
        std::cerr << "Error: Class '" << className << "' not found" << std::endl;
        return nullptr;
    }

    auto classSymbol = (*classSymbolOpt);

    // 클래스 타입 가져오기
    llvm::StructType* classType = llvm::dyn_cast<llvm::StructType>(classSymbol->classType);
    if (!classType) {
        std::cerr << "Error: Unknown type about class '" << className << "'" << std::endl;
        return nullptr;
    }

    llvm::PointerType* classPtrTy = llvm::PointerType::getUnqual(classType);

    {
        std::vector<llvm::Type*> ctorArgTys;

        ctorArgTys.push_back(classPtrTy); // this 포인터 추가
        for (auto& field : classSymbol->constructorParams) {
            if (field.first.compare("this") == 0) continue;
            ctorArgTys.push_back(codeGenerator->getLLVMType(field.second->type.get()));
        }

        llvm::FunctionType* ctorFT = llvm::FunctionType::get(
            /*Result=*/llvm::Type::getVoidTy(codeGenerator->context),
            ctorArgTys,
            /*isVarArg=*/false
        );

        auto functionName = className + "_ctor";
        llvm::Function* ctorF = llvm::Function::Create(
            ctorFT,
            llvm::Function::ExternalLinkage,
            functionName,
            *codeGenerator->module
        );

        auto argIt = ctorF->arg_begin();
        argIt->setName("this_ptr");
        for (auto& field : classSymbol->constructorParams) {
            if (field.first.compare("this") == 0) continue;
            (++argIt)->setName("p_" + field.first);
        }

        // 3. BasicBlock 만들고 IRBuilder 삽입 위치 지정
        llvm::BasicBlock* bb = llvm::BasicBlock::Create(codeGenerator->context, "entry", ctorF);
        codeGenerator->builder.SetInsertPoint(bb);

        // 4. this_ptr->a = p_a; this_ptr->b = p_b;
        llvm::Value* thisPtr = ctorF->getArg(0);

        int fieldIndex = 0;
        for (auto& field : classSymbol->constructorParams) {
            if (field.first.compare("this") == 0) continue;

            llvm::Value* fieldPtr = codeGenerator->builder.CreateStructGEP(classType, thisPtr, fieldIndex, field.first + "_ptr");
            llvm::Value* paramValue = nullptr;
            for (auto& arg : ctorF->args()) {
                if (arg.getName() == "p_" + field.first) {
                    paramValue = &arg;
                    break;
                }
            }
            if (paramValue) {
                codeGenerator->builder.CreateStore(paramValue, fieldPtr);
            }
            fieldIndex++;
        }

        // 5. return void
        codeGenerator->builder.CreateRetVoid();
    }

    {
        // TODO: 어디다 생성할지 정하는 로직 필요
        // “객체 생성 + 생성자 호출” 예제
        llvm::FunctionType* useFT = llvm::FunctionType::get(llvm::Type::getVoidTy(codeGenerator->context), {}, false);
        llvm::Function* useF = llvm::Function::Create(useFT, llvm::Function::ExternalLinkage, "use", *codeGenerator->module);
        llvm::BasicBlock* bb = llvm::BasicBlock::Create(codeGenerator->context, "entry", useF);
        codeGenerator->builder.SetInsertPoint(bb);

        // alloca — 스택에 MyStruct 공간 할당
        llvm::Value* obj = codeGenerator->builder.CreateAlloca(classType, nullptr, "obj");

        // 생성자 호출
        llvm::Function* ctorF = codeGenerator->module->getFunction(className + "_ctor");
        // 인자: this, int, double
        llvm::Value* arg_int = llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(32, 123));
        llvm::Value* arg_double = llvm::ConstantFP::get(codeGenerator->context, llvm::APFloat(3.1415));
        codeGenerator->builder.CreateCall(ctorF, { obj, arg_int, arg_double });

        codeGenerator->builder.CreateRetVoid();
    }

    return nullptr;
}

std::shared_ptr<Type> ClassInstanceCreationNode::getType() {
    return std::make_shared<ClassType>(className);
}