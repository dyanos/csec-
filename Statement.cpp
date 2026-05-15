#include "parser.h"
#include "all_ast.h"

std::unique_ptr<ASTNode> Parser::parseStatement() {
	if (match(TokenType::KEYWORD, "val") || match(TokenType::KEYWORD, "var")) {
		bool isMutable = previous().value == "var";
		auto expr = parseVariableDeclaration(isMutable);
		match(TokenType::OPERATOR, ";");
		return expr;
	}
	else if (match(TokenType::KEYWORD, "if")) {
		return parseIfStatement();
	}
	else if (match(TokenType::KEYWORD, "for")) {
		return parseForStatement();
	}
	else if (match(TokenType::KEYWORD, "def")) {
		return parseFunctionDeclaration();
	}
	else if (match(TokenType::KEYWORD, "return")) {
		std::unique_ptr<ASTNode> expr = nullptr;
		if (!check(TokenType::END_OF_FILE) && !check(TokenType::OPERATOR, ";")) {
			expr = parseExpression();
		}
		match(TokenType::OPERATOR, ";");
		auto returnNode = std::make_unique<ReturnStatementNode>();
		returnNode->expression = std::move(expr);
		return returnNode;
	}
	else if (match(TokenType::KEYWORD, "while")) {
		return parseWhileStatement();
	}
	else if (match(TokenType::KEYWORD, "map")) {
		return parseMapStatement();
	}
	else if (match(TokenType::KEYWORD, "pmap")) {
		return parsePMapStatement();
	}
	else if (match(TokenType::KEYWORD, "reduce")) {
		return parseReduceStatement();
	}
	else if (match(TokenType::KEYWORD, "filter")) {
		return parseFilterStatement();
	}
	else if (match(TokenType::KEYWORD, "object")) {
		return parseObjectDeclaration();
	}
	else {
		auto expr = parseExpression();
		match(TokenType::OPERATOR, ";");
		return expr;
	}
}

std::unique_ptr<BlockNode> Parser::parseBlock() {
	auto block = std::make_unique<BlockNode>();
	while (!match(TokenType::OPERATOR, "}")) {
		if (isAtEnd()) {
			error("Unterminated block");
			return nullptr;
		}
		auto stmt = parseStatement();
		if (stmt) {
			block->statements.push_back(std::move(stmt));
		}
	}
	return block;
}

std::unique_ptr<ASTNode> Parser::parseIfStatement() {
	auto ifNode = std::make_unique<IfStatementNode>();

	expect(TokenType::OPERATOR, "(");
	ifNode->condition = parseExpression();
	expect(TokenType::OPERATOR, ")");

	if (match(TokenType::OPERATOR, "{")) {
		ifNode->thenBlock = parseBlock();
	}
	else {
		error("Expected '{' after 'if' condition");
	}

	if (match(TokenType::KEYWORD, "else")) {
		if (match(TokenType::OPERATOR, "{")) {
			ifNode->elseBlock = parseBlock();
		}
		else {
			error("Expected '{' after 'else'");
		}
	}

	return ifNode;
}

std::unique_ptr<ASTNode> Parser::parseForStatement() {
	auto forNode = std::make_unique<ForStatementNode>();

	expect(TokenType::OPERATOR, "(");

	if (match(TokenType::IDENTIFIER)) {
		forNode->variable = previous().value;

		if (match(TokenType::OPERATOR, "<-")) {
			auto startExpr = parseExpression();

			if (match(TokenType::KEYWORD, "to") || match(TokenType::KEYWORD, "until")) {
				forNode->isRange = true;
				forNode->isInclusive = previous().value == "to";

				auto endExpr = parseExpression();

				auto rangeExpr = std::make_unique<RangeExpressionNode>();
				rangeExpr->startExpr = std::move(startExpr);
				rangeExpr->endExpr = std::move(endExpr);
				rangeExpr->isInclusive = forNode->isInclusive;

				forNode->iterableExpr = std::move(rangeExpr);
			}
			else {
				forNode->iterableExpr = std::move(startExpr);
			}
		}
		else {
			error("Expected '<-' in for comprehension");
		}
	}
	else {
		error("Expected identifier in for comprehension");
	}

	expect(TokenType::OPERATOR, ")");

	if (match(TokenType::OPERATOR, "{")) {
		forNode->body = parseBlock();
	}
	else {
		error("Expected '{' after 'for' comprehension");
	}

	return forNode;
}

std::unique_ptr<ASTNode> Parser::parseWhileStatement() {
	auto whileNode = std::make_unique<WhileStatementNode>();

	expect(TokenType::OPERATOR, "(");
	whileNode->condition = parseExpression();
	expect(TokenType::OPERATOR, ")");

	if (match(TokenType::OPERATOR, "{")) {
		whileNode->body = parseBlock();
	}
	else {
		error("Expected '{' after 'while' condition");
	}

	return whileNode;
}

std::unique_ptr<ASTNode> Parser::parseMapStatement() {
	auto mapNode = std::make_unique<MapStatementNode>();

	expect(TokenType::OPERATOR, "(");

	if (match(TokenType::IDENTIFIER)) {
		mapNode->variable = previous().value;

		if (match(TokenType::OPERATOR, "<-")) {
			mapNode->iterableExpr = parseExpression();
		}
		else {
			error("Expected '<-' in map statement");
		}
	}
	else {
		error("Expected identifier in map statement");
	}

	expect(TokenType::OPERATOR, ")");

	if (match(TokenType::OPERATOR, "{")) {
		mapNode->body = parseBlock();
	}
	else {
		error("Expected '{' after 'map' statement");
	}

	return mapNode;
}

std::unique_ptr<ASTNode> Parser::parsePMapStatement() {
	auto pmapNode = std::make_unique<PMapStatementNode>();

	expect(TokenType::OPERATOR, "(");

	if (match(TokenType::IDENTIFIER)) {
		pmapNode->variable = previous().value;

		if (match(TokenType::OPERATOR, "<-")) {
			pmapNode->iterableExpr = parseExpression();
		}
		else {
			error("Expected '<-' in pmap statement");
		}
	}
	else {
		error("Expected identifier in pmap statement");
	}

	expect(TokenType::OPERATOR, ")");

	if (match(TokenType::OPERATOR, "{")) {
		pmapNode->body = parseBlock();
	}
	else {
		error("Expected '{' after 'pmap' statement");
	}

	return pmapNode;
}

std::unique_ptr<ASTNode> Parser::parseReduceStatement() {
	auto reduceNode = std::make_unique<ReduceStatementNode>();

	expect(TokenType::OPERATOR, "(");

	if (match(TokenType::IDENTIFIER)) {
		reduceNode->variable = previous().value;

		if (match(TokenType::OPERATOR, "<-")) {
			reduceNode->iterableExpr = parseExpression();
		}
		else {
			error("Expected '<-' in reduce statement");
		}
	}
	else {
		error("Expected identifier in reduce statement");
	}

	expect(TokenType::OPERATOR, ")");

	if (match(TokenType::OPERATOR, "{")) {
		reduceNode->body = parseBlock();
	}
	else {
		error("Expected '{' after 'reduce' statement");
	}

	return reduceNode;
}

std::unique_ptr<ASTNode> Parser::parseFilterStatement() {
	auto filterNode = std::make_unique<FilterStatementNode>();

	expect(TokenType::OPERATOR, "(");

	if (match(TokenType::IDENTIFIER)) {
		filterNode->variable = previous().value;

		if (match(TokenType::OPERATOR, "<-")) {
			filterNode->iterableExpr = parseExpression();
		}
		else {
			error("Expected '<-' in filter statement");
		}
	}
	else {
		error("Expected identifier in filter statement");
	}

	expect(TokenType::OPERATOR, ")");

	if (match(TokenType::OPERATOR, "{")) {
		filterNode->body = parseBlock();
	}
	else {
		error("Expected '{' after 'filter' statement");
	}

	return filterNode;
}