// module_loader.cpp

#include "module_loader.h"
#include "lexer.h"
#include "parser.h"
#include "ast.h"
#include "codegen.h"
#include "utils.h"

#include <iostream>
#include <sstream>
#include <utility>

ModuleLoader::ModuleLoader() {
    // NOTE: Deferred until std module file exists to avoid silent failure.
}

SymbolTable* ModuleLoader::loadModule(const std::vector<std::string>& path) {
    std::ostringstream oss;
    for (size_t i = 0; i < path.size(); ++i) {
        oss << path[i];
        if (i != path.size() - 1) {
            oss << ".";
        }
    }
    std::string moduleName = oss.str();

    auto it = moduleCache.find(moduleName);
    if (it != moduleCache.end()) {
        return it->second.get();
    }

    std::string filepath;
    for (size_t i = 0; i < path.size(); ++i) {
        filepath += path[i];
        if (i != path.size() - 1) {
            filepath += "/";
        }
    }
    filepath += ".scala";

    auto moduleSymbols = std::make_unique<SymbolTable>();
    if (!parseModuleFile(filepath, *moduleSymbols)) {
        std::cerr << "Error: Failed to parse module file: " << filepath << std::endl;
        return nullptr;
    }

    auto* moduleSymbolsRaw = moduleSymbols.get();
    moduleCache[moduleName] = std::move(moduleSymbols);

    return moduleSymbolsRaw;
}

llvm::Function* ModuleLoader::loadFunction(const std::string& name, llvm::Module* module) {
    if (module->getFunction(name)) {
        return module->getFunction(name);
    }

    return nullptr;
}

bool ModuleLoader::parseModuleFile(const std::string& filepath, SymbolTable& moduleSymbols) {
    std::string code = read_utf8_file(filepath);
    if (code.empty()) {
        std::cerr << "Error: Unable to open module file: " << filepath << std::endl;
        return false;
    }

    Lexer lexer(code);
    std::vector<Token> tokens = lexer.tokenize();

    Parser parser(tokens);
    auto ast = parser.parse();

    auto& codegenSymbolTable = CodeGenerator::getInstance().symbolTable;
    auto savedSymbolTable = std::move(codegenSymbolTable);
    codegenSymbolTable = std::move(moduleSymbols);
    ast->codegen();

    moduleSymbols = std::move(codegenSymbolTable);
    codegenSymbolTable = std::move(savedSymbolTable);

    return true;
}
