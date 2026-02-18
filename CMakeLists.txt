cmake_minimum_required(VERSION 3.16.0 FATAL_ERROR)

set(CMAKE_SYSTEM_VERSION 10.0 CACHE STRING "" FORCE)

project(csec++ CXX)

################################################################################
# Set target arch type if empty. Visual studio solution generator provides it.
################################################################################
if(NOT CMAKE_VS_PLATFORM_NAME)
    set(CMAKE_VS_PLATFORM_NAME "x64")
endif()
message("${CMAKE_VS_PLATFORM_NAME} architecture in use")

if(NOT ("${CMAKE_VS_PLATFORM_NAME}" STREQUAL "x64"
     OR "${CMAKE_VS_PLATFORM_NAME}" STREQUAL "x86"))
    message(FATAL_ERROR "${CMAKE_VS_PLATFORM_NAME} arch is not supported!")
endif()

################################################################################
# Global configuration types
################################################################################
set(CMAKE_CONFIGURATION_TYPES
    "Debug"
    "Release"
    CACHE STRING "" FORCE
)

################################################################################
# Global compiler options
################################################################################
if(MSVC)
    # remove default flags provided with CMake for MSVC
    set(CMAKE_CXX_FLAGS "")
    set(CMAKE_CXX_FLAGS_DEBUG "")
    set(CMAKE_CXX_FLAGS_RELEASE "")
endif()

# Clang compiler options
if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fcolor-diagnostics -fansi-escape-codes")
    set(CMAKE_CXX_FLAGS_DEBUG "-g -O0")
    set(CMAKE_CXX_FLAGS_RELEASE "-O3")
endif()

################################################################################
# Global linker options
################################################################################
if(MSVC)
    # remove default flags provided with CMake for MSVC
    set(CMAKE_EXE_LINKER_FLAGS "")
    set(CMAKE_MODULE_LINKER_FLAGS "")
    set(CMAKE_SHARED_LINKER_FLAGS "")
    set(CMAKE_STATIC_LINKER_FLAGS "")
    set(CMAKE_EXE_LINKER_FLAGS_DEBUG "${CMAKE_EXE_LINKER_FLAGS}")
    set(CMAKE_MODULE_LINKER_FLAGS_DEBUG "${CMAKE_MODULE_LINKER_FLAGS}")
    set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "${CMAKE_SHARED_LINKER_FLAGS}")
    set(CMAKE_STATIC_LINKER_FLAGS_DEBUG "${CMAKE_STATIC_LINKER_FLAGS}")
    set(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS}")
    set(CMAKE_MODULE_LINKER_FLAGS_RELEASE "${CMAKE_MODULE_LINKER_FLAGS}")
    set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "${CMAKE_SHARED_LINKER_FLAGS}")
    set(CMAKE_STATIC_LINKER_FLAGS_RELEASE "${CMAKE_STATIC_LINKER_FLAGS}")
endif()

################################################################################
# Nuget packages function stub.
################################################################################
function(use_package TARGET PACKAGE VERSION)
    message(WARNING "No implementation of use_package. Create yours. "
                    "Package \"${PACKAGE}\" with version \"${VERSION}\" "
                    "for target \"${TARGET}\" is ignored!")
endfunction()

################################################################################
# Common utils
################################################################################
include(CMake/Utils.cmake)

################################################################################
# Additional Global Settings(add specific info there)
################################################################################
include(CMake/GlobalSettingsInclude.cmake OPTIONAL)

################################################################################
# Use solution folders feature
################################################################################
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

################################################################################
# Sub-projects
################################################################################



























set(PROJECT_NAME csec++)

################################################################################
# Source groups
################################################################################
set(samples
    "sample1.csec"
    "sample2.csec"
)
source_group("samples" FILES ${samples})

set(_
    "README.md"
)
source_group("리소스 파일" FILES ${_})

set(_
    "ast.cpp"
    "ASTPrinter.cpp"
    "codegen.cpp"
    "LatexMathEqParser.cpp"
    "lexer.cpp"
    "main.cpp"
    "mangling.cpp"
    "module_loader.cpp"
    "symbol_table.cpp"
    "type.cpp"
    "type_checker.cpp"
    "type_utils.cpp"
    "utils.cpp"
)
source_group("소스 파일" FILES ${_})

set(___AST
    "AccessFieldNode.cpp"
    "ArrayAccessNode.cpp"
    "ArrayCreationExpressionNode.cpp"
    "ArrayCreationNode.cpp"
    "ArrayLiteralNode.cpp"
    "AssignmentExpressionNode.cpp"
    "AssignmentNode.cpp"
    "AttributeNode.cpp"
    "BinaryExpressionNode.cpp"
    "BlockNode.cpp"
    "CallExpressionNode.cpp"
    "CastingExpressionNode.cpp"
    "ClassBodyNode.cpp"
    "ClassDeclarationNode.cpp"
    "ClassInstanceCreationNode.cpp"
    "ExpressionNode.cpp"
    "FilterStatementNode.cpp"
    "ForStatementNode.cpp"
    "FunctionCallNode.cpp"
    "FunctionDeclarationNode.cpp"
    "IdentifierNode.cpp"
    "IfStatementNode.cpp"
    "ImportNode.cpp"
    "LambdaExpressionNode.cpp"
    "MapStatementNode.cpp"
    "MatchExpressionNode.cpp"
    "MethodCallNode.cpp"
    "ObjectDeclarationNode.cpp"
    "ParameterNode.cpp"
    "PMapStatementNode.cpp"
    "PostfixExpressionNode.cpp"
    "PrefixExpressionNode.cpp"
    "ProgramNode.cpp"
    "RangeExpressionNode.cpp"
    "ReduceStatementNode.cpp"
    "ReturnStatementNode.cpp"
    "UnaryExpressionNode.cpp"
    "UnitNode.cpp"
    "ValueNode.cpp"
    "VariableDeclarationNode.cpp"
    "WhileStatementNode.cpp"
)
source_group("소스 파일\\AST" FILES ${___AST})

set(___Parser
    "Declaration.cpp"
    "Expression.cpp"
    "parser.cpp"
    "Statement.cpp"
    "Token.cpp"
)
source_group("소스 파일\\Parser" FILES ${___Parser})

set(_
    "all_ast.h"
    "ast.h"
    "codegen.h"
    "context.h"
    "LatexMathEqParser.h"
    "lexer.h"
    "mangling.h"
    "module_loader.h"
    "parser.h"
    "symbol.h"
    "symbol_table.h"
    "token.h"
    "type.h"
    "type_checker.h"
    "type_utils.h"
    "utils.h"
)
source_group("헤더 파일" FILES ${_})

set(___AST
    "AccessFieldNode.h"
    "ArrayAccessNode.h"
    "ArrayCreationExpressionNode.h"
    "ArrayCreationNode.h"
    "ArrayLiteralNode.h"
    "AssignmentExpressionNode.h"
    "AssignmentNode.h"
    "ASTVisitor.h"
    "AttributeNode.h"
    "BinaryExpressionNode.h"
    "BlockNode.h"
    "CallExpressionNode.h"
    "CastingExpressionNode.h"
    "ClassBodyNode.h"
    "ClassDeclarationNode.h"
    "ClassInstanceCreationNode.h"
    "ExpressionNode.h"
    "FilterStatementNode.h"
    "ForStatementNode.h"
    "FunctionCallNode.h"
    "FunctionDeclarationNode.h"
    "IdentifierNode.h"
    "IfStatementNode.h"
    "ImportNode.h"
    "LambdaExpressionNode.h"
    "MapStatementNode.h"
    "MatchExpressionNode.h"
    "MethodCallNode.h"
    "ObjectDeclarationNode.h"
    "ParameterNode.h"
    "PMapStatementNode.h"
    "PostfixExpressionNode.h"
    "PrefixExpressionNode.h"
    "ProgramNode.h"
    "RangeExpressionNode.h"
    "ReduceStatementNode.h"
    "ReturnStatementNode.h"
    "UnaryExpressionNode.h"
    "UnitNode.h"
    "ValueNode.h"
    "VariableDeclarationNode.h"
    "WhileStatementNode.h"
)
source_group("헤더 파일\\AST" FILES ${___AST})

file(GLOB PROJECT_SOURCES CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp"
)
file(GLOB PROJECT_HEADERS CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/*.h"
)

set(ALL_FILES
    ${PROJECT_SOURCES}
    ${PROJECT_HEADERS}
    ${samples}
    "README.md"
)

################################################################################
# Target
################################################################################
add_executable(${PROJECT_NAME} ${ALL_FILES})

use_props(${PROJECT_NAME} "${CMAKE_CONFIGURATION_TYPES}" "${DEFAULT_CXX_PROPS}")
set(ROOT_NAMESPACE csec)

set_target_properties(${PROJECT_NAME} PROPERTIES
    VS_GLOBAL_KEYWORD "Win32Proj"
)
set_target_properties(${PROJECT_NAME} PROPERTIES
    INTERPROCEDURAL_OPTIMIZATION_RELEASE "TRUE"
)
################################################################################
# MSVC runtime library
################################################################################
get_property(MSVC_RUNTIME_LIBRARY_DEFAULT TARGET ${PROJECT_NAME} PROPERTY MSVC_RUNTIME_LIBRARY)
string(CONCAT "MSVC_RUNTIME_LIBRARY_STR"
    $<$<CONFIG:Debug>:
        MultiThreadedDebugDLL
    >
    $<$<CONFIG:Release>:
        MultiThreaded
    >
    $<$<NOT:$<OR:$<CONFIG:Debug>,$<CONFIG:Release>>>:${MSVC_RUNTIME_LIBRARY_DEFAULT}>
)
set_target_properties(${PROJECT_NAME} PROPERTIES MSVC_RUNTIME_LIBRARY ${MSVC_RUNTIME_LIBRARY_STR})

################################################################################
# Include directories
################################################################################
target_include_directories(${PROJECT_NAME} PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/../llvm-project/build/include;"
    "${CMAKE_CURRENT_SOURCE_DIR}/../llvm-project/llvm/include"
)

################################################################################
# Compile definitions
################################################################################
if("${CMAKE_VS_PLATFORM_NAME}" STREQUAL "x64")
    target_compile_definitions(${PROJECT_NAME} PRIVATE
        "$<$<CONFIG:Debug>:"
            "_DEBUG"
        ">"
        "$<$<CONFIG:Release>:"
            "NDEBUG"
        ">"
        "_CONSOLE;"
        "UNICODE;"
        "_UNICODE"
    )
elseif("${CMAKE_VS_PLATFORM_NAME}" STREQUAL "x86")
    target_compile_definitions(${PROJECT_NAME} PRIVATE
        "$<$<CONFIG:Debug>:"
            "_DEBUG"
        ">"
        "$<$<CONFIG:Release>:"
            "NDEBUG"
        ">"
        "WIN32;"
        "_CONSOLE;"
        "UNICODE;"
        "_UNICODE"
    )
endif()

################################################################################
# Compile and link options
################################################################################
if(MSVC)
    target_compile_options(${PROJECT_NAME} PRIVATE
        $<$<CONFIG:Debug>:
            /TP
        >
        $<$<CONFIG:Release>:
            /Oi;
            /Gy
        >
        /permissive-;
        /std:c++17;
        /utf-8;
        /sdl-;
        /W3;
        ${DEFAULT_CXX_DEBUG_INFORMATION_FORMAT};
        ${DEFAULT_CXX_EXCEPTION_HANDLING}
    )
   
    target_link_options(${PROJECT_NAME} PRIVATE
        $<$<CONFIG:Release>:
            /OPT:REF;
            /OPT:ICF
        >
        /DEBUG;
        /SUBSYSTEM:CONSOLE
    )
endif()

################################################################################
# Dependencies
################################################################################
set(ADDITIONAL_LIBRARY_DEPENDENCIES
    "$<$<CONFIG:Debug>:"
        "z"
    ">"
    "ntdll;"
    "LLVM-C;"
    "LLVMAggressiveInstCombine;"
    "LLVMAnalysis;"
    "LLVMAsmParser;"
    "LLVMAsmPrinter;"
    "LLVMBinaryFormat;"
    "LLVMBitReader;"
    "LLVMBitWriter;"
    "LLVMBitstreamReader;"
    "LLVMCFGuard;"
    "LLVMCFIVerify;"
    "LLVMCGData;"
    "LLVMCodeGen;"
    "LLVMCodeGenTypes;"
    "LLVMCore;"
    "LLVMCoroutines;"
    "LLVMCoverage;"
    "LLVMDWARFLinker;"
    "LLVMDWARFLinkerClassic;"
    "LLVMDWARFLinkerParallel;"
    "LLVMDWP;"
    "LLVMDebugInfoBTF;"
    "LLVMDebugInfoCodeView;"
    "LLVMDebugInfoDWARF;"
    "LLVMDebugInfoGSYM;"
    "LLVMDebugInfoLogicalView;"
    "LLVMDebugInfoMSF;"
    "LLVMDebugInfoPDB;"
    "LLVMDebuginfod;"
    "LLVMDemangle;"
    "LLVMDiff;"
    "LLVMDlltoolDriver;"
    "LLVMExecutionEngine;"
    "LLVMExegesis;"
    "LLVMExegesisX86;"
    "LLVMExtensions;"
    "LLVMFileCheck;"
    "LLVMFrontendDriver;"
    "LLVMFrontendHLSL;"
    "LLVMFrontendOffloading;"
    "LLVMFrontendOpenACC;"
    "LLVMFrontendOpenMP;"
    "LLVMFuzzMutate;"
    "LLVMFuzzerCLI;"
    "LLVMGlobalISel;"
    "LLVMHipStdPar;"
    "LLVMIRPrinter;"
    "LLVMIRReader;"
    "LLVMInstCombine;"
    "LLVMInstrumentation;"
    "LLVMInterfaceStub;"
    "LLVMInterpreter;"
    "LLVMJITLink;"
    "LLVMLTO;"
    "LLVMLibDriver;"
    "LLVMLineEditor;"
    "LLVMLinker;"
    "LLVMMC;"
    "LLVMMCA;"
    "LLVMMCDisassembler;"
    "LLVMMCJIT;"
    "LLVMMCParser;"
    "LLVMMIRParser;"
    "LLVMObjCARCOpts;"
    "LLVMObjCopy;"
    "LLVMObject;"
    "LLVMObjectYAML;"
    "LLVMOptDriver;"
    "LLVMOption;"
    "LLVMOrcDebugging;"
    "LLVMOrcJIT;"
    "LLVMOrcShared;"
    "LLVMOrcTargetProcess;"
    "LLVMPasses;"
    "LLVMProfileData;"
    "LLVMRemarks;"
    "LLVMRuntimeDyld;"
    "LLVMSandboxIR;"
    "LLVMScalarOpts;"
    "LLVMSelectionDAG;"
    "LLVMSupport;"
    "LLVMSymbolize;"
    "LLVMTableGen;"
    "LLVMTableGenBasic;"
    "LLVMTableGenCommon;"
    "LLVMTarget;"
    "LLVMTargetParser;"
    "LLVMTextAPI;"
    "LLVMTextAPIBinaryReader;"
    "LLVMTransformUtils;"
    "LLVMVectorize;"
    "LLVMWindowsDriver;"
    "LLVMWindowsManifest;"
    "LLVMX86AsmParser;"
    "LLVMX86CodeGen;"
    "LLVMX86Desc;"
    "LLVMX86Disassembler;"
    "LLVMX86Info;"
    "LLVMX86TargetMCA;"
    "LLVMXRay;"
    "LLVMipo"
)
target_link_libraries(${PROJECT_NAME} PRIVATE "${ADDITIONAL_LIBRARY_DEPENDENCIES}")

target_link_directories(${PROJECT_NAME} PRIVATE
    "C:/Users/USER/Projects/llvm-project/build/lib"
)
