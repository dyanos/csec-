// symbol_table.cpp

#include "symbol_table.h"
#include "ast.h"
#include "type_utils.h"
#include "utils.h"

#include "context.h"

#include <optional>
#include <functional>
#include <memory> // shared_ptr 사용을 위해 추가

// SymbolTable 구현
// scope에 따른 다단계 네임스페이스 지원 필요
// 1단계: 전역 심볼 테이블
// 2~n단계: namespace, class, 함수 내부 등
// namespace는 중첩이 가능
// class는 현재로써는 중첩 불가
// 함수 내부는 지역 변수만 관리
// 심볼 검색 시에는 현재 스코프부터 시작하여 상위 스코프로 올라가며 검색
// 심볼 추가 시에는 현재 스코프에만 추가
// 심볼 충돌 시 에러 처리 필요
// 심볼 삭제 시에는 현재 스코프에서만 삭제
// 심볼 테이블 병합 시에는 충돌 처리 필요
// 심볼 테이블 복사 시에는 깊은 복사 필요
// 심볼 테이블 출력 시에는 계층 구조로 출력
// 심볼 테이블 초기화 시에는 기본 타입 및 내장 심볼 추가
// 심볼 테이블 정리 시에는 메모리 해제 및 리소스 정리
// 심볼 테이블 디버깅 시에는 심볼 검색 경로 출력
// 심볼 테이블 최적화 시에는 검색 속도 향상 기법 적용
// 심볼 테이블 확장 시에는 새로운 심볼 타입 및 속성 추가 지원
// 심볼 테이블 동기화 시에는 멀티스레드 환경에서의 안전성 보장

SymbolTable::SymbolTable() {
    // 전역 범위 생성
	// Context::getInstance에 기본적으로 root가 생성되어 있음
    //enterScope();
    // root는 맨 처음 scope
    this->currentScope = new Scope();
    this->currentScope->outer = nullptr;
    this->currentScope->count = 0;
    this->currentScopeLevel = 1;
}

SymbolTable::SymbolTable(const SymbolTable& other) {
	// 복사 생성자
	// other을 그대로 복사하면 메모리 문제가 발생하므로, 참조 형식으로 가져올 수 있을까? 그런데 그러면 원본은 어떻게 하지?
    // properties를 그대로 복사합니다.
	printf("Called SymbolTable copy constructor\n");
}

void SymbolTable::initializeBuiltInTypes(llvm::LLVMContext& context) {
    auto& ctxt = Context::getInstance();

    // 최상위 타입 Any
    auto anyType = std::make_unique<ClassType>("Any");

    //addTypeSymbol("Any", anyType);
	// root -> namespace symbol이므로 강제 캐스팅
    this->currentScope->symbols["Any"] = std::make_unique<ClassSymbol>("Any", llvm::Type::getInt32Ty(context), "System.lang.Object");
    //((NamespaceSymbol*)&root)->classes["Any"] = ClassSymbol("Any", llvm::Type::getInt32Ty(context), "System.lang.Object");

    // 값 타입 AnyVal
    //auto anyValType = std::make_shared<ClassType>("AnyVal", anyType);
    //addTypeSymbol("AnyVal", anyValType);
    this->currentScope->symbols["AnyVal"] = std::make_unique<ClassSymbol>("AnyVal", llvm::Type::getInt32Ty(context), "System.lang.Object");

    // 기본 타입 등록
    //addTypeSymbol("Int", std::make_shared<BasicType>("Int", anyValType));
    //addTypeSymbol("Float", std::make_shared<BasicType>("Float", anyValType));
    //addTypeSymbol("Double", std::make_shared<BasicType>("Double", anyValType));
    //addTypeSymbol("Char", std::make_shared<BasicType>("Char", anyValType));
    //addTypeSymbol("Boolean", std::make_shared<BasicType>("Boolean", anyValType));
	this->currentScope->symbols["Short"] = std::make_unique<ClassSymbol>("Short", llvm::Type::getInt16Ty(context), "System.lang.Object");
    this->currentScope->symbols["Int"] = std::make_unique<ClassSymbol>("Int", llvm::Type::getInt32Ty(context), "System.lang.Object");
	this->currentScope->symbols["Long"] = std::make_unique<ClassSymbol>("Long", llvm::Type::getInt64Ty(context), "System.lang.Object");
    this->currentScope->symbols["Float"] = std::make_unique<ClassSymbol>("Float", llvm::Type::getInt32Ty(context), "System.lang.Object");
    this->currentScope->symbols["Double"] = std::make_unique<ClassSymbol>("Double", llvm::Type::getInt32Ty(context), "System.lang.Object");
    this->currentScope->symbols["Char"] = std::make_unique<ClassSymbol>("Char", llvm::Type::getInt32Ty(context), "System.lang.Object");
    this->currentScope->symbols["Boolean"] = std::make_unique<ClassSymbol>("Boolean", llvm::Type::getInt32Ty(context), "System.lang.Object");

    // 참조 타입 AnyRef
    auto anyRefType = std::make_unique<ClassType>("AnyRef");
    //addTypeSymbol("AnyRef", anyRefType);
    this->currentScope->symbols["AnyRef"] = std::make_unique<ClassSymbol>("AnyRef", llvm::Type::getInt32Ty(context), "System.lang.Object");

    // String 타입
    //addTypeSymbol("String", std::make_shared<ClassType>("String", anyRefType));
    this->currentScope->symbols["String"] = std::make_unique<ClassSymbol>("String", llvm::Type::getInt32Ty(context), "System.lang.Object");

    // Unit 타입 (void)
    //addTypeSymbol("Unit", std::make_shared<BasicType>("Unit", anyValType));
    this->currentScope->symbols["Unit"] = std::make_unique<ClassSymbol>("Unit", llvm::Type::getInt32Ty(context), "System.lang.Object");

    // Int 타입의 메서드 등록
    //auto& intClassSymbol = classSymbols["Int"];

    // 예를 들어, toString 메서드 등록
    std::vector<std::unique_ptr<Type>> emptyParams;
    auto rightCopy = std::make_unique<Type>(Type::Kind::BASIC, std::string("String"));
    ((ClassSymbol*)(this->currentScope->symbols["String"].get()))->methods["toString"] = std::make_unique<Symbol>(
        std::string("toString"),
        std::make_unique<FunctionType>(emptyParams, rightCopy),
        nullptr,
        false,
        SymbolType::METHOD);
}

SymbolTable::~SymbolTable() {
    // 현재 스코프부터 모든 스코프를 해제
    for (int i = 0; i < this->currentScopeLevel; ++i) {
        exitScope();
	}

    this->currentScope = nullptr;
}

bool SymbolTable::addSymbol(const std::string& name, const Symbol* symbol) {
    auto& ctxt = Context::getInstance();
    auto current = ctxt.getCurrentNamespace();

    if (this->currentSymbol == nullptr) {
        this->currentSymbol = const_cast<Symbol*>(symbol);  // currentSymbol은 메모리 해제하면 안됨!!!
		this->currentScope->symbols[name] = std::make_unique<Symbol>(symbol);
		return true;
    }

    switch (this->currentSymbol->symbolType) {
    case SymbolType::NAMESPACE:
        {
            auto target = (NamespaceSymbol*)this->currentSymbol;

            switch (symbol->symbolType) {
            case SymbolType::VARIABLE:
            case SymbolType::FIELD:
                if (target->variables.count(name) != 0)
                    return false;

                target->variables[name] = std::make_unique<Symbol>(symbol);
                this->currentScope->symbols[name] = std::make_unique<Symbol>(symbol);
                break;

            case SymbolType::FUNCTION:
            case SymbolType::METHOD:
                if (target->functions.count(name) != 0)
                    return false;

                target->functions[name] = std::make_unique<Symbol>(symbol);
                this->currentScope->symbols[name] = std::make_unique<Symbol>(symbol);
                break;

            case SymbolType::CLASS:
                if (target->classes.count(name) != 0)
                    return false;

                target->classes[name] = std::make_unique<ClassSymbol>(symbol);
                this->currentScope->symbols[name] = std::make_unique<Symbol>(symbol);
                break;

            case SymbolType::NAMESPACE:
                if (target->namespaces.count(name) != 0)
                    return false;

				target->namespaces[name] = std::make_unique<NamespaceSymbol>((NamespaceSymbol*)symbol);
                this->currentScope->symbols[name] = std::make_unique<Symbol>(symbol);
                break;

            default:
                printf("Unsupported symbol type for namespace: %d\n", (int)symbol->symbolType);
                break;
            }
        }

        break;

    case SymbolType::CLASS:
        {
            auto* target = (ClassSymbol*)this->currentSymbol;
            switch (symbol->symbolType) {
            case SymbolType::VARIABLE:
            case SymbolType::FIELD:
                if (target->fields.count(name) != 0)
                    return false;

                target->fields[name] = std::make_unique<Symbol>(symbol);
                this->currentScope->symbols[name] = std::make_unique<Symbol>(symbol);
                break;

            case SymbolType::FUNCTION:
            case SymbolType::METHOD:
                if (target->methods.count(name) != 0)
                    return false;

                target->methods[name] = std::make_unique<Symbol>(symbol);
                this->currentScope->symbols[name] = std::make_unique<Symbol>(symbol);
                break;

            default:
                printf("Unsupported symbol type for class: %d\n", (int)symbol->symbolType);
                break;
            }
        }
        break;

    case SymbolType::FUNCTION:
        {
		    auto* target = (FunctionSymbol*)this->currentSymbol;
            switch (symbol->symbolType) {
            case SymbolType::VARIABLE:
            case SymbolType::FIELD:
                // 타입을 맞춰서 push_back
                target->symbols.push_back(const_cast<Symbol*>(symbol));
				this->currentScope->symbols[name] = std::make_unique<Symbol>(symbol);
                break;
            default:
                printf("Unsupported symbol type for function: %d\n", (int)symbol->symbolType);
                break;
            }
        }
		break;

    default:
        // 오류
		printf("Unsupported current symbol type: %d\n", (int)current->symbolType);
        break;
    }

    return true;
}

std::optional<Symbol*> checkSymbol(Symbol* symbol, const std::string& name) {
    switch (symbol->symbolType) {
    case SymbolType::NAMESPACE:
    {
        auto target = (NamespaceSymbol*)symbol;

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

        return std::nullopt;
    }
    break;

    case SymbolType::CLASS:
    {
        auto target = (ClassSymbol*)symbol;
        if (target->methods.count(name) != 0) {
            return target->methods[name].get();
        }
        if (target->fields.count(name) != 0) {
            return target->fields[name].get();
        }
        return std::nullopt;
    }
    break;

    default:
        printf("Unsupported symbol type for lookup: %d\n", (int)symbol->symbolType);
        break;
    }

    return std::nullopt;
}

std::optional<Symbol*> SymbolTable::lookup(const std::string& name) {
    // TODO : name이 path(A.B.C)일 경우 처리 필요
    auto& ctxt = Context::getInstance();
	auto root = static_cast<NamespaceSymbol*>(ctxt.getRootNamespace());

	auto names = split(name, '.');

	// 현재 스코프부터 시작하여 상위 스코프로 올라가며 검색
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
                root = (NamespaceSymbol*)pair.second;

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
                auto classSymbol = (ClassSymbol*)pair.second;
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
                auto functionSymbol = (FunctionSymbol*)pair.second;
                for (auto& symbol : functionSymbol->symbols) {
                    if (symbol->name == name) {
                        return symbol;
                    }
                }
            }
            break;

            case SymbolType::METHOD:
            {
                auto methodSymbol = (FunctionSymbol*)pair.second;
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

    return std::nullopt;
}

std::optional<ClassSymbol*> SymbolTable::lookupClass(const std::string& name) {
	auto symbol = lookup(name);
	printf("SymbolTable::lookupClass: Looking up class '%s'\n", name.c_str());
	printf("SymbolTable::lookupClass: Symbol found: %s\n", symbol ? "yes" : "no");
	printf("SymbolTable::lookupClass: Symbol type: %d\n", symbol ? (int)((*symbol)->symbolType) : -1);
    if (symbol && (*symbol)->symbolType == SymbolType::CLASS) {
        return static_cast<ClassSymbol*>(*symbol);
	}
	return std::nullopt;
}

std::optional<NamespaceSymbol*> SymbolTable::lookupNamespace(const std::string& name) {
    auto symbol = lookup(name);
    if (symbol && (*symbol)->symbolType == SymbolType::NAMESPACE) {
        return (NamespaceSymbol*)(*symbol);
    }
    return std::nullopt;
}

std::optional<Symbol*> SymbolTable::lookupFunction(const std::string& name, std::vector<std::unique_ptr<Type>>& argTypes) {
    auto symbol = lookup(name);
    if (symbol && (*symbol)->symbolType == SymbolType::FUNCTION) {
        return (Symbol*)(*symbol);
    }
    return std::nullopt;
}

std::optional<Symbol*> SymbolTable::lookupMethod(const ClassSymbol& symbol, const std::string& methodName)
{
	printf("SymbolTable::lookupMethod is not implemented yet.\n");
    return std::nullopt;
}

void SymbolTable::merge(const SymbolTable& other) {
    return;
}

void SymbolTable::enterScope() {
	printf("entering enterScope\n");
    Scope* newScope = new Scope();
    newScope->outer = this->currentScope;
	this->currentScope = newScope;
    this->currentScopeLevel += 1;
}

void SymbolTable::exitScope() {
    printf("entering exitScope\n");
	auto* temp = this->currentScope;
    this->currentScope = this->currentScope->outer;
    temp->outer = nullptr;
    delete temp;
	this->currentScopeLevel -= 1;
}

void SymbolTable::print(std::ostream& os, int indent) const {
    // 심볼 테이블 출력
    auto& ctxt = Context::getInstance();
    auto root = static_cast<NamespaceSymbol*>(ctxt.getRootNamespace());
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