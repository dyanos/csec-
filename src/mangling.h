#pragma once

#include "ast.h"

#include "ClassDeclarationNode.h"
#include "ObjectDeclarationNode.h"
#include "FunctionDeclarationNode.h"
#include "ParameterNode.h"

std::unordered_map<std::string, std::string> mangle(ClassDeclarationNode &node);
std::string mangle(ObjectDeclarationNode &node);
std::string mangle(FunctionDeclarationNode &node);
std::string mangle(ParameterNode &node);