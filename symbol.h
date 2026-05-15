#pragma once

#include "type.h"
#include "ast.h"
#include "TemplateDeclarationNode.h"

#include <memory>
#include <string>
#include <unordered_map>
#include <vector>

#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/Type.h>
#include <llvm/IR/Value.h>

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

    Symbol(const std::string& name, std::unique_ptr<Type> type, llvm::Value* value, bool isMutable, SymbolType symbolType)
        : name(name), type(std::move(type)), value(value), function(nullptr), isMutable(isMutable), symbolType(symbolType) {}

    Symbol(const Symbol& other) {
        copyFrom(other);
    }

    Symbol& operator=(const Symbol& other) {
        if (this != &other) {
            copyFrom(other);
        }
        return *this;
    }

    Symbol(Symbol&&) noexcept = default;
    Symbol& operator=(Symbol&&) noexcept = default;

    virtual void copyFrom(const Symbol& other) {
        copyHelper(other);
    }

    virtual std::unique_ptr<Symbol> clone() const {
        return std::make_unique<Symbol>(*this);
    }

    virtual ~Symbol() = default;

protected:
    void copyHelper(const Symbol& other) {
        this->name = other.name;
        this->type = other.type ? other.type->clone() : nullptr;
        this->value = other.value;
        this->function = other.function;
        this->isMutable = other.isMutable;
        this->symbolType = other.symbolType;
    }
};

struct FunctionSymbol : public Symbol {
    FunctionSymbol() {
        this->function = nullptr;
        this->symbolType = SymbolType::FUNCTION;
    }

    FunctionSymbol(const std::string& name, std::unique_ptr<Type> type, llvm::Value* value, bool isMutable, SymbolType symbolType)
        : Symbol(name, std::move(type), value, isMutable, SymbolType::FUNCTION) {
        this->function = static_cast<llvm::Function*>(value);
        this->name = name;
    }

    FunctionSymbol(const FunctionSymbol& other) {
        copyFrom(other);
    }

    FunctionSymbol& operator=(const FunctionSymbol& other) {
        if (this != &other) {
            copyFrom(other);
        }
        return *this;
    }

    FunctionSymbol(FunctionSymbol&&) noexcept = default;
    FunctionSymbol& operator=(FunctionSymbol&&) noexcept = default;

    void copyFrom(const Symbol& other) override {
        const auto* funcOtherPtr = dynamic_cast<const FunctionSymbol*>(&other);
        if (!funcOtherPtr) { Symbol::copyFrom(other); return; }
        const FunctionSymbol& funcOther = *funcOtherPtr;
        this->name = funcOther.name;
        this->type = funcOther.type ? funcOther.type->clone() : nullptr;
        this->value = funcOther.value;
        this->function = funcOther.function;
        this->isMutable = funcOther.isMutable;
        this->symbolType = SymbolType::FUNCTION;
    }

    std::unique_ptr<Symbol> clone() const override {
        return std::make_unique<FunctionSymbol>(*this);
    }

    ~FunctionSymbol() override = default;
};

struct StructSymbol : public Symbol {
    llvm::Type* structType;
    std::unordered_map<std::string, std::unique_ptr<Symbol>> fields;

    StructSymbol() : structType(nullptr) {
        this->symbolType = SymbolType::STRUCT;
    }

    StructSymbol(const std::string& name, llvm::Type* structType)
        : structType(structType) {
        Symbol::name = name;
        this->symbolType = SymbolType::STRUCT;
    }

    StructSymbol(const StructSymbol& other) {
        copyFrom(other);
    }

    StructSymbol& operator=(const StructSymbol& other) {
        if (this != &other) {
            copyFrom(other);
        }
        return *this;
    }

    StructSymbol(StructSymbol&&) noexcept = default;
    StructSymbol& operator=(StructSymbol&&) noexcept = default;

    void copyFrom(const Symbol& other) override {
        const auto* structOtherPtr = dynamic_cast<const StructSymbol*>(&other);
        if (!structOtherPtr) { Symbol::copyFrom(other); return; }
        const StructSymbol& structOther = *structOtherPtr;
        this->name = structOther.name;
        this->structType = structOther.structType;
        this->isMutable = structOther.isMutable;
        this->symbolType = SymbolType::STRUCT;
        this->fields.clear();
        for (const auto& pair : structOther.fields) {
            this->fields[pair.first] = pair.second ? pair.second->clone() : nullptr;
        }
    }

    std::unique_ptr<Symbol> clone() const override {
        return std::make_unique<StructSymbol>(*this);
    }

    ~StructSymbol() override = default;

    Symbol* getField(const std::string& fieldName) {
        if (fields.find(fieldName) != fields.end()) {
            return this->fields[fieldName].get();
        }
        return nullptr;
    }
};

struct ClassSymbol : public Symbol {
    llvm::Type* classType;
    std::unordered_map<std::string, std::unique_ptr<Symbol>> constructorParams;
    std::unordered_map<std::string, std::unique_ptr<Symbol>> fields;
    std::unordered_map<std::string, std::unique_ptr<Symbol>> methods;
    std::string superClassName;
    const ClassSymbol* superClassSymbol;
    std::unordered_map<std::string, std::unique_ptr<ASTNode>> methodBodies;

    ClassSymbol() : superClassName(""), superClassSymbol(nullptr), classType(nullptr) {
        this->symbolType = SymbolType::CLASS;
    }

    ClassSymbol(const std::string& name, llvm::Type* classType, const std::string& superClassName)
        : classType(classType), superClassName(superClassName), superClassSymbol(nullptr) {
        Symbol::name = name;
        this->symbolType = SymbolType::CLASS;
    }

    ClassSymbol(const ClassSymbol& other) {
        copyHelper(other);
    }

    ClassSymbol& operator=(const ClassSymbol& other) {
        if (this != &other) {
            copyHelper(other);
        }
        return *this;
    }

    ClassSymbol(ClassSymbol&&) = default;
    ClassSymbol& operator=(ClassSymbol&&) noexcept = default;

    void copyFrom(const Symbol& other) override {
        copyHelper(other);
    }

    std::unique_ptr<Symbol> clone() const override {
        return std::make_unique<ClassSymbol>(*this);
    }

    ~ClassSymbol() override = default;

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
        const auto* classOtherPtr = dynamic_cast<const ClassSymbol*>(&other);
        if (!classOtherPtr) { Symbol::copyHelper(other); return; }
        const ClassSymbol& classOther = *classOtherPtr;
        Symbol::copyHelper(classOther);
        this->classType = classOther.classType;
        this->symbolType = SymbolType::CLASS;
        this->superClassName = classOther.superClassName;
        this->superClassSymbol = classOther.superClassSymbol;
        this->constructorParams.clear();
        for (const auto& pair : classOther.constructorParams) {
            this->constructorParams[pair.first] = pair.second ? pair.second->clone() : nullptr;
        }
        this->fields.clear();
        for (const auto& pair : classOther.fields) {
            this->fields[pair.first] = pair.second ? pair.second->clone() : nullptr;
        }
        this->methods.clear();
        for (const auto& pair : classOther.methods) {
            this->methods[pair.first] = pair.second ? pair.second->clone() : nullptr;
        }
    }
};

struct TemplateSymbol : public Symbol {
    std::vector<std::string> typeParameters;       // backward compat - just names
    std::vector<TemplateParam> templateParams;     // full param info including non-type
    std::unique_ptr<ASTNode> declaration;  // stored AST for instantiation
    std::unordered_map<std::string, llvm::Function*> instantiations;  // func template cache
    std::unordered_map<std::string, ClassSymbol*> classInstantiations;  // class template cache

    TemplateSymbol() {
        this->symbolType = SymbolType::TEMPLATE;
    }

    TemplateSymbol(const TemplateSymbol& other) {
        copyFrom(other);
    }

    TemplateSymbol& operator=(const TemplateSymbol& other) {
        if (this != &other) {
            copyFrom(other);
        }
        return *this;
    }

    TemplateSymbol(TemplateSymbol&&) noexcept = default;
    TemplateSymbol& operator=(TemplateSymbol&&) noexcept = default;

    void copyFrom(const Symbol& other) override {
        const auto* tmplOtherPtr = dynamic_cast<const TemplateSymbol*>(&other);
        if (!tmplOtherPtr) { Symbol::copyFrom(other); return; }
        const TemplateSymbol& tmplOther = *tmplOtherPtr;
        Symbol::copyHelper(tmplOther);
        this->symbolType = SymbolType::TEMPLATE;
        this->typeParameters = tmplOther.typeParameters;
        this->templateParams.clear();
        for (auto& p : tmplOther.templateParams) this->templateParams.push_back(TemplateParam(p));
        this->declaration = tmplOther.declaration ? tmplOther.declaration->clone() : nullptr;
        this->instantiations = tmplOther.instantiations;
        this->classInstantiations = tmplOther.classInstantiations;
    }

    std::unique_ptr<Symbol> clone() const override {
        return std::make_unique<TemplateSymbol>(*this);
    }

    ~TemplateSymbol() override = default;
};

struct NamespaceSymbol : public Symbol {
    std::unordered_map<std::string, std::unique_ptr<Symbol>> variables;
    std::unordered_map<std::string, std::unique_ptr<ClassSymbol>> classes;
    std::unordered_map<std::string, std::unique_ptr<Symbol>> functions;
    std::unordered_map<std::string, std::unique_ptr<NamespaceSymbol>> namespaces;

    NamespaceSymbol() {
        this->symbolType = SymbolType::NAMESPACE;
    }

    NamespaceSymbol(const std::string& name) {
        Symbol::name = name;
        this->symbolType = SymbolType::NAMESPACE;
    }

    NamespaceSymbol(const NamespaceSymbol& other) {
        copyHelper(other);
    }

    NamespaceSymbol& operator=(const NamespaceSymbol& other) {
        if (this != &other) {
            copyHelper(other);
        }
        return *this;
    }

    NamespaceSymbol(NamespaceSymbol&&) = default;
    NamespaceSymbol& operator=(NamespaceSymbol&&) noexcept = default;

    ~NamespaceSymbol() override = default;

    void copyFrom(const Symbol& other) override {
        copyHelper(other);
    }

    std::unique_ptr<Symbol> clone() const override {
        return std::make_unique<NamespaceSymbol>(*this);
    }

protected:
    void copyHelper(const Symbol& other) {
        const auto* nsOtherPtr = dynamic_cast<const NamespaceSymbol*>(&other);
        if (!nsOtherPtr) { Symbol::copyHelper(other); return; }
        const NamespaceSymbol& nsOther = *nsOtherPtr;
        this->name = nsOther.name;
        this->isMutable = nsOther.isMutable;
        this->symbolType = SymbolType::NAMESPACE;
        this->variables.clear();
        for (const auto& pair : nsOther.variables) {
            this->variables[pair.first] = pair.second ? pair.second->clone() : nullptr;
        }
        this->classes.clear();
        for (const auto& pair : nsOther.classes) {
            this->classes[pair.first] = std::make_unique<ClassSymbol>(*pair.second);
        }
        this->functions.clear();
        for (const auto& pair : nsOther.functions) {
            this->functions[pair.first] = pair.second ? pair.second->clone() : nullptr;
        }
        this->namespaces.clear();
        for (const auto& pair : nsOther.namespaces) {
            this->namespaces[pair.first] = std::make_unique<NamespaceSymbol>(*pair.second);
        }
    }
};
