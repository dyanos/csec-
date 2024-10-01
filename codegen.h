// codegen.h
#pragma once

#include "ast.h"
#include "symbol_table.h"
#include "module_loader.h"
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/Module.h>

class CodeGenerator {
public:
    CodeGenerator();
    llvm::LLVMContext context;
    llvm::IRBuilder<> builder;
    std::unique_ptr<llvm::Module> module;
    ModuleLoader moduleLoader;
    llvm::Function* mainFunction;
    llvm::Function* mallocFunction;
	llvm::Function* freeFunction;

    SymbolTable symbolTable;  // 심볼 테이블 추가
    std::string currentClassName;
    
    void generateCode(std::shared_ptr<ProgramNode> program);
    void dumpIR();
    llvm::Type* getLLVMType(std::shared_ptr<Type> type);
};
