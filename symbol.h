#pragma once

#include "type.h"

#include <string>
#include <llvm/IR/Type.h>
#include <llvm/IR/Value.h>
#include <llvm/IR/DerivedTypes.h>

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

class FunctionDeclarationNode;

struct Symbol {
    std::string name;
    std::shared_ptr<Type> type;  // Ÿ���� std::string���� llvm::Type*���� ����
    llvm::Value* value;
    llvm::Function* function; // 'function' ��� �߰�
    bool isMutable;
    SymbolType symbolType;

	Symbol() : name(""), type(nullptr), value(nullptr), function(nullptr), isMutable(false), symbolType(SymbolType::NOSYMBOL) {}
    Symbol(const std::string& name, std::shared_ptr<Type> type, llvm::Value* value, bool isMutable, SymbolType symbolType)
        : name(name), type(type), value(value), function(nullptr), isMutable(isMutable), symbolType(symbolType) {} // 'function' �ʱ�ȭ
    virtual ~Symbol() = default;
};

struct FunctionSymbol : public Symbol {
    llvm::Function* function;
    FunctionSymbol() : function(nullptr) {
        this->symbolType = SymbolType::FUNCTION;
    }
    FunctionSymbol(const std::string& name, std::shared_ptr<Type> type, llvm::Value* value, bool isMutable, SymbolType symbolType)
        : function(function) {
        this->name = name;
        this->type = type;
        this->value = nullptr;
        this->isMutable = isMutable;
        this->symbolType = SymbolType::FUNCTION;
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
    std::unordered_map<std::string, Symbol*> fields;
    StructSymbol() : name(""), structType(nullptr), fields({}) {
        this->symbolType = SymbolType::STRUCT;
    }
    StructSymbol(const std::string& name, llvm::Type* structType)
        : name(name), structType(structType) {
        this->symbolType = SymbolType::STRUCT;
    }
    Symbol* getField(const std::string& fieldName) {
        if (fields.find(fieldName) != fields.end()) {
            return this->fields[fieldName];
        }
        return nullptr;
    }
};

struct ClassSymbol : public Symbol {
    std::string name;
    llvm::Type* classType;
	std::unordered_map<std::string, Symbol*> constructorParams;
    std::unordered_map<std::string, Symbol*> fields;
    std::unordered_map<std::string, Symbol*> methods;
    std::string superClassName;
    ClassSymbol* superClassSymbol;
	std::unordered_map<std::string, FunctionDeclarationNode*> methodBodies;

    ClassSymbol() : name(""), superClassName(""), superClassSymbol(nullptr), classType(nullptr), fields({}), methods({}) {
        this->symbolType = SymbolType::CLASS;
    }
    ClassSymbol(const std::string& name, llvm::Type* classType, const std::string& superClassName)
        : name(name), classType(classType), superClassName(superClassName), superClassSymbol(nullptr) {
        this->symbolType = SymbolType::CLASS;
    }

    ~ClassSymbol() {
        for (auto& pair : methodBodies) {
            delete pair.second;
		}
    }

	Symbol* getField(const std::string& fieldName) {
		if (fields.find(fieldName) != fields.end()) {
			return this->fields[fieldName];
		}
		return nullptr;
	}

	Symbol* getMethod(const std::string& methodName) {
		if (methods.find(methodName) != methods.end()) {
			return this->methods[methodName];
		}
		return nullptr;
	}
};

struct NamespaceSymbol : public Symbol {
	std::string name;
	std::unordered_map<std::string, Symbol*> variables;
	std::unordered_map<std::string, ClassSymbol*> classes;
	std::unordered_map<std::string, Symbol*> functions;
	std::unordered_map<std::string, NamespaceSymbol*> namespaces;
	NamespaceSymbol() : name("") {
		this->symbolType = SymbolType::NAMESPACE;
		this->classes = {};
		this->variables = {};
		this->functions = {};
    }
	NamespaceSymbol(const std::string& name) : name(name) {
        this->symbolType = SymbolType::NAMESPACE;
        this->classes = {};
        this->variables = {};
        this->functions = {};
    }
};