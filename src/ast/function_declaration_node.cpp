#include "../../include/ast/function_declaration_node.h"
#include "../../include/ast/ast_visitor.h"
#include <iostream>

FunctionDeclarationNode::FunctionDeclarationNode() {
    nodeType = ASTNodeType::FUNCTION_DECLARATION;
}

void FunctionDeclarationNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* FunctionDeclarationNode::codegen() {
    // 클래스 메서드인지 확인
    bool isClassMethod = !codeGenerator->currentClassName.empty();
    ClassSymbol* classSymbol = nullptr;

    if (isClassMethod) {
        classSymbol = codeGenerator->symbolTable.lookupClass(codeGenerator->currentClassName);
        if (!classSymbol) {
            std::cerr << "Error: Undefined class '" << codeGenerator->currentClassName << "'" << std::endl;
            return nullptr;
        }
    }

    // 함수 타입 생성
    std::vector<llvm::Type*> argTypes;
    if (isClassMethod) {
        // 첫 번째 인자로 클래스 포인터를 받음 (this 포인터)
        llvm::Type* classType = classSymbol->classType->getPointerTo();
        argTypes.push_back(classType);
    }

    for (auto& param : parameters) {
        llvm::Type* paramType = codeGenerator->getLLVMType(param->type);
        if (!paramType) {
            std::cerr << "Error: Unsupported parameter type '" << param->type->name 
                     << "' in function '" << name << "'" << std::endl;
            return nullptr;
        }
        argTypes.push_back(paramType);
    }

    llvm::Type* llvmReturnType = codeGenerator->getLLVMType(returnType);
    if (!llvmReturnType) {
        std::cerr << "Error: Unsupported return type '" << returnType->name 
                 << "' in function '" << name << "'" << std::endl;
        return nullptr;
    }

    llvm::FunctionType* funcType = llvm::FunctionType::get(llvmReturnType, argTypes, false);

    // 함수 이름 설정 (클래스 메서드인 경우 클래스 이름을 접두사로 붙임)
    std::string functionName = isClassMethod ? (codeGenerator->currentClassName + "_" + name) : name;

    // 함수 생성
    llvm::Function* function = llvm::Function::Create(funcType, llvm::Function::ExternalLinkage, 
                                                    functionName, codeGenerator->module.get());

    // 심볼 테이블에 함수 추가
    std::vector<std::shared_ptr<Type>> paramTypeList;
    if (isClassMethod) {
        paramTypeList.push_back(std::make_shared<ClassType>(codeGenerator->currentClassName));
    }
    for (auto& param : parameters) {
        paramTypeList.push_back(param->type);
    }
    auto funcTypeObject = std::make_shared<FunctionType>(paramTypeList, returnType);

    Symbol functionSymbol(name, funcTypeObject, function, false, SymbolType::METHOD);
    if (isClassMethod && classSymbol) {
        classSymbol->methods[name].value = function;
    }
    else {
        functionSymbol.symbolType = SymbolType::FUNCTION;
        codeGenerator->symbolTable.addFunctionSymbol(name, functionSymbol);
    }

    // 함수 본문 생성
    llvm::BasicBlock* block = llvm::BasicBlock::Create(codeGenerator->context, "entry", function);
    codeGenerator->builder.SetInsertPoint(block);

    // 새로운 스코프 진입
    codeGenerator->symbolTable.enterScope();

    // 파라미터를 심볼 테이블에 추가하고 변수로 할당
    int idx = 0;
    for (auto& param : function->args()) {
        param.setName(parameters[idx]->name);
        Symbol paramSymbol(parameters[idx]->name, parameters[idx]->type, 
                         (llvm::Value*)&param, false, SymbolType::VARIABLE);
        codeGenerator->symbolTable.addSymbol(parameters[idx]->name, paramSymbol);
        idx += 1;
    }

    // 함수 본문 코드 생성
    llvm::Value* returnValue = body->codegen();

    // 반환 타입 처리
    if (llvmReturnType->isVoidTy()) {
        codeGenerator->builder.CreateRetVoid();
    }
    else {
        if (returnValue) {
            codeGenerator->builder.CreateRet(returnValue);
        }
        else {
            llvm::Value* defaultValue = llvm::Constant::getNullValue(llvmReturnType);
            codeGenerator->builder.CreateRet(defaultValue);
        }
    }

    // 스코프 종료
    codeGenerator->symbolTable.exitScope();

    // 삽입 지점 복원
    codeGenerator->builder.SetInsertPoint(&codeGenerator->mainFunction->getEntryBlock());

    return function;
}

std::shared_ptr<Type> FunctionDeclarationNode::getType() {
    return nullptr;
} 