// ast.cpp
#include "token.h"
#include "ast.h"
#include "codegen.h"
#include "utils.h"

#include <iostream>


CodeGenerator* ASTNode::codeGenerator = nullptr;