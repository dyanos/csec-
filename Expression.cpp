#include "parser.h"

#include "all_ast.h"
#include "utils.h"

std::unique_ptr<ASTNode> Parser::parseSimpleExpression() {
	std::unique_ptr<ASTNode> expr;

	if (match(TokenType::IDENTIFIER)) {
		std::vector<std::string> pathComponents;
		pathComponents.push_back(previous().value);
		while (match(TokenType::OPERATOR, ".")) {
			if (match(TokenType::IDENTIFIER)) {
				pathComponents.push_back(previous().value);
			}
			else {
				error("Expected identifier after '.'");
				return nullptr;
			}
		}

		if (match(TokenType::OPERATOR, "(")) {
			if (pathComponents.size() == 1) {
				auto callNode = std::make_unique<FunctionCallNode>();
				callNode->functionName = pathComponents[0];
				callNode->arguments = parseCallParameterList();
				return callNode;
			}
			else {
				auto callNode = std::make_unique<MethodCallNode>();

				std::vector<std::string> result;
				std::copy(pathComponents.begin(), pathComponents.end() - 1, std::back_inserter(result));

				callNode->object = std::make_unique<IdentifierNode>(join(result, "."));
				callNode->methodName = pathComponents.back();
				callNode->arguments = parseCallParameterList();

				return callNode;
			}
		}
		else if (match(TokenType::OPERATOR, "=") || match(TokenType::OPERATOR, "<-")) {
			auto assignNode = std::make_unique<AssignmentExpressionNode>();
			assignNode->left = std::make_unique<IdentifierNode>(join(pathComponents, "."));
			assignNode->right = parseExpression();
			return assignNode;
		}

		return std::make_unique<IdentifierNode>(join(pathComponents, "."));
	}
	else if (match(TokenType::INTEGER_LITERAL) ||
		match(TokenType::FLOAT_LITERAL) ||
		match(TokenType::EXPONENTIAL_LITERAL) ||
		match(TokenType::HEX_LITERAL) ||
		match(TokenType::BINARY_LITERAL) ||
		match(TokenType::OCTAL_LITERAL) ||
		match(TokenType::STRING_LITERAL) ||
		match(TokenType::BOOLEAN_LITERAL)) {
		return std::make_unique<ValueNode>(previous().value, previous().type);
	}
	else if (match(TokenType::OPERATOR, "$")) {
		expr = parseInlineMathLatex();
		match(TokenType::OPERATOR, "$");
		return expr;
	}
	else if (match(TokenType::OPERATOR, "$$")) {
		expr = parseBlockMathLatex();
		match(TokenType::OPERATOR, "$$");
		return expr;
	}
	else if (match(TokenType::OPERATOR, "_")) {
		return std::make_unique<UnitNode>();
	}
	else if (match(TokenType::OPERATOR, "{")) {
		return parseBlock();
	}
	else if (check(TokenType::OPERATOR, "[")) {
		saveTokenPosition();
		auto lambdaExpr = parseLambdaExpression();
		if (lambdaExpr) {
			expr = std::move(lambdaExpr);
		}
		else {
			restoreTokenPosition();
			// Array literal parsing code commented out for future implementation
			advance(); // consume '['
			std::vector<std::unique_ptr<ASTNode>> elements;
			if (!check(TokenType::OPERATOR, "]")) {
				do {
					elements.push_back(parseExpression());
				} while (match(TokenType::OPERATOR, ","));
			}
			expect(TokenType::OPERATOR, "]");
			auto node = std::make_unique<ArrayLiteralNode>();
			node->elements = std::move(elements);
			return node;
		}
	}
	else if (match(TokenType::KEYWORD, "new")) {
		if (match(TokenType::IDENTIFIER)) {
			auto id = previous().value;
			if (match(TokenType::OPERATOR, "[")) {
				std::vector<std::unique_ptr<ASTNode>> sizes;
				while (!check(TokenType::OPERATOR, "]")) {
					sizes.push_back(parseExpression());
					if (!match(TokenType::OPERATOR, ",")) {
						break;
					}
				}
				expect(TokenType::OPERATOR, "]");
				auto node = std::make_unique<ArrayCreationExpressionNode>(id);
				node->sizes = std::move(sizes);
				return node;
			}
			else if (match(TokenType::OPERATOR, "(")) {
				return std::make_unique<ClassInstanceCreationNode>(id, parseArgumentList());
			}
			else {
				return std::make_unique<ClassInstanceCreationNode>(id);
			}
		}
		else {
			error("Expected class name after 'new'");
			return nullptr;
		}
	}
	else {
		return nullptr;
	}

	return expr;
}

std::unique_ptr<ASTNode> Parser::parseAssignmentExpression() {
	if (match(TokenType::OPERATOR, "=")) {
		return std::make_unique<AssignmentExpressionNode>(parseExpression(), parseExpression());
	}
	else {
		return parseSimpleExpression();
	}
}

std::unique_ptr<ASTNode> Parser::parsePrimaryExpression() {
	std::unique_ptr<ASTNode> expr = parseSimpleExpression();
	if (expr != nullptr) {
		return expr;
	}

	if (match(TokenType::OPERATOR, "(")) {
		auto casting = parseExpression();
		expect(TokenType::OPERATOR, ")");
		auto expr = parseExpression();

		return std::make_unique<CastingExpressionNode>(expr, casting);
	}
	else if (match(TokenType::OPERATOR, "-") ||
		match(TokenType::OPERATOR, "+") ||
		match(TokenType::OPERATOR, "~")) {
		auto rightCopy = parsePrimaryExpression();
		return std::make_unique<UnaryExpressionNode>(previous().value, rightCopy);
	}
	else if (match(TokenType::OPERATOR, "++") || match(TokenType::OPERATOR, "--")) {
		auto rightCopy = parsePrimaryExpression();
		return std::make_unique<PrefixExpressionNode>(previous().value, rightCopy);
	}
	else if (match(TokenType::OPERATOR, "!")) {
		auto rightCopy = parsePrimaryExpression();
		return std::make_unique<UnaryExpressionNode>("!", rightCopy);
	}
	else {
		return parseSimpleExpression();
	}
}

std::unique_ptr<ASTNode> Parser::parseMulDivExpression() {
	std::unique_ptr<ASTNode> expr = parsePrimaryExpression();
	while (match(TokenType::OPERATOR, "*") || match(TokenType::OPERATOR, "/") || match(TokenType::OPERATOR, "%")) {
		auto rightCopy = parsePrimaryExpression();
		return std::make_unique<BinaryExpressionNode>(expr, previous().value, rightCopy);
	}
	return expr;
}

std::unique_ptr<ASTNode> Parser::parseAddSubExpression() {
	std::unique_ptr<ASTNode> expr = parseMulDivExpression();
	if (match(TokenType::OPERATOR, "+") || match(TokenType::OPERATOR, "-")) {
		auto rigthCopy = parseMulDivExpression();
		return std::make_unique<BinaryExpressionNode>(expr, previous().value, rigthCopy);
	}
	else {
		return expr;
	}
}

std::unique_ptr<ASTNode> Parser::parseComparisonExpression() {
	std::unique_ptr<ASTNode> expr = parseShiftExpression();
	if (match(TokenType::OPERATOR, "<") || match(TokenType::OPERATOR, ">") ||
		match(TokenType::OPERATOR, "<=") || match(TokenType::OPERATOR, ">=")) {
		auto rightCopy = parseShiftExpression();
		return std::make_unique<BinaryExpressionNode>(expr, previous().value, rightCopy);
	}
	else {
		return expr;
	}
}

std::unique_ptr<ASTNode> Parser::parseShiftExpression() {
	std::unique_ptr<ASTNode> expr = parseAddSubExpression();
	if (match(TokenType::OPERATOR, "<<") || match(TokenType::OPERATOR, ">>")) {
		auto rightCopy = parseAddSubExpression();
		return std::make_unique<BinaryExpressionNode>(expr, previous().value, rightCopy);
	}
	else {
		return expr;
	}
}

std::unique_ptr<ASTNode> Parser::parseEqualityExpression() {
	std::unique_ptr<ASTNode> expr = parseComparisonExpression();
	if (match(TokenType::OPERATOR, "==") || match(TokenType::OPERATOR, "!=")) {
		auto rightCopy = parseComparisonExpression();
		return std::make_unique<BinaryExpressionNode>(expr, previous().value, rightCopy);
	}
	else {
		return expr;
	}
}

std::unique_ptr<ASTNode> Parser::parseConditionExpression() {
	if (match(TokenType::KEYWORD, "and") || match(TokenType::KEYWORD, "or") || match(TokenType::KEYWORD, "xor")) {
		auto leftCopy = parseEqualityExpression();
		auto rightCopy = parseEqualityExpression();
		return std::make_unique<BinaryExpressionNode>(leftCopy, previous().value, rightCopy);
	}
	else {
		return parseEqualityExpression();
	}
}

std::unique_ptr<ASTNode> Parser::parseOrExpression() {
	std::unique_ptr<ASTNode> expr = parseAndExpression();
	if (match(TokenType::KEYWORD, "or")) {
		auto rightCopy = parseAndExpression();
		return std::make_unique<BinaryExpressionNode>(expr, previous().value, rightCopy);
	}
	else {
		return expr;
	}
}

std::unique_ptr<ASTNode> Parser::parseAndExpression() {
	std::unique_ptr<ASTNode> expr = parseBitwiseOrExpression();
	if (match(TokenType::KEYWORD, "and")) {
		auto rightCopy = parseBitwiseOrExpression();
		return std::make_unique<BinaryExpressionNode>(expr, previous().value, rightCopy);
	}
	else {
		return expr;
	}
}

std::unique_ptr<ASTNode> Parser::parseXorExpression() {
	std::unique_ptr<ASTNode> expr = parseBitwiseAndExpression();
	if (match(TokenType::KEYWORD, "xor")) {
		auto rightCopy = parseBitwiseAndExpression();
		return std::make_unique<BinaryExpressionNode>(expr, previous().value, rightCopy);
	}
	else {
		return expr;
	}
}

std::unique_ptr<ASTNode> Parser::parseBitwiseOrExpression() {
	std::unique_ptr<ASTNode> expr = parseXorExpression();
	if (match(TokenType::OPERATOR, "|")) {
		auto rightCopy = parseXorExpression();
		return std::make_unique<BinaryExpressionNode>(expr, previous().value, rightCopy);
	}
	else {
		return expr;
	}
}

std::unique_ptr<ASTNode> Parser::parseBitwiseAndExpression() {
	std::unique_ptr<ASTNode> expr = parseEqualityExpression();
	if (match(TokenType::OPERATOR, "|")) {
		auto rightCopy = parseEqualityExpression();
		return std::make_unique<BinaryExpressionNode>(expr, previous().value, rightCopy);
	}
	else {
		return expr;
	}
}

std::unique_ptr<ASTNode> Parser::parseUnaryExpression() {
	if (match(TokenType::OPERATOR, "-") || match(TokenType::OPERATOR, "!")) {
		auto rightCopy = parseUnaryExpression();
		return std::make_unique<UnaryExpressionNode>(previous().value, rightCopy);
	}
	else {
		return parseXorExpression();
	}
}

std::unique_ptr<ASTNode> Parser::parsePostfixExpression() {
	if (match(TokenType::OPERATOR, "++") || match(TokenType::OPERATOR, "--")) {
		auto rightCopy = parsePostfixExpression();
		return std::make_unique<PostfixExpressionNode>(previous().value, rightCopy);
	}
	else {
		return parseUnaryExpression();
	}
}

std::unique_ptr<ASTNode> Parser::parsePrefixExpression()
{
	if (match(TokenType::OPERATOR, "++") || match(TokenType::OPERATOR, "--")) {
		auto rightCopy = parsePrefixExpression();
		return std::make_unique<PrefixExpressionNode>(previous().value, rightCopy);
	}
	else {
		return parsePostfixExpression();
	}
}

std::unique_ptr<ASTNode> Parser::parseExpression() {
	std::unique_ptr<ASTNode> expr = parseOrExpression();

	if (match(TokenType::KEYWORD, "match")) {
		auto matchNode = std::make_unique<MatchExpressionNode>();
		matchNode->expression = std::move(expr);

		expect(TokenType::OPERATOR, "{");

		while (!check(TokenType::OPERATOR, "}")) {
			if (isAtEnd()) {
				error("Unterminated 'match' block");
				return nullptr;
			}

			expect(TokenType::KEYWORD, "case");

			auto casePattern = parseSimpleExpression();

			expect(TokenType::OPERATOR, "=>");

			auto caseResult = parseExpression();

			matchNode->cases.emplace_back(std::move(casePattern), std::move(caseResult));
		}

		expect(TokenType::OPERATOR, "}");

		expr = std::move(matchNode);
	}
	else {
		match(TokenType::OPERATOR, ";");
	}
	return expr;
}

std::unique_ptr<ASTNode> Parser::parseLambdaExpression() {
	// C++�� ���ٽİ� ������ ������ ����
	// ��: [&](x: Int, y: Int) -> { x + y }
	auto lambdaNode = std::make_unique<LambdaExpressionNode>();

	expect(TokenType::OPERATOR, "[");
	if (match(TokenType::OPERATOR, "&")) {
		lambdaNode->capturesByReference = true;
	}
	else if (match(TokenType::OPERATOR, "=")) {
		lambdaNode->capturesByReference = false;
	}
	else {
		lambdaNode->capturesByReference = false;
		while (!check(TokenType::OPERATOR, "]")) {
			if (match(TokenType::IDENTIFIER)) {
				lambdaNode->captureVariables.push_back(previous().value);
				if (!match(TokenType::OPERATOR, ",")) {
					break;
				}
			}
			else {
				error("Expected identifier in lambda capture list");
			}
		}
	}
	expect(TokenType::OPERATOR, "]");

	expect(TokenType::OPERATOR, "(");
	auto params = parseCallParameterList();
	for (auto& arg : params) {
		lambdaNode->arguments.push_back(std::move(arg));
	}
	expect(TokenType::OPERATOR, ")");

	expect(TokenType::OPERATOR, "->");
	if (match(TokenType::OPERATOR, "{")) {
		lambdaNode->body = std::move(parseBlock());
	}
	else {
		error("Expected '{' after '->' in lambda expression");
	}

	return lambdaNode;
}