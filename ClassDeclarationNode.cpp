#include "codegen.h"
#include "ClassDeclarationNode.h"
#include "ASTVisitor.h"
#include "ast.h"
#include "symbol.h"

#include <iostream>
#include <llvm/IR/Function.h>

void ClassDeclarationNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ClassDeclarationNode::codegen() {
    // 상위 클래스 심볼 찾기
    ClassSymbol* superClassSymbol = nullptr;
    if (!superClassName.empty()) {
        auto superClassSymbolOpt = CodeGenerator::getInstance().symbolTable.lookup(superClassName);
        if (superClassSymbolOpt) {
            superClassSymbol = static_cast<ClassSymbol*>(*superClassSymbolOpt);
        }

        if (!superClassSymbol) {
            std::cerr << "Error: Undefined superclass '" << superClassName << "' for class '" << name << "'" << std::endl;
            return nullptr;
        }
    }

    // 클래스 심볼 생성 및 클래스 타입 저장
    ClassSymbol* classSymbol = new ClassSymbol(name, nullptr, superClassName);
    classSymbol->superClassSymbol = superClassSymbol;

    // 필드 및 메서드 수집
    if (superClassSymbol) {
        for (auto& field : superClassSymbol->fields) {
            classSymbol->fields[field.first] = std::make_unique<Symbol>(field.second.get());
        }
        for (auto& method : superClassSymbol->methods) {
            classSymbol->methods[method.first] = std::make_unique<Symbol>(method.second.get());
        }
    }

    // 현재 클래스의 필드와 메서드 추가 또는 오버라이딩
    for (auto& field : constructorParams) {
        llvm::Type* fieldType = CodeGenerator::getInstance().getLLVMType(field->type.get());
        if (!fieldType) {
            std::cerr << "Error: Unsupported field type '" << field->type->getName() << "' in class '" << name << "'" << std::endl;
            return nullptr;
        }

        auto f = (ParameterNode*)(field.get());
        Symbol* fieldSymbol = new Symbol(f->name, f->type.get(), nullptr, false, SymbolType::FIELD);
        classSymbol->constructorParams[f->name] = std::make_unique<Symbol>(fieldSymbol);
    }

    for (auto& field : ((ClassBodyNode*)(body.get()))->fields) {
        llvm::Type* fieldType = CodeGenerator::getInstance().getLLVMType(field->type.get());
        if (!fieldType) {
            std::cerr << "Error: Unsupported field type '" << field->type->getName() << "' in class '" << name << "'" << std::endl;
            return nullptr;
        }

		auto f = dynamic_cast<VariableDeclarationNode*>(field.get());
        Symbol* fieldSymbol = new Symbol(f->name, field->type.get(), nullptr, f->isMutable, SymbolType::FIELD);
        classSymbol->fields[f->name] = std::make_unique<Symbol>(fieldSymbol);
    }

    // 클래스 타입 생성
    std::vector<llvm::Type*> fieldTypes;
    // 생성자 파라메터 추가
    for (auto& fieldEntry : classSymbol->constructorParams) {
        llvm::Type* fieldType = CodeGenerator::getInstance().getLLVMType(fieldEntry.second->type.get());
        if (!fieldType) {
            std::cerr << "Error: Unsupported field type '" << fieldEntry.second->type->getName() << "' in class '" << name << "'" << std::endl;
            return nullptr;
        }
        fieldTypes.push_back(fieldType);
    }

    // 일반 필드 추가
    for (auto& fieldEntry : classSymbol->fields) {
        llvm::Type* fieldType = CodeGenerator::getInstance().getLLVMType(fieldEntry.second->type.get());
        if (!fieldType) {
            std::cerr << "Error: Unsupported field type '" << fieldEntry.second->type->getName() << "' in class '" << name << "'" << std::endl;
            return nullptr;
        }
        fieldTypes.push_back(fieldType);
    }

    llvm::StructType* classType = llvm::StructType::create(CodeGenerator::getInstance().context, fieldTypes, name);
    classSymbol->classType = classType;

    // 메서드 선언 생성 (실제 코드 생성은 나중에 수행)
    for (auto& method : ((ClassBodyNode*)(body.get()))->methods) {
		auto md = dynamic_cast<FunctionDeclarationNode*>(method.get());
        declareMethod(md, classSymbol);
    }

    // 심볼 테이블에 클래스 심볼 추가
    CodeGenerator::getInstance().symbolTable.addSymbol(name, classSymbol);

    return nullptr;
}

void ClassDeclarationNode::declareMethod(FunctionDeclarationNode* method, ClassSymbol* classSymbol) {
    std::vector<llvm::Type*> paramTypes;
    paramTypes.push_back(classSymbol->classType->getPointerTo()); // this 포인터 타입

    for (auto& param : method->parameters) {
        llvm::Type* paramType = CodeGenerator::getInstance().getLLVMType(param->type.get());
        if (!paramType) {
            std::cerr << "Error: Not supported the parameter's type of '" << method->name << "'" << std::endl;
            return;
        }
        paramTypes.push_back(paramType);
    }

    llvm::Type* returnType = CodeGenerator::getInstance().getLLVMType(method->returnType.get());
    if (!returnType) {
        std::cerr << "Error: Not supported the return type of '" << method->name << "'" << std::endl;
        return;
    }

    llvm::FunctionType* funcType = llvm::FunctionType::get(returnType, paramTypes, false);
    std::string methodName = name + "_" + method->name; // 클래스 이름을 접두사로 사용
    llvm::Function* function = llvm::Function::Create(funcType, llvm::Function::ExternalLinkage, methodName, CodeGenerator::getInstance().module.get());

    std::vector<std::unique_ptr<Type>> types;
    types.push_back(std::make_unique<ClassType>(name));
    for (auto& param : method->parameters) {
        types.push_back(param->getType()->clone());
    }

    // 메서드 심볼 업데이트
    Symbol* methodSymbol = new Symbol(method->name, new FunctionType(types, method->returnType), function, false, SymbolType::METHOD);
    classSymbol->methods[method->name] = std::make_unique<Symbol>(methodSymbol);

    // 메서드 본문 생성을 지연시키기 위해 FunctionDeclarationNode를 저장
    classSymbol->methodBodies[method->name] = std::make_unique<FunctionDeclarationNode>(method);
    //classSymbol->methodBodies[method->name] = method;
}