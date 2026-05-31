#include "codegen.h"
#include "ClassDeclarationNode.h"
#include "ASTVisitor.h"
#include "ast.h"
#include "symbol.h"

#include <iostream>
#include <sstream>
#include <llvm/IR/Function.h>
#include <llvm/IR/Instructions.h>

namespace {
std::string methodStorageKey(const std::string& methodName, const std::vector<std::unique_ptr<ASTNode>>& parameters) {
    if (parameters.empty()) {
        return methodName;
    }

    std::ostringstream key;
    key << methodName;
    for (const auto& param : parameters) {
        auto type = param ? param->getType() : nullptr;
        key << "@" << (type ? type->getName() : "Unknown");
    }
    return key.str();
}
}

void ClassDeclarationNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ClassDeclarationNode::codegen() {
    auto& cg = CodeGenerator::getInstance();
    if (this->isExternal && !body) {
        return nullptr;
    }

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
    ClassSymbol* classSymbol = cg.symbolTable.lookupClass(name);
    if (!classSymbol) {
        auto symbol = std::make_unique<ClassSymbol>(name, nullptr, superClassName);
        symbol->superClassSymbol = superClassSymbol;
        classSymbol = symbol.get();
        cg.symbolTable.addSymbol(name, std::move(symbol));
    }
    else {
        classSymbol->superClassName = superClassName;
        classSymbol->superClassSymbol = superClassSymbol;
        classSymbol->constructorParams.clear();
        classSymbol->fields.clear();
        classSymbol->methods.clear();
        classSymbol->methodBodies.clear();
    }

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
        auto f = dynamic_cast<ParameterNode*>(field.get());
        if (!f || !f->type) {
            std::cerr << "Error: Expected typed parameter node in constructor of '" << name << "'" << std::endl;
            return nullptr;
        }

        llvm::Type* fieldType = cg.getLLVMType(f->type.get());
        if (!fieldType) {
            std::cerr << "Error: Unsupported field type '" << f->type->getName() << "' in class '" << name << "'" << std::endl;
            return nullptr;
        }

        classSymbol->constructorParams[f->name] = std::make_unique<Symbol>(f->name, f->type->clone(), nullptr, false, SymbolType::FIELD);
    }

    auto* classBody = dynamic_cast<ClassBodyNode*>(body.get());
    if (!classBody) {
        if (this->isExternal) {
            return nullptr;
        }
        std::cerr << "Error: Expected class body in class '" << name << "'" << std::endl;
        return nullptr;
    }
    for (auto& field : classBody->fields) {
		auto f = dynamic_cast<VariableDeclarationNode*>(field.get());
		if (!f || !f->type) {
			std::cerr << "Error: Expected typed variable declaration in class body of '" << name << "'" << std::endl;
			return nullptr;
		}
        llvm::Type* fieldType = cg.getLLVMType(f->type.get());
        if (!fieldType) {
            std::cerr << "Error: Unsupported field type '" << f->type->getName() << "' in class '" << name << "'" << std::endl;
            return nullptr;
        }
        classSymbol->fields[f->name] = std::make_unique<Symbol>(f->name, f->type->clone(), nullptr, f->isMutable, SymbolType::FIELD);
    }

    // 클래스 타입 생성
    auto resolveStorageType = [&](const Type* declaredType) -> llvm::Type* {
        if (!declaredType) {
            return nullptr;
        }

        llvm::Type* llvmType = cg.getLLVMType(declaredType);
        if (!llvmType) {
            return nullptr;
        }

        if (declaredType->getKind() == Type::Kind::CLASS) {
            return llvm::PointerType::getUnqual(llvmType);
        }

        return llvmType;
    };

    std::vector<llvm::Type*> fieldTypes;
    // 생성자 파라메터 추가 (use source-ordered constructorParams to ensure deterministic layout)
    for (auto& field : constructorParams) {
        auto f = dynamic_cast<ParameterNode*>(field.get());
        if (!f) continue;
        llvm::Type* fieldType = resolveStorageType(f->type.get());
        if (!fieldType) {
            std::cerr << "Error: Unsupported field type '" << f->type->getName() << "' in class '" << name << "'" << std::endl;
            return nullptr;
        }
        fieldTypes.push_back(fieldType);
    }

    // 일반 필드 추가 (use source-ordered classBody->fields to ensure deterministic layout)
    for (auto& field : classBody->fields) {
        auto* fieldNode = dynamic_cast<VariableDeclarationNode*>(field.get());
        if (!fieldNode || !fieldNode->type) {
            std::cerr << "Error: Expected typed field declaration in class '" << name << "'" << std::endl;
            return nullptr;
        }
        llvm::Type* fieldType = resolveStorageType(fieldNode->type.get());
        if (!fieldType) {
            std::cerr << "Error: Unsupported field type '" << fieldNode->type->getName() << "' in class '" << name << "'" << std::endl;
            return nullptr;
        }
        fieldTypes.push_back(fieldType);
    }

    llvm::StructType* classType = llvm::dyn_cast_or_null<llvm::StructType>(classSymbol->classType);
    if (!classType) {
        classType = llvm::StructType::create(cg.context, name);
    }
    if (classType->isOpaque()) {
        classType->setBody(fieldTypes, false);
    }
    classSymbol->classType = classType;

    // 메서드 선언 생성 (실제 코드 생성은 나중에 수행)
    for (auto& method : classBody->methods) {
		auto md = dynamic_cast<FunctionDeclarationNode*>(method.get());
		if (!md) {
			std::cerr << "Error: Expected function declaration in class body of '" << name << "'" << std::endl;
			continue;
		}
        declareMethod(md, classSymbol);
    }

    for (auto& method : classBody->methods) {
        auto md = dynamic_cast<FunctionDeclarationNode*>(method.get());
        if (!md) {
            continue;
        }
        defineMethod(md, classSymbol, classBody);
    }

    // 심볼 테이블에 클래스 심볼 추가
    return nullptr;
}

void ClassDeclarationNode::declareMethod(FunctionDeclarationNode* method, ClassSymbol* classSymbol) {
    auto& cg = CodeGenerator::getInstance();

    std::vector<llvm::Type*> paramTypes;
    paramTypes.push_back(llvm::PointerType::get(cg.context, 0)); // this 포인터 타입

    for (auto& param : method->parameters) {
        auto* paramNode = dynamic_cast<ParameterNode*>(param.get());
        if (!paramNode || !paramNode->type) {
            std::cerr << "Error: Expected typed parameter in method '" << method->name << "'" << std::endl;
            return;
        }
        llvm::Type* paramType = cg.getLLVMType(paramNode->type.get());
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
    std::string storageKey = methodStorageKey(method->name, method->parameters);
    if (method->isOverride && !classSymbol->superClassSymbol) {
        std::cerr << "Error: Method '" << method->name << "' is marked override but class '" << name << "' has no superclass" << std::endl;
        return;
    }
    if (method->isOverride && classSymbol->superClassSymbol) {
        std::vector<std::unique_ptr<Type>> argTypes;
        for (auto& param : method->parameters) {
            argTypes.push_back(param->getType() ? param->getType()->clone() : std::make_unique<UnknownType>());
        }
        if (!cg.symbolTable.lookupMethod(*classSymbol->superClassSymbol, method->name, argTypes)) {
            std::cerr << "Error: Method '" << method->name << "' is marked override but no matching superclass method exists" << std::endl;
            return;
        }
    }

    auto methodSymbol = std::make_unique<Symbol>(method->name, std::make_unique<FunctionType>(types, method->returnType), function, false, SymbolType::METHOD);
    classSymbol->methods[storageKey] = std::move(methodSymbol);

    // 메서드 본문 생성을 지연시키기 위해 FunctionDeclarationNode를 저장
        classSymbol->methodBodies[storageKey] = std::make_unique<FunctionDeclarationNode>(*method);
    //classSymbol->methodBodies[method->name] = method;
}

llvm::Function* ClassDeclarationNode::defineMethod(FunctionDeclarationNode* method, ClassSymbol* classSymbol, ClassBodyNode* classBody) {
    if (!method || !classSymbol || !classBody || !method->body) {
        return nullptr;
    }

    auto& cg = CodeGenerator::getInstance();
    std::string storageKey = methodStorageKey(method->name, method->parameters);
    auto methodIt = classSymbol->methods.find(storageKey);
    if (methodIt == classSymbol->methods.end() || !methodIt->second) {
        return nullptr;
    }

    auto* function = llvm::dyn_cast_or_null<llvm::Function>(methodIt->second->value);
    if (!function) {
        return nullptr;
    }
    if (!function->empty()) {
        return function;
    }

    auto* classType = llvm::dyn_cast_or_null<llvm::StructType>(classSymbol->classType);
    if (!classType) {
        std::cerr << "Error: Invalid class type for method '" << method->name << "'" << std::endl;
        return nullptr;
    }

    llvm::BasicBlock* savedBlock = cg.builder.GetInsertBlock();
    auto savedPoint = cg.builder.GetInsertPoint();
    auto* savedCurrentSymbol = cg.symbolTable.getCurrentSymbol();

    cg.symbolTable.saveCurrentSymbol();
    cg.symbolTable.setCurrentSymbol(nullptr);
    cg.symbolTable.enterScope();

    auto* entry = llvm::BasicBlock::Create(cg.context, "entry", function);
    cg.builder.SetInsertPoint(entry);

    auto argIt = function->arg_begin();
    if (argIt == function->arg_end()) {
        std::cerr << "Error: Method '" << method->name << "' is missing this parameter" << std::endl;
        cg.symbolTable.exitScope();
        cg.symbolTable.popCurrentSymbol();
        cg.symbolTable.setCurrentSymbol(savedCurrentSymbol);
        if (savedBlock) {
            cg.builder.SetInsertPoint(savedBlock, savedPoint);
        }
        return nullptr;
    }

    llvm::Value* thisValue = &*argIt++;
    thisValue->setName("this");
    auto* classPtrType = llvm::PointerType::getUnqual(classType);
    if (thisValue->getType() != classPtrType) {
        thisValue = cg.builder.CreateBitCast(thisValue, classPtrType, "this.class");
    }

    cg.symbolTable.addSymbol(
        "this",
        std::make_unique<Symbol>("this", std::make_unique<ClassType>(name), thisValue, false, SymbolType::VARIABLE));

    int fieldIndex = 0;
    auto bindField = [&](const std::string& fieldName, const std::unique_ptr<Type>& fieldType, bool isMutable) {
        if (!fieldType) {
            return;
        }
        llvm::Value* fieldPtr = cg.builder.CreateStructGEP(
            classType,
            thisValue,
            static_cast<unsigned>(fieldIndex),
            fieldName + ".field");
        cg.symbolTable.addSymbol(
            fieldName,
            std::make_unique<Symbol>(fieldName, fieldType->clone(), fieldPtr, isMutable, SymbolType::FIELD));
        fieldIndex += 1;
    };

    for (auto& field : constructorParams) {
        auto* param = dynamic_cast<ParameterNode*>(field.get());
        if (!param) {
            continue;
        }
        bindField(param->name, param->type, false);
    }

    for (auto& field : classBody->fields) {
        auto* fieldNode = dynamic_cast<VariableDeclarationNode*>(field.get());
        if (!fieldNode) {
            continue;
        }
        bindField(fieldNode->name, fieldNode->type, fieldNode->isMutable);
    }

    for (auto& param : method->parameters) {
        auto* paramNode = dynamic_cast<ParameterNode*>(param.get());
        if (!paramNode || !paramNode->type || argIt == function->arg_end()) {
            continue;
        }

        llvm::Value* argValue = &*argIt++;
        argValue->setName(paramNode->name);
        cg.symbolTable.addSymbol(
            paramNode->name,
            std::make_unique<Symbol>(paramNode->name, paramNode->type->clone(), argValue, false, SymbolType::VARIABLE));
    }

    method->body->codegen();

    llvm::BasicBlock* currentBlock = cg.builder.GetInsertBlock();
    if (currentBlock && !currentBlock->getTerminator()) {
        llvm::Type* returnType = function->getReturnType();
        if (returnType->isVoidTy()) {
            cg.builder.CreateRetVoid();
        }
        else if (returnType->isIntegerTy()) {
            cg.builder.CreateRet(llvm::ConstantInt::get(returnType, 0));
        }
        else if (returnType->isFloatingPointTy()) {
            cg.builder.CreateRet(llvm::ConstantFP::get(returnType, 0.0));
        }
        else {
            cg.builder.CreateRet(llvm::Constant::getNullValue(returnType));
        }
    }

    cg.symbolTable.exitScope();
    cg.symbolTable.popCurrentSymbol();
    cg.symbolTable.setCurrentSymbol(savedCurrentSymbol);
    if (savedBlock) {
        cg.builder.SetInsertPoint(savedBlock, savedPoint);
    }

    return function;
}
