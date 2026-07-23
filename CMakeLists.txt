cmake_minimum_required(VERSION 3.16.0 FATAL_ERROR)

if(WIN32)
    set(CMAKE_SYSTEM_VERSION 10.0 CACHE STRING "" FORCE)
endif()

project(csec++ CXX)

################################################################################
# Set target arch type if empty. Visual studio solution generator provides it.
################################################################################
if(MSVC AND NOT CMAKE_VS_PLATFORM_NAME)
    set(CMAKE_VS_PLATFORM_NAME "x64")
endif()
if(CMAKE_VS_PLATFORM_NAME)
    message("${CMAKE_VS_PLATFORM_NAME} architecture in use")
endif()

if(MSVC AND NOT ("${CMAKE_VS_PLATFORM_NAME}" STREQUAL "x64"
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
source_group("由ъ냼???뚯씪" FILES ${_})

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
source_group("?뚯뒪 ?뚯씪" FILES ${_})

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
source_group("?뚯뒪 ?뚯씪\\AST" FILES ${___AST})

set(___Parser
    "Declaration.cpp"
    "Expression.cpp"
    "parser.cpp"
    "Statement.cpp"
    "Token.cpp"
)
source_group("?뚯뒪 ?뚯씪\\Parser" FILES ${___Parser})

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
source_group("?ㅻ뜑 ?뚯씪" FILES ${_})

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
source_group("?ㅻ뜑 ?뚯씪\\AST" FILES ${___AST})

file(GLOB PROJECT_SOURCES CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp"
)
list(REMOVE_ITEM PROJECT_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/NativeRuntime.cpp")
file(GLOB PROJECT_HEADERS CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/src/*.h"
)
file(GLOB NATIVE_RUNTIME_MODULES CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/src/native_runtime/*.inc"
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
target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_17)

add_library(csec_native_runtime SHARED
    "src/NativeRuntime.cpp"
    "src/NativeRuntime.h"
    ${NATIVE_RUNTIME_MODULES}
)
source_group("Native Runtime" FILES ${NATIVE_RUNTIME_MODULES})
target_compile_features(csec_native_runtime PRIVATE cxx_std_17)
target_compile_definitions(csec_native_runtime PRIVATE CSEC_NATIVE_RUNTIME_BUILD)
find_package(Threads REQUIRED)
find_package(OpenMP QUIET)
if(OpenMP_CXX_FOUND)
    target_link_libraries(csec_native_runtime PRIVATE OpenMP::OpenMP_CXX)
endif()
if(WIN32)
    target_compile_definitions(csec_native_runtime PRIVATE
        _CRT_SECURE_NO_WARNINGS
        _WINSOCK_DEPRECATED_NO_WARNINGS
    )
    if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        target_compile_definitions(csec_native_runtime PRIVATE _ALLOW_COMPILER_AND_STL_VERSION_MISMATCH)
    endif()
endif()
set_target_properties(csec_native_runtime PROPERTIES
    OUTPUT_NAME "System.Native"
    CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN YES
)
if(WIN32)
    target_link_libraries(csec_native_runtime PRIVATE ws2_32)
else()
    target_link_libraries(csec_native_runtime PRIVATE Threads::Threads ${CMAKE_DL_LIBS})
endif()
add_dependencies(${PROJECT_NAME} csec_native_runtime)
target_link_libraries(${PROJECT_NAME} PRIVATE csec_native_runtime Threads::Threads)
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        $<TARGET_FILE:csec_native_runtime>
        $<TARGET_FILE_DIR:${PROJECT_NAME}>
)
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        $<TARGET_FILE:csec_native_runtime>
        "$<TARGET_FILE_DIR:${PROJECT_NAME}>/csec_native_runtime${CMAKE_SHARED_LIBRARY_SUFFIX}"
)
if(WIN32)
    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            $<TARGET_LINKER_FILE:csec_native_runtime>
            $<TARGET_FILE_DIR:${PROJECT_NAME}>
    )
endif()
if(WIN32 AND CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    target_compile_definitions(${PROJECT_NAME} PRIVATE _ALLOW_COMPILER_AND_STL_VERSION_MISMATCH)
endif()

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
find_package(LLVM CONFIG QUIET
    PATHS "${CMAKE_CURRENT_SOURCE_DIR}/../llvm-project/build/lib/cmake/llvm"
    NO_DEFAULT_PATH
)
if(NOT LLVM_FOUND)
    find_package(LLVM CONFIG REQUIRED)
endif()

target_include_directories(${PROJECT_NAME} PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/src"
    ${LLVM_INCLUDE_DIRS}
)

################################################################################
# Compile definitions
################################################################################
if(MSVC AND "${CMAKE_VS_PLATFORM_NAME}" STREQUAL "x64")
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
elseif(MSVC AND "${CMAKE_VS_PLATFORM_NAME}" STREQUAL "x86")
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
llvm_map_components_to_libnames(LLVM_COMPONENT_LIBS
    AggressiveInstCombine
    Analysis
    AsmParser
    AsmPrinter
    BinaryFormat
    BitReader
    BitWriter
    CodeGen
    Core
    ExecutionEngine
    InstCombine
    Interpreter
    IPO
    IRPrinter
    IRReader
    JITLink
    Linker
    MC
    MCJIT
    MCParser
    Object
    OrcJIT
    Passes
    RuntimeDyld
    ScalarOpts
    Support
    Target
    TargetParser
    TransformUtils
    Vectorize
    X86
)

find_library(LLVM_C_LIBRARY
    NAMES LLVM-C
    PATHS ${LLVM_LIBRARY_DIRS}
    NO_DEFAULT_PATH
)
if(NOT LLVM_C_LIBRARY)
    set(LLVM_C_LIBRARY "")
endif()

target_link_libraries(${PROJECT_NAME} PRIVATE
    ${LLVM_C_LIBRARY}
    ${LLVM_COMPONENT_LIBS}
)
if(WIN32)
    find_library(CSEC_ZLIB_DEBUG_LIBRARY
        NAMES zlibd z
        PATHS
            "${CMAKE_CURRENT_SOURCE_DIR}/vcpkg_installed/x64-windows/debug/lib"
            "${CMAKE_CURRENT_SOURCE_DIR}/vcpkg_installed/vcpkg/blds/zlib/x64-windows-dbg"
        NO_DEFAULT_PATH
    )
    find_library(CSEC_ZLIB_RELEASE_LIBRARY
        NAMES zlib z
        PATHS
            "${CMAKE_CURRENT_SOURCE_DIR}/vcpkg_installed/x64-windows/lib"
            "${CMAKE_CURRENT_SOURCE_DIR}/vcpkg_installed/vcpkg/blds/zlib/x64-windows-rel"
        NO_DEFAULT_PATH
    )
    target_link_libraries(${PROJECT_NAME} PRIVATE
        "$<$<CONFIG:Debug>:${CSEC_ZLIB_DEBUG_LIBRARY}>"
        "$<$<CONFIG:Release>:${CSEC_ZLIB_RELEASE_LIBRARY}>"
        ntdll
    )
endif()

if(WIN32 AND LLVM_LIBRARY_DIRS)
    target_link_directories(${PROJECT_NAME} PRIVATE
        ${LLVM_LIBRARY_DIRS}
    )
endif()
