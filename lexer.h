// lexer.h
#pragma once

#include "token.h"
#include <string>
#include <vector>
#include <unordered_set>

class Lexer {
public:
    Lexer(const std::string& source);
    std::vector<Token> tokenize();

private:
    std::string source;
    size_t position;
    int line;
    int column;
    std::unordered_set<std::string> keywords;
    std::unordered_set<std::string> operators;

    void initializeKeywords();
    void initializeOperators();

    void advance(int steps = 1);
    char peek(int offset = 0) const;

    bool matchComment(std::vector<Token>& tokens);
    bool matchWhitespace(std::vector<Token>& tokens);
    bool matchNewline(std::vector<Token>& tokens);
    bool matchStringLiteral(std::vector<Token>& tokens);
    bool matchCharLiteral(std::vector<Token>& tokens);
    bool matchNumberLiteral(std::vector<Token>& tokens);
    bool matchIdentifierOrKeyword(std::vector<Token>& tokens);
    bool matchOperator(std::vector<Token>& tokens);
};
