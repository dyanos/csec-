// main.cpp
#define _CRTDBG_MAP_ALLOC
#include <stdlib.h>
#include <crtdbg.h>

#include "lexer.h"
#include "parser.h"
#include "ast.h"
#include "codegen.h"
#include "type_checker.h"

#include <iostream>
#include <llvm/Support/TargetSelect.h>
#include <llvm/ExecutionEngine/ExecutionEngine.h>
#include <llvm/ExecutionEngine/GenericValue.h>
#include <llvm/ExecutionEngine/MCJIT.h>

#include <llvm/IR/PassManager.h>
#include <llvm/Passes/PassBuilder.h>
#include <llvm/Transforms/Utils/Mem2Reg.h>

#include <fstream>
#include <sstream>

#include "ProgramNode.h"

// 파일 내용을 읽어서 std::string으로 반환하는 함수 구현
std::string readFileContent(const std::string& filename) {
    std::ifstream file(filename, std::ios::in | std::ios::binary);
    if (!file) {
        return "";
    }
    std::ostringstream contents;
    contents << file.rdbuf();
    return contents.str();
}

int main(int argc, char** argv) {
    /*llvm::PassBuilder PB;

    // ModulePassManager 생성
    llvm::ModulePassManager MPM;

    MPM.addPass(llvm::PromotePass());

    llvm::LoopAnalysisManager LAM;
    llvm::FunctionAnalysisManager FAM;
    llvm::CGSCCAnalysisManager CGAM;
    llvm::ModuleAnalysisManager MAM;

    PB.registerModuleAnalyses(MAM);
    PB.registerFunctionAnalyses(FAM);
    PB.registerLoopAnalyses(LAM);
    PB.registerCGSCCAnalyses(CGAM);
    PB.crossRegisterProxies(LAM, FAM, CGAM, MAM);*/

    _CrtSetDbgFlag(_CRTDBG_ALLOC_MEM_DF | _CRTDBG_LEAK_CHECK_DF);
    //_CrtSetBreakAlloc(3404);

    /*if (argc < 2) {
        std::cout << "No input file provided." << std::endl;
        return -1;
	}

    // 파일이 존재하는지 체크
    if (FILE* file = fopen(argv[1], "r")) {
        // 아무것도 하지 않는다.
    }
    else {
        std::cout << "File not found: " << argv[1] << std::endl;
        return -1;
	}*/

	std::cout << "get current directory: " << _getcwd(NULL, 0) << std::endl;
	std::string code = readFileContent("sample2.csec");

    // 코드 생성
    Lexer lexer(code);
    std::vector<Token> tokens = lexer.tokenize();

    // EOF 토큰 추가
    tokens.push_back(Token{ TokenType::END_OF_FILE, "", 0, 0 });

    Parser parser(tokens);
    auto ast = parser.parse();

    std::cout << "Parsing completed successfully." << std::endl;

    // AST 출력 (선택 사항)
    //ASTPrinter printer;
    //ast->accept(printer);

    TypeChecker typeChecker;
    ast->accept(typeChecker);
    ast->codegen();

    // LLVM IR 출력
    CodeGenerator::getInstance().dumpIR();

    // 실행 엔진 초기화
    llvm::InitializeNativeTarget();
    llvm::InitializeNativeTargetAsmPrinter();
    llvm::InitializeNativeTargetAsmParser();

    std::string errStr;
    auto engine = llvm::EngineBuilder(std::move(CodeGenerator::getInstance().module))
        .setErrorStr(&errStr)
        .setOptLevel(llvm::CodeGenOpt::getLevel(0).value())
        .create();

    if (!engine) {
        std::cerr << "Failed to create ExecutionEngine: " << errStr << std::endl;
        return 1;
    }

    //MPM.run(*codeGen.module, MAM);


    // main 함수 실행
    auto result = engine->runFunction(CodeGenerator::getInstance().mainFunction, {});

    return 0;
}
