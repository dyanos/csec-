#pragma once

#include "../type.h"
#include "../token.h"
#include "../symbol.h"
#include <memory>
#include <llvm/IR/Value.h>

enum class ASTNodeType {
    PROGRAM, 
    IMPORT, 
    OBJECT_DECLARATION, 
    CLASS_DECLARATION, 
    FUNCTION_DECLARATION, 
    PARAMETER, 
    BLOCK, 
    EXPRESSION, 
    VARIABLE_DECLARATION, 
    CALL_EXPRESSION,
    METHOD_CALL, 
    CLASS_INSTANCE_CREATION, 
    ARRAY_CREATION_EXPRESSION, 
    ASSIGNMENT_EXPRESSION, 
    UNARY_EXPRESSION, 
    CASTING_EXPRESSION, 
    POSTFIX_EXPRESSION, 
    PREFIX_EXPRESSION, 
    FUNCTION_CALL, 
    ARRAY_CREATION, 
    ARRAY_ACCESS, 
    ACCESS_FIELD,
    IF_STATEMENT,
    FOR_STATEMENT,
    MATCH_EXPRESSION,
    RANGE_EXPRESSION,
    BINARY_EXPRESSION,
    RETURN_STATEMENT,
    UNIT,
    IDENTIFIER,
    VALUE,
    ASSIGNMENT,
    CLASS_BODY
};

class ASTVisitor;
class CodeGenerator;

class ASTNode {
public:
    ASTNodeType nodeType;
    static CodeGenerator* codeGenerator;
    std::shared_ptr<Type> type;

    virtual ~ASTNode() = default;
    virtual void accept(ASTVisitor& visitor) = 0;
    virtual llvm::Value* codegen() = 0;
    virtual std::shared_ptr<Type> getType() = 0;
}; 