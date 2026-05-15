#include "parser.h"

#include <iostream>

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
	return tokens[position - 1];
}

bool Parser::check(TokenType type, const std::string& value) const {
	if (isAtEnd()) return false;
	if (tokens[position].type != type) return false;
	if (!value.empty() && tokens[position].value != value) return false;
	return true;
}

bool Parser::match(TokenType type, const std::string& value) {
	while (tokens[position].type == TokenType::COMMENT) {
		advance();
	}

	if (check(type, value)) {
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

void Parser::expect(TokenType type, const std::string& value) {
	if (!check(type, value)) {
		std::string expected = value.empty() ? tokenTypeToString(type) : "'" + value + "'";
		std::string found = isAtEnd() ? "end of input" : "'" + peek().value + "'";
		error("Expected " + expected + ", but found " + found);
	}
	advance();
}

void Parser::error(const std::string& message) {
	std::cerr << "Parser Error: " << message;
	if (!isAtEnd()) {
		std::cerr << " at line " << peek().line << ", column " << peek().column;
	}
	std::cerr << std::endl;
	exit(1);
}

std::string Parser::tokenTypeToString(TokenType type) const {
	switch (type) {
	case TokenType::KEYWORD: return "keyword";
	case TokenType::IDENTIFIER: return "identifier";
	case TokenType::OPERATOR: return "operator";
	default: return "token";
	}
}