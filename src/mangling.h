#pragma once

#include "ast.h"

#include "ClassDeclarationNode.h"
#include "ObjectDeclarationNode.h"
#include "FunctionDeclarationNode.h"
#include "ParameterNode.h"

#include <string>
#include <unordered_map>

enum class CppMangleStyle {
    Itanium,
    MSVC
};

std::string mangleCppSignature(const std::string& signature, CppMangleStyle style);
std::string mangleItaniumSignature(const std::string& signature);
std::string mangleMSVCSignature(const std::string& signature);

std::unordered_map<std::string, std::string> mangle(ClassDeclarationNode &node);
std::string mangle(ObjectDeclarationNode &node);
std::string mangle(FunctionDeclarationNode &node);
std::string mangle(ParameterNode &node);
