#pragma once

#include "ast.h"

class Mangling {
public:
    std::string mangle(ASTNode& node);

private:
	std::string visit(ClassDeclarationNode& node);
	std::string visit(ObjectDeclarationNode& node);
	std::string visit(FunctionDeclarationNode& node);
	std::string visit(ParameterNode& node);

};
