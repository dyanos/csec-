// symbol_table.cpp

#include "symbol_table.h"
#include "ast.h"
#include "type_utils.h"

SymbolTable::SymbolTable() {
    // 전역 범위 생성
    enterScope();
}

void SymbolTable::initializeBuiltInTypes(llvm::LLVMContext& context) {
    // 최상위 타입 Any
    auto anyType = std::make_shared<ClassType>("Any");
    addTypeSymbol("Any", anyType);

    // 값 타입 AnyVal
    auto anyValType = std::make_shared<ClassType>("AnyVal", anyType);
    addTypeSymbol("AnyVal", anyValType);

    // 기본 타입 등록
    addTypeSymbol("Int", std::make_shared<BasicType>("Int", anyValType));
    addTypeSymbol("Float", std::make_shared<BasicType>("Float", anyValType));
    addTypeSymbol("Double", std::make_shared<BasicType>("Double", anyValType));
    addTypeSymbol("Char", std::make_shared<BasicType>("Char", anyValType));
    addTypeSymbol("Boolean", std::make_shared<BasicType>("Boolean", anyValType));

    // 참조 타입 AnyRef
    auto anyRefType = std::make_shared<ClassType>("AnyRef", anyType);
    addTypeSymbol("AnyRef", anyRefType);

    // String 타입
    addTypeSymbol("String", std::make_shared<ClassType>("String", anyRefType));

    // Unit 타입 (void)
    addTypeSymbol("Unit", std::make_shared<BasicType>("Unit", anyValType));

    // 기본 타입을 클래스 심볼로 등록
    auto intType = lookupType("Int");
    ClassSymbol intClassSymbol("Int", llvm::Type::getInt32Ty(context), "AnyVal");
    classSymbols["Int"] = intClassSymbol;

    auto charType = lookupType("Char");
    ClassSymbol charClassSymbol("Char", llvm::Type::getInt8Ty(context), "AnyVal");
    classSymbols["Char"] = charClassSymbol;

	auto stringType = lookupType("String");
	ClassSymbol stringClassSymbol("String", llvm::PointerType::getUnqual(llvm::Type::getInt8Ty(context)), "AnyRef");
	classSymbols["String"] = stringClassSymbol;

    // Int 타입의 메서드 등록
    //auto& intClassSymbol = classSymbols["Int"];
    // 예를 들어, toString 메서드 등록
    auto toStringType = std::make_shared<FunctionType>(std::vector<std::shared_ptr<Type>>{}, lookupType("String"));
    Symbol toStringSymbol("toString", toStringType, nullptr, false, SymbolType::METHOD);
    intClassSymbol.methods["toString"] = toStringSymbol;
}

void SymbolTable::enterScope() {
    scopes.emplace_back();
}

void SymbolTable::exitScope() {
    if (!scopes.empty()) {
        scopes.pop_back();
    }
}

bool SymbolTable::addTypeSymbol(const std::string& name, std::shared_ptr<Type> type) {
    if (typeSymbols.count(name) == 0) {
        typeSymbols[name] = type;
        return true;
    }
    return false;  // 이미 존재하는 타입 심볼
}

std::shared_ptr<Type> SymbolTable::lookupType(const std::string& name) {
    auto it = typeSymbols.find(name);
    if (it != typeSymbols.end()) {
        return it->second;
    }
    return nullptr;  // 타입을 찾지 못함
}

bool SymbolTable::addSymbol(const std::string& name, const Symbol& symbol) {
    if (scopes.back().count(name) == 0) {
        scopes.back()[name] = symbol;
        return true;
    }
    return false;  // 이미 존재하는 심볼
}

Symbol* SymbolTable::lookup(const std::string& name) {
    for (auto it = scopes.rbegin(); it != scopes.rend(); ++it) {
        auto found = it->find(name);
        if (found != it->end()) {
            return &found->second;
        }
    }
    return nullptr;  // 심볼을 찾지 못함
}

Symbol* SymbolTable::lookupMethod(ClassSymbol* classSymbol, const std::string& methodName) {
    if (!classSymbol) {
        return nullptr;
    }

    auto it = classSymbol->methods.find(methodName);
    if (it != classSymbol->methods.end()) {
        return &it->second;
    }

    // 상위 클래스에서 메서드 찾기
    if (classSymbol->superClassSymbol) {
        return lookupMethod(classSymbol->superClassSymbol, methodName);
    }

    return nullptr;  // 메서드를 찾지 못함
}

SymbolTable* SymbolTable::resolveNamespace(const std::vector<std::string>& path) {
    SymbolTable* current = this;  // 또는 전역 네임스페이스에서 시작
    for (const auto& name : path) {
        auto it = current->namespaces.find(name);
        if (it != current->namespaces.end()) {
            current = it->second.get();
        }
        else {
            // 네임스페이스를 찾지 못함
            return nullptr;
        }
    }
    return current;
}

bool SymbolTable::importSymbols(const std::vector<std::string>& path) {
    SymbolTable* namespaceTable = resolveNamespace(path);
    if (namespaceTable) {
        // 현재 스코프로 심볼을 가져옵니다
        for (const auto& entry : namespaceTable->scopes.back()) {
            // 심볼을 현재 스코프에 추가
            scopes.back()[entry.first] = entry.second;
        }
        return true;
    }
    else {
        // 에러 처리: 네임스페이스를 찾지 못함
        return false;
    }
}

void SymbolTable::merge(const std::shared_ptr<SymbolTable>& other) {
    if (!other) {
        return;
    }

    // 다른 심볼 테이블의 전역 심볼을 현재 심볼 테이블의 전역 스코프에 병합
    auto& globalScope = scopes.front();
    auto& otherGlobalScope = other->scopes.front();

    for (const auto& entry : otherGlobalScope) {
        // 심볼 이름이 충돌하는 경우 처리 필요 (여기서는 단순히 덮어씁니다)
        globalScope[entry.first] = entry.second;
    }
}

bool SymbolTable::addClassSymbol(const std::string& name, const ClassSymbol& classSymbol) {
    if (classSymbols.count(name) == 0) {
        classSymbols[name] = classSymbol;
        scopes.back()[name] = classSymbol;
        return true;
    }
    return false;  // 이미 존재하는 클래스 심볼
}

ClassSymbol* SymbolTable::lookupClass(const std::string& name) {
    auto it = classSymbols.find(name);
    if (it != classSymbols.end()) {
        return &it->second;
    }
    return nullptr;  // 클래스를 찾지 못함
}

bool SymbolTable::addFunctionSymbol(const std::string& name, const Symbol& symbol) {
    functionSymbols[name].push_back(symbol);
    return true;
}

std::vector<Symbol>* SymbolTable::lookupFunctions(const std::string& name) {
    auto it = functionSymbols.find(name);
    if (it != functionSymbols.end()) {
        return &it->second;
    }
    return nullptr;
}

Symbol* SymbolTable::resolveFunctionCall(const std::string& name, const std::vector<std::shared_ptr<Type>>& argTypes) {
    auto functions = lookupFunctions(name);
    if (!functions) {
        return nullptr;
    }

    for (auto& funcSymbol : *functions) {
        auto funcType = std::dynamic_pointer_cast<FunctionType>(funcSymbol.type);
        if (funcType && areTypesCompatible(funcType->parameterTypes, argTypes)) {
            return &funcSymbol;
        }
    }
    return nullptr;
}