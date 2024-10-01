// main.cpp
#include "lexer.h"
#include "parser.h"
#include "codegen.h"
#include "ast.h"
#include "type_checker.h"

#include <iostream>
#include <llvm/Support/TargetSelect.h>
#include <llvm/ExecutionEngine/ExecutionEngine.h>
#include <llvm/ExecutionEngine/GenericValue.h>
#include <llvm/ExecutionEngine/MCJIT.h>

int main() {
    std::string code = R"(
        class Person(name: String, age: Int) {
            val occupation: String = "Unknown"

            def greet() {
                println("Hello, my name is " + name)
            }

            def getAge(): Int = {
                age
            }
        }

        object Main {
            def main(args: Array[String]) {
                val person = new Person("Alice", 30)
                person.greet()
                println(person.getAge())
            }
        }
    )";

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

    // 코드 생성
    CodeGenerator codeGen;
    ASTNode::codeGenerator = &codeGen;

    codeGen.generateCode(ast);

    // LLVM IR 출력
    codeGen.dumpIR();

    // 실행 엔진 초기화
    llvm::InitializeNativeTarget();
    llvm::InitializeNativeTargetAsmPrinter();
    llvm::InitializeNativeTargetAsmParser();

    std::string errStr;
    auto engine = llvm::EngineBuilder(std::move(codeGen.module))
        .setErrorStr(&errStr)
        .setOptLevel(llvm::CodeGenOpt::getLevel(0).value())
        .create();

    if (!engine) {
        std::cerr << "Failed to create ExecutionEngine: " << errStr << std::endl;
        return 1;
    }

    // main 함수 실행
    auto result = engine->runFunction(codeGen.mainFunction, {});

    return 0;
}
