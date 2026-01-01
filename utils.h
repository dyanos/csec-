#pragma once

#include <vector>
#include <string>
#include <sstream>
#include <llvm/IR/Value.h>
#include "codegen.h"

inline static bool exist_file(const std::string& name);
std::string read_file(const std::string& path);

template<class...T>
std::string join(const std::string& sep, T&&...strings);

std::string join(std::vector<std::string> vec, std::string const& separator);

bool isPrimitiveType(const std::string& type);

template<typename T>
std::string checkTypeName(T x) {
    return typeid(decltype(x)).name();
}

std::vector<std::string> split(const std::string& str, char delimiter);

// 문자열 타입인지 확인하는 헬퍼 함수
inline bool isStringTypeFromLLVM(llvm::Value* value, CodeGenerator* codeGenerator);