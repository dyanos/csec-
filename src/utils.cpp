#include <string>
#include <fstream>
#include <sys/stat.h>
#include <iostream>
#include <algorithm>
#include <sstream>
#include <iterator>
#include "utils.h"


inline static bool exist_file(const std::string& name) {
	struct stat buffer;
	return (stat(name.c_str(), &buffer) == 0);
}

std::string read_file(const std::string& path)
{
	return read_utf8_file(path);
}

std::string read_utf8_file(const std::string& path)
{
	std::ifstream file(path, std::ios::in | std::ios::binary);
	if (!file.is_open()) {
		return std::string();
	}

	std::ostringstream contents;
	contents << file.rdbuf();
	std::string text = contents.str();

	// Strip UTF-8 BOM if present so lexer sees the first real token.
	if (text.size() >= 3 &&
		static_cast<unsigned char>(text[0]) == 0xEF &&
		static_cast<unsigned char>(text[1]) == 0xBB &&
		static_cast<unsigned char>(text[2]) == 0xBF) {
		text.erase(0, 3);
	}

	return text;
}

template<class...T>
std::string join(const std::string& sep, T&&...strings) {
	if constexpr (sizeof...(T)) {
		auto t = ((strings + sep) + ...);
		return t.substr(0, t.size() - sep.size());
	}
	else {
		return "";
	}
}

std::string join(std::vector<std::string> vec, const std::string& separator)
{
	std::stringstream result;
	auto it = vec.begin();
	result << *it++;
	for (; it != vec.end(); it++) {
		result << separator;
		result << *it;
	}
	return result.str();
}

bool isPrimitiveType(const std::string& type)
{
	std::vector<std::string> primitiveTypes = {
        "byte", "char", "word", "short", "int", "float", "double", "string",
        "Byte", "Char", "Word", "Short", "Int", "Float", "Double", "String",
        "Boolean", "Bool", "Long", "Natural", "Integer", "Real"
    };
	if (std::find(primitiveTypes.begin(), primitiveTypes.end(), type) != primitiveTypes.end()) {
		return true;
	}
	return false;
}

std::vector<std::string> split(const std::string& str, char delimiter) {
    std::vector<std::string> result;
    std::stringstream ss(str);
    std::string item;

    while (std::getline(ss, item, delimiter)) {
        result.push_back(item);
    }

    return result;
}

inline bool isStringTypeFromLLVM(llvm::Value* value, CodeGenerator* codeGenerator) {
	return value->getType()->isPointerTy() &&
		(static_cast<llvm::PointerType*>(value->getType()))->isValidElementType(
			llvm::Type::getInt8Ty(CodeGenerator::getInstance().context));
}
