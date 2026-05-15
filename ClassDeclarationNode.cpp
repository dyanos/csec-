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
    auto& cg = CodeGenerator::getInstance();

    // 상위 클래스 심볼 찾기
    ClassSymbol* superClassSymbol = nullptr;

    if (!superClassName.empty()) {
        superClassSymbol = cg.symbolTable.lookupClass(superClassName);
        if (!superClassSymbol) {
            std::cerr << "Error: Undefined superclass '" << superClassName << "' for class '" << name << "'" << std::endl;
            return nullptr;
        }
    }

    // 클래스 심볼 생성 및 클래스 타입 저장
    auto classSymbol = std::make_unique<ClassSymbol>(name, nullptr, superClassName);
    classSymbol->superClassSymbol = superClassSymbol;

    // 필드 및 메서드 수집
    if (superClassSymbol) {
        for (auto& field : superClassSymbol->fields) {
            classSymbol->fields[field.first] = field.second ? field.second->clone() : nullptr;
        }
        for (auto& method : superClassSymbol->methods) {
            classSymbol->methods[method.first] = method.second ? method.second->clone() : nullptr;
        }
    }

    // 현재 클래스의 필드와 메서드 추가 또는 오버라이딩
    for (auto& field : constructorParams) {
        llvm::Type* fieldType = cg.getLLVMType(field->type.get());
        if (!fieldType) {
            
            std::cerr << "Error: Unsupported field type '" << field->type->getName() << "' in class '" << name << "'" << std::endl;
            return nullptr;
        }

        auto f = dynamic_cast<ParameterNode*>(field.get());
        if (!f) {
            std::cerr << "Error: Expected parameter node in constructor of '" << name << "'" << std::endl;
            return nullptr;
        }
        classSymbol->constructorParams[f->name] = std::make_unique<Symbol>(f->name, f->type->clone(), nullptr, false, SymbolType::FIELD);
    }

    auto* classBody = dynamic_cast<ClassBodyNode*>(body.get());
    if (!classBody) {
        std::cerr << "Error: Expected class body in class '" << name << "'" << std::endl;
        return nullptr;
    }

    for (auto& field : classBody->fields) {
        llvm::Type* fieldType = cg.getLLVMType(field->type.get());
        if (!fieldType) {
            
            std::cerr << "Error: Unsupported field type '" << field->type->getName() << "' in class '" << name << "'" << std::endl;
            return nullptr;
        }

		auto f = dynamic_cast<VariableDeclarationNode*>(field.get());
		if (!f) {
			std::cerr << "Error: Expected variable declaration in class body of '" << name << "'" << std::endl;
			return nullptr;
		}
        classSymbol->fields[f->name] = std::make_unique<Symbol>(f->name, field->type->clone(), nullptr, f->isMutable, SymbolType::FIELD);
    }

    // 클래스 타입 생성
    std::vector<llvm::Type*> fieldTypes;
    // 생성자 파라메터 추가 (use source-ordered constructorParams to ensure deterministic layout)
    for (auto& field : constructorParams) {
        auto f = dynamic_cast<ParameterNode*>(field.get());
        if (!f) continue;
        llvm::Type* fieldType = cg.getLLVMType(f->type.get());
        if (!fieldType) {
            std::cerr << "Error: Unsupported field type '" << f->type->getName() << "' in class '" << name << "'" << std::endl;
            return nullptr;
        }
        fieldTypes.push_back(fieldType);
    }

    // 일반 필드 추가 (use source-ordered classBody->fields to ensure deterministic layout)
    for (auto& field : classBody->fields) {
        llvm::Type* fieldType = cg.getLLVMType(field->type.get());
        if (!fieldType) {
            std::cerr << "Error: Unsupported field type '" << field->type->getName() << "' in class '" << name << "'" << std::endl;
            return nullptr;
        }
        fieldTypes.push_back(fieldType);
    }

    llvm::StructType* classType = llvm::StructType::create(cg.context, fieldTypes, name);
    classSymbol->classType = classType;

    // 메서드 선언 생성 (실제 코드 생성은 나중에 수행)
    for (auto& method : classBody->methods) {
		auto md = dynamic_cast<FunctionDeclarationNode*>(method.get());
		if (!md) {
			std::cerr << "Error: Expected function declaration in class body of '" << name << "'" << std::endl;
			continue;
		}
        declareMethod(md, classSymbol.get());
    }

    // 심볼 테이블에 클래스 심볼 추가
    cg.symbolTable.addSymbol(name, std::move(classSymbol));

    return nullptr;
}

void ClassDeclarationNode::declareMethod(FunctionDeclarationNode* method, ClassSymbol* classSymbol) {
    auto& cg = CodeGenerator::getInstance();

    std::vector<llvm::Type*> paramTypes;
    paramTypes.push_back(llvm::PointerType::get(cg.context, 0)); // this 포인터 타입

    for (auto& param : method->parameters) {
        llvm::Type* paramType = cg.getLLVMType(param->type.get());
        if (!paramType) {
            std::cerr << "Error: Not supported the parameter's type of '" << method->name << "'" << std::endl;
            return;
        }
        paramTypes.push_back(paramType);
    }

    llvm::Type* returnType = cg.getLLVMType(method->returnType.get());
    if (!returnType) {
        std::cerr << "Error: Not supported the return type of '" << method->name << "'" << std::endl;
        return;
    }

    llvm::FunctionType* funcType = llvm::FunctionType::get(returnType, paramTypes, false);
    std::string methodName = name + "_" + method->name; // 클래스 이름을 접두사로 사용
    llvm::Function* function = llvm::Function::Create(funcType, llvm::Function::ExternalLinkage, methodName, cg.module.get());

    std::vector<std::unique_ptr<Type>> types;
    types.push_back(std::make_unique<ClassType>(name));
    for (auto& param : method->parameters) {
        types.push_back(param->getType()->clone());
    }

    // 메서드 심볼 업데이트
    auto methodSymbol = std::make_unique<Symbol>(method->name, std::make_unique<FunctionType>(types, method->returnType), function, false, SymbolType::METHOD);
    classSymbol->methods[method->name] = std::move(methodSymbol);

    // 메서드 본문 생성을 지연시키기 위해 FunctionDeclarationNode를 저장
        classSymbol->methodBodies[method->name] = std::make_unique<FunctionDeclarationNode>(*method);
    //classSymbol->methodBodies[method->name] = method;
}
