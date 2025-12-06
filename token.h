// token.h
#pragma once

#include <string>

enum class TokenType {
    KEYWORD,
    IDENTIFIER,
    INTEGER_LITERAL,
    FLOAT_LITERAL,
	EXPONENTIAL_LITERAL,
	HEX_LITERAL,
	BINARY_LITERAL,
	OCTAL_LITERAL,
    STRING_LITERAL,
    CHAR_LITERAL,
    BOOLEAN_LITERAL,
    OPERATOR,
    COMMENT,
    NEWLINE,
    WHITESPACE,
    UNKNOWN,
    END_OF_FILE  // EOF ÅäÅ«
};

struct Token {
    TokenType type;
    std::string value;
    int line;
    int column;
};
