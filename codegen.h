// codegen.h
#pragma once

#include "symbol_table.h"

#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/Module.h>

class CodeGenerator {
public:
    static CodeGenerator& getInstance() {
        static CodeGenerator instance; // Guaranteed to be destroyed
        return instance;          // Instantiated on first use
    }

    CodeGenerator();
    llvm::LLVMContext context;
    llvm::IRBuilder<> builder;
    std::unique_ptr<llvm::Module> module;
    llvm::Function* mainFunction;

	// 현재 스코프 체인: namespace 및 클래스 스코프 추적용 -> body가 시작될때 push, 끝날때 pop
    std::vector<std::string> scopes;

    SymbolTable symbolTable;
    // 현재 namespace 또는 클래스, function(or method), block 등을 의미(상위 심볼의 정보도 검색되어야 하는 조건이 있음), nullptr이면 전역 스코프
	Symbol* currentSymbol;

    llvm::LLVMContext& getContext() { return context; }

    void dumpIR();
    llvm::Type* getLLVMType(const Type* type);

    llvm::Function* mallocFunction;
    llvm::Function* freeFunction;
};
