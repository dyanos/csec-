// main.cpp
#ifdef _WIN32
#define _CRTDBG_MAP_ALLOC
#include <stdlib.h>
#include <crtdbg.h>
#include <direct.h>
#else
#include <unistd.h>
#endif

#include "lexer.h"
#include "parser.h"
#include "ast.h"
#include "codegen.h"
#include "type_checker.h"
#include "utils.h"

#include <iostream>
#include <llvm/Support/TargetSelect.h>
#include <llvm/ExecutionEngine/ExecutionEngine.h>
#include <llvm/ExecutionEngine/GenericValue.h>
#include <llvm/ExecutionEngine/Interpreter.h>
#include <llvm/ExecutionEngine/MCJIT.h>
#include <llvm/IR/Constants.h>
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/Verifier.h>
#include <llvm/Support/FileSystem.h>
#include <llvm/Support/raw_ostream.h>

#include <llvm/IR/PassManager.h>
#include <llvm/Passes/PassBuilder.h>
#include <llvm/Transforms/Utils/Mem2Reg.h>

#include "ProgramNode.h"

#include <cstdlib>
#include <exception>
#include <filesystem>
#include <string>
#include <vector>

namespace {
enum class OutputMode {
    Run,
    SyntaxOnly,
    EmitIR,
    EmitObject,
    EmitExecutable
};

void printUsage(const char* programName) {
    std::cerr
        << "Usage: " << programName << " [options] <input.csec>\n"
        << "Options:\n"
        << "  --syntax-only, --parse-only  Parse only, no code generation\n"
        << "  --run                        Generate and run with LLVM interpreter (default)\n"
        << "  --emit-ir, -S                Write LLVM IR (.ll)\n"
        << "  --emit-obj, -c               Write native object code (.obj/.o)\n"
        << "  --emit-exe                   Write native executable (.exe)\n"
        << "  -o <path>                    Output path for --emit-ir/--emit-obj/--emit-exe\n"
        << "  --link-lib <name-or-path>    Link an additional native library/import library\n"
        << "  --link-path <path>           Add a native library search path\n";
}

std::string defaultOutputPath(const std::string& inputFile, OutputMode mode) {
    std::filesystem::path path(inputFile);
    if (path.has_parent_path()) {
        path = path.parent_path() / path.stem();
    }
    else {
        path = path.stem();
    }

    if (mode == OutputMode::EmitIR) {
        path.replace_extension(".ll");
    }
    else if (mode == OutputMode::EmitObject) {
#ifdef _WIN32
        path.replace_extension(".obj");
#else
        path.replace_extension(".o");
#endif
    }
    else if (mode == OutputMode::EmitExecutable) {
#ifdef _WIN32
        path.replace_extension(".exe");
#else
        path.replace_extension("");
#endif
    }

    return path.string();
}

llvm::Value* coerceReturnToInt32(llvm::IRBuilder<>& builder, llvm::Value* value) {
    if (!value) {
        return builder.getInt32(0);
    }

    llvm::Type* sourceType = value->getType();
    llvm::Type* int32Type = builder.getInt32Ty();
    if (sourceType == int32Type) {
        return value;
    }
    if (sourceType->isIntegerTy()) {
        unsigned sourceBits = sourceType->getIntegerBitWidth();
        if (sourceBits < 32) {
            return builder.CreateSExt(value, int32Type, "main.ret.sext");
        }
        if (sourceBits > 32) {
            return builder.CreateTrunc(value, int32Type, "main.ret.trunc");
        }
    }
    if (sourceType->isFloatingPointTy()) {
        return builder.CreateFPToSI(value, int32Type, "main.ret.fptosi");
    }
    return builder.getInt32(0);
}

void rebuildRuntimeMain(CodeGenerator& codeGen) {
    llvm::Function* userMain = codeGen.module->getFunction("_main");
    if (!userMain || userMain->arg_size() != 0) {
        return;
    }

    codeGen.mainFunction->deleteBody();
    llvm::BasicBlock* entry = llvm::BasicBlock::Create(codeGen.context, "entry", codeGen.mainFunction);
    llvm::IRBuilder<> builder(entry);

    llvm::Value* result = nullptr;
    if (userMain->getReturnType()->isVoidTy()) {
        builder.CreateCall(userMain);
    }
    else {
        result = builder.CreateCall(userMain, {}, "user.main");
    }

    builder.CreateRet(coerceReturnToInt32(builder, result));
}

bool writeIRToFile(llvm::Module& module, const std::string& outputPath, bool announce = true) {
    std::error_code ec;
    llvm::raw_fd_ostream output(outputPath, ec, llvm::sys::fs::OF_Text);
    if (ec) {
        std::cerr << "Failed to open IR output file '" << outputPath << "': " << ec.message() << std::endl;
        return false;
    }

    module.print(output, nullptr);
    if (announce) {
        std::cout << "Wrote LLVM IR: " << outputPath << std::endl;
    }
    return true;
}

std::string quoteCommandArg(const std::string& value) {
    std::string quoted = "\"";
    for (char ch : value) {
        if (ch == '"') {
            quoted += "\\\"";
        }
        else {
            quoted += ch;
        }
    }
    quoted += "\"";
    return quoted;
}

std::string getEnvironmentVariable(const std::string& name) {
#ifdef _WIN32
    char* value = nullptr;
    size_t length = 0;
    if (_dupenv_s(&value, &length, name.c_str()) != 0 || !value) {
        return "";
    }
    std::string result(value);
    free(value);
    return result;
#else
    const char* value = std::getenv(name.c_str());
    return value ? std::string(value) : "";
#endif
}

std::filesystem::path findToolPath(const std::string& envVar, const std::string& fallbackName) {
    std::string envValue = getEnvironmentVariable(envVar);
    if (!envValue.empty()) {
        std::filesystem::path path(envValue);
        std::error_code ec;
        if (std::filesystem::is_directory(path, ec)) {
            path /= fallbackName;
        }
        if (std::filesystem::exists(path, ec)) {
            auto canonicalPath = std::filesystem::weakly_canonical(path, ec);
            return ec ? path : canonicalPath;
        }
        return path;
    }
    return fallbackName;
}

std::filesystem::path findLlvmTool(const std::string& toolName) {
    std::string llvmBin = getEnvironmentVariable("LLVM_BIN");
    if (!llvmBin.empty()) {
        std::filesystem::path candidate = std::filesystem::path(llvmBin) / toolName;
        std::error_code ec;
        if (std::filesystem::exists(candidate, ec)) {
            auto canonicalPath = std::filesystem::weakly_canonical(candidate, ec);
            return ec ? candidate : canonicalPath;
        }
    }

    std::filesystem::path candidate = std::filesystem::absolute(
        std::filesystem::path("..") / "llvm-project" / "build" / "bin" / toolName);
    std::error_code ec;
    if (std::filesystem::exists(candidate, ec)) {
        auto canonicalPath = std::filesystem::weakly_canonical(candidate, ec);
        return ec ? candidate : canonicalPath;
    }
    return toolName;
}

bool writeObjectToFile(llvm::Module& module, const std::string& outputPath, bool announce = true) {
#ifdef _WIN32
    std::filesystem::path llcPath = findLlvmTool("llc.exe");
#else
    std::filesystem::path llcPath = findLlvmTool("llc");
#endif

    std::filesystem::path tempIR = std::filesystem::path(outputPath).replace_extension(".tmp.ll");
    if (!writeIRToFile(module, tempIR.string(), false)) {
        return false;
    }

    std::string command = quoteCommandArg(llcPath.string()) +
        " -filetype=obj -o " + quoteCommandArg(outputPath) + " " + quoteCommandArg(tempIR.string());
#ifdef _WIN32
    command = "\"" + command + "\"";
#endif
    int result = std::system(command.c_str());
    std::error_code removeError;
    std::filesystem::remove(tempIR, removeError);
    if (result != 0) {
        std::cerr << "Failed to emit object file via llc. Command exited with code " << result << std::endl;
        return false;
    }

    if (announce) {
        std::cout << "Wrote object file: " << outputPath << std::endl;
    }
    return true;
}

std::string nativeLinkLibraryArg(const std::string& library) {
    if (library.empty()) {
        return "";
    }
    if (library.rfind("-l", 0) == 0 || library.rfind("-Wl,", 0) == 0) {
        return library;
    }

    std::filesystem::path path(library);
    const bool hasDirectory = path.has_parent_path();
    const std::string extension = path.extension().string();
    if (hasDirectory || extension == ".o") {
        return quoteCommandArg(library);
    }
    if (extension == ".so") {
        return "-l:" + path.filename().string();
    }
    if (extension == ".a") {
#ifdef __APPLE__
        std::string stemName = path.stem().string();
        if (stemName.rfind("lib", 0) == 0 && stemName.size() > 3) {
            return "-l" + stemName.substr(3);
        }
        return quoteCommandArg(library);
#else
        return "-l:" + path.filename().string();
#endif
    }
    if (extension == ".dylib") {
        std::string stem = path.stem().string();
        if (stem.rfind("lib", 0) == 0 && stem.size() > 3) {
            return "-l" + stem.substr(3);
        }
        return quoteCommandArg(library);
    }
    std::string stem = path.stem().string();
    if (path.filename().string().rfind("lib", 0) == 0 && stem.size() > 3) {
        return "-l" + stem.substr(3);
    }
    return "-l" + library;
}

std::filesystem::path findWindowsLinker() {
    std::filesystem::path linkerPath = "link.exe";
    if (std::filesystem::exists(linkerPath)) {
        return linkerPath;
    }

#ifdef _WIN32
    std::filesystem::path msvcRoot =
        R"(C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC)";
    std::error_code ec;
    if (std::filesystem::exists(msvcRoot, ec)) {
        for (const auto& entry : std::filesystem::recursive_directory_iterator(
                 msvcRoot, std::filesystem::directory_options::skip_permission_denied, ec)) {
            if (ec) {
                break;
            }

            auto path = entry.path();
            std::string pathText = path.string();
            if (entry.is_regular_file(ec) && path.filename() == "link.exe" &&
                pathText.find("\\bin\\Hostx64\\x64\\") != std::string::npos) {
                auto canonicalPath = std::filesystem::weakly_canonical(path, ec);
                return ec ? path : canonicalPath;
            }
        }
    }
#endif

    return linkerPath;
}

#ifdef _WIN32
std::filesystem::path findMsvcX64LibPath(const std::filesystem::path& linkPath) {
    std::error_code ec;
    auto canonical = std::filesystem::weakly_canonical(linkPath, ec);
    const auto path = ec ? linkPath : canonical;
    const auto versionDir = path.parent_path().parent_path().parent_path().parent_path();
    auto libPath = versionDir / "lib" / "x64";
    if (std::filesystem::exists(libPath / "libcmt.lib", ec)) {
        return libPath;
    }
    return {};
}

std::filesystem::path findWindowsSdkLibRoot() {
    std::filesystem::path sdkLibRoot = R"(C:\Program Files (x86)\Windows Kits\10\Lib)";
    std::error_code ec;
    if (!std::filesystem::exists(sdkLibRoot, ec)) {
        return {};
    }

    std::filesystem::path best;
    for (const auto& entry : std::filesystem::directory_iterator(sdkLibRoot, ec)) {
        if (ec || !entry.is_directory(ec)) {
            continue;
        }
        auto candidate = entry.path();
        if (std::filesystem::exists(candidate / "ucrt" / "x64" / "ucrt.lib", ec) &&
            std::filesystem::exists(candidate / "um" / "x64" / "kernel32.lib", ec) &&
            (best.empty() || candidate.filename().string() > best.filename().string())) {
            best = candidate;
        }
    }
    return best;
}

std::filesystem::path findNativeRuntimeObject() {
    std::vector<std::filesystem::path> candidates = {
        std::filesystem::absolute(std::filesystem::path("csec++") / "x64" / "Debug" / "NativeRuntime.obj"),
        std::filesystem::absolute(std::filesystem::path("csec++") / "x64" / "Release" / "NativeRuntime.obj"),
        std::filesystem::absolute(std::filesystem::path("x64") / "Debug" / "NativeRuntime.obj"),
        std::filesystem::absolute(std::filesystem::path("x64") / "Release" / "NativeRuntime.obj"),
        std::filesystem::absolute(std::filesystem::path("Debug") / "NativeRuntime.obj"),
        std::filesystem::absolute(std::filesystem::path("Release") / "NativeRuntime.obj")
    };
    std::error_code ec;
    for (const auto& candidate : candidates) {
        if (std::filesystem::exists(candidate, ec)) {
            return candidate;
        }
    }
    return {};
}

bool compileNativeRuntimeObject(const std::filesystem::path& linkPath, const std::filesystem::path& outputObject) {
    std::filesystem::path clPath = linkPath.parent_path() / "cl.exe";
    std::error_code ec;
    if (!std::filesystem::exists(clPath, ec)) {
        std::cerr << "MSVC compiler not found next to linker: " << clPath << std::endl;
        return false;
    }

    std::filesystem::path sourcePath = std::filesystem::absolute("NativeRuntime.cpp");
    const auto versionDir = linkPath.parent_path().parent_path().parent_path().parent_path();
    const auto vcInclude = versionDir / "include";
    const auto sdkRoot = findWindowsSdkLibRoot();
    std::string command =
        quoteCommandArg(clPath.string()) +
        " /nologo /c /EHsc /MT /O2 /DCSEC_NATIVE_RUNTIME_BUILD /D_CRT_SECURE_NO_WARNINGS /D_WINSOCK_DEPRECATED_NO_WARNINGS " +
        "/I" + quoteCommandArg(vcInclude.string()) + " ";
    if (!sdkRoot.empty()) {
        auto sdkBase = sdkRoot.parent_path().parent_path();
        command +=
            "/I" + quoteCommandArg((sdkBase / "Include" / sdkRoot.filename() / "ucrt").string()) + " " +
            "/I" + quoteCommandArg((sdkBase / "Include" / sdkRoot.filename() / "shared").string()) + " " +
            "/I" + quoteCommandArg((sdkBase / "Include" / sdkRoot.filename() / "um").string()) + " ";
    }
    command +=
        quoteCommandArg(sourcePath.string()) +
        " /Fo:" + quoteCommandArg(outputObject.string());
    command = "\"" + command + "\"";
    int result = std::system(command.c_str());
    if (result != 0) {
        std::cerr << "Failed to compile NativeRuntime.cpp. Command exited with code " << result << std::endl;
        return false;
    }
    return true;
}
#endif

bool writeExecutableToFile(
    llvm::Module& module,
    const std::string& outputPath,
    const std::vector<std::string>& linkLibraries,
    const std::vector<std::string>& linkPaths) {
#ifndef _WIN32
    std::filesystem::path tempObject = std::filesystem::path(outputPath).replace_extension(".tmp.o");
    if (!writeObjectToFile(module, tempObject.string(), false)) {
        return false;
    }

    std::filesystem::path tempRuntimeObject = std::filesystem::path(outputPath).replace_extension(".native.tmp.o");
    std::filesystem::path cxxPath = findToolPath("CXX", "c++");
    std::string cxx = cxxPath.string();
    std::string compileCommand =
        quoteCommandArg(cxx) +
        " -std=c++17 -O2 -pthread -DCSEC_NATIVE_RUNTIME_BUILD -c " +
        quoteCommandArg(std::filesystem::absolute("NativeRuntime.cpp").string()) +
        " -o " + quoteCommandArg(tempRuntimeObject.string());
    int compileResult = std::system(compileCommand.c_str());
    if (compileResult != 0) {
        std::error_code removeError;
        std::filesystem::remove(tempObject, removeError);
        std::cerr << "Failed to compile NativeRuntime.cpp. Command exited with code " << compileResult << std::endl;
        return false;
    }

    std::string linkCommand =
        quoteCommandArg(cxx) +
        " -o " + quoteCommandArg(outputPath) + " " +
        quoteCommandArg(tempObject.string()) + " " +
        quoteCommandArg(tempRuntimeObject.string());
    for (const auto& linkPathArg : linkPaths) {
        if (!linkPathArg.empty()) {
            linkCommand += " -L" + quoteCommandArg(linkPathArg);
        }
    }
    for (const auto& library : linkLibraries) {
        std::string linkArg = nativeLinkLibraryArg(library);
        if (!linkArg.empty()) {
            linkCommand += " " + linkArg;
        }
    }
    linkCommand += " -pthread";
#ifndef __APPLE__
    linkCommand += " -ldl";
#endif

    int linkResult = std::system(linkCommand.c_str());
    std::error_code removeError;
    std::filesystem::remove(tempObject, removeError);
    std::filesystem::remove(tempRuntimeObject, removeError);
    if (linkResult != 0) {
        std::cerr << "Failed to emit executable via native linker. Command exited with code " << linkResult << std::endl;
        return false;
    }

    std::cout << "Wrote executable: " << outputPath << std::endl;
    return true;
#else
    std::filesystem::path tempObject = std::filesystem::path(outputPath).replace_extension(".tmp.obj");
    if (!writeObjectToFile(module, tempObject.string(), false)) {
        return false;
    }

    std::filesystem::path linkPath = findWindowsLinker();
    std::filesystem::path tempRuntimeObject = std::filesystem::path(outputPath).replace_extension(".native.tmp.obj");
    if (!compileNativeRuntimeObject(linkPath, tempRuntimeObject)) {
        std::error_code removeError;
        std::filesystem::remove(tempObject, removeError);
        return false;
    }
    std::vector<std::string> linkArgs = {
        quoteCommandArg(linkPath.string()),
        "/NOLOGO",
        "/SUBSYSTEM:CONSOLE",
        "/OUT:" + quoteCommandArg(outputPath),
        quoteCommandArg(tempObject.string())
    };
    linkArgs.push_back(quoteCommandArg(tempRuntimeObject.string()));

    auto msvcLibPath = findMsvcX64LibPath(linkPath);
    if (!msvcLibPath.empty()) {
        linkArgs.push_back("/LIBPATH:" + quoteCommandArg(msvcLibPath.string()));
    }
    auto sdkLibRoot = findWindowsSdkLibRoot();
    if (!sdkLibRoot.empty()) {
        linkArgs.push_back("/LIBPATH:" + quoteCommandArg((sdkLibRoot / "ucrt" / "x64").string()));
        linkArgs.push_back("/LIBPATH:" + quoteCommandArg((sdkLibRoot / "um" / "x64").string()));
    }
    for (const auto& linkPathArg : linkPaths) {
        if (!linkPathArg.empty()) {
            linkArgs.push_back("/LIBPATH:" + quoteCommandArg(linkPathArg));
        }
    }
    linkArgs.push_back("libcmt.lib");
    linkArgs.push_back("libvcruntime.lib");
    linkArgs.push_back("libucrt.lib");
    linkArgs.push_back("kernel32.lib");
    linkArgs.push_back("ws2_32.lib");
    linkArgs.push_back("legacy_stdio_definitions.lib");
    for (const auto& library : linkLibraries) {
        if (!library.empty()) {
            linkArgs.push_back(quoteCommandArg(library));
        }
    }

    std::string command;
    for (size_t i = 0; i < linkArgs.size(); ++i) {
        if (i > 0) {
            command += " ";
        }
        command += linkArgs[i];
    }
    command = "\"" + command + "\"";
    int result = std::system(command.c_str());
    std::error_code removeError;
    std::filesystem::remove(tempObject, removeError);
    std::filesystem::remove(tempRuntimeObject, removeError);
    if (result != 0) {
        std::cerr << "Failed to emit executable via link.exe. Command exited with code " << result << std::endl;
        return false;
    }

    std::cout << "Wrote executable: " << outputPath << std::endl;
    return true;
#endif
}
}

int main(int argc, char** argv) {
#ifdef _WIN32
    _CrtSetDbgFlag(_CRTDBG_ALLOC_MEM_DF | _CRTDBG_LEAK_CHECK_DF);
#endif
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

    char* cwd =
#ifdef _WIN32
        _getcwd(NULL, 0);
#else
        getcwd(NULL, 0);
#endif
    if (cwd) {
        std::cout << "get current directory: " << cwd << std::endl;
        free(cwd);
    }
    else {
        std::cout << "get current directory: <unavailable>" << std::endl;
    }
    OutputMode outputMode = OutputMode::Run;
    std::string inputFile = "sample2.csec";
    bool inputFileSet = false;
    std::string outputFile;
    std::vector<std::string> linkLibraries;
    std::vector<std::string> linkPaths;
    for (int i = 1; i < argc; ++i) {
        std::string arg = argv[i];
        if (arg == "--syntax-only" || arg == "--parse-only") {
            outputMode = OutputMode::SyntaxOnly;
            continue;
        }
        if (arg == "--run") {
            outputMode = OutputMode::Run;
            continue;
        }
        if (arg == "--emit-ir" || arg == "-S") {
            outputMode = OutputMode::EmitIR;
            continue;
        }
        if (arg == "--emit-obj" || arg == "-c") {
            outputMode = OutputMode::EmitObject;
            continue;
        }
        if (arg == "--emit-exe") {
            outputMode = OutputMode::EmitExecutable;
            continue;
        }
        if (arg == "-o") {
            if (i + 1 >= argc) {
                std::cerr << "Missing output path after -o" << std::endl;
                printUsage(argv[0]);
                return 1;
            }
            outputFile = argv[++i];
            continue;
        }
        if (arg == "--link-lib") {
            if (i + 1 >= argc) {
                std::cerr << "Missing library after --link-lib" << std::endl;
                printUsage(argv[0]);
                return 1;
            }
            linkLibraries.push_back(argv[++i]);
            continue;
        }
        if (arg == "--link-path") {
            if (i + 1 >= argc) {
                std::cerr << "Missing path after --link-path" << std::endl;
                printUsage(argv[0]);
                return 1;
            }
            linkPaths.push_back(argv[++i]);
            continue;
        }
        if (arg == "--help" || arg == "-h") {
            printUsage(argv[0]);
            return 0;
        }
        if (!inputFileSet) {
            inputFile = arg;
            inputFileSet = true;
            continue;
        }
        std::cerr << "Unexpected argument: " << arg << std::endl;
        printUsage(argv[0]);
        return 1;
    }

    std::string code = read_utf8_file(inputFile);
    if (code.empty()) {
        std::error_code ec;
        if (!std::filesystem::exists(inputFile, ec) || !std::filesystem::is_regular_file(inputFile, ec)) {
            std::cerr << "Unable to read input file: " << inputFile << std::endl;
            return 1;
        }
    }

    // 肄붾뱶 ?앹꽦
    Lexer lexer(code);
    std::vector<Token> tokens = lexer.tokenize();
    for (const auto& token : tokens) {
        if (token.type == TokenType::UNKNOWN) {
            std::cerr << "Lexing failed: unknown token '" << token.value
                      << "' at line " << token.line << ", column " << token.column << std::endl;
            return 1;
        }
    }

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
    if (outputMode == OutputMode::SyntaxOnly) {
        ast.reset();
        return 0;
    }

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

    // Keep IR dumping opt-in; unconditional dumps make large template suites unreasonably slow.
    // CodeGenerator::getInstance().dumpIR();

    LLVMLinkInMCJIT();
    LLVMLinkInInterpreter();
    llvm::InitializeNativeTarget();
    llvm::InitializeNativeTargetAsmPrinter();
    llvm::InitializeNativeTargetAsmParser();

    auto& codeGen = CodeGenerator::getInstance();
    rebuildRuntimeMain(codeGen);
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

    llvm::PassBuilder PB;
    llvm::ModulePassManager MPM;
    llvm::FunctionPassManager FPM;
    FPM.addPass(llvm::PromotePass());
    MPM.addPass(llvm::createModuleToFunctionPassAdaptor(std::move(FPM)));

    llvm::LoopAnalysisManager LAM;
    llvm::FunctionAnalysisManager FAM;
    llvm::CGSCCAnalysisManager CGAM;
    llvm::ModuleAnalysisManager MAM;

    PB.registerModuleAnalyses(MAM);
    PB.registerFunctionAnalyses(FAM);
    PB.registerLoopAnalyses(LAM);
    PB.registerCGSCCAnalyses(CGAM);
    PB.crossRegisterProxies(LAM, FAM, CGAM, MAM);
    MPM.run(*codeGen.module, MAM);

    if (outputMode == OutputMode::EmitIR || outputMode == OutputMode::EmitObject ||
        outputMode == OutputMode::EmitExecutable) {
        if (outputFile.empty()) {
            outputFile = defaultOutputPath(inputFile, outputMode);
        }

        if (outputMode == OutputMode::EmitIR) {
            return writeIRToFile(*codeGen.module, outputFile) ? 0 : 1;
        }

        if (outputMode == OutputMode::EmitObject) {
            return writeObjectToFile(*codeGen.module, outputFile) ? 0 : 1;
        }

        std::vector<std::string> allLinkLibraries = linkLibraries;
        for (const auto& library : codeGen.externalLinkLibraries) {
            bool exists = false;
            for (const auto& current : allLinkLibraries) {
                if (current == library) {
                    exists = true;
                    break;
                }
            }
            if (!exists) allLinkLibraries.push_back(library);
        }
        std::vector<std::string> allLinkPaths = linkPaths;
        for (const auto& path : codeGen.externalLinkPaths) {
            bool exists = false;
            for (const auto& current : allLinkPaths) {
                if (current == path) {
                    exists = true;
                    break;
                }
            }
            if (!exists) allLinkPaths.push_back(path);
        }
        return writeExecutableToFile(*codeGen.module, outputFile, allLinkLibraries, allLinkPaths) ? 0 : 1;
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

    // main ?⑥닔 ?ㅽ뻾
    auto result = engine->runFunction(codeGen.mainFunction, {});

    return 0;
}



