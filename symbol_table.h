#pragma once

#include "symbol.h"

#include <functional>
#include <memory>
#include <string>
#include <unordered_map>
#include <vector>

class CodeGenerator;

struct Scope {
    std::unordered_map<std::string, std::unique_ptr<Symbol>> symbols;
    Scope* outer = nullptr; // non-owning parent scope
    int count = 0;
};

class SymbolTable {
public:
    SymbolTable();
    SymbolTable(const SymbolTable& other) = delete;
    SymbolTable(SymbolTable&& other) noexcept = default;
    SymbolTable& operator=(const SymbolTable& other) = delete;
    SymbolTable& operator=(SymbolTable&& other) noexcept = default;
    ~SymbolTable();

    void initializeBuiltInTypes(llvm::LLVMContext& context);
    void enterScope();
    void exitScope();
    bool addSymbol(const std::string& name, std::unique_ptr<Symbol> symbol);
    Symbol* lookup(const std::string& name);
    ClassSymbol* lookupClass(const std::string& name);
    StructSymbol* lookupStruct(const std::string& name);
    NamespaceSymbol* lookupNamespace(const std::string& name);
    FunctionSymbol* lookupFunction(const std::string& name, const std::vector<std::unique_ptr<Type>>& argTypes);
    Symbol* lookupMethod(const ClassSymbol& symbol, const std::string& methodName);
    void merge(const SymbolTable& other);
    void print(std::ostream& os, int indent = 0) const;

private:
    Scope* currentScope = nullptr; // non-owning, owned by ownedScopes
    int currentScopeLevel = 0;
    Symbol* currentSymbol = nullptr;
    std::vector<std::unique_ptr<Scope>> ownedScopes;
    std::vector<Symbol*> symbolStack; // non-owning snapshot stack

public:
    void setCurrentSymbol(Symbol& symbol) {
        this->currentSymbol = &symbol;
    }

    void setCurrentSymbol(Symbol* symbol) {
        this->currentSymbol = symbol;
    }

    Symbol* getCurrentSymbol() const {
        return currentSymbol;
    }

    void saveCurrentSymbol() {
        symbolStack.push_back(currentSymbol);
    }

    void popCurrentSymbol() {
        if (!symbolStack.empty()) {
            this->currentSymbol = symbolStack.back();
            symbolStack.pop_back();
        }
    }
};
