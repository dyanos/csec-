// codegen.h
#pragma once

#include "symbol_table.h"

#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/Module.h>
#include <vector>
#include <unordered_map>

class CodeGenerator {
public:
    static CodeGenerator& getInstance() {
        static CodeGenerator instance; // Guaranteed to be destroyed
        return instance;          // Instantiated on first use
    }

    llvm::LLVMContext context;
    llvm::IRBuilder<> builder;
    std::unique_ptr<llvm::Module> module;
    llvm::Function* mainFunction; // non-owning, owned by module

	// 현재 스코프 체인: namespace 및 클래스 스코프 추적용 -> body가 시작될때 push, 끝날때 pop
    std::vector<std::string> scopes;
    std::vector<std::string> externalLinkLibraries;
    std::vector<std::string> externalLinkPaths;

    SymbolTable symbolTable;
    // 현재 namespace 또는 클래스, function(or method), block 등을 의미(상위 심볼의 정보도 검색되어야 하는 조건이 있음), nullptr이면 전역 스코프
	Symbol* currentSymbol; // non-owning, owned by SymbolTable

    // Runtime element counts for collection results whose length is not encoded in their static
    // type. `filter` produces a buffer over-allocated to the source size but valid only for the
    // surviving-element count; `map` produces a statically sized buffer. Keyed by the result
    // pointer so a downstream `preduce`/`map`/`filter` iterating that pointer can use the real
    // length instead of the (unknown or over-allocated) static size. Non-owning LLVM values.
    std::unordered_map<llvm::Value*, llvm::Value*> arrayRuntimeLength;

    llvm::LLVMContext& getContext() { return context; }

    void addExternalLinkLibrary(const std::string& library);
    void addExternalLinkPath(const std::string& path);
    void requireSystemNative();

    void dumpIR();
    llvm::Type* getLLVMType(const Type* type);
    void enterCleanupScope();
    void exitCleanupScope();
    void registerCleanup(llvm::Value* pointer);
    void emitCurrentScopeCleanups();
    void emitAllCleanups();
    void emitAllCleanupsExcept(llvm::Value* retainedPointer);

    llvm::Function* mallocFunction; // non-owning, owned by module
    llvm::Function* freeFunction;  // non-owning, owned by module

private:
    CodeGenerator();
    std::vector<std::vector<llvm::Value*>> cleanupScopes;
};
