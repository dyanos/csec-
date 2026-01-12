#pragma once

#include "type.h"
#include "ast.h"

#include <string>
#include <llvm/IR/Type.h>
#include <llvm/IR/Value.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Function.h>

enum class SymbolType {
    NOSYMBOL,
    VARIABLE,
    FUNCTION,
    CLASS,
    NAMESPACE,
    TEMPLATE,
    STRUCT,
    UNION,
    FIELD,
    METHOD
};

struct Symbol {
    std::string name;
    std::unique_ptr<Type> type;
    llvm::Value* value;
    llvm::Function* function;
    bool isMutable;
    SymbolType symbolType;

	Symbol() : name(""), type(nullptr), value(nullptr), function(nullptr), isMutable(false), symbolType(SymbolType::NOSYMBOL) {}
    Symbol(const std::string& name, Type* type, llvm::Value* value, bool isMutable, SymbolType symbolType)
		: name(name), type(std::make_unique<Type>(type)), value(value), function(nullptr), isMutable(isMutable), symbolType(symbolType) {
	} 
    Symbol(const std::string& name, std::unique_ptr<Type> type, llvm::Value* value, bool isMutable, SymbolType symbolType)
        : name(name), type(std::move(type)), value(value), function(nullptr), isMutable(isMutable), symbolType(symbolType) {

    }
    Symbol(const Symbol* other) {
		copyFrom(*other);
    }
    Symbol(Symbol& other) {
		copyFrom(other);
    }
    virtual void copyFrom(const Symbol& other) {
		copyHelper(other);
	}

    virtual ~Symbol() {
    }

protected:
    void copyHelper(const Symbol& other) {
        this->name = other.name;
        this->type = std::make_unique<Type>(other.type.get());
        this->value = other.value;
        this->function = other.function;
        this->isMutable = other.isMutable;
        this->symbolType = other.symbolType;
    }
};

struct FunctionSymbol : public Symbol {
    llvm::Function* function;

    FunctionSymbol() : function(nullptr) {
        this->symbolType = SymbolType::FUNCTION;
    }

    FunctionSymbol(const std::string& name, Type* type, llvm::Value* value, bool isMutable, SymbolType symbolType)
        : function(function) {
        this->name = name;
        this->type = std::make_unique<Type>(type);
        this->value = nullptr;
        this->isMutable = isMutable;
        this->symbolType = SymbolType::FUNCTION;
    }

    FunctionSymbol(const FunctionSymbol* other) {
        copyFrom(*other);
    }

    FunctionSymbol(FunctionSymbol& other) noexcept {
        copyFrom(other);
	}

    void copyFrom(const Symbol& other) override {
        const FunctionSymbol& funcOther = static_cast<const FunctionSymbol&>(other);
        this->name = funcOther.name;
        this->type = std::make_unique<Type>(funcOther.type.get());
        this->value = nullptr;
        this->function = funcOther.function;
        this->isMutable = funcOther.isMutable;
        this->symbolType = SymbolType::FUNCTION;
        this->symbols.clear();
        for (auto* symbol : funcOther.symbols) {
			this->symbols.push_back(symbol); // 깊은 복사가 필요하면 여기를 수정
        }
	}

    ~FunctionSymbol() {
        for (auto* symbol: this->symbols) {
			if (symbol != nullptr)
                delete symbol;
		}
    }

    std::vector<Symbol*> symbols;   // 함수 안에서 사용된 변수 또는 관련 심볼들을 담고 있는 벡터
};

struct StructSymbol : public Symbol {
    std::string name;
    llvm::Type* structType;
    std::unordered_map<std::string, std::unique_ptr<Symbol>> fields;

    StructSymbol() : name(""), structType(nullptr) {
        this->symbolType = SymbolType::STRUCT;
    }

    StructSymbol(const std::string& name, llvm::Type* structType)
        : name(name), structType(structType) {
        this->symbolType = SymbolType::STRUCT;
    }

    StructSymbol(const StructSymbol* other) noexcept {
        copyFrom(*other);
    }

    StructSymbol(StructSymbol& other) noexcept {
		copyFrom(other);
	}

    void copyFrom(const Symbol& other) override {
        const StructSymbol& structOther = static_cast<const StructSymbol&>(other);
        this->name = structOther.name;
        this->structType = structOther.structType;
        this->isMutable = structOther.isMutable;
        this->symbolType = SymbolType::STRUCT;
        this->fields.clear();
        for (const auto& pair : structOther.fields) {
            this->fields[pair.first] = std::make_unique<Symbol>(pair.second.get());
		}
	}

    ~StructSymbol() {
	}

    Symbol* getField(const std::string& fieldName) {
        if (fields.find(fieldName) != fields.end()) {
            return this->fields[fieldName].get();
        }
        return nullptr;
    }
};

struct ClassSymbol : public Symbol {
    std::string name;
    llvm::Type* classType;
	std::unordered_map<std::string, std::unique_ptr<Symbol>> constructorParams;
    std::unordered_map<std::string, std::unique_ptr<Symbol>> fields;
    std::unordered_map<std::string, std::unique_ptr<Symbol>> methods;
    std::string superClassName;
    ClassSymbol* superClassSymbol;
	std::unordered_map<std::string, std::unique_ptr<ASTNode>> methodBodies;

    ClassSymbol() : name(""), superClassName(""), superClassSymbol(nullptr), classType(nullptr) {
        this->symbolType = SymbolType::CLASS;
    }
    ClassSymbol(const std::string& name, llvm::Type* classType, const std::string& superClassName)
        : name(name), classType(classType), superClassName(superClassName), superClassSymbol(nullptr) {
        this->symbolType = SymbolType::CLASS;
    }

    ClassSymbol(const Symbol* other) {
        copyHelper(*other);
	}
    ClassSymbol(const ClassSymbol* other) noexcept {
        copyHelper(*other);
    }

    ClassSymbol(ClassSymbol& other) noexcept {
        copyHelper(other);
	}

    void copyFrom(const Symbol& other) override {
        copyHelper(other);
	}

    ~ClassSymbol() {
    }

	Symbol* getField(const std::string& fieldName) {
		if (fields.find(fieldName) != fields.end()) {
            return this->fields[fieldName].get();
		}
		return nullptr;
	}

	Symbol* getMethod(const std::string& methodName) {
		if (methods.find(methodName) != methods.end()) {
            return this->methods[methodName].get();
		}
		return nullptr;
	}

protected:
    void copyHelper(const Symbol& other) {
        const ClassSymbol& classOther = static_cast<const ClassSymbol&>(other);
        this->name = classOther.name;
        this->classType = classOther.classType;
        this->isMutable = classOther.isMutable;
        this->symbolType = SymbolType::CLASS;
        this->superClassName = classOther.superClassName;
        this->superClassSymbol = classOther.superClassSymbol;
        this->constructorParams.clear();
        for (const auto& pair : classOther.constructorParams) {
            this->constructorParams[pair.first] = std::make_unique<Symbol>(pair.second.get());
        }
        this->fields.clear();
        for (const auto& pair : classOther.fields) {
            this->fields[pair.first] = std::make_unique<Symbol>(pair.second.get());
        }
        this->methods.clear();
        for (const auto& pair : classOther.methods) {
            this->methods[pair.first] = std::make_unique<Symbol>(pair.second.get());
        }
    }
};

struct NamespaceSymbol : public Symbol {
	std::string name;
	std::unordered_map<std::string, std::unique_ptr<Symbol>> variables;
	std::unordered_map<std::string, std::unique_ptr<ClassSymbol>> classes;
	std::unordered_map<std::string, std::unique_ptr<Symbol>> functions;
	std::unordered_map<std::string, std::unique_ptr<NamespaceSymbol>> namespaces;
	NamespaceSymbol() : name("") {
		this->symbolType = SymbolType::NAMESPACE;
    }
	NamespaceSymbol(const std::string& name) : name(name) {
        this->symbolType = SymbolType::NAMESPACE;
    }
    NamespaceSymbol(const NamespaceSymbol* other) noexcept {
        copyHelper(*other);
	}
    NamespaceSymbol(NamespaceSymbol& other) noexcept {
        copyHelper(other);
	}
    ~NamespaceSymbol() {
	}

    void copyFrom(const Symbol& other) override {
        copyHelper(other);
    }

protected:
    void copyHelper(const Symbol& other) {
        const NamespaceSymbol& nsOther = static_cast<const NamespaceSymbol&>(other);
        this->name = nsOther.name;
        this->isMutable = nsOther.isMutable;
        this->symbolType = SymbolType::NAMESPACE;
        this->variables.clear();
        for (const auto& pair : nsOther.variables) {
            this->variables[pair.first] = std::make_unique<Symbol>(*pair.second);
        }
        this->classes.clear();
        for (const auto& pair : nsOther.classes) {
            this->classes[pair.first] = std::make_unique<ClassSymbol>(*pair.second);
        }
        this->functions.clear();
        for (const auto& pair : nsOther.functions) {
            this->functions[pair.first] = std::make_unique<Symbol>(*pair.second);
        }
        this->namespaces.clear();
        for (const auto& pair : nsOther.namespaces) {
            this->namespaces[pair.first] = std::make_unique<NamespaceSymbol>(*pair.second);
        }
    }
};