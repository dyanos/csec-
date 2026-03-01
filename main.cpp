// main.cpp
#define _CRTDBG_MAP_ALLOC
#include <stdlib.h>
#include <crtdbg.h>

#include "lexer.h"
#include "parser.h"
#include "ast.h"
#include "codegen.h"
#include "type_checker.h"
#include "utils.h"

#include <iostream>
#include <direct.h>
#include <llvm/Support/TargetSelect.h>
#include <llvm/ExecutionEngine/ExecutionEngine.h>
#include <llvm/ExecutionEngine/GenericValue.h>
#include <llvm/ExecutionEngine/Interpreter.h>
#include <llvm/ExecutionEngine/MCJIT.h>
#include <llvm/IR/Constants.h>
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/Verifier.h>

#include <llvm/IR/PassManager.h>
#include <llvm/Passes/PassBuilder.h>
#include <llvm/Transforms/Utils/Mem2Reg.h>

#include "ProgramNode.h"

#include <exception>

int main(int argc, char** argv) {
    /*llvm::PassBuilder PB;

    // ModulePassManager ?앹꽦
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

    // ?뚯씪??議댁옱?섎뒗吏 泥댄겕
    if (FILE* file = fopen(argv[1], "r")) {
        // ?꾨Т寃껊룄 ?섏? ?딅뒗??
    }
    else {
        std::cout << "File not found: " << argv[1] << std::endl;
        return -1;
    }*/

    char* cwd = _getcwd(NULL, 0);
    if (cwd) {
        std::cout << "get current directory: " << cwd << std::endl;
        free(cwd);
    }
    else {
        std::cout << "get current directory: <unavailable>" << std::endl;
    }
    std::string inputFile = "sample2.csec";
    if (argc >= 2) {
        inputFile = argv[1];
    }

    std::string code = read_utf8_file(inputFile);
    if (code.empty()) {
        std::cerr << "Unable to read input file: " << inputFile << std::endl;
        return 1;
    }

    // 肄붾뱶 ?앹꽦
    Lexer lexer(code);
    std::vector<Token> tokens = lexer.tokenize();

    std::unique_ptr<ASTNode> ast;
    try {
        Parser parser(tokens);
        ast = parser.parse();
    }
    catch (const std::exception& e) {
        std::cerr << "Parsing failed: " << e.what() << std::endl;
        return 1;
    }

    std::cout << "Parsing completed successfully." << std::endl;

    // AST 異쒕젰 (?좏깮 ?ы빆)
    //ASTPrinter printer;
    //ast->accept(printer);

    TypeChecker typeChecker;
    ast->accept(typeChecker);
    if (typeChecker.hasErrors()) {
        std::cerr << "Type checking found " << typeChecker.getErrorCount()
                  << " error(s). Aborting code generation." << std::endl;
        return 1;
    }
    ast->codegen();

    // LLVM IR 異쒕젰
    CodeGenerator::getInstance().dumpIR();

    // ?ㅽ뻾 ?붿쭊 珥덇린??
    LLVMLinkInMCJIT();
    LLVMLinkInInterpreter();
    llvm::InitializeNativeTarget();
    llvm::InitializeNativeTargetAsmPrinter();
    llvm::InitializeNativeTargetAsmParser();

    auto& codeGen = CodeGenerator::getInstance();
    if (codeGen.mainFunction && !codeGen.mainFunction->empty()) {
        llvm::BasicBlock& rootEntry = codeGen.mainFunction->getEntryBlock();
        if (!rootEntry.getTerminator()) {
            llvm::IRBuilder<> rootBuilder(&rootEntry);
            rootBuilder.CreateRet(llvm::ConstantInt::get(llvm::Type::getInt32Ty(codeGen.context), 0));
        }
    }

    if (llvm::verifyModule(*codeGen.module, &llvm::errs())) {
        std::cerr << "Generated LLVM IR is invalid. Aborting execution." << std::endl;
        return 1;
    }

    std::string errStr;
    auto engine = llvm::EngineBuilder(std::move(codeGen.module))
        .setErrorStr(&errStr)
        .setEngineKind(llvm::EngineKind::Interpreter)
        .setOptLevel(llvm::CodeGenOpt::getLevel(0).value())
        .create();

    if (!engine) {
        std::cerr << "Failed to create ExecutionEngine: " << errStr << std::endl;
        std::cerr << "Execution backend is unavailable. Skipping run phase." << std::endl;
        return 0;
    }

    //MPM.run(*codeGen.module, MAM);

    // main ?⑥닔 ?ㅽ뻾
    auto result = engine->runFunction(codeGen.mainFunction, {});

    return 0;
}


