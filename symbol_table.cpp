// symbol_table.cpp

#include "symbol_table.h"
#include "ast.h"
#include "type_utils.h"
#include "utils.h"

#include "context.h"

#include <functional>
#include <iostream>
#include <memory>

namespace {
std::string makeUniqueKey(const std::unordered_map<std::string, std::unique_ptr<Symbol>>& table, const std::string& base) {
    if (table.count(base) == 0) {
        return base;
    }

    int suffix = 1;
    std::string candidate;
    do {
        candidate = base + "#" + std::to_string(suffix++);
    } while (table.count(candidate) != 0);
    return candidate;
}

bool matchesFunctionArguments(const Symbol* symbol, const std::string& name, const std::vector<std::unique_ptr<Type>>& argTypes) {
    if (!symbol || symbol->symbolType != SymbolType::FUNCTION || symbol->name != name) {
        return false;
    }

    auto* funcType = dynamic_cast<FunctionType*>(symbol->type.get());
    if (!funcType) {
        return false;
    }

    if (funcType->parameterTypes.size() != argTypes.size()) {
        return false;
    }

    for (size_t i = 0; i < argTypes.size(); ++i) {
        if (!argTypes[i] || !funcType->parameterTypes[i]) {
            return false;
        }
        if (!argTypes[i]->equals(funcType->parameterTypes[i])) {
            return false;
        }
    }
    return true;
}
}


SymbolTable::SymbolTable() {
    //enterScope();
    auto rootScope = std::make_unique<Scope>();
    rootScope->outer = nullptr;
    rootScope->count = 0;
    this->currentScope = rootScope.get();
    this->ownedScopes.push_back(std::move(rootScope));
    this->currentScopeLevel = 1;
}

void SymbolTable::initializeBuiltInTypes(llvm::LLVMContext& context) {
    //auto& ctxt = Context::getInstance();

    auto anyType = std::make_unique<ClassType>("Any");

    //addTypeSymbol("Any", anyType);
    this->currentScope->symbols["Any"] = std::make_unique<ClassSymbol>("Any", llvm::Type::getInt32Ty(context), "System.lang.Object");
    //(static_cast<NamespaceSymbol*>(&root))->classes["Any"] = ClassSymbol("Any", llvm::Type::getInt32Ty(context), "System.lang.Object");

    //auto anyValType = std::make_shared<ClassType>("AnyVal", anyType);
    //addTypeSymbol("AnyVal", anyValType);
    this->currentScope->symbols["AnyVal"] = std::make_unique<ClassSymbol>("AnyVal", llvm::Type::getInt32Ty(context), "System.lang.Object");

    //addTypeSymbol("Int", std::make_shared<BasicType>("Int", anyValType));
    //addTypeSymbol("Float", std::make_shared<BasicType>("Float", anyValType));
    //addTypeSymbol("Double", std::make_shared<BasicType>("Double", anyValType));
    //addTypeSymbol("Char", std::make_shared<BasicType>("Char", anyValType));
    //addTypeSymbol("Boolean", std::make_shared<BasicType>("Boolean", anyValType));
	this->currentScope->symbols["Short"] = std::make_unique<ClassSymbol>("Short", llvm::Type::getInt16Ty(context), "System.lang.Object");
    this->currentScope->symbols["Int"] = std::make_unique<ClassSymbol>("Int", llvm::Type::getInt32Ty(context), "System.lang.Object");
	this->currentScope->symbols["Long"] = std::make_unique<ClassSymbol>("Long", llvm::Type::getInt64Ty(context), "System.lang.Object");
    this->currentScope->symbols["Float"] = std::make_unique<ClassSymbol>("Float", llvm::Type::getFloatTy(context), "System.lang.Object");
    this->currentScope->symbols["Double"] = std::make_unique<ClassSymbol>("Double", llvm::Type::getDoubleTy(context), "System.lang.Object");
    this->currentScope->symbols["Char"] = std::make_unique<ClassSymbol>("Char", llvm::Type::getInt32Ty(context), "System.lang.Object");
    this->currentScope->symbols["Boolean"] = std::make_unique<ClassSymbol>("Boolean", llvm::Type::getInt32Ty(context), "System.lang.Object");

    auto anyRefType = std::make_unique<ClassType>("AnyRef");
    //addTypeSymbol("AnyRef", anyRefType);
    this->currentScope->symbols["AnyRef"] = std::make_unique<ClassSymbol>("AnyRef", llvm::Type::getInt32Ty(context), "System.lang.Object");

    //addTypeSymbol("String", std::make_shared<ClassType>("String", anyRefType));
    this->currentScope->symbols["String"] = std::make_unique<ClassSymbol>("String", llvm::Type::getInt32Ty(context), "System.lang.Object");

    //addTypeSymbol("Unit", std::make_shared<BasicType>("Unit", anyValType));
    this->currentScope->symbols["Unit"] = std::make_unique<ClassSymbol>("Unit", llvm::Type::getInt32Ty(context), "System.lang.Object");
	this->currentScope->symbols["Void"] = std::make_unique<ClassSymbol>("Void", llvm::Type::getVoidTy(context), "System.lang.Object");

    //auto& intClassSymbol = classSymbols["Int"];

    std::vector<std::unique_ptr<Type>> emptyParams;
    std::unique_ptr<Type> rightCopy = std::make_unique<BasicType>(std::string("String"));
    (static_cast<ClassSymbol*>(this->currentScope->symbols["String"].get()))->methods["toString"] = std::make_unique<Symbol>(
        std::string("toString"),
        std::make_unique<FunctionType>(emptyParams, rightCopy),
        nullptr,
        false,
        SymbolType::METHOD);
}

SymbolTable::~SymbolTable() {
    for (int i = 0; i < this->currentScopeLevel; ++i) {
        exitScope();
	}

    this->currentScope = nullptr;
}

bool SymbolTable::addSymbol(const std::string& name, std::unique_ptr<Symbol> symbol) {
    if (!symbol || !this->currentScope) {
        return false;
    }

    Symbol* rawSymbol = symbol.get();
    auto& ctxt = Context::getInstance();
    auto current = ctxt.getCurrentNamespace();

    if (this->currentSymbol == nullptr) {
        std::string key = name;
        if (rawSymbol->symbolType == SymbolType::FUNCTION || rawSymbol->symbolType == SymbolType::METHOD) {
            key = makeUniqueKey(this->currentScope->symbols, name);
        }
        else if (this->currentScope->symbols.count(name) != 0) {
            return false;
        }

		this->currentScope->symbols[key] = std::move(symbol);
        this->currentSymbol = this->currentScope->symbols[key].get();
		return true;
    }

    switch (this->currentSymbol->symbolType) {
    case SymbolType::NAMESPACE:
        {
            auto* target = dynamic_cast<NamespaceSymbol*>(this->currentSymbol);
            if (!target) {
                std::cerr << "Error: Current symbol is not a namespace" << std::endl;
                return false;
            }

            switch (rawSymbol->symbolType) {
            case SymbolType::VARIABLE:
            case SymbolType::FIELD:
                if (target->variables.count(name) != 0)
                    return false;

                target->variables[name] = rawSymbol->clone();
                this->currentScope->symbols[name] = std::move(symbol);
                break;

            case SymbolType::FUNCTION:
            case SymbolType::METHOD:
            {
                auto functionKey = makeUniqueKey(target->functions, name);
                auto scopeKey = makeUniqueKey(this->currentScope->symbols, name);
                target->functions[functionKey] = rawSymbol->clone();
                this->currentScope->symbols[scopeKey] = std::move(symbol);
                break;
            }

            case SymbolType::CLASS:
            {
                if (target->classes.count(name) != 0)
                    return false;

                auto* classRaw = dynamic_cast<ClassSymbol*>(rawSymbol);
                if (!classRaw) {
                    std::cerr << "Error: Symbol marked as CLASS is not a ClassSymbol" << std::endl;
                    return false;
                }
                target->classes[name] = std::make_unique<ClassSymbol>(*classRaw);
                this->currentScope->symbols[name] = std::move(symbol);
                break;
            }

            case SymbolType::NAMESPACE:
            {
                if (target->namespaces.count(name) != 0)
                    return false;

                auto* nsRaw = dynamic_cast<NamespaceSymbol*>(rawSymbol);
                if (!nsRaw) {
                    std::cerr << "Error: Symbol marked as NAMESPACE is not a NamespaceSymbol" << std::endl;
                    return false;
                }
                target->namespaces[name] = std::make_unique<NamespaceSymbol>(*nsRaw);
                this->currentScope->symbols[name] = std::move(symbol);
                break;
            }

            default:
                std::cerr << "Unsupported symbol type for namespace: " << (int)rawSymbol->symbolType << std::endl;
                break;
            }
        }

        break;

    case SymbolType::CLASS:
        {
            auto* target = dynamic_cast<ClassSymbol*>(this->currentSymbol);
            if (!target) {
                std::cerr << "Error: Current symbol is not a class" << std::endl;
                return false;
            }

            switch (rawSymbol->symbolType) {
            case SymbolType::VARIABLE:
            case SymbolType::FIELD:
                if (target->fields.count(name) != 0)
                    return false;

                target->fields[name] = rawSymbol->clone();
                this->currentScope->symbols[name] = std::move(symbol);
                break;

            case SymbolType::FUNCTION:
            case SymbolType::METHOD:
            {
                auto methodKey = makeUniqueKey(target->methods, name);
                auto scopeKey = makeUniqueKey(this->currentScope->symbols, name);
                target->methods[methodKey] = rawSymbol->clone();
                this->currentScope->symbols[scopeKey] = std::move(symbol);
                break;
            }

            default:
                std::cerr << "Unsupported symbol type for class: " << (int)rawSymbol->symbolType << std::endl;
                break;
            }
        }
        break;

    case SymbolType::FUNCTION:
        {
            switch (rawSymbol->symbolType) {
            case SymbolType::VARIABLE:
            case SymbolType::FIELD:
				this->currentScope->symbols[name] = std::move(symbol);
                break;
            case SymbolType::FUNCTION:
				this->currentScope->symbols[name] = std::move(symbol);
                break;
            default:
                std::cerr << "Unsupported symbol type for function: " << (int)rawSymbol->symbolType << std::endl;
                break;
            }
        }
		break;

    default:
        std::cerr << "Unsupported current symbol type: " << (int)current->symbolType << std::endl;
        break;
    }

    return true;
}

Symbol* checkSymbol(Symbol* symbol, const std::string& name) {
    switch (symbol->symbolType) {
    case SymbolType::NAMESPACE:
    {
        auto* target = dynamic_cast<NamespaceSymbol*>(symbol);
        if (!target) return nullptr;

        if (target->namespaces.count(name) != 0) {
            return target->namespaces[name].get();
        }

        if (target->classes.count(name) != 0) {
            return target->classes[name].get();
        }

        if (target->functions.count(name) != 0) {
            return target->functions[name].get();
        }

        if (target->variables.count(name) != 0) {
            return target->variables[name].get();
        }

        return nullptr;
    }
    break;

    case SymbolType::CLASS:
    {
        auto* target = dynamic_cast<ClassSymbol*>(symbol);
        if (!target) return nullptr;

        if (target->methods.count(name) != 0) {
            return target->methods[name].get();
        }
        if (target->fields.count(name) != 0) {
            return target->fields[name].get();
        }
        return nullptr;
    }
    break;

    default:
        std::cerr << "Unsupported symbol type for lookup: " << (int)symbol->symbolType << std::endl;
        break;
    }

    return nullptr;
}

Symbol* SymbolTable::lookup(const std::string& name) {
    // TODO : name?? path(A.B.C)?? ??? o?? ???
    auto& ctxt = Context::getInstance();
	//auto root = ctxt.getRootNamespace();

	auto names = split(name, '.');

	// ???? ?????????? ??????? ???? ???????? ?o??? ???
	Scope* curScope = this->currentScope;
    while (curScope != nullptr) {
        for (auto& pair : curScope->symbols) {
            if (pair.first != name) {
                continue;
            }

            return pair.second.get();
        }

        curScope = curScope->outer;
    }
    /*        switch (pair.second->symbolType) {
            case SymbolType::NAMESPACE:
                root = static_cast<NamespaceSymbol*>(pair.second);

                for (auto& function : root->functions) {
                    if (function.first == name) {
                        return function.second;
                    }
                }

                for (auto& variable : root->variables) {
                    if (variable.first == name) {
                        return variable.second;
                    }
                }

                for (auto& classSymbol : root->classes) {
                    if (classSymbol.first == name) {
                        return classSymbol.second;
                    }
                }

                for (auto& namespaceSymbol : root->namespaces) {
                    if (namespaceSymbol.first == name) {
                        return namespaceSymbol.second;
                    }
                }

                break;

            case SymbolType::CLASS:
            {
                auto classSymbol = static_cast<ClassSymbol*>(pair.second);
                for (auto& method : classSymbol->methods) {
                    if (method.first == name) {
                        return method.second;
                    }
                }
                for (auto& field : classSymbol->fields) {
                    if (field.first == name) {
                        return field.second;
                    }
                }
            }
            break;

            case SymbolType::FUNCTION:
            {
                auto functionSymbol = static_cast<FunctionSymbol*>(pair.second);
                for (auto& symbol : functionSymbol->symbols) {
                    if (symbol->name == name) {
                        return symbol;
                    }
                }
            }
            break;

            case SymbolType::METHOD:
            {
                auto methodSymbol = static_cast<FunctionSymbol*>(pair.second);
                for (auto& symbol : methodSymbol->symbols) {
                    if (symbol->name == name) {
                        return symbol;
                    }
                }
            }
            break;

            default:
                printf("Unsupported current symbol type for lookup: %d\n", (int)this->currentSymbol->symbolType);
                break;
            }
        }
        curScope = curScope->outer;
    }*/

    return nullptr;
}

ClassSymbol* SymbolTable::lookupClass(const std::string& name) {
	auto symbol = lookup(name);
    if (symbol && symbol->symbolType == SymbolType::CLASS) {
        return static_cast<ClassSymbol*>(symbol);
	}
	return nullptr;
}

StructSymbol* SymbolTable::lookupStruct(const std::string& name) {
    auto symbol = lookup(name);
    if (symbol && symbol->symbolType == SymbolType::STRUCT) {
        return static_cast<StructSymbol*>(symbol);
    }
    return nullptr;
}

NamespaceSymbol* SymbolTable::lookupNamespace(const std::string& name) {
    auto symbol = lookup(name);
    if (symbol && symbol->symbolType == SymbolType::NAMESPACE) {
        return static_cast<NamespaceSymbol*>(symbol);
    }
    return nullptr;
}

FunctionSymbol* SymbolTable::lookupFunction(const std::string& name, const std::vector<std::unique_ptr<Type>>& argTypes) {
    Scope* curScope = this->currentScope;
    while (curScope != nullptr) {
        for (const auto& pair : curScope->symbols) {
            Symbol* candidate = pair.second.get();
            if (!matchesFunctionArguments(candidate, name, argTypes)) {
                continue;
            }

            auto* functionSymbol = dynamic_cast<FunctionSymbol*>(candidate);
            if (functionSymbol) {
                return functionSymbol;
            }
        }
        curScope = curScope->outer;
    }

    auto symbol = lookup(name);
    if (symbol && symbol->symbolType == SymbolType::FUNCTION) {
        return dynamic_cast<FunctionSymbol*>(symbol);
    }

    return nullptr;
}

Symbol* SymbolTable::lookupMethod(const ClassSymbol& symbol, const std::string& methodName)
{
    const ClassSymbol* current = &symbol;
    while (current) {
        auto methodIt = current->methods.find(methodName);
        if (methodIt != current->methods.end()) {
            return methodIt->second.get();
        }
        current = current->superClassSymbol;
    }
    return nullptr;
}

void SymbolTable::merge(const SymbolTable& other) {
    return;
}

void SymbolTable::enterScope() {
    auto newScope = std::make_unique<Scope>();
    newScope->outer = this->currentScope;
    this->currentScope = newScope.get();
    this->ownedScopes.push_back(std::move(newScope));
    this->currentScopeLevel += 1;
}

void SymbolTable::exitScope() {
	if (this->currentScope == nullptr) {
        return;
    }
    this->currentScope = this->currentScope->outer;
    this->currentScopeLevel -= 1;
}

void SymbolTable::print(std::ostream& os, int indent) const {
    auto& ctxt = Context::getInstance();
    auto root = ctxt.getRootNamespace();
    std::function<void(const NamespaceSymbol*, int)> printNamespace;
    printNamespace = [&](const NamespaceSymbol* ns, int level) {
        std::string indentStr(level * 2, ' ');
        os << indentStr << "Namespace: " << ns->name << "\n";
        for (const auto& varPair : ns->variables) {
            os << indentStr << "  Variable: " << varPair.first << "\n";
        }
        for (const auto& funcPair : ns->functions) {
            os << indentStr << "  Function: " << funcPair.first << "\n";
        }
        for (const auto& classPair : ns->classes) {
            os << indentStr << "  Class: " << classPair.first << "\n";
            auto* classSym = classPair.second.get();
            for (const auto& fieldPair : classSym->fields) {
                os << indentStr << "    Field: " << fieldPair.first << "\n";
            }
            for (const auto& methodPair : classSym->methods) {
                os << indentStr << "    Method: " << methodPair.first << "\n";
            }
        }
        for (const auto& nsPair : ns->namespaces) {
            printNamespace(nsPair.second.get(), level + 1);
        }
    };
    printNamespace(root, indent);
}


