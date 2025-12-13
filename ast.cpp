// ast.cpp
#include "token.h"
#include "ast.h"
#include "codegen.h"
#include "utils.h"

#include <iostream>


CodeGenerator* ASTNode::codeGenerator = nullptr;

//   accept  codegen Լ
// https://stackoverflow.com/questions/33327097/llvm-irbuilder-set-insert-point-after-a-particular-instruction
// 참고: Builder.SetInsertPoint(I->getNextNode());

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
    if (!type) {
        std::cerr << "Error: Parameter type is null for '" << name << "'" << std::endl;
        return nullptr;
    }

    llvm::Type* paramType = codeGenerator->getLLVMType(type.get());
    if (!paramType) {
        std::cerr << "Error: Unsupported parameter type '" << type->getName() << "' in parameter '" << name << "'" << std::endl;
        return nullptr;
    }

    auto symbol = codeGenerator->symbolTable.lookup(name);
    if (!symbol) {
        std::cerr << "Error: Symbol not found for parameter '" << name << "'" << std::endl;
        return nullptr;
    }

	return symbol.has_value() ? (*symbol)->value : nullptr;
}

void ImportNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ImportNode::codegen() {
    auto moduleSymbols = codeGenerator->moduleLoader.loadModule(path);
    if (moduleSymbols) {
        //  ɺ  ɺ ̺
        codeGenerator->symbolTable.merge(*moduleSymbols);
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
		auto superClassSymbolOpt = codeGenerator->symbolTable.lookup(superClassName);
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
			classSymbol->fields[field.first] = field.second;
		}
		for (auto& method : superClassSymbol->methods) {
			classSymbol->methods[method.first] = method.second;
		}
    }

    // 현재 클래스의 필드와 메서드 추가 또는 오버라이딩
    for (auto& field : constructorParams) {
        llvm::Type* fieldType = codeGenerator->getLLVMType(field->type.get());
        if (!fieldType) {
            std::cerr << "Error: Unsupported field type '" << field->type->getName() << "' in class '" << name << "'" << std::endl;
            return nullptr;
        }

        Symbol *fieldSymbol = new Symbol(field->name, field->type, nullptr, false, SymbolType::FIELD);
        classSymbol->constructorParams[field->name] = fieldSymbol;
    }

    for (auto& field : body->fields) {
        llvm::Type* fieldType = codeGenerator->getLLVMType(field->type.get());
        if (!fieldType) {
            std::cerr << "Error: Unsupported field type '" << field->type->getName() << "' in class '" << name << "'" << std::endl;
            return nullptr;
        }

        Symbol* fieldSymbol = new Symbol(field->name, field->type, nullptr, field->isMutable, SymbolType::FIELD);
        classSymbol->fields[field->name] = fieldSymbol;
    }

    // 클래스 타입 생성
    std::vector<llvm::Type*> fieldTypes;
    // 생성자 파라메터 추가
    for (auto& fieldEntry : classSymbol->constructorParams) {
        llvm::Type* fieldType = codeGenerator->getLLVMType(fieldEntry.second->type.get());
        if (!fieldType) {
            std::cerr << "Error: Unsupported field type '" << fieldEntry.second->type->getName() << "' in class '" << name << "'" << std::endl;
            return nullptr;
        }
        fieldTypes.push_back(fieldType);
    }

    // 일반 필드 추가
    for (auto& fieldEntry : classSymbol->fields) {
        llvm::Type* fieldType = codeGenerator->getLLVMType(fieldEntry.second->type.get());
        if (!fieldType) {
            std::cerr << "Error: Unsupported field type '" << fieldEntry.second->type->getName() << "' in class '" << name << "'" << std::endl;
            return nullptr;
        }
        fieldTypes.push_back(fieldType);
    }

    llvm::StructType* classType = llvm::StructType::create(codeGenerator->context, fieldTypes, name);
    classSymbol->classType = classType;

    // 메서드 선언 생성 (실제 코드 생성은 나중에 수행)
    for (auto& method : body->methods) {
        declareMethod(method.get(), classSymbol);
    }

    // 심볼 테이블에 클래스 심볼 추가
    codeGenerator->symbolTable.addSymbol(name, classSymbol);

    return nullptr;
}

void ClassDeclarationNode::declareMethod(FunctionDeclarationNode* method, ClassSymbol* classSymbol) {
    std::vector<llvm::Type*> paramTypes;
    paramTypes.push_back(classSymbol->classType->getPointerTo()); // this 포인터 타입

    for (auto& param : method->parameters) {
        llvm::Type* paramType = codeGenerator->getLLVMType(param->type.get());
        if (!paramType) {
            std::cerr << "Error: Not supported the parameter's type of '" << method->name << "'" << std::endl;
            return;
        }
        paramTypes.push_back(paramType);
    }

    llvm::Type* returnType = codeGenerator->getLLVMType(method->returnType.get());
    if (!returnType) {
        std::cerr << "Error: Not supported the return type of '" << method->name << "'" << std::endl;
        return;
    }

    llvm::FunctionType* funcType = llvm::FunctionType::get(returnType, paramTypes, false);
    std::string methodName = name + "_" + method->name; // 클래스 이름을 접두사로 사용
    llvm::Function* function = llvm::Function::Create(funcType, llvm::Function::ExternalLinkage, methodName, codeGenerator->module.get());

    std::vector<Type*> types;
    types.push_back(new ClassType(name));
    for (auto& param : method->parameters) {
        types.push_back(param->getType().get());
    }

    // 메서드 심볼 업데이트
	std::shared_ptr<Type> pType = std::make_shared<FunctionType>(types, method->returnType.get());
    Symbol* methodSymbol = new Symbol(method->name, pType, function, false, SymbolType::METHOD);
	classSymbol->methods[method->name] = methodSymbol;

    // 메서드 본문 생성을 지연시키기 위해 FunctionDeclarationNode를 저장
    classSymbol->methodBodies[method->name] = method;
    //classSymbol->methodBodies[method->name] = method;
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
	std::vector<llvm::Type*> paramTypes;

    for (auto& param: this->parameters) {
        paramTypes.push_back(codeGenerator->getLLVMType(param->getType().get()));
	}

    llvm::Type* returnType = codeGenerator->getLLVMType(this->returnType.get());
    if (!returnType) {
        std::cerr << "Error: Not supported the return type of '" << this->name << "'" << std::endl;
        return nullptr;
    }
    llvm::FunctionType* funcType = llvm::FunctionType::get(returnType, paramTypes, false);
	// 함수를 둘러싸고 있는 이름공간이 있을 경우 이름공간 접두사 추가
    std::string funcName = [&]() {
        if (codeGenerator->scopes.empty()) {
            return "_" + this->name;
        }
        else {
            return join(codeGenerator->scopes, "#") + "#" + this->name;
        }
    }();

    llvm::Function* function = llvm::Function::Create(funcType, llvm::Function::ExternalLinkage, this->name, codeGenerator->module.get());

    // TODO: 심볼 테이블에 함수 심볼 추가
    // TODO: 지금까지 symboltable에 함수 심볼을 추가하고, 기존 심볼 테이블의 정보를 계승받는 새로운 심볼 테이블을 만들어서, 거기에 함수 내부 변수등이 선언되어 들어가도록 함
	Symbol* functionSymbol = new FunctionSymbol(this->name, this->getType(), function, false, SymbolType::FUNCTION);
	codeGenerator->symbolTable.addSymbol(this->name, functionSymbol);
	codeGenerator->symbolTable.setCurrentSymbol(functionSymbol);
    codeGenerator->symbolTable.enterScope();

    // 함수 인자 심볼 추가
    int cnt = 0;
    for (auto& arg : this->parameters) {
		Symbol* paramSymbol = new Symbol(arg->name, arg->getType(), function->getArg(cnt), false, SymbolType::VARIABLE);
		codeGenerator->symbolTable.addSymbol(arg->name, paramSymbol);
        cnt += 1;
    }

    // block start
	llvm::BasicBlock* bb = llvm::BasicBlock::Create(codeGenerator->context, "entry", function);
	codeGenerator->builder.SetInsertPoint(bb);
    this->body->codegen();
    // block end
	// body에 return이 있을 것이므로 여기서 리턴 코드를 추가하지 않음

    codeGenerator->symbolTable.exitScope();

    return nullptr;
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
    auto symbolOpt = codeGenerator->symbolTable.lookup(value);
    if (symbolOpt) {
		Symbol* symbol = (*symbolOpt);
        return codeGenerator->builder.CreateLoad(codeGenerator->getLLVMType(symbol->type.get()), symbol->value, value.c_str());
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

    auto symbolOpt = codeGenerator->symbolTable.lookup(value);
    if (symbolOpt) {
		Symbol* symbol = (*symbolOpt);
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
    if (this->initializer) {
        initValue = this->initializer->codegen();
        if (!initValue) {
            return nullptr;
        }
    }
    else {
        initValue = llvm::Constant::getNullValue(codeGenerator->getLLVMType(type.get()));
    }

    if (this->type->getKind() == Type::Kind::UNKNOWN && initValue != nullptr) {
                // 초기화 식의 타입으로 변수 타입 추론
        if (initValue->getType()->isIntegerTy(32)) {
            this->type = std::make_shared<BasicType>("Int");
        }
        else if (initValue->getType()->isFloatTy()) {
            this->type = std::make_shared<BasicType>("Float");
        }
        else if (initValue->getType()->isDoubleTy()) {
            this->type = std::make_shared<BasicType>("Double");
        }
        else if (initValue->getType()->isStructTy()) {
            std::string structName = initValue->getType()->getStructName().str();
            this->type = std::make_shared<ClassType>(structName);
		}
        // string type
        else if (initValue->getType()->isPointerTy() &&
                 initValue->getType()->isIntegerTy(1)) {
            this->type = std::make_shared<BasicType>("String");
		}
        /*else if (initValue->getType()->isPointerTy()) {
            this->type = std::make_shared<PointerType>(std::make_shared<UnknownType>());
         }*/
        else {
            std::cerr << "Error: Unable to infer variable type for '" << name << "'" << std::endl;
            return nullptr;
		}
    }

    llvm::Type* varType = codeGenerator->getLLVMType(type.get());
    if (!varType) {
        std::cerr << "Error: Unsupported variable type '" << type->getName() << "'" << std::endl;
        return nullptr;
    }

    llvm::AllocaInst* alloc = codeGenerator->builder.CreateAlloca(varType, nullptr, name.c_str());

    codeGenerator->builder.CreateStore(initValue, alloc);

    Symbol* symbol = new Symbol(name, type, alloc, isMutable, SymbolType::VARIABLE);
    codeGenerator->symbolTable.addSymbol(name, symbol);

    return alloc;
}

// IfStatementNode
void IfStatementNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* IfStatementNode::codegen() {
    llvm::Value* conditionValue = this->condition->codegen();
    if (!conditionValue) {
        return nullptr;
    }

    // conditionValue가 정수 타입인 경우 0과 비교하여 boolean으로 변환 후 분기 처리
    if (conditionValue->getType()->isIntegerTy()) {
        conditionValue = codeGenerator->builder.CreateICmpNE(
            conditionValue, llvm::ConstantInt::get(codeGenerator->context, llvm::APInt(conditionValue->getType()->getIntegerBitWidth(), 0)), "ifcond");
    }
	// conditionValue가 pointer 타입인 경우 null과 비교하여 boolean으로 변환 후 분기 처리
    else if (conditionValue->getType()->isPointerTy()) {
        conditionValue = codeGenerator->builder.CreateICmpNE(
			conditionValue, llvm::ConstantPointerNull::get(static_cast<llvm::PointerType*>(conditionValue->getType())), "ifcond");
    }
	// conditionValue가 boolean 타입이 아닌 경우 오류 처리
    else if (!conditionValue->getType()->isIntegerTy(1)) {
        std::cerr << "Error: Condition is not a boolean expression." << std::endl;
        return nullptr;
    }

    // 현재 current block을 얻어옴
    auto* currentFunction = codeGenerator->builder.GetInsertBlock()->getParent();
    auto* currBlock = codeGenerator->builder.GetInsertBlock();

	// then 블록과 else 블록을 생성 후 위 에서 얻어온 current block에서 조건에 따라 분기
    llvm::BasicBlock* thenBB = llvm::BasicBlock::Create(codeGenerator->context, "then", currentFunction);
	llvm::BasicBlock* elseBB = nullptr;
    if (this->elseBlock != nullptr) {
        elseBB = llvm::BasicBlock::Create(codeGenerator->context, "else", currentFunction);
    }
    llvm::BasicBlock* mergeBB = llvm::BasicBlock::Create(codeGenerator->context, "ifcont", currentFunction);

	// if else 일때 마지막 expression(또는 statement)의 값을 다음 instruction에서 사용할 수 있도록 PHI 노드 생성
    if (this->elseBlock != nullptr) {
        codeGenerator->builder.CreateCondBr(conditionValue, thenBB, elseBB);
        // then 블록 코드 생성
        codeGenerator->builder.SetInsertPoint(thenBB);
        llvm::Value* thenValue = thenBlock->codegen();
        if (!thenValue) {
            return nullptr;
        }
        codeGenerator->builder.CreateBr(mergeBB);
        thenBB = codeGenerator->builder.GetInsertBlock();
        // else 블록 코드 생성
        codeGenerator->builder.SetInsertPoint(elseBB);
        llvm::Value* elseValue = elseBlock->codegen();
        if (!elseValue) {
            return nullptr;
        }
        codeGenerator->builder.CreateBr(mergeBB);
        elseBB = codeGenerator->builder.GetInsertBlock();

		codeGenerator->builder.SetInsertPoint(mergeBB);

        auto* phi = codeGenerator->builder.CreatePHI(llvm::Type::getInt32Ty(codeGenerator->context), 2, "result");
		// then 와 else 경우 구분
        phi->addIncoming(thenValue, thenBB);
		phi->addIncoming(elseValue, elseBB);

        return phi;
    }
    else {
        codeGenerator->builder.CreateCondBr(conditionValue, thenBB, mergeBB);
        // then 블록 코드 생성
        codeGenerator->builder.SetInsertPoint(thenBB);
        llvm::Value* thenValue = thenBlock->codegen();
        if (!thenValue) {
            return nullptr;
        }
        codeGenerator->builder.CreateBr(mergeBB);

		codeGenerator->builder.SetInsertPoint(mergeBB);

        /*auto* phi = codeGenerator->builder.CreatePHI(llvm::Type::getInt32Ty(codeGenerator->context), 2, "result");
        // then 와 else 경우 구분
        phi->addIncoming(thenValue, thenBB);
        phi->addIncoming(elseValue, elseBB);*/
		// null 반환
        return nullptr;
    }

    //return llvm::Constant::getNullValue(llvm::Type::getInt32Ty(codeGenerator->context));
}

// ForStatementNode
void ForStatementNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* ForStatementNode::codegen() {
    llvm::Function* function = codeGenerator->builder.GetInsertBlock()->getParent();

    // for 문은 맨 처음 iteration 변수를 초기화하고,
	llvm::BasicBlock* beforeLoopBB = codeGenerator->builder.GetInsertBlock();

    llvm::Value* startValue;
    llvm::Value* endValue;

    llvm::Value* value_ptr = nullptr;

    if (this->isRange) {
        //
        auto rangeExpr = std::dynamic_pointer_cast<RangeExpressionNode>(this->iterableExpr);
        startValue = rangeExpr->startExpr->codegen();
        endValue = rangeExpr->endExpr->codegen();
        if (!startValue || !endValue) {
            return nullptr;
        }

        if (!rangeExpr->isInclusive) {
            endValue = codeGenerator->builder.CreateSub(endValue, llvm::ConstantInt::get(llvm::Type::getInt32Ty(codeGenerator->context), 1), "untilEnd");
        }

		// 새로운 integer type의 value를 만들어서 추가
        value_ptr = codeGenerator->builder.CreateAlloca(startValue->getType(), nullptr, this->variable + "_ptr");
		// 초기화: startValue의 값을 value에 assign함
        codeGenerator->builder.CreateStore(startValue, value_ptr);

        // iteration 변수를 symbol table에 추가 : VARIABLE은 ptr임
        auto varSymbol = new Symbol(this->variable, rangeExpr->startExpr->getType(), value_ptr, false, SymbolType::VARIABLE);
        codeGenerator->symbolTable.addSymbol(this->variable, varSymbol);
    }
    else {
        startValue = llvm::ConstantInt::get(llvm::Type::getInt32Ty(codeGenerator->context), 0);
        endValue = llvm::ConstantInt::get(llvm::Type::getInt32Ty(codeGenerator->context), 10);

        // 새로운 value를 만들어서 추가
        value_ptr = codeGenerator->builder.CreateAlloca(startValue->getType(), nullptr, this->variable + "_ptr");
		codeGenerator->builder.CreateStore(startValue, value_ptr);

        // iteration 변수를 symbol table에 추가
        auto varSymbol = new Symbol(this->variable, std::make_shared<BasicType>("Int"), value_ptr, false, SymbolType::VARIABLE);
        codeGenerator->symbolTable.addSymbol(this->variable, varSymbol);
    }

    llvm::BasicBlock* loopBB = llvm::BasicBlock::Create(codeGenerator->context, "loop", function);
    llvm::BasicBlock* afterBB = llvm::BasicBlock::Create(codeGenerator->context, "afterloop", function);

	codeGenerator->builder.SetInsertPoint(loopBB);
	this->body->codegen();

    // i를 하나 증가 시킴
    // next value를 가져오는 함수를 호출해야하지만, 여기서는 일단 단순히 1 증가시킴
    auto* value = codeGenerator->builder.CreateLoad(startValue->getType(), value_ptr, this->variable.c_str());
    auto* next_value = codeGenerator->builder.CreateAdd(value, codeGenerator->builder.getInt32(1), "next_i");
    codeGenerator->builder.CreateStore(next_value, value_ptr);

    auto* cond = codeGenerator->builder.CreateICmpSLE(value, endValue, "cond");
    codeGenerator->builder.CreateCondBr(cond, loopBB /*body and increment*/, afterBB);

    // jump back to loop
    codeGenerator->builder.SetInsertPoint(afterBB);

    return nullptr;
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

/*bool isStringTypeFromLLVM(llvm::Value* value, CodeGenerator* codeGenerator) {
    return value->getType()->isPointerTy() && ((llvm::PointerType*)value->getType())->isValidElementType(llvm::Type::getInt8Ty(codeGenerator->context));
}*/

llvm::Value* BinaryExpressionNode::codegen() {
    llvm::Value* leftValue = left->codegen();
    llvm::Value* rightValue = right->codegen();
    if (!leftValue || !rightValue) {
        return nullptr;
    }

    if (leftValue->getType()->isPointerTy()) {
        leftValue = codeGenerator->builder.CreateLoad(codeGenerator->getLLVMType(left->getType().get()), leftValue, "loadtmp");
    }
    if (rightValue->getType()->isPointerTy()) {
        rightValue = codeGenerator->builder.CreateLoad(codeGenerator->getLLVMType(right->getType().get()), rightValue, "loadtmp");
    }

    if (op == "+") {
        // If leftvalue and rightvalue are both numerical primitives type, perform numerical addition.
        // If leftvalue and rightvalue are both objects based on class, perform method call.
        // If leftvalue and rightvalue are different types, perform type casting and then addition.
        // First, we need to check if leftValue and rightValue are both numerical primitives type.
        if (left->getType()->getName() == right->getType()->getName()) {
            if (left->getType()->isIntegerTy()) {
                return codeGenerator->builder.CreateAdd(leftValue, rightValue, "addtmp");
            }
            else if (left->getType()->isFloatTy()) {
                return codeGenerator->builder.CreateFAdd(leftValue, rightValue, "faddtmp");
            }
            else {
                std::cerr << "Type error: Operator '" << op << "' not applicable to type '" << left->getType()->getName() << "' and '" << right->getType()->getName() << "'" << std::endl;
                return nullptr;
            }
        }
        else {
            // TODO: 상속 관계일 경우 비교 연산자가 재정의 되어 있는지 확인 후 해당 메소드 호출
            // 없다면, 아래 오류 발생
            std::cerr << "Type error: Left and right expressions have different types for operator '" << op << "'" << std::endl;
			return nullptr;
        }
    }
    else if (op == "-") {
        if (left->getType()->getName() == right->getType()->getName()) {
            if (left->getType()->isIntegerTy()) {
                return codeGenerator->builder.CreateSub(leftValue, rightValue, "subtmp");
            }
            else if (left->getType()->isFloatTy()) {
                return codeGenerator->builder.CreateFSub(leftValue, rightValue, "fsubtmp");
            }
            else {
                std::cerr << "Type error: Operator '" << op << "' not applicable to type '" << left->getType()->getName() << "' and '" << right->getType()->getName() << "'" << std::endl;
                return nullptr;
            }
        }
        else {
            std::cerr << "Type error: Operator '" << op << "' not applicable to type '" << left->type->getName() << "' and '" << right->type->getName() << "'" << std::endl;
            return nullptr;
        }
    }
    else if (op == "*") {
        if (left->getType()->getName() == right->getType()->getName()) {
            if (left->getType()->isIntegerTy()) {
                return codeGenerator->builder.CreateMul(leftValue, rightValue, "subtmp");
            }
            else if (left->getType()->isFloatTy()) {
                return codeGenerator->builder.CreateFMul(leftValue, rightValue, "fsubtmp");
            }
            else {
                std::cerr << "Type error: Operator '" << op << "' not applicable to type '" << left->getType()->getName() << "' and '" << right->getType()->getName() << "'" << std::endl;
                return nullptr;
            }
        }
        else {
            std::cerr << "Type error: Operator '" << op << "' not applicable to type '" << left->type->getName() << "' and '" << right->type->getName() << "'" << std::endl;
            return nullptr;
        }
    }
    else if (op == "/") {
        if (left->getType()->getName() == right->getType()->getName()) {
            if (left->getType()->isIntegerTy()) {
                // signed?
                return codeGenerator->builder.CreateSDiv(leftValue, rightValue, "subtmp");
            }
            else if (left->getType()->isFloatTy()) {
                return codeGenerator->builder.CreateFDiv(leftValue, rightValue, "fsubtmp");
            }
            else {
                std::cerr << "Type error: Operator '" << op << "' not applicable to type '" << left->getType()->getName() << "' and '" << right->getType()->getName() << "'" << std::endl;
                return nullptr;
            }
        }
        else {
            std::cerr << "Type error: Operator '" << op << "' not applicable to type '" << left->type->getName() << "' and '" << right->type->getName() << "'" << std::endl;
            return nullptr;
        }
    }
    else if (op == ">") {
		return codeGenerator->builder.CreateICmpSGT(leftValue, rightValue, "gttmp");
    }
    else if (op == "<") {
		return codeGenerator->builder.CreateICmpSLT(leftValue, rightValue, "lttmp");
    }
	else if (op == "==") {
        return codeGenerator->builder.CreateICmpEQ(leftValue, rightValue, "eqtmp");
	}
    else if (op == ">=") {
        return codeGenerator->builder.CreateICmpSGE(leftValue, rightValue, "getmp");
    }
    else if (op == "<=") {
        return codeGenerator->builder.CreateICmpSLE(leftValue, rightValue, "letmp");
	}
    else {
        std::cerr << "Unsupported binary operator: " << op << std::endl;
        return nullptr;
    }
}

std::shared_ptr<Type> BinaryExpressionNode::getType() {
    if (type) return type;

    auto leftType = left->getType().get();
    auto rightType = right->getType().get();

    if (!leftType->equals(rightType)) {
        std::cerr << "Type error: Left and right expressions have different types" << std::endl;
        type = std::make_shared<UnknownType>();
        return type;
    }

    if (op == "+" || op == "-" || op == "*" || op == "/") {
        if (leftType->getName() == "Int" || leftType->getName() == "Float" || leftType->getName() == "Double") {
            // 기존 raw 포인터를 이용해 새 객체를 만들지 않고,
            // 서브식이 갖고 있는 shared_ptr을 그대로 재사용하여 타입을 설정.
            type = left->getType();
            return type;
        }
        else {
            std::cerr << "Type error: Operator '" << op << "' not applicable to type '" << leftType->getName() << "'" << std::endl;
            type = std::make_shared<UnknownType>();
            return type;
        }
    }
    else {
        // 다른 연산자 추가 시 처리 예정
    }

    type = std::make_shared<UnknownType>();
    return type;
}

void AssignmentNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* AssignmentNode::codegen() {
    // C/C++의 '=' 연산자는 오른쪽 값을 왼쪽에 대입하는 연산자이다.
    // 왼쪽 값은 변수이어야 한다.
    // 오른쪽 값은 변수이거나 메서드 호출 결과이어야 한다.
    auto symbolOpt = codeGenerator->symbolTable.lookup(name);
    if (!symbolOpt) {
        std::cerr << "Undefined variable: " << name << std::endl;
        return nullptr;
    }

	auto symbol = (*symbolOpt);
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
    auto symbolOpt = codeGenerator->symbolTable.lookup(value);
    if (!symbolOpt) {
        std::cerr << "Undefined variable: " << value << std::endl;
        return nullptr;
    }

    auto symbol = (*symbolOpt);

	// this 포인터 또는 parameter, class의 field인 경우는 CreateLoad를 하지 않아야 함. llvm::Value가 있기 때문에
    // local 변수는?
	return symbol->value;
}

std::shared_ptr<Type> IdentifierNode::getType() {
	if (type) return type;

	auto symbolOpt = codeGenerator->symbolTable.lookup(value);
	if (symbolOpt) {
		auto symbol = (*symbolOpt);
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
        // long, short, int, char, byte 등의 타입 처리가 필요
		return llvm::ConstantInt::get(llvm::Type::getInt32Ty(codeGenerator->context), std::stoi(value));
	}
	else if (valueType == TokenType::FLOAT_LITERAL) {
		return llvm::ConstantFP::get(llvm::Type::getFloatTy(codeGenerator->context), std::stof(value));
	}
	else if (valueType == TokenType::BINARY_LITERAL) {
		return llvm::ConstantInt::get(llvm::Type::getInt32Ty(codeGenerator->context), std::stoi(value.substr(2), nullptr, 2));
	}
	else if (valueType == TokenType::HEX_LITERAL) {
		return llvm::ConstantInt::get(llvm::Type::getInt32Ty(codeGenerator->context), std::stoi(value.substr(2), nullptr, 16));
	}
	else if (valueType == TokenType::OCTAL_LITERAL) {
		return llvm::ConstantInt::get(llvm::Type::getInt32Ty(codeGenerator->context), std::stoi(value.substr(2), nullptr, 8));
	}
	else if (valueType == TokenType::STRING_LITERAL) {
		return codeGenerator->builder.CreateGlobalStringPtr(value);
	}
    else if (valueType == TokenType::BOOLEAN_LITERAL) {
        if (value == "true") {
            return llvm::ConstantInt::get(llvm::Type::getInt1Ty(codeGenerator->context), 1);
        }
        else {
            return llvm::ConstantInt::get(llvm::Type::getInt1Ty(codeGenerator->context), 0);
        }
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
	//std::cout << "name: " << name.str() << std::endl;
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
    if (!objectType || objectType->getKind() != Type::Kind::CLASS) {
        std::cerr << "Error: Method call on non-class type" << std::endl;
        return nullptr;
    }

    // 클래스 심볼 가져오기
    auto symbol = codeGenerator->symbolTable.lookupClass(objectType->getName());
    if (!symbol) {
        std::cerr << "Error: Undefined class type '" << objectType->getName() << "'" << std::endl;
        return nullptr;
    }

	ClassSymbol* classSymbol = (*symbol);

    // 메서드 룩업
    auto methodSymbolOpt = codeGenerator->symbolTable.lookupMethod(*classSymbol, methodName);
    if (!methodSymbolOpt) {
        std::cerr << "Error: Method '" << methodName << "' not found in class '" << objectType->getName() << "'" << std::endl;
        return nullptr;
    }

	auto methodSymbol = (*methodSymbolOpt);

    // 함수 타입과 LLVM 함수 가져오기
    auto funcType = std::dynamic_pointer_cast<FunctionType>(methodSymbol->type);
    llvm::Function* function = static_cast<llvm::Function*>(methodSymbol->value);
    if (!function) {
        auto symbol = codeGenerator->symbolTable.lookupClass(objectType->getName());
        if (!symbol) {
            std::cerr << "Error: Undefined class type '" << objectType->getName() << "'" << std::endl;
            return nullptr;
		}

		ClassSymbol* classSymbol = *symbol;
        if (classSymbol->methodBodies.find(methodName) == classSymbol->methodBodies.end()) {
            std::cerr << "Error: Method '" << methodName << "' not found in class '" << objectType->getName() << "'" << std::endl;
            return nullptr;
        }
        // 해당 method가 구현되어 있지 않다면, 구한다.
        auto method = classSymbol->methodBodies[methodName];
        method->codegen();
        function = codeGenerator->module->getFunction(methodName);
        methodSymbol->value = function;
        codeGenerator->symbolTable.addSymbol(methodName, methodSymbol);
    }

    if (!funcType || !function) {
        std::cerr << "Error: Invalid method '" << methodName << "' in class '" << objectType->getName() << "'" << std::endl;
        return nullptr;
    }

    // 인자 값 생성
    std::vector<llvm::Value*> argValues;
    // 첫 번째 인자로 객체 포인터 전달 (this 포인터)
    argValues.push_back(objectValue);

    if (arguments.size() + 1 != funcType->parameterTypes.size()) {
        std::cerr << "Error: Argument count mismatch in method call '" << methodName << "'" << std::endl;
        return nullptr;
    }

    for (size_t i = 0; i < arguments.size(); ++i) {
        llvm::Value* argValue = arguments[i]->codegen();
        if (!argValue) {
            return nullptr;
        }

        // 인자의 타입 검사
        auto expectedType = funcType->parameterTypes[i];
        std::shared_ptr<Type> actualType = arguments[i]->getType();
        if (!actualType->equals(expectedType)) {
            std::cerr << "Type error: Argument type mismatch in method call '" << methodName << "'" << std::endl;
            return nullptr;
        }

        argValues.push_back(argValue);
    }

    // 함수 호출 생성
    llvm::Value* result = codeGenerator->builder.CreateCall(function, argValues);
    return result;
}

std::shared_ptr<Type> MethodCallNode::getType() {
    // 메서드의 반환 타입을 반환
    if (type) return type;

    // 객체의 타입 가져오기
    std::shared_ptr<Type> objectType = object->getType();
    if (!objectType || objectType->getKind() != Type::Kind::CLASS) {
        type = std::make_shared<UnknownType>();
        return type;
    }

    // 클래스 심볼 가져오기
    auto classSymbolOpt = codeGenerator->symbolTable.lookupClass(objectType->getName());
    if (!classSymbolOpt) {
        type = std::make_shared<UnknownType>();
        return type;
    }

	auto classSymbol = *classSymbolOpt;

    // 메서드 룩업
    auto methodSymbolOpt = codeGenerator->symbolTable.lookupMethod(*classSymbol, methodName);
    if (!methodSymbolOpt) {
        type = std::make_shared<UnknownType>();
        return type;
    }

	auto methodSymbol = *methodSymbolOpt;

    // 함수 타입 가져오기
    auto funcType = std::dynamic_pointer_cast<FunctionType>(methodSymbol->type);
    if (funcType) {
        type = std::make_shared<Type>(*funcType->returnType);
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
        llvm::Type* type = codeGenerator->getLLVMType(new BasicType(typeName));
        return codeGenerator->builder.CreateAlloca(type, array_size, typeName);
    }

    // Template Class인지 확인은 나중에 코드 추가되면...

    // 클래스 심볼 찾기
    auto classSymbolOpt = codeGenerator->symbolTable.lookupClass(typeName);
    if (!classSymbolOpt) {
        std::cerr << "Error: Class '" << typeName << "' not found" << std::endl;
        return nullptr;
    }

	auto classSymbol = (*classSymbolOpt);

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

llvm::Value* AssignmentExpressionNode::codegen() {
    llvm::Value* leftValue = left->codegen();
    llvm::Value* rightValue = right->codegen();
    if (!leftValue || !rightValue) {
		std::cerr << "Error: Assignment failed" << std::endl;
        return nullptr;
    }

    // 메모리 사이의 이동은 CreateStore로
    codeGenerator->builder.CreateStore(rightValue, leftValue);

	return leftValue;
}

std::shared_ptr<Type> AssignmentExpressionNode::getType()
{
    return left->getType();
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
            auto classSymbolOpt = codeGenerator->symbolTable.lookupClass(classType->getName().str());

            if (classSymbolOpt) {
				auto classSymbol = (*classSymbolOpt);
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
            auto classSymbolOpt = codeGenerator->symbolTable.lookupClass(classType->getName().str());

            if (classSymbolOpt) {
				auto classSymbol = *classSymbolOpt;
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
            auto classSymbolOpt = codeGenerator->symbolTable.lookupClass(classType->getName().str());

            if (classSymbolOpt) {
				auto classSymbol = *classSymbolOpt;
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
            auto classSymbolOpt = codeGenerator->symbolTable.lookupClass(classType->getName().str());

            if (classSymbolOpt) {
				auto classSymbol = *classSymbolOpt;
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
            auto classSymbolOpt = codeGenerator->symbolTable.lookupClass(classType->getName().str());

            if (classSymbolOpt) {
				auto classSymbol = *classSymbolOpt;
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
    auto functionSymbolOpt = codeGenerator->symbolTable.lookupFunction(functionName, argTypes);
    if (functionSymbolOpt) {
		auto functionSymbol = *functionSymbolOpt;
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
        type = std::make_shared<Type>(*funcType->returnType);
        return result;
    }
    else {
        llvm::Function* function = codeGenerator->module->getFunction(functionName);
        if (function) {
            llvm::Value* result = codeGenerator->builder.CreateCall(function, argValues, "calltmp");
            return result;
        }
        else {
            std::cerr << "Error: Not found function name '" << functionName << "'" << std::endl;
            return nullptr;
        }
    }
}

std::shared_ptr<Type> FunctionCallNode::getType() {
    if (type) return type;

    // 함수 심볼 찾기
    std::vector<std::shared_ptr<Type>> argTypes;
    for (auto& arg : arguments) {
        argTypes.push_back(arg->getType());
    }

    auto functionSymbolOpt = codeGenerator->symbolTable.lookupFunction(functionName, argTypes);
    if (!functionSymbolOpt) {
        printf("functionSymbolOpt is nullopt");
        type = std::make_shared<UnknownType>();
        return type;
    }

	auto functionSymbol = *functionSymbolOpt;

    auto funcType = std::dynamic_pointer_cast<FunctionType>(functionSymbol->type);
    if (funcType) {
        type = std::make_shared<Type>(*funcType->returnType);
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
    llvm::Type* elementType = codeGenerator->getLLVMType(arrayType->typeArguments[0].get());
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

    llvm::Type* elementType = codeGenerator->getLLVMType(getType().get());
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
    auto leftValue = base;
    auto rightValue = field;
    if (!leftValue || !rightValue) {
        return nullptr;
    }

    // base가 IdentifierNode가 아닐 수 있으므로 타입 체크 필요
    if (!dynamic_cast<IdentifierNode*>(leftValue.get())) {
        std::cerr << "Error: Base must be an identifier" << std::endl;
        return nullptr;
    }

    auto baseType = ((IdentifierNode*)leftValue.get())->getType();
    if (!baseType || baseType->getKind() != Type::Kind::CLASS) {
        std::cerr << "Error: Base must be a class type" << std::endl;
        return nullptr;
    }

    auto classSymbolOpt = codeGenerator->symbolTable.lookupClass(baseType->getName());
    if (!classSymbolOpt) {
        std::cerr << "Error: Class '" << baseType->getName() << "' not found" << std::endl;
        return nullptr;
    }

	auto classSymbol = *classSymbolOpt;

    auto thisSymbolOpt = codeGenerator->symbolTable.lookup(((IdentifierNode*)leftValue.get())->value);
    if (!thisSymbolOpt) {
        std::cerr << "Error: Base object not found" << std::endl;
        return nullptr;
    }

	auto thisSymbol = *thisSymbolOpt;

    auto targetName = ((IdentifierNode*)rightValue.get())->value;

    // 필드 위치 찾기를 별도 함수로 분리
    int fieldIndex = findFieldIndex(classSymbol, targetName);
    if (fieldIndex == -1) {
        std::cerr << "Error: Field '" << targetName << "' not found in class '"
                  << baseType->getName() << "'" << std::endl;
        return nullptr;
    }

    return codeGenerator->builder.CreateStructGEP(
        codeGenerator->getLLVMType(field->getType().get()),
        thisSymbol->value,
        fieldIndex + 1, // +1 for this pointer
        targetName
    );
}

// 필드 인덱스를 찾는 헬퍼 함수 추가
int AccessFieldNode::findFieldIndex(ClassSymbol* classSymbol, const std::string& fieldName) {
    int idx = 0;

    // 생성 파라미터에서 검색
    for (auto& field : classSymbol->constructorParams) {
        if (field.first == fieldName) {
            return idx;
        }
        idx++;
    }

    // 일반 필드에서 검색
    for (auto& field : classSymbol->fields) {
        if (field.first == fieldName) {
            return idx;
        }
        idx++;
    }

    return -1;
}

std::shared_ptr<Type> AccessFieldNode::getType() {
    // left의 type과 동일
	return field->getType();
}

void AttributeNode::accept(ASTVisitor& visitor) {
    visitor.visit(*this);
}

llvm::Value* AttributeNode::codegen() {
	// Node가 IdentifierNode이라고 하더라도 FunctionCall로 취급
    switch(this->expr->nodeType) {
    case ASTNodeType::FUNCTION_CALL:
		return this->expr->codegen();

    case ASTNodeType::IDENTIFIER:
        {
            auto identifierNode = dynamic_cast<IdentifierNode*>(this->expr.get());
            if (!identifierNode) {
                std::cerr << "Error: Invalid identifier node" << std::endl;
                return nullptr;
            }

            // Attribute 종류에 따른 처리
            if (identifierNode->value == "DllImport") {
				// 이거 다음의 함수는 외부 DLL에서 가져오는 함수로 처리
            }
            else if (identifierNode->value == "StaticLibraryImport") {
				// 이거 다음의 함수는 외부 Static Library에서 가져오는 함수로 처리
		    }
            else if (identifierNode->value == "Native") {
				// 이거 다음의 함수는 네이티브 함수로 처리 = Compiler에서 지원하는 함수
            }
            else {
                // 나머지는 사용자 지정으로 할 예정
            }
        }
        break;

    default:
        std::cerr << "Error: Unsupported expression type in AttributeNode" << std::endl;
		break;
	}

    return nullptr;
}

std::shared_ptr<Type> AttributeNode::getType() {
    // left의 type과 동일
    return nullptr;
}

