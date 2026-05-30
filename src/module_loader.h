#pragma once

#include <string>
#include <memory>
#include <vector>
#include "symbol_table.h"

class ModuleLoader {
public:
    ModuleLoader();
    SymbolTable* loadModule(const std::vector<std::string>& path);
    llvm::Function* loadFunction(const std::string& name, llvm::Module* module); // Add this line

private:
    // 모듈 캐싱을 위한 맵
    std::unordered_map<std::string, std::unique_ptr<SymbolTable>> moduleCache;

    // 모듈을 읽고 파싱하는 함수
    bool parseModuleFile(const std::string& filepath, SymbolTable& moduleSymbols);
};