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
    FIELD,
    METHOD
};

struct Symbol {
    std::string name;
    std::shared_ptr<Type> type;  // 타입을 std::string에서 llvm::Type*으로 변경
    llvm::Value* value;
    llvm::Function* function; // 'function' 멤버 추가
    bool isMutable;
    SymbolType symbolType;

	Symbol() : name(""), type(nullptr), value(nullptr), function(nullptr), isMutable(false), symbolType(SymbolType::NOSYMBOL) {}
    Symbol(const std::string& name, std::shared_ptr<Type> type, llvm::Value* value, bool isMutable, SymbolType symbolType)
        : name(name), type(type), value(value), function(nullptr), isMutable(isMutable), symbolType(symbolType) {} // 'function' 초기화
};

struct ClassSymbol {
    std::string name;
    llvm::Type* classType;
    std::unordered_map<std::string, Symbol> fields;
    std::unordered_map<std::string, Symbol> methods;
    std::string superClassName;
    ClassSymbol* superClassSymbol;

    ClassSymbol() : name(""), superClassName(""), superClassSymbol(nullptr), classType(nullptr), fields({}), methods({}) {}
    ClassSymbol(const std::string& name, llvm::Type* classType, const std::string& superClassName)
        : name(name), classType(classType), superClassName(superClassName), superClassSymbol(nullptr) {}

	std::shared_ptr<Symbol> getField(const std::string& fieldName) {
		if (fields.find(fieldName) != fields.end()) {
			return std::make_shared<Symbol>(fields[fieldName]);
		}
		return nullptr;
	}

	std::shared_ptr<Symbol> getMethod(const std::string& methodName) {
		if (methods.find(methodName) != methods.end()) {
			return std::make_shared<Symbol>(methods[methodName]);
		}
		return nullptr;
	}
};
