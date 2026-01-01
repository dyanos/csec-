// module_loader.cpp

#include "module_loader.h"
#include "lexer.h"
#include "parser.h"
#include "ast.h"
#include "codegen.h"
#include <sstream>
#include <fstream>
#include <iostream>

ModuleLoader::ModuleLoader() {
    // TODO: standard library를 로드하는 코드가 들어있어야 합니다.
	// c/c++과 호환할 것이므로, c/c++의 표준 라이브러리를 로드하는 코드를 작성해야 합니다.
	loadModule({ "std" });
}

std::shared_ptr<SymbolTable> ModuleLoader::loadModule(const std::vector<std::string>& path) {
    // 모듈 이름을 생성 (예: "package.module")
    std::ostringstream oss;
    for (size_t i = 0; i < path.size(); ++i) {
        oss << path[i];
        if (i != path.size() - 1) {
            oss << ".";
        }
    }
    std::string moduleName = oss.str();

    // 이미 로드된 모듈인지 확인
    auto it = moduleCache.find(moduleName);
    if (it != moduleCache.end()) {
        return it->second;
    }

    // 모듈 파일 경로를 생성 (예: "package/module.scala")
    std::string filepath;
    for (size_t i = 0; i < path.size(); ++i) {
        filepath += path[i];
        if (i != path.size() - 1) {
            filepath += "/";
        }
    }
    filepath += ".scala";

    // 모듈 파일을 파싱하여 심볼 테이블을 생성
    std::shared_ptr<SymbolTable> moduleSymbols = std::make_shared<SymbolTable>();
    if (!parseModuleFile(filepath, moduleSymbols)) {
        std::cerr << "Error: Failed to parse module file: " << filepath << std::endl;
        return nullptr;
    }

    // 모듈 캐시에 저장
    moduleCache[moduleName] = moduleSymbols;

    return moduleSymbols;
}

llvm::Function* ModuleLoader::loadFunction(const std::string& name, llvm::Module* module) {
    // 함수가 이미 있는지 확인
    if (module->getFunction(name)) {
        return module->getFunction(name);
    }

    // 함수를 로드할 수 없는 경우
    return nullptr;
}

bool ModuleLoader::parseModuleFile(const std::string& filepath, std::shared_ptr<SymbolTable>& moduleSymbols) {
	// c/c++과 호환할 것이므로, c/c++의 표준 라이브러리를 로드하는 코드를 작성해야 합니다.
	// TODO: 표준 라이브러리를 로드하는 코드가 들어있어야 합니다.

    // 파일을 읽어들입니다.
    std::ifstream file(filepath);
    if (!file) {
        std::cerr << "Error: Unable to open module file: " << filepath << std::endl;
        return false;
    }

    std::stringstream buffer;
    buffer << file.rdbuf();
    std::string code = buffer.str();

    // 렉싱 및 파싱
    Lexer lexer(code);
    std::vector<Token> tokens = lexer.tokenize();
    tokens.push_back(Token{ TokenType::END_OF_FILE, "", 0, 0 });

    Parser parser(tokens);
    auto ast = parser.parse();

    // 코드 생성기를 생성하고 모듈 심볼 테이블을 사용합니다.
    CodeGenerator::getInstance().symbolTable = *moduleSymbols;
    ast->codegen();

    // 모듈의 심볼 테이블을 반환
    *moduleSymbols = CodeGenerator::getInstance().symbolTable;

    return true;
}
