#include "parser.h"

#include <iostream>
#include <sstream>
#include <stdexcept>

bool Parser::isAtEnd() const {
	return position >= tokens.size() || tokens[position].type == TokenType::END_OF_FILE;
}

const Token& Parser::peek(int pos) const {
	if (pos < 0)
		return tokens[position];
	else if (position + pos < tokens.size())
		return tokens[position + pos];
	else {
		// END_OF_FILE
		return tokens[tokens.size() - 1];
	}
}

const Token& Parser::advance() {
	if (!isAtEnd()) position++;
	return previous();
}

const Token& Parser::previous() const {
	if (position == 0) return tokens[0];
	return tokens[position - 1];
}

bool Parser::check(TokenType type, const std::string& value) const {
	if (isAtEnd()) return false;
	if (tokens[position].type != type) return false;
	if (!value.empty() && tokens[position].value != value) return false;
	return true;
}

bool Parser::match(TokenType type, const std::string& value) {
	while (position < tokens.size() && tokens[position].type == TokenType::COMMENT) {
		advance();
	}

	if (check(type, value)) {
		advance();
		return true;
	}
	return false;
}

bool Parser::matchIdentifierName() {
	if (match(TokenType::IDENTIFIER)) {
		return true;
	}
	if (check(TokenType::KEYWORD, "box")) {
		advance();
		return true;
	}
	return false;
}

bool Parser::saveTokenPosition() {
	positionStack.push_back(position);
	return true;
}

void Parser::restoreTokenPosition() {
	if (!positionStack.empty()) {
		position = positionStack.back();
		positionStack.pop_back();
	}
}

void Parser::discardTokenPosition() {
	if (!positionStack.empty()) {
		positionStack.pop_back();
	}
}

void Parser::expect(TokenType type, const std::string& value) {
	if (!check(type, value)) {
		std::string expected = value.empty() ? tokenTypeToString(type) : "'" + value + "'";
		std::string found = isAtEnd() ? "end of input" : "'" + peek().value + "'";
		error("Expected " + expected + ", but found " + found);
	}
	advance();
}

void Parser::error(const std::string& message) {
	std::ostringstream oss;
	oss << "Parser Error: " << message;
	if (!isAtEnd()) {
		oss << " at line " << peek().line << ", column " << peek().column;
	}
	std::cerr << oss.str() << std::endl;
	throw std::runtime_error(oss.str());
}

std::string Parser::tokenTypeToString(TokenType type) const {
	switch (type) {
	case TokenType::KEYWORD: return "keyword";
	case TokenType::IDENTIFIER: return "identifier";
    case TokenType::STRING_LITERAL: return "string literal";
    case TokenType::REGEX_LITERAL: return "regex literal";
	case TokenType::OPERATOR: return "operator";
	default: return "token";
	}
}
