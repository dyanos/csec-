#pragma once

#include "symbol.h"
#include <unordered_map>
#include <vector>
#include <string>
#include <memory>

class SymbolTable {
public:
    SymbolTable();

    void initializeBuiltInTypes();

    void enterScope();
    void exitScope();

    bool addSymbol(const std::string& name, const Symbol& symbol);
    Symbol* lookup(const std::string& name);
    Symbol* lookupMethod(ClassSymbol* classSymbol, const std::string& methodName);

    // 타입 심볼 관리 함수
    bool addTypeSymbol(const std::string& name, std::shared_ptr<Type> type);
    std::shared_ptr<Type> lookupType(const std::string& name);

    // 네임스페이스 관리 함수
    bool importSymbols(const std::vector<std::string>& path);

    // merge 함수 추가
    void merge(const std::shared_ptr<SymbolTable>& other);

    bool addClassSymbol(const std::string& name, const ClassSymbol& classSymbol);
    ClassSymbol* lookupClass(const std::string& name);

    // 함수 심볼 추가
    bool addFunctionSymbol(const std::string& name, const Symbol& symbol);

    // 함수 심볼 목록 가져오기
    std::vector<Symbol>* lookupFunctions(const std::string& name);
    Symbol* resolveFunctionCall(const std::string& name, const std::vector<std::shared_ptr<Type>>& argTypes);

private:
    std::vector<std::unordered_map<std::string, Symbol>> scopes;

    // 네임스페이스를 나타내는 맵
    std::unordered_map<std::string, std::shared_ptr<SymbolTable>> namespaces;

    // 네임스페이스 경로를 해석하는 함수
    SymbolTable* resolveNamespace(const std::vector<std::string>& path);

    // 타입 심볼 맵
    std::unordered_map<std::string, std::shared_ptr<Type>> typeSymbols;

    // 함수 심볼을 관리하기 위한 맵 (함수 이름 -> 함수 심볼 리스트)
    std::unordered_map<std::string, std::vector<Symbol>> functionSymbols;

    std::unordered_map<std::string, ClassSymbol> classSymbols;
};
