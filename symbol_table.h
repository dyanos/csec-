#pragma once

#include "symbol.h"
#include <unordered_map>
#include <vector>
#include <string>
#include <memory>
#include <optional>
#include <functional>

class CodeGenerator;

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

struct Scope {
	std::unordered_map<std::string, Symbol*> symbols;
	Scope* outer;
	int count;
};

class SymbolTable {
public:
	SymbolTable();
	SymbolTable(const SymbolTable& other);
	~SymbolTable();
	void initializeBuiltInTypes(llvm::LLVMContext& context);
	void enterScope();
	void exitScope();
	bool addSymbol(const std::string& name, const Symbol* symbol);
	std::optional<Symbol*> lookup(const std::string& name);
	std::optional<ClassSymbol*> lookupClass(const std::string& name);
	std::optional<NamespaceSymbol*> lookupNamespace(const std::string& name);
	std::optional<Symbol*> lookupFunction(const std::string& name, std::vector<std::shared_ptr<Type>>& argTypes);
	std::optional<Symbol*> lookupMethod(const ClassSymbol& symbol, const std::string& methodName);
	void merge(const SymbolTable& other);
	void print(std::ostream& os, int indent = 0) const;

private:
	struct Scope* currentScope = nullptr;
	int currentScopeLevel = 0;
	struct Symbol* currentSymbol = nullptr;

	std::vector<struct Scope*> scopeStack;

public:
	void setCurrentSymbol(Symbol* symbol) {
		this->currentSymbol = symbol;
	}

	void saveCurrentSymbol() {
		// 현재 심볼 저장용 (필요시 구현)
		scopeStack.push_back(currentScope);
	}

	void popCurrentSymbol() {
		// 저장된 심볼 복원용 (필요시 구현)
		if (!scopeStack.empty()) {
			this->currentScope = scopeStack.back();
			scopeStack.pop_back();
		}
	}
};