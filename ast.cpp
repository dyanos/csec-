// ast.cpp
#include "token.h"
#include "ast.h"
#include "codegen.h"
#include "utils.h"

#include <iostream>


CodeGenerator* ASTNode::codeGenerator = nullptr;

//   accept  codegen Լ

void ProgramNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ProgramNode::codegen() {
    llvm::Value* last = nullptr;
    for (auto& stmt : statements) {
        last = stmt->codegen();
    }
    return last;
}

void ParameterNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ParameterNode::codegen() {
	// 함수의 Parameter는 local변수로 처리
	llvm::Type* paramType = codeGenerator->getLLVMType(type);
    if (!paramType) {
        std::cerr << "Error: Unsupported parameter type '" << type->name << "' in function '" << name << "'" << std::endl;
        return nullptr;
    }

	llvm::AllocaInst* alloc = codeGenerator->builder.CreateAlloca(paramType, nullptr, name.c_str());
	Symbol symbol(name, type, alloc, false, SymbolType::VARIABLE);
	codeGenerator->symbolTable.addSymbol(name, symbol);
    return alloc;
}

void ImportNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ImportNode::codegen() {
    auto moduleSymbols = codeGenerator->moduleLoader.loadModule(path);
    if (moduleSymbols) {
        //  ɺ  ɺ ̺
        codeGenerator->symbolTable.merge(moduleSymbols);
    }
    else {
        std::cerr << "Error: Failed to import module ";
        for (const auto& p : path) {
            std::cerr << p << ".";
        }
        std::cerr << std::endl;
        return nullptr;
    }
    return nullptr;
}

void ObjectDeclarationNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ObjectDeclarationNode::codegen() {
    if (body) {
        return body->codegen();
    }
    return nullptr;
}

void ClassDeclarationNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ClassDeclarationNode::codegen() {
    // 상위 클래스 심볼 찾기
    ClassSymbol* superClassSymbol = nullptr;
    if (!superClassName.empty()) {
        superClassSymbol = codeGenerator->symbolTable.lookupClass(superClassName);
        if (!superClassSymbol) {
            std::cerr << "Error: Undefined superclass '" << superClassName << "' for class '" << name << "'" << std::endl;
            return nullptr;
        }
    }

    // 클래스 심볼 생성 및 클래스 타입 저장
    ClassSymbol classSymbol(name, nullptr, superClassName);
    classSymbol.superClassSymbol = superClassSymbol;

    // 필드 및 메서드 수집
    // 상위 클래스의 필드와 메서드를 복사
    if (superClassSymbol) {
        classSymbol.fields = superClassSymbol->fields;
        classSymbol.methods = superClassSymbol->methods;
    }

    // 현재 클래스의 필드와 메서드 추가 또는 오버라이딩
    // 필드 처리
    for (auto& field : body->fields) {
        llvm::Type* fieldType = codeGenerator->getLLVMType(field->type);
        if (!fieldType) {
            std::cerr << "Error: Unsupported field type '" << field->type->name << "' in class '" << name << "'" << std::endl;
            return nullptr;
        }

		llvm::AllocaInst* alloc = codeGenerator->builder.CreateAlloca(fieldType, nullptr, field->name.c_str());
        Symbol fieldSymbol(field->name, field->type, alloc, field->isMutable, SymbolType::FIELD);
        classSymbol.fields[field->name] = fieldSymbol;
    }

    // 메서드 처리
    for (auto& method : body->methods) {
        // 메서드 시그니처 생성
        std::vector<std::shared_ptr<Type>> paramTypes;
        for (auto& param : method->parameters) {
            paramTypes.push_back(param->type);
        }
        auto funcType = std::make_shared<FunctionType>(paramTypes, method->returnType);

        // 메서드 심볼 생성
        Symbol methodSymbol(method->name, funcType, nullptr, false, SymbolType::METHOD);

        // 메서드 오버라이딩 처리
        classSymbol.methods[method->name] = methodSymbol;
    }

    // 클래스 타입 생성 (필드 타입으로 구성된 구조체)
    std::vector<llvm::Type*> fieldTypes;
    for (auto& fieldEntry : classSymbol.fields) {
        llvm::Type* fieldType = codeGenerator->getLLVMType(fieldEntry.second.type);
        if (!fieldType) {
            std::cerr << "Error: Unsupported field type '" << fieldEntry.second.type->name << "' in class '" << name << "'" << std::endl;
            return nullptr;
        }
        fieldTypes.push_back(fieldType);
    }

    // 클래스 구조체 타입 생성
    llvm::StructType* classType = llvm::StructType::create(codeGenerator->context, fieldTypes, name);
    classSymbol.classType = classType;

    // 심볼 테이블에 클래스 심볼 추가
    codeGenerator->symbolTable.addClassSymbol(name, classSymbol);

    // 메서드 코드 생성
    codeGenerator->currentClassName = name;
    for (auto& method : body->methods) {
        method->codegen();
    }
    codeGenerator->currentClassName.clear();

    return nullptr;
}

std::vector<llvm::Type*> ClassDeclarationNode::createFieldTypes() {
    std::vector<llvm::Type*> fieldTypes;
    for (auto& field : body->fields) {
        llvm::Type* fieldType = llvm::Type::getInt32Ty(codeGenerator->context);  // 임시로 int32로 설정
        fieldTypes.push_back(fieldType);
    }
    return fieldTypes;
}

llvm::StructType* ClassDeclarationNode::createClassType(const std::vector<llvm::Type*>& fieldTypes) {
    return llvm::StructType::create(codeGenerator->context, fieldTypes, name);
}

ClassSymbol ClassDeclarationNode::createClassSymbol(llvm::StructType* classType) {
    return ClassSymbol(name, classType, superClassName);
}

void ClassDeclarationNode::addFieldsToClassSymbol(ClassSymbol& classSymbol, const std::vector<llvm::Type*>& fieldTypes) {
    for (size_t i = 0; i < body->fields.size(); ++i) {
        auto& field = body->fields[i];
        Symbol fieldSymbol(field->name, field->type, nullptr, field->isMutable, SymbolType::FIELD);
        classSymbol.fields[field->name] = fieldSymbol;
    }
}

void ClassDeclarationNode::addClassSymbolToTable(const ClassSymbol& classSymbol) {
    codeGenerator->symbolTable.addClassSymbol(name, classSymbol);
}

void ClassDeclarationNode::generateMethodCode() {
    for (auto& method : body->methods) {
        method->codegen();
    }
}

void ClassBodyNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ClassBodyNode::codegen() {
    return nullptr;
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
            std::cerr << "Error: Unsupported parameter type '" << param->type->name << "' in function '" << name << "'" << std::endl;
            return nullptr;
        }
        argTypes.push_back(paramType);
    }

    llvm::Type* llvmReturnType = codeGenerator->getLLVMType(returnType);
    if (!llvmReturnType) {
        std::cerr << "Error: Unsupported return type '" << returnType->name << "' in function '" << name << "'" << std::endl;
        return nullptr;
    }

    llvm::FunctionType* funcType = llvm::FunctionType::get(llvmReturnType, argTypes, false);

    // 함수 이름 설정 (클래스 메서드인 경우 클래스 이름을 접두사로 붙임)
    std::string functionName = isClassMethod ? (codeGenerator->currentClassName + "_" + name) : name;

    // 함수 생성
    llvm::Function* function = llvm::Function::Create(funcType, llvm::Function::ExternalLinkage, functionName, codeGenerator->module.get());

    // 심볼 테이블에 함수 추가
    std::vector<std::shared_ptr<Type>> paramTypeList;
    if (isClassMethod) {
        // this 포인터 타입 추가
        paramTypeList.push_back(std::make_shared<ClassType>(codeGenerator->currentClassName));
    }
    for (auto& param : parameters) {
        paramTypeList.push_back(param->type);
    }
    auto funcTypeObject = std::make_shared<FunctionType>(paramTypeList, returnType);

    Symbol functionSymbol(name, funcTypeObject, function, false, SymbolType::METHOD);
    if (isClassMethod && classSymbol) {
        classSymbol->methods[name].value = function;  // 함수 포인터 저장
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
    auto argIter = function->arg_begin();
    if (isClassMethod) {
        // 첫 번째 인자는 this 포인터
        llvm::Argument* thisArg = argIter++;
        thisArg->setName("this");
        llvm::AllocaInst* alloc = codeGenerator->builder.CreateAlloca(thisArg->getType(), nullptr, "this");
        codeGenerator->builder.CreateStore(thisArg, alloc);

        // this 포인터를 심볼 테이블에 추가
        Symbol thisSymbol("this", std::make_shared<ClassType>(codeGenerator->currentClassName), alloc, false, SymbolType::VARIABLE);
        codeGenerator->symbolTable.addSymbol("this", thisSymbol);

		// class의 필드와 함수를 심볼 테이블에 추가
		auto classSymbol = codeGenerator->symbolTable.lookupClass(codeGenerator->currentClassName);
        if (classSymbol) {
            for (auto& field : classSymbol->fields) {
                codeGenerator->symbolTable.addSymbol(field.first, field.second);
            }
            for (auto& method : classSymbol->methods) {
                codeGenerator->symbolTable.addSymbol(method.first, method.second);
            }
        }
    }

    for (size_t idx = 0; idx < parameters.size(); ++idx, ++argIter) {
        auto& param = parameters[idx];
        llvm::Argument* arg = argIter;
        arg->setName(param->name);
        llvm::AllocaInst* alloc = codeGenerator->builder.CreateAlloca(arg->getType(), nullptr, arg->getName());
        codeGenerator->builder.CreateStore(arg, alloc);

        // 심볼 테이블에 추가
        Symbol paramSymbol(param->name, param->type, alloc, false, SymbolType::VARIABLE);
        codeGenerator->symbolTable.addSymbol(param->name, paramSymbol);
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

void BlockNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* BlockNode::codegen() {
    codeGenerator->symbolTable.enterScope();

    llvm::Value* last = nullptr;
    for (auto& stmt : statements) {
        last = stmt->codegen();
    }

    codeGenerator->symbolTable.exitScope();

    return last;
}

void ExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ExpressionNode::codegen() {
    Symbol* symbol = codeGenerator->symbolTable.lookup(value);
    if (symbol) {
        return codeGenerator->builder.CreateLoad(codeGenerator->getLLVMType(symbol->type), symbol->value, value.c_str());
    }
    if (value.find('"') != std::string::npos) {
        std::string str = value.substr(1, value.length() - 2);
        return codeGenerator->builder.CreateGlobalStringPtr(str);
    }

    if (value.front() == '"' && value.back() == '"') {
        std::string str = value.substr(1, value.length() - 2);
        return codeGenerator->builder.CreateGlobalStringPtr(str);
    }

    if (std::all_of(value.begin(), value.end(), ::isdigit)) {
        return llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(32, std::stoi(value)));
    }

    std::cerr << "Undefined variable or invalid expression: " << value << std::endl;
    return nullptr;
}

std::shared_ptr<Type> ExpressionNode::getType() {
    if (type) return type;

    Symbol* symbol = codeGenerator->symbolTable.lookup(value);
    if (symbol) {
        type = symbol->type;
        return type;
    }

    if (value.front() == '"' && value.back() == '"') {
        type = std::make_shared<ClassType>("String");
        return type;
    }

    if (std::all_of(value.begin(), value.end(), ::isdigit)) {
        type = std::make_shared<BasicType>("Int");
        return type;
    }

    type = std::make_shared<UnknownType>();
    return type;
}

void VariableDeclarationNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* VariableDeclarationNode::codegen() {
    llvm::Value* initValue = nullptr;
    if (initializer) {
        initValue = initializer->codegen();
        if (!initValue) {
            return nullptr;
        }
    }
    else {
        initValue = llvm::Constant::getNullValue(codeGenerator->getLLVMType(type));
    }

    llvm::Type* varType = codeGenerator->getLLVMType(type);
    if (!varType) {
        std::cerr << "Error: Unsupported variable type '" << type->name << "'" << std::endl;
        return nullptr;
    }

    llvm::AllocaInst* alloc = codeGenerator->builder.CreateAlloca(varType, nullptr, name.c_str());

    codeGenerator->builder.CreateStore(initValue, alloc);

    Symbol symbol(name, type, alloc, isMutable, SymbolType::VARIABLE);
    codeGenerator->symbolTable.addSymbol(name, symbol);

    return alloc;
}

// IfStatementNode
void IfStatementNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* IfStatementNode::codegen() {
    llvm::Value* conditionValue = condition->codegen();
    if (!conditionValue) {
        return nullptr;
    }

    if (conditionValue->getType()->isIntegerTy(32)) {
        conditionValue = codeGenerator->builder.CreateICmpNE(
            conditionValue, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(32, 0)), "ifcond");
    }
    else if (!conditionValue->getType()->isIntegerTy(1)) {
        std::cerr << "Error: Condition is not a boolean expression." << std::endl;
        return nullptr;
    }

    llvm::Function* function = codeGenerator->builder.GetInsertBlock()->getParent();

    bool hasElse = elseBlock != nullptr;

    llvm::BasicBlock* thenBB = llvm::BasicBlock::Create(codeGenerator->context, "then", function);
    llvm::BasicBlock* elseBB = nullptr;
    llvm::BasicBlock* mergeBB = llvm::BasicBlock::Create(codeGenerator->context, "ifcont", function);

    if (hasElse) {
        elseBB = llvm::BasicBlock::Create(codeGenerator->context, "else", function);
        codeGenerator->builder.CreateCondBr(conditionValue, thenBB, elseBB);
    }
    else {
        codeGenerator->builder.CreateCondBr(conditionValue, thenBB, mergeBB);
    }

    codeGenerator->builder.SetInsertPoint(thenBB);

    llvm::Value* thenValue = thenBlock->codegen();
    if (!thenValue) {
        return nullptr;
    }

    codeGenerator->builder.CreateBr(mergeBB);

    thenBB = codeGenerator->builder.GetInsertBlock();

    if (hasElse) {
        codeGenerator->builder.SetInsertPoint(elseBB);

        llvm::Value* elseValue = elseBlock->codegen();
        if (!elseValue) {
            return nullptr;
        }

        codeGenerator->builder.CreateBr(mergeBB);

        elseBB = codeGenerator->builder.GetInsertBlock();
    }

    codeGenerator->builder.SetInsertPoint(mergeBB);

    return llvm::Constant::getNullValue(llvm::Type::getInt32Ty(codeGenerator->context));
}

// ForStatementNode
void ForStatementNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ForStatementNode::codegen() {
    llvm::Function* function = codeGenerator->builder.GetInsertBlock()->getParent();

    llvm::Value* startValue;
    llvm::Value* endValue;

    if (isRange) {
        //
        auto rangeExpr = std::dynamic_pointer_cast<RangeExpressionNode>(iterableExpr);
        startValue = rangeExpr->startExpr->codegen();
        endValue = rangeExpr->endExpr->codegen();
        if (!startValue || !endValue) {
            return nullptr;
        }

        if (!rangeExpr->isInclusive) {
            endValue = codeGenerator->builder.CreateSub(endValue, llvm::ConstantInt::get(llvm::Type::getInt32Ty(codeGenerator->context), 1), "untilEnd");
        }
    }
    else {
        startValue = llvm::ConstantInt::get(llvm::Type::getInt32Ty(codeGenerator->context), 0);
        endValue = llvm::ConstantInt::get(llvm::Type::getInt32Ty(codeGenerator->context), 10);
    }

    llvm::BasicBlock* preheaderBB = codeGenerator->builder.GetInsertBlock();
    llvm::BasicBlock* loopBB = llvm::BasicBlock::Create(codeGenerator->context, "loop", function);
    llvm::BasicBlock* afterBB = llvm::BasicBlock::Create(codeGenerator->context, "afterloop", function);

    codeGenerator->builder.CreateBr(loopBB);

    codeGenerator->builder.SetInsertPoint(loopBB);

    llvm::PHINode* variableNode = codeGenerator->builder.CreatePHI(llvm::Type::getInt32Ty(codeGenerator->context), 2, variable.c_str());
    variableNode->addIncoming(startValue, preheaderBB);

    auto varExpr = std::make_shared<ExpressionNode>();
    varExpr->value = variableNode->getName().str();

    if (!body->codegen()) {
        return nullptr;
    }

    llvm::Value* nextValue = codeGenerator->builder.CreateAdd(variableNode, llvm::ConstantInt::get(llvm::Type::getInt32Ty(codeGenerator->context), 1), "nextvar");

    llvm::Value* endCond = codeGenerator->builder.CreateICmpSLE(variableNode, endValue, "loopcond");

    codeGenerator->builder.CreateCondBr(endCond, loopBB, afterBB);

    variableNode->addIncoming(nextValue, codeGenerator->builder.GetInsertBlock());

    codeGenerator->builder.SetInsertPoint(afterBB);

    return llvm::Constant::getNullValue(llvm::Type::getInt32Ty(codeGenerator->context));
}

void MatchExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* MatchExpressionNode::codegen() {
    llvm::Value* matchValue = expression->codegen();
    if (!matchValue) {
        return nullptr;
    }

    llvm::Function* function = codeGenerator->builder.GetInsertBlock()->getParent();
    llvm::BasicBlock* afterBB = llvm::BasicBlock::Create(codeGenerator->context, "afterMatch", function);

    llvm::Value* result = nullptr;

    for (size_t i = 0; i < cases.size(); ++i) {
        auto& casePair = cases[i];

        llvm::BasicBlock* caseBB = llvm::BasicBlock::Create(codeGenerator->context, "case", function);
        llvm::BasicBlock* nextCaseBB = (i == cases.size() - 1) ? afterBB : llvm::BasicBlock::Create(codeGenerator->context, "nextCase", function);

        codeGenerator->builder.SetInsertPoint(codeGenerator->builder.GetInsertBlock());

        llvm::Value* caseValue = casePair.first->codegen();
        if (!caseValue) {
            return nullptr;
        }

        llvm::Value* condition = codeGenerator->builder.CreateICmpEQ(matchValue, caseValue, "matchCond");

        codeGenerator->builder.CreateCondBr(condition, caseBB, nextCaseBB);

        codeGenerator->builder.SetInsertPoint(caseBB);
        llvm::Value* caseResult = casePair.second->codegen();
        if (!caseResult) {
            return nullptr;
        }
        result = caseResult;

        codeGenerator->builder.CreateBr(afterBB);

        //  ̽
        if (nextCaseBB != afterBB) {
            codeGenerator->builder.SetInsertPoint(nextCaseBB);
        }
    }

    // afterBB
    codeGenerator->builder.SetInsertPoint(afterBB);

    return result ? result : llvm::Constant::getNullValue(llvm::Type::getInt32Ty(codeGenerator->context));
}

void RangeExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* RangeExpressionNode::codegen() {
    // RangeExpressionNode ForStatementNode  ó ⼭ nullptr ȯ
    return nullptr;
}

void BinaryExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

bool isStringTypeFromLLVM(llvm::Value* value, CodeGenerator* codeGenerator) {
    return value->getType()->isPointerTy() && ((llvm::PointerType*)value->getType())->isValidElementType(llvm::Type::getInt8Ty(codeGenerator->context));
}

llvm::Value* BinaryExpressionNode::codegen() {
    llvm::Value* leftValue = left->codegen();
    llvm::Value* rightValue = right->codegen();
    if (!leftValue || !rightValue) {
        return nullptr;
    }

    if (op == "+") {
        // If leftValue is a pointer and rightValue is an integer, perform pointer arithmetic
        if (isStringTypeFromLLVM(leftValue, codeGenerator) && rightValue->getType()->isIntegerTy()) {
            // To add int to pointer, we need to convert pointer to int64.
            llvm::Value* int64Pointer = codeGenerator->builder.CreatePtrToInt(rightValue, llvm::Type::getInt64Ty(codeGenerator->context), "int64Pointer");
            // Then we add int to int64 pointer.
            llvm::Value* resultPointer = codeGenerator->builder.CreateAdd(int64Pointer, leftValue, "resultPointer");
            // Then we convert int64 to pointer.
            return codeGenerator->builder.CreateIntToPtr(resultPointer, llvm::Type::getInt8Ty(codeGenerator->context), "resultPointer");
        }
        // If rightValue is a pointer and leftValue is an integer, perform pointer arithmetic
        else if (isStringTypeFromLLVM(rightValue, codeGenerator) && leftValue->getType()->isIntegerTy()) {
            // To add int to pointer, we need to convert pointer to int64.
            llvm::Value* int64Pointer = codeGenerator->builder.CreatePtrToInt(rightValue, llvm::Type::getInt64Ty(codeGenerator->context), "int64Pointer");
            // Then we add int to int64 pointer.
            llvm::Value* resultPointer = codeGenerator->builder.CreateAdd(int64Pointer, leftValue, "resultPointer");
            return resultPointer;
        }
        // If leftvalue is string and rightvalue is int, perform string addition
        else if (isStringTypeFromLLVM(leftValue, codeGenerator) && isStringTypeFromLLVM(rightValue, codeGenerator)) {
            // To concatenate string and int, we need to convert int to string.
            // To convert int to string, we need to call toString from int class.
            // But we can't call method directly from int value, so we need to store int value in a variable.
            llvm::Value* intToString = codeGenerator->builder.CreateCall(codeGenerator->module->getFunction("toString"), rightValue, "intToString");
            // Then we call string concatenation method with intToString as argument.
            return codeGenerator->builder.CreateCall(codeGenerator->module->getFunction("operator+"), std::vector<llvm::Value*>{leftValue, intToString}, "concattmp");
        }
        else {
            // If leftvalue and rightvalue are both numerical primitives type, perform numerical addition.
            // If leftvalue and rightvalue are both objects based on class, perform method call.
            // If leftvalue and rightvalue are different types, perform type casting and then addition.
            // First, we need to check if leftValue and rightValue are both numerical primitives type.
            if (leftValue->getType()->isIntegerTy() && rightValue->getType()->isIntegerTy()) {
                return codeGenerator->builder.CreateAdd(leftValue, rightValue, "addtmp");
            }
            else if (leftValue->getType()->isFloatingPointTy() && rightValue->getType()->isFloatingPointTy()) {
                return codeGenerator->builder.CreateFAdd(leftValue, rightValue, "faddtmp");
            }
            // If leftvalue and rightvalue are both strings, perform string addition.
            else if (isStringTypeFromLLVM(leftValue, codeGenerator) && isStringTypeFromLLVM(rightValue, codeGenerator)) {
                return codeGenerator->builder.CreateCall(codeGenerator->module->getFunction("operator+"), std::vector<llvm::Value*>{leftValue, rightValue}, "concattmp");
            }
            // If leftvalue and rightvalue are different types, perform type casting and then addition.
            else if (leftValue->getType() == rightValue->getType()) {
                // To cast type, we need to call constructor of that type with value as argument.
                // But we can't call constructor directly, so we need to store value in a variable.
                // We can call constructor with variable as argument.
                // We need to get constructor of that type.
                // get the type name of leftValue and rightValue.
                llvm::Function* constructor = codeGenerator->module->getFunction(left->type->name);
                if (!constructor) {
                    std::cerr << "Error: Constructor not found for type '" << right->type->name << "' from " << left->type->name << std::endl;
                    return nullptr;
                }
                llvm::Value* convertedValue = codeGenerator->builder.CreateCall(constructor, std::vector<llvm::Value*>{rightValue}, "casttmp");
                return codeGenerator->builder.CreateCall(codeGenerator->module->getFunction("operator+"), std::vector<llvm::Value*>{leftValue, convertedValue}, "addtmp");
            }
            else {
                std::cerr << "Type error: Operator '" << op << "' not applicable to type '" << left->type->name << "' and '" << right->type->name << "'" << std::endl;
                return nullptr;
            }
        }
    }
    else if (op == "-") {
        return nullptr;
    }
    else if (op == "*") {
        return nullptr;
    }
    else if (op == "/") {
        return codeGenerator->builder.CreateFDiv(leftValue, rightValue, "divtmp");
    }
    else {
        std::cerr << "Unsupported binary operator: " << op << std::endl;
        return nullptr;
    }
}

std::shared_ptr<Type> BinaryExpressionNode::getType() {
    if (type) return type;

    auto leftType = left->getType();
    auto rightType = right->getType();

    if (!leftType->equals(rightType)) {
        std::cerr << "Type error: Left and right expressions have different types" << std::endl;
        type = std::make_shared<UnknownType>();
        return type;
    }

    if (op == "+" || op == "-" || op == "*" || op == "/") {
        if (leftType->name == "Int" || leftType->name == "Float" || leftType->name == "Double") {
            type = leftType;
            return type;
        }
        else {
            std::cerr << "Type error: Operator '" << op << "' not applicable to type '" << leftType->name << "'" << std::endl;
            type = std::make_shared<UnknownType>();
            return type;
        }
    }
    else {
        // 다른게 추가된다면 여기에 추가할 예정
    }

    type = std::make_shared<UnknownType>();
    return type;
}

void AssignmentNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* AssignmentNode::codegen() {
    Symbol* symbol = codeGenerator->symbolTable.lookup(name);
    if (!symbol) {
        std::cerr << "Undefined variable: " << name << std::endl;
        return nullptr;
    }
    if (!symbol->isMutable) {
        std::cerr << "Cannot assign to immutable variable: " << name << std::endl;
        return nullptr;
    }

    llvm::Value* exprValue = expression->codegen();
    if (!exprValue) {
        return nullptr;
    }

    codeGenerator->builder.CreateStore(exprValue, symbol->value);

    return exprValue;
}

void ReturnStatementNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ReturnStatementNode::codegen() {
    llvm::Value* returnValue = nullptr;
    if (expression) {
        returnValue = expression->codegen();
    }

    llvm::Function* currentFunction = codeGenerator->builder.GetInsertBlock()->getParent();
    llvm::Type* returnType = currentFunction->getReturnType();

    if (returnType->isVoidTy()) {
        codeGenerator->builder.CreateRetVoid();
    }
    else {
        if (!returnValue) {
            std::cerr << "Error: Return statement with no value in function returning non-void type" << std::endl;
            return nullptr;
        }

        if (returnValue->getType() != returnType) {
            std::cerr << "Error: Return value type does not match function return type" << std::endl;
            return nullptr;
        }

        codeGenerator->builder.CreateRet(returnValue);
    }

    return nullptr;
}

void UnitNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

void IdentifierNode::accept(ASTVisitor& visitor) {
	visitor.visit(*this);
}

llvm::Value* IdentifierNode::codegen() {
    // symbolTable에서의 symbol 검색은 symbolTable의 scopes를 역순으로 해서 따라가면서 symbol을 lookup한다.
	Symbol* symbol = codeGenerator->symbolTable.lookup(value);
	if (!symbol) {
		std::cerr << "Undefined variable: " << value << std::endl;
		return nullptr;
	}
	return codeGenerator->builder.CreateLoad(codeGenerator->getLLVMType(symbol->type), symbol->value, value.c_str());
}

std::shared_ptr<Type> IdentifierNode::getType() {
	if (type) return type;

	Symbol* symbol = codeGenerator->symbolTable.lookup(value);
	if (symbol) {
		type = symbol->type;
		return type;
	}

	type = std::make_shared<UnknownType>();
	return type;
}

void ValueNode::accept(ASTVisitor& visitor) {
	visitor.visit(*this);
}

llvm::Value* ValueNode::codegen() {
	if (valueType == TokenType::INTEGER_LITERAL) {
		return llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(64, value, 10));
	}
	else if (valueType == TokenType::FLOAT_LITERAL) {
		return llvm::ConstantFP::get(codeGenerator->context, llvm::APFloat(std::stof(value)));
	}
	else if (valueType == TokenType::BINARY_LITERAL) {
		return llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(64, value.substr(2), 2));
	}
	else if (valueType == TokenType::HEX_LITERAL) {
		return llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(64, value.substr(2), 16));
	}
	else if (valueType == TokenType::OCTAL_LITERAL) {
		return llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(64, value.substr(2), 8));
	}
	else if (valueType == TokenType::STRING_LITERAL) {
		return codeGenerator->builder.CreateGlobalStringPtr(value);
	}
	else {
		std::cerr << "Invalid value type: " << value << std::endl;
		return nullptr;
	}
}

std::shared_ptr<Type> ValueNode::getType() {
	if (type) return type;

	if (value.front() == '"' && value.back() == '"') {
		type = std::make_shared<ClassType>("String");
		return type;
	}
	if (std::all_of(value.begin(), value.end(), ::isdigit)) {
		type = std::make_shared<BasicType>("Int");
		return type;
	}

	type = std::make_shared<UnknownType>();
	return type;
}

void CallExpressionNode::accept(ASTVisitor& visitor) {
	visitor.visit(*this);
}

llvm::Value* CallExpressionNode::codegen() {
	auto name = callee->codegen()->getName();
	std::cout << "name: " << name.str() << std::endl;
	llvm::Function* function = codeGenerator->module->getFunction(name);
	if (!function) {
		std::cerr << "Function not found: " << name.str() << std::endl;
		return nullptr;
	}

	std::vector<llvm::Value*> args;
	for (auto& arg : arguments) {
		args.push_back(arg->codegen());
	}

	return codeGenerator->builder.CreateCall(function, args, "calltmp");
}

std::shared_ptr<Type> CallExpressionNode::getType() {
	if (type) return type;

    auto name = callee->codegen()->getName();
	llvm::Function* function = codeGenerator->module->getFunction(name);
	if (!function) {
		std::cerr << "Function not found: " << name.str() << std::endl;
		type = std::make_shared<UnknownType>();
		return type;
	}

	//llvm::Type* returnType = function->getReturnType();
	//type = codeGenerator->getLLVMType(returnType);

    return std::make_shared<BasicType>("");
}

void MethodCallNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* MethodCallNode::codegen() {
    // 객체의 값을 생성
    llvm::Value* objectValue = object->codegen();
    if (!objectValue) {
        return nullptr;
    }

    // 객체의 타입 가져오기
    std::shared_ptr<Type> objectType = object->getType();
    if (!objectType || objectType->kind != TypeKind::CLASS) {
        std::cerr << "Error: Method call on non-class type" << std::endl;
        return nullptr;
    }

    // 클래스 심볼 가져오기
    ClassSymbol* classSymbol = codeGenerator->symbolTable.lookupClass(objectType->name);
    if (!classSymbol) {
        std::cerr << "Error: Undefined class type '" << objectType->name << "'" << std::endl;
        return nullptr;
    }

    // 메서드 룩업
    Symbol* methodSymbol = codeGenerator->symbolTable.lookupMethod(classSymbol, methodName);
    if (!methodSymbol) {
        std::cerr << "Error: Method '" << methodName << "' not found in class '" << objectType->name << "'" << std::endl;
        return nullptr;
    }

    // 함수 타입과 LLVM 함수 가져오기
    auto funcType = std::dynamic_pointer_cast<FunctionType>(methodSymbol->type);
    llvm::Function* function = static_cast<llvm::Function*>(methodSymbol->value);
    if (!funcType || !function) {
        std::cerr << "Error: Invalid method '" << methodName << "' in class '" << objectType->name << "'" << std::endl;
        return nullptr;
    }

    // 인자 값 생성
    std::vector<llvm::Value*> argValues;
    // 첫 번째 인자로 객체 포인터 전달 (this 포인터)
    argValues.push_back(objectValue);

    if (arguments.size() != funcType->parameterTypes.size()) {
        std::cerr << "Error: Argument count mismatch in method call '" << methodName << "'" << std::endl;
        return nullptr;
    }

    for (size_t i = 0; i < arguments.size(); ++i) {
        llvm::Value* argValue = arguments[i]->codegen();
        if (!argValue) {
            return nullptr;
        }

        // 인자의 타입 검사
        std::shared_ptr<Type> expectedType = funcType->parameterTypes[i];
        std::shared_ptr<Type> actualType = arguments[i]->getType();
        if (!actualType->equals(expectedType)) {
            std::cerr << "Type error: Argument type mismatch in method call '" << methodName << "'" << std::endl;
            return nullptr;
        }

        argValues.push_back(argValue);
    }

    // 함수 호출 생성
    llvm::Value* result = codeGenerator->builder.CreateCall(function, argValues, "calltmp");
    return result;
}

std::shared_ptr<Type> MethodCallNode::getType() {
    // 메서드의 반환 타입을 반환
    if (type) return type;

    // 객체의 타입 가져오기
    std::shared_ptr<Type> objectType = object->getType();
    if (!objectType || objectType->kind != TypeKind::CLASS) {
        type = std::make_shared<UnknownType>();
        return type;
    }

    // 클래스 심볼 가져오기
    ClassSymbol* classSymbol = codeGenerator->symbolTable.lookupClass(objectType->name);
    if (!classSymbol) {
        type = std::make_shared<UnknownType>();
        return type;
    }

    // 메서드 룩업
    Symbol* methodSymbol = codeGenerator->symbolTable.lookupMethod(classSymbol, methodName);
    if (!methodSymbol) {
        type = std::make_shared<UnknownType>();
        return type;
    }

    // 함수 타입 가져오기
    auto funcType = std::dynamic_pointer_cast<FunctionType>(methodSymbol->type);
    if (funcType) {
        type = funcType->returnType;
        return type;
    }

    type = std::make_shared<UnknownType>();
    return type;
}

void ClassInstanceCreationNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ClassInstanceCreationNode::codegen() {
	// primitive type인지, class type인지 확인, template type인지 확인
    // primitive type이면 llvm::CreateAlloca로
	if (isPrimitiveType(className)) {
        // new로 시작한 것이므로, malloc사용
		llvm::Type* type = codeGenerator->getLLVMType(std::make_shared<BasicType>(className));
        // type을 메모리 할당할때 필요한 메모리 크기를 계산
		llvm::DataLayout dataLayout;
		uint64_t typeSize = dataLayout.getTypeAllocSize(type);
		llvm::Value* allocSize = llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(64, typeSize));
		// malloc함수 호출
		return codeGenerator->builder.CreateCall(codeGenerator->mallocFunction, allocSize, "malloc");
    }

	// Template Class인지 확인은 나중에 코드 추가되면...

    // 클래스 심볼 찾기
    ClassSymbol* classSymbol = codeGenerator->symbolTable.lookupClass(className);
    if (!classSymbol) {
        std::cerr << "Error: Class '" << className << "' not found" << std::endl;
        return nullptr;
    }

    // 클래스 타입 가져오기
    llvm::StructType* classType = llvm::dyn_cast<llvm::StructType>(classSymbol->classType);
    if (!classType) {
        std::cerr << "Error: Unknown type about class '" << className << "'" << std::endl;
        return nullptr;
    }

    // 메모리 할당
    llvm::DataLayout dataLayout;
    uint64_t typeSize = dataLayout.getTypeAllocSize(classType);
    llvm::Value* allocSize = llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(64, typeSize));
    llvm::Value* allocatedMemory = codeGenerator->builder.CreateCall(codeGenerator->mallocFunction, allocSize, "objAlloc");
    allocatedMemory = codeGenerator->builder.CreateBitCast(allocatedMemory, classType->getPointerTo());

    // 객체 초기화 (생성자 호출)
    std::string constructorName = className;
    llvm::Function* constructorFunc = codeGenerator->module->getFunction(constructorName);
    if (constructorFunc) {
        std::vector<llvm::Value*> constructorArgs = { allocatedMemory };
        for (auto& arg : arguments) {
            constructorArgs.push_back(arg->codegen());
        }
        codeGenerator->builder.CreateCall(constructorFunc, constructorArgs);
    }
    else {
        std::cerr << "Warning: Constructor for class '" << className << "' not found" << std::endl;
    }

    return allocatedMemory;
}

std::shared_ptr<Type> ClassInstanceCreationNode::getType() {
    return std::make_shared<ClassType>(className);
}

void ArrayCreationExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ArrayCreationExpressionNode::codegen() {
    // sizes로 배열 크기를 받아서 처리하는데 이들은 4차원이 최대이므로, 이들을 곱한다.
    llvm::Value* array_size = sizes[0]->codegen();
    for (int i = 1; i < sizes.size(); i++) {
        array_size = codeGenerator->builder.CreateMul(array_size, sizes[i]->codegen());
    }

    // primitive type인지, class type인지 확인, template type인지 확인
    if (isPrimitiveType(typeName)) {
        llvm::Type* type = codeGenerator->getLLVMType(std::make_shared<BasicType>(typeName));
        return codeGenerator->builder.CreateAlloca(type, array_size, typeName);
    }

    // Template Class인지 확인은 나중에 코드 추가되면...

    // 클래스 심볼 찾기
    ClassSymbol* classSymbol = codeGenerator->symbolTable.lookupClass(typeName);
    if (!classSymbol) {
        std::cerr << "Error: Class '" << typeName << "' not found" << std::endl;
        return nullptr;
    }

    // 클래스 타입 가져오기
    llvm::StructType* classType = (llvm::StructType*)classSymbol->classType;

    // 메모리 할당
    llvm::Value* allocSize = codeGenerator->builder.CreateStructGEP(classType, nullptr, 0);
	llvm::Value* allocatedMemory = codeGenerator->builder.CreateAlloca(classType, array_size, typeName);

    // 객체 초기화 (생성자 호출)
    std::string constructorName = typeName + "_constructor";
    llvm::Function* constructorFunc = codeGenerator->module->getFunction(constructorName);
    if (constructorFunc) {
        std::vector<llvm::Value*> constructorArgs = { allocatedMemory };
        for (auto& arg : sizes) {
            constructorArgs.push_back(arg->codegen());
        }
        codeGenerator->builder.CreateCall(constructorFunc, constructorArgs);
    }
    else {
        std::cerr << "Warning: Constructor for class '" << typeName << "' not found" << std::endl;
    }

    return allocatedMemory;
}

std::shared_ptr<Type> ArrayCreationExpressionNode::getType() {
    return std::make_shared<ClassType>(typeName);
}

void AssignmentExpressionNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* AssignmentExpressionNode::codegen()
{
    llvm::Value* leftValue = left->codegen();
    llvm::Value* rightValue = right->codegen();
    if (!leftValue || !rightValue) {
		std::cerr << "Error: Assignment failed" << std::endl;
        return nullptr;
    }

    codeGenerator->builder.CreateStore(rightValue, leftValue);
	return leftValue;
}

std::shared_ptr<Type> AssignmentExpressionNode::getType()
{
    return std::shared_ptr<Type>();
}

void UnaryExpressionNode::accept(ASTVisitor& visitor)
{
	visitor.visit(*this);
}

llvm::Value* UnaryExpressionNode::codegen()
{
    llvm::Value* value = expression->codegen();
	if (!value) {
		std::cerr << "Error: Unary expression failed" << std::endl;
		return nullptr;
	}

    if (op == "-") {
		return codeGenerator->builder.CreateNeg(value, "negtmp");
	}
    else if (op == "+") {
		return value;
    }
	else if (op == "!") {
		return codeGenerator->builder.CreateNot(value, "nottmp");
	}
	else if (op == "~") {
        // bitwise not
		return codeGenerator->builder.CreateNot(value, "bnottmp");
	}
	else if (op == "++") {
		// increment
		// byte, char, word, short, int, long, long long, float, double, long double만 가능하도록 변경
		if (value->getType()->isIntegerTy(1)) { // byte

			return codeGenerator->builder.CreateAdd(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(1, 1)), "inc");
		}
		else if (value->getType()->isIntegerTy(8)) { // char
			return codeGenerator->builder.CreateAdd(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(8, 1)), "inc");
		}
		else if (value->getType()->isIntegerTy(16)) { // word, short
			return codeGenerator->builder.CreateAdd(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(16, 1)), "inc");
		}
		else if (value->getType()->isIntegerTy(32)) { // int
			return codeGenerator->builder.CreateAdd(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(32, 1)), "inc");
		}
		else if (value->getType()->isIntegerTy(64)) { // long, long long
			return codeGenerator->builder.CreateAdd(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(64, 1)), "inc");
		}
		else if (value->getType()->isFloatTy()) { // float
			return codeGenerator->builder.CreateFAdd(value, llvm::ConstantFP::get(codeGenerator->context, llvm::APFloat(1.0)), "inc");
		}
		else if (value->getType()->isDoubleTy()) { // double
			return codeGenerator->builder.CreateFAdd(value, llvm::ConstantFP::get(codeGenerator->context, llvm::APFloat(1.0)), "inc");
		}
		else {
			std::cerr << "Error: Increment operator not applicable to type" << std::endl;
			return nullptr;
		}
	}
	else if (op == "--") {
		// decrement
        // byte, char, word, short, int, long, long long, float, double, long double만 가능하도록 변경
        if (value->getType()->isIntegerTy(1)) { // byte

            return codeGenerator->builder.CreateSub(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(1, 1)), "dec");
        }
        else if (value->getType()->isIntegerTy(8)) { // char
            return codeGenerator->builder.CreateSub(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(8, 1)), "dec");
        }
        else if (value->getType()->isIntegerTy(16)) { // word, short
            return codeGenerator->builder.CreateSub(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(16, 1)), "dec");
        }
        else if (value->getType()->isIntegerTy(32)) { // int
            return codeGenerator->builder.CreateSub(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(32, 1)), "dec");
        }
        else if (value->getType()->isIntegerTy(64)) { // long, long long
            return codeGenerator->builder.CreateSub(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(64, 1)), "dec");
        }
        else if (value->getType()->isFloatTy()) { // float
            return codeGenerator->builder.CreateFSub(value, llvm::ConstantFP::get(codeGenerator->context, llvm::APFloat(1.0)), "dec");
        }
        else if (value->getType()->isDoubleTy()) { // double
            return codeGenerator->builder.CreateFSub(value, llvm::ConstantFP::get(codeGenerator->context, llvm::APFloat(1.0)), "dec");
        }
        else if (value->getType()->isStructTy()) {
            // 구조체일 경우 구조체 안에 '++' 연산자가 정의되어 있는지 확인 후 사용할 수 있다면, 사용
            auto classType = llvm::cast<llvm::StructType>(value->getType());
            auto classSymbol = codeGenerator->symbolTable.lookupClass(classType->getName().str());

            if (classSymbol) {
                auto method = classSymbol->getMethod("operator++");
                if (method) {
                    // '++' 연산자 메서드 호출
                    std::vector<llvm::Value*> args;
                    return codeGenerator->builder.CreateCall(llvm::FunctionCallee(method->function), args, "inc");
                }
                else {
                    std::cerr << "Error: '++' operator not defined for class " << classType->getName().str() << std::endl;
                    return nullptr;
                }
            }
            else {
                std::cerr << "Error: Class symbol not found for type " << classType->getName().str() << std::endl;
                return nullptr;
            }
        }
        else {
            std::cerr << "Error: Increment operator not applicable to type" << std::endl;
            return nullptr;
        }
    }
    else {
		std::cerr << "Unsupported unary operator: " << op << std::endl;
    }

    return nullptr;
}

std::shared_ptr<Type> UnaryExpressionNode::getType() {
    auto res = this->codegen();
    if (res->getType()->isVoidTy()) {
        return std::make_shared<BasicType>("Void");
    }
    else if (res->getType()->isStructTy()) {
		return std::make_shared<ClassType>(res->getType()->getStructName().str());
	}
	else if (res->getType()->isIntegerTy(1)) {
		return std::make_shared<BasicType>("Bool");
	}
	else if (res->getType()->isIntegerTy(8)) {
		return std::make_shared<BasicType>("Byte");
	}
	else if (res->getType()->isIntegerTy(16)) {
		return std::make_shared<BasicType>("Short");
	}
	else if (res->getType()->isIntegerTy(32)) {
		return std::make_shared<BasicType>("Int");
	}
	else if (res->getType()->isIntegerTy(64)) {
		return std::make_shared<BasicType>("Long");
	}
	else if (res->getType()->isFloatTy()) {
		return std::make_shared<BasicType>("Float");
	}
	else if (res->getType()->isDoubleTy()) {
		return std::make_shared<BasicType>("Double");
	}
	else {
		return std::make_shared<UnknownType>();
	}
}

void CastingExpressionNode::accept(ASTVisitor& visitor) {
	visitor.visit(*this);
}

llvm::Value* CastingExpressionNode::codegen() {
    return nullptr;
}

std::shared_ptr<Type> CastingExpressionNode::getType() {
    return std::shared_ptr<Type>();
}

void PostfixExpressionNode::accept(ASTVisitor& visitor) {
	visitor.visit(*this);
}

llvm::Value* PostfixExpressionNode::codegen() {
    llvm::Value* value = expression->codegen();
    if (!value) {
        std::cerr << "Error: Unary expression failed" << std::endl;
        return nullptr;
    }

    if (op == "++") {
        // increment
        // byte, char, word, short, int, long, long long, float, double, long double만 가능하도록 변경
        if (value->getType()->isIntegerTy(1)) { // byte

            return codeGenerator->builder.CreateAdd(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(1, 1)), "inc");
        }
        else if (value->getType()->isIntegerTy(8)) { // char
            return codeGenerator->builder.CreateAdd(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(8, 1)), "inc");
        }
        else if (value->getType()->isIntegerTy(16)) { // word, short
            return codeGenerator->builder.CreateAdd(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(16, 1)), "inc");
        }
        else if (value->getType()->isIntegerTy(32)) { // int
            return codeGenerator->builder.CreateAdd(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(32, 1)), "inc");
        }
        else if (value->getType()->isIntegerTy(64)) { // long, long long
            return codeGenerator->builder.CreateAdd(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(64, 1)), "inc");
        }
        else if (value->getType()->isFloatTy()) { // float
            return codeGenerator->builder.CreateFAdd(value, llvm::ConstantFP::get(codeGenerator->context, llvm::APFloat(1.0)), "inc");
        }
        else if (value->getType()->isDoubleTy()) { // double
            return codeGenerator->builder.CreateFAdd(value, llvm::ConstantFP::get(codeGenerator->context, llvm::APFloat(1.0)), "inc");
        }
        else if (value->getType()->isStructTy()) {
            // 구조체일 경우 구조체 안에 '++' 연산자가 정의되어 있는지 확인 후 사용할 수 있다면, 사용
            auto classType = llvm::cast<llvm::StructType>(value->getType());
            auto classSymbol = codeGenerator->symbolTable.lookupClass(classType->getName().str());

            if (classSymbol) {
                auto method = classSymbol->getMethod("operator--");
                if (method) {
                    // '++' 연산자 메서드 호출
                    std::vector<llvm::Value*> args;
                    return codeGenerator->builder.CreateCall(llvm::FunctionCallee(method->function), args, "inc");
                }
                else {
                    std::cerr << "Error: '++' operator not defined for class " << classType->getName().str() << std::endl;
                    return nullptr;
                }
            }
            else {
                std::cerr << "Error: Class symbol not found for type " << classType->getName().str() << std::endl;
                return nullptr;
            }
        }
        else {
            std::cerr << "Error: Increment operator not applicable to type" << std::endl;
            return nullptr;
        }
    }
    else if (op == "--") {
        // decrement
        // byte, char, word, short, int, long, long long, float, double, long double만 가능하도록 변경
        if (value->getType()->isIntegerTy(1)) { // byte
            return codeGenerator->builder.CreateSub(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(1, 1)), "dec");
        }
        else if (value->getType()->isIntegerTy(8)) { // char
            return codeGenerator->builder.CreateSub(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(8, 1)), "dec");
        }
        else if (value->getType()->isIntegerTy(16)) { // word, short
            return codeGenerator->builder.CreateSub(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(16, 1)), "dec");
        }
        else if (value->getType()->isIntegerTy(32)) { // int
            return codeGenerator->builder.CreateSub(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(32, 1)), "dec");
        }
        else if (value->getType()->isIntegerTy(64)) { // long, long long
            return codeGenerator->builder.CreateSub(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(64, 1)), "dec");
        }
        else if (value->getType()->isFloatTy()) { // float
            return codeGenerator->builder.CreateFSub(value, llvm::ConstantFP::get(codeGenerator->context, llvm::APFloat(1.0)), "dec");
        }
        else if (value->getType()->isDoubleTy()) { // double
            return codeGenerator->builder.CreateFSub(value, llvm::ConstantFP::get(codeGenerator->context, llvm::APFloat(1.0)), "dec");
        }
        else if (value->getType()->isStructTy()) {
            // 구조체일 경우 구조체 안에 '++' 연산자가 정의되어 있는지 확인 후 사용할 수 있다면, 사용
            auto classType = llvm::cast<llvm::StructType>(value->getType());
            auto classSymbol = codeGenerator->symbolTable.lookupClass(classType->getName().str());

            if (classSymbol) {
                auto method = classSymbol->getMethod("operator++");
                if (method) {
                    // '++' 연산자 메서드 호출
                    std::vector<llvm::Value*> args;
                    return codeGenerator->builder.CreateCall(llvm::FunctionCallee(method->function), args, "inc");
                }
                else {
                    std::cerr << "Error: '++' operator not defined for class " << classType->getName().str() << std::endl;
                    return nullptr;
                }
            }
            else {
                std::cerr << "Error: Class symbol not found for type " << classType->getName().str() << std::endl;
                return nullptr;
            }
        }
        else {
            std::cerr << "Error: Increment operator not applicable to type" << std::endl;
            return nullptr;
        }
    }
    else {
        std::cerr << "Unsupported unary operator: " << op << std::endl;
    }

    return nullptr;
}

std::shared_ptr<Type> PostfixExpressionNode::getType() {
    auto res = this->codegen();
    if (res->getType()->isVoidTy()) {
        return std::make_shared<BasicType>("Void");
    }
    else if (res->getType()->isStructTy()) {
        return std::make_shared<ClassType>(res->getType()->getStructName().str());
    }
    else if (res->getType()->isIntegerTy(1)) {
        return std::make_shared<BasicType>("Bool");
    }
    else if (res->getType()->isIntegerTy(8)) {
        return std::make_shared<BasicType>("Byte");
    }
    else if (res->getType()->isIntegerTy(16)) {
        return std::make_shared<BasicType>("Short");
    }
    else if (res->getType()->isIntegerTy(32)) {
        return std::make_shared<BasicType>("Int");
    }
    else if (res->getType()->isIntegerTy(64)) {
        return std::make_shared<BasicType>("Long");
    }
    else if (res->getType()->isFloatTy()) {
        return std::make_shared<BasicType>("Float");
    }
    else if (res->getType()->isDoubleTy()) {
        return std::make_shared<BasicType>("Double");
    }
    else {
        return std::make_shared<UnknownType>();
    }
}

void PrefixExpressionNode::accept(ASTVisitor& visitor) {
	visitor.visit(*this);
}

llvm::Value* PrefixExpressionNode::codegen() {
    llvm::Value* value = expression->codegen();
    if (!value) {
        std::cerr << "Error: Unary expression failed" << std::endl;
        return nullptr;
    }

    if (op == "++") {
        // increment
        // byte, char, word, short, int, long, long long, float, double, long double만 가능하도록 변경
        if (value->getType()->isIntegerTy(1)) { // byte

            return codeGenerator->builder.CreateAdd(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(1, 1)), "inc");
        }
        else if (value->getType()->isIntegerTy(8)) { // char
            return codeGenerator->builder.CreateAdd(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(8, 1)), "inc");
        }
        else if (value->getType()->isIntegerTy(16)) { // word, short
            return codeGenerator->builder.CreateAdd(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(16, 1)), "inc");
        }
        else if (value->getType()->isIntegerTy(32)) { // int
            return codeGenerator->builder.CreateAdd(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(32, 1)), "inc");
        }
        else if (value->getType()->isIntegerTy(64)) { // long, long long
            return codeGenerator->builder.CreateAdd(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(64, 1)), "inc");
        }
        else if (value->getType()->isFloatTy()) { // float
            return codeGenerator->builder.CreateFAdd(value, llvm::ConstantFP::get(codeGenerator->context, llvm::APFloat(1.0)), "inc");
        }
        else if (value->getType()->isDoubleTy()) { // double
            return codeGenerator->builder.CreateFAdd(value, llvm::ConstantFP::get(codeGenerator->context, llvm::APFloat(1.0)), "inc");
        }
        else if (value->getType()->isStructTy()) {
            // 구조체일 경우 구조체 안에 '++' 연산자가 정의되어 있는지 확인 후 사용할 수 있다면, 사용
            auto classType = llvm::cast<llvm::StructType>(value->getType());
            auto classSymbol = codeGenerator->symbolTable.lookupClass(classType->getName().str());

            if (classSymbol) {
                auto method = classSymbol->getMethod("operator--");
                if (method) {
                    // '++' 연산자 메서드 호출
                    std::vector<llvm::Value*> args;
                    return codeGenerator->builder.CreateCall(llvm::FunctionCallee(method->function), args, "inc");
                }
                else {
                    std::cerr << "Error: '++' operator not defined for class " << classType->getName().str() << std::endl;
                    return nullptr;
                }
            }
            else {
                std::cerr << "Error: Class symbol not found for type " << classType->getName().str() << std::endl;
                return nullptr;
            }
        }
        else {
            std::cerr << "Error: Increment operator not applicable to type" << std::endl;
            return nullptr;
        }
    }
    else if (op == "--") {
        // decrement
        // byte, char, word, short, int, long, long long, float, double, long double만 가능하도록 변경
        if (value->getType()->isIntegerTy(1)) { // byte
            return codeGenerator->builder.CreateSub(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(1, 1)), "dec");
        }
        else if (value->getType()->isIntegerTy(8)) { // char
            return codeGenerator->builder.CreateSub(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(8, 1)), "dec");
        }
        else if (value->getType()->isIntegerTy(16)) { // word, short
            return codeGenerator->builder.CreateSub(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(16, 1)), "dec");
        }
        else if (value->getType()->isIntegerTy(32)) { // int
            return codeGenerator->builder.CreateSub(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(32, 1)), "dec");
        }
        else if (value->getType()->isIntegerTy(64)) { // long, long long
            return codeGenerator->builder.CreateSub(value, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(64, 1)), "dec");
        }
        else if (value->getType()->isFloatTy()) { // float
            return codeGenerator->builder.CreateFSub(value, llvm::ConstantFP::get(codeGenerator->context, llvm::APFloat(1.0)), "dec");
        }
        else if (value->getType()->isDoubleTy()) { // double
            return codeGenerator->builder.CreateFSub(value, llvm::ConstantFP::get(codeGenerator->context, llvm::APFloat(1.0)), "dec");
        }
        else if (value->getType()->isStructTy()) {
            // 구조체일 경우 구조체 안에 '++' 연산자가 정의되어 있는지 확인 후 사용할 수 있다면, 사용
            auto classType = llvm::cast<llvm::StructType>(value->getType());
            auto classSymbol = codeGenerator->symbolTable.lookupClass(classType->getName().str());

            if (classSymbol) {
                auto method = classSymbol->getMethod("operator++");
                if (method) {
                    // '++' 연산자 메서드 호출
                    std::vector<llvm::Value*> args;
                    return codeGenerator->builder.CreateCall(llvm::FunctionCallee(method->function), args, "inc");
                }
                else {
                    std::cerr << "Error: '++' operator not defined for class " << classType->getName().str() << std::endl;
                    return nullptr;
                }
            }
            else {
                std::cerr << "Error: Class symbol not found for type " << classType->getName().str() << std::endl;
                return nullptr;
            }
        }
        else {
            std::cerr << "Error: Increment operator not applicable to type" << std::endl;
            return nullptr;
        }
    }
    else {
        std::cerr << "Unsupported unary operator: " << op << std::endl;
    }

    return nullptr;
}

std::shared_ptr<Type> PrefixExpressionNode::getType() {
    auto res = this->codegen();
    if (res->getType()->isVoidTy()) {
        return std::make_shared<BasicType>("Void");
    }
    else if (res->getType()->isStructTy()) {
        return std::make_shared<ClassType>(res->getType()->getStructName().str());
    }
    else if (res->getType()->isIntegerTy(1)) {
        return std::make_shared<BasicType>("Bool");
    }
    else if (res->getType()->isIntegerTy(8)) {
        return std::make_shared<BasicType>("Byte");
    }
    else if (res->getType()->isIntegerTy(16)) {
        return std::make_shared<BasicType>("Short");
    }
    else if (res->getType()->isIntegerTy(32)) {
        return std::make_shared<BasicType>("Int");
    }
    else if (res->getType()->isIntegerTy(64)) {
        return std::make_shared<BasicType>("Long");
    }
    else if (res->getType()->isFloatTy()) {
        return std::make_shared<BasicType>("Float");
    }
    else if (res->getType()->isDoubleTy()) {
        return std::make_shared<BasicType>("Double");
    }
    else {
        return std::make_shared<UnknownType>();
    }
}



void FunctionCallNode::accept(ASTVisitor& visitor) {
	visitor.visit(*this);
}

llvm::Value* FunctionCallNode::codegen() {
    // 인자 값 생성 및 타입 수집
    std::vector<llvm::Value*> argValues;
    std::vector<std::shared_ptr<Type>> argTypes;
    for (auto& arg : arguments) {
        llvm::Value* argValue = arg->codegen();
        if (!argValue) {
            return nullptr;
        }
        argValues.push_back(argValue);
        argTypes.push_back(arg->getType());
    }

    // 함수 심볼 찾기
    Symbol* functionSymbol = codeGenerator->symbolTable.resolveFunctionCall(functionName, argTypes);
    if (!functionSymbol) {
        std::cerr << "Error: No matching function found for '" << functionName << "' with given argument types" << std::endl;
        return nullptr;
    }

    // 함수 타입과 LLVM 함수 가져오기
    auto funcType = std::dynamic_pointer_cast<FunctionType>(functionSymbol->type);
    llvm::Function* function = static_cast<llvm::Function*>(functionSymbol->value);
    if (!funcType || !function) {
        std::cerr << "Error: Invalid function '" << functionName << "'" << std::endl;
        return nullptr;
    }

    // 함수 호출 생성
    llvm::Value* result = codeGenerator->builder.CreateCall(function, argValues, "calltmp");

    // 타입 설정
    type = funcType->returnType;
    return result;
}

std::shared_ptr<Type> FunctionCallNode::getType() {
    if (type) return type;

    // 함수 심볼 찾기
    std::vector<std::shared_ptr<Type>> argTypes;
    for (auto& arg : arguments) {
        argTypes.push_back(arg->getType());
    }

    Symbol* functionSymbol = codeGenerator->symbolTable.resolveFunctionCall(functionName, argTypes);
    if (!functionSymbol) {
        type = std::make_shared<UnknownType>();
        return type;
    }

    auto funcType = std::dynamic_pointer_cast<FunctionType>(functionSymbol->type);
    if (funcType) {
        type = funcType->returnType;
        return type;
    }

    type = std::make_shared<UnknownType>();
    return type;
}

void ArrayCreationNode::accept(ASTVisitor& visitor) {
	visitor.visit(*this);
}

llvm::Value* ArrayCreationNode::codegen() {
    // 요소 타입의 LLVM 타입 가져오기
    llvm::Type* elementType = codeGenerator->getLLVMType(arrayType->typeArguments[0]);
    if (!elementType) {
        std::cerr << "Error: Invalid array element type" << std::endl;
        return nullptr;
    }

    // 배열 크기 결정
    llvm::Value* arraySize = codeGenerator->builder.getInt32(elements.size());

    // 메모리 할당 (malloc 등 사용)
    llvm::Function* mallocFunc = llvm::Function::Create(
        llvm::FunctionType::get(
			llvm::PointerType::getUnqual(llvm::Type::getInt8Ty(codeGenerator->context)),
            { llvm::Type::getInt64Ty(codeGenerator->context) },
            false
        ),
        llvm::Function::ExternalLinkage,
        "malloc",
        codeGenerator->module.get()
    );

    llvm::Value* totalSize = codeGenerator->builder.CreateMul(
        codeGenerator->builder.CreateZExt(arraySize, llvm::Type::getInt64Ty(codeGenerator->context)),
        llvm::ConstantInt::get(llvm::Type::getInt64Ty(codeGenerator->context), codeGenerator->module->getDataLayout().getTypeAllocSize(elementType))
    );

    llvm::Value* rawPtr = codeGenerator->builder.CreateCall(mallocFunc, { totalSize }, "malloccall");
    llvm::Value* arrayPtr = codeGenerator->builder.CreateBitCast(rawPtr, llvm::PointerType::getUnqual(elementType));

    // 배열 요소 초기화
    for (size_t i = 0; i < elements.size(); ++i) {
        llvm::Value* elemValue = elements[i]->codegen();
        if (!elemValue) {
            return nullptr;
        }
        llvm::Value* index = llvm::ConstantInt::get(codeGenerator->builder.getInt32Ty(), i);
        llvm::Value* elemPtr = codeGenerator->builder.CreateGEP(elementType, arrayPtr, index);
        codeGenerator->builder.CreateStore(elemValue, elemPtr);
    }

    return arrayPtr;
}

void ArrayAccessNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ArrayAccessNode::codegen() {
    llvm::Value* arrayValue = array->codegen();
    llvm::Value* indexValue = index->codegen();
    if (!arrayValue || !indexValue) {
        return nullptr;
    }

    llvm::Type* elementType = codeGenerator->getLLVMType(getType());
    if (!elementType) {
        std::cerr << "Error: Invalid array element type" << std::endl;
        return nullptr;
    }

    // 요소 포인터 계산
    llvm::Value* elemPtr = codeGenerator->builder.CreateGEP(elementType, arrayValue, indexValue, "arrayelem");
    // 요소 로드
    return codeGenerator->builder.CreateLoad(elementType, elemPtr, "arrayload");
}

void AccessFieldNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* AccessFieldNode::codegen() {
	auto leftValue = base->codegen();
    auto rightValue = field->codegen();
    return nullptr;
}

std::shared_ptr<Type> AccessFieldNode::getType() {
    // left의 type과 동일
    return base->getType();
}