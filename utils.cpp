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
	// TODO: read file
	std::ifstream file(path.c_str());
	if (file.is_open()) {
		std::string content;
		std::string line;
		while (std::getline(file, line)) {
			content += line;
		}
		file.close();
		return content;
	}

	return std::string();
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
	std::vector<std::string> primitiveTypes = { "byte", "char", "word", "short", "int", "float", "double", "string" };
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

