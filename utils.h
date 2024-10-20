#pragma once

#include <vector>

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

