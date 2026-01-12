// lexer.cpp
#include "lexer.h"
#include <cctype>

Lexer::Lexer(const std::string& source)
    : source(source), position(0), line(1), column(1) {
    initializeKeywords();
    initializeOperators();
}

void Lexer::initializeKeywords() {
    std::string kws[] = {
        "abstract", "case", "catch", "class", "def", "do", "else", "extends",
        "false", "final", "finally", "for", "forSome", "if", "implicit",
        "import", "lazy", "match", "new", "null", "object", "override",
        "package", "private", "protected", "return", "sealed", "super",
        "this", "throw", "trait", "try", "true", "type", "val", "var",
        "while", "with", "yield", "to", "val", "var", "map", "pmap", "reduce", "filter"
    };
    keywords.insert(kws, kws + sizeof(kws) / sizeof(kws[0]));
}

void Lexer::initializeOperators() {
    std::string ops[] = {
		"=", "+", "-", "*", "/", "%", "$", "$$", "\\", "<", ">", "!", "&", "|", "^", "~", ":", ".", ",", ";", "(", ")", "{", "}", "[", "]", "[@", "<-", "_", "=>", "<:", "<%", ">:", "#", "@"
    };
    operators.insert(ops, ops + sizeof(ops) / sizeof(ops[0]));
}

std::vector<Token> Lexer::tokenize() {
    std::vector<Token> tokens;

    while (position < source.length()) {
        if (matchComment(tokens)) continue;
        if (matchWhitespace(tokens)) continue;
        if (matchNewline(tokens)) continue;
        if (matchStringLiteral(tokens)) continue;
        if (matchCharLiteral(tokens)) continue;
        if (matchNumberLiteral(tokens)) continue;
        if (matchIdentifierOrKeyword(tokens)) continue;
        if (matchOperator(tokens)) continue;

        // �� �� ���� ���� ó��
        tokens.push_back(Token{ TokenType::UNKNOWN, std::string(1, source[position]), line, column });
        advance();
    }

    return tokens;
}

// ���� �� ��Ī �Լ����� ���� (���� �ڵ�� ����)
void Lexer::advance(int steps) {
    for (int i = 0; i < steps; ++i) {
        if (source[position] == '\n') {
            ++line;
            column = 1;
        }
        else {
            ++column;
        }
        ++position;
    }
}

char Lexer::peek(int offset) const {
    if (position + offset < source.length()) {
        return source[position + offset];
    }
    else {
        return '\0';
    }
}

bool Lexer::matchComment(std::vector<Token>& tokens) {
    if (peek() == '/' && peek(1) == '/') {
        size_t start = position;
        while (peek() != '\n' && peek() != '\0') {
            advance();
        }
        std::string comment = source.substr(start, position - start);
        tokens.push_back(Token{ TokenType::COMMENT, comment, line, column });
        return true;
    }
    else if (peek() == '/' && peek(1) == '*') {
        size_t start = position;
        advance(2);
        while (!(peek() == '*' && peek(1) == '/')) {
            if (peek() == '\0') {
                break;
            }
            advance();
        }
        advance(2);  // '*/' ��ŵ
        std::string comment = source.substr(start, position - start);
        tokens.push_back(Token{ TokenType::COMMENT, comment, line, column });
        return true;
    }
    return false;
}

bool Lexer::matchWhitespace(std::vector<Token>& tokens) {
    if (std::isspace(peek()) && peek() != '\n') {
        //size_t start = position;
        while (std::isspace(peek()) && peek() != '\n') {
            advance();
        }
        //std::string whitespace = source.substr(start, position - start);
        //tokens.push_back(Token{ TokenType::WHITESPACE, whitespace, line, column });
        return true;
    }
    return false;
}

bool Lexer::matchNewline(std::vector<Token>& tokens) {
    if (peek() == '\n') {
        while (peek() == '\n') {
            advance();
        }
        //tokens.push_back(Token{ TokenType::NEWLINE, "\n", line, column });
        //advance();
        return true;
    }
    return false;
}

bool Lexer::matchStringLiteral(std::vector<Token>& tokens) {
    if (peek() == '"') {
        size_t start = position;
        advance();
        while (peek() != '"' && peek() != '\0') {
            if (peek() == '\\') {
                advance(2);  // �̽������� ���� ��ŵ
            }
            else {
                advance();
            }
        }
        advance();  // �ݴ� ����ǥ ��ŵ
        std::string strLiteral = source.substr(start, position - start);
        tokens.push_back(Token{ TokenType::STRING_LITERAL, strLiteral, line, column });
        return true;
    }
    return false;
}

bool Lexer::matchCharLiteral(std::vector<Token>& tokens) {
    if (peek() == '\'') {
        size_t start = position;
        advance();
        if (peek() == '\\') {
            advance(2);  // �̽������� ����
        }
        else {
            advance();
        }
        if (peek() == '\'') {
            advance();
            std::string charLiteral = source.substr(start, position - start);
            tokens.push_back(Token{ TokenType::CHAR_LITERAL, charLiteral, line, column });
            return true;
        }
        // ���� ���� ó��
    }
    return false;
}

bool Lexer::matchNumberLiteral(std::vector<Token>& tokens) {
    if (std::isdigit(peek())) {
        size_t start = position;
        while (std::isdigit(peek())) {
            advance();
        }
        // ���� �� 16����, 2����, 8���� ���ͷ� ó��
		if (peek() == 'e' || peek() == 'E') {
			advance();
			if (peek() == '+' || peek() == '-') {
				advance();
			}
			while (std::isdigit(peek())) {
				advance();
			}

            std::string value = source.substr(start, position - start);
			tokens.push_back(Token{ TokenType::EXPONENTIAL_LITERAL, value, line, column });
		}
		else if (peek() == 'x' || peek() == 'X') {
			advance();
			while (std::isxdigit(peek())) {
				advance();
			}

			std::string value = source.substr(start, position - start);
			tokens.push_back(Token{ TokenType::HEX_LITERAL, value, line, column });
		}
		else if (peek() == 'b' || peek() == 'B') {
			advance();
			while (peek() == '0' || peek() == '1') {
				advance();
			}

            std::string value = source.substr(start, position - start);
            tokens.push_back(Token{ TokenType::BINARY_LITERAL, value, line, column });
		}
		else if (peek() == 'o' || peek() == 'O') {
			advance();
			while (std::isdigit(peek()) && peek() < '8') {
				advance();
			}

            std::string value = source.substr(start, position - start);
            tokens.push_back(Token{ TokenType::OCTAL_LITERAL, value, line, column });
		}
        else if (peek() == '.') {
            advance();
            while (std::isdigit(peek())) {
                advance();
            }
            std::string floatLiteral = source.substr(start, position - start);
            tokens.push_back(Token{ TokenType::FLOAT_LITERAL, floatLiteral, line, column });
        }
        else {
            std::string intLiteral = source.substr(start, position - start);
            tokens.push_back(Token{ TokenType::INTEGER_LITERAL, intLiteral, line, column });
        }
        return true;
    }
    return false;
}

bool Lexer::matchIdentifierOrKeyword(std::vector<Token>& tokens) {
    if (std::isalpha(peek()) || peek() == '_') {
        size_t start = position;
        while (std::isalnum(peek()) || peek() == '_') {
            advance();
        }
        std::string identifier = source.substr(start, position - start);
        if (keywords.find(identifier) != keywords.end()) {
            if (identifier == "true" || identifier == "false") {
                tokens.push_back(Token{ TokenType::BOOLEAN_LITERAL, identifier, line, column });
            }
            else {
                tokens.push_back(Token{ TokenType::KEYWORD, identifier, line, column });
            }
        }
        else {
            tokens.push_back(Token{ TokenType::IDENTIFIER, identifier, line, column });
        }
        return true;
    }
    return false;
}

bool Lexer::matchOperator(std::vector<Token>& tokens) {
    // ���� ���� ������ ó��
    std::string op = "";
    size_t maxOpLength = 2;  // �ִ� ������ ���� ����
    for (size_t len = maxOpLength; len > 0; --len) {
        op = source.substr(position, len);
        if (operators.find(op) != operators.end()) {
            tokens.push_back(Token{ TokenType::OPERATOR, op, line, column });
            advance(len);
            return true;
        }
    }
    return false;
}