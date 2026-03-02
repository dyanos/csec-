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

		// Check for explicit template arguments: identifier<Type, ...>(args)
		if (pathComponents.size() == 1 && check(TokenType::OPERATOR, "<")) {
			saveTokenPosition();
			advance(); // consume '<'
			std::vector<std::unique_ptr<Type>> typeArgs;
			bool isTemplateCall = false;
			// Try to parse type list followed by '>' and '('
			auto firstType = parseType();
			if (firstType && firstType->getKind() != Type::Kind::UNKNOWN) {
				typeArgs.push_back(std::move(firstType));
				while (match(TokenType::OPERATOR, ",")) {
					typeArgs.push_back(parseType());
				}
				if (match(TokenType::OPERATOR, ">") && match(TokenType::OPERATOR, "(")) {
					isTemplateCall = true;
				}
			}
			if (isTemplateCall) {
				discardTokenPosition();
				auto callNode = std::make_unique<FunctionCallNode>();
				callNode->functionName = pathComponents[0];
				callNode->explicitTypeArgs = std::move(typeArgs);
				callNode->arguments = parseCallParameterList();
				return callNode;
			}
			else {
				restoreTokenPosition();
				typeArgs.clear();
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
			discardTokenPosition();
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

			// Check for template arguments: new ClassName<Type, ...>(args)
			std::vector<std::unique_ptr<Type>> tmplArgs;
			if (match(TokenType::OPERATOR, "<")) {
				do {
					tmplArgs.push_back(parseType());
				} while (match(TokenType::OPERATOR, ","));
				expect(TokenType::OPERATOR, ">");
			}

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
				auto node = std::make_unique<ClassInstanceCreationNode>(id, parseArgumentList());
				node->templateArgs = std::move(tmplArgs);
				return node;
			}
			else {
				auto node = std::make_unique<ClassInstanceCreationNode>(id);
				node->templateArgs = std::move(tmplArgs);
				return node;
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
		auto grouped = parseExpression();
		expect(TokenType::OPERATOR, ")");
		return grouped;
	}
	else if (match(TokenType::OPERATOR, "-") ||
		match(TokenType::OPERATOR, "+") ||
		match(TokenType::OPERATOR, "~")) {
		std::string op = previous().value;
		auto rightCopy = parsePrimaryExpression();
		return std::make_unique<UnaryExpressionNode>(op, std::move(rightCopy));
	}
	else if (match(TokenType::OPERATOR, "++") || match(TokenType::OPERATOR, "--")) {
		std::string op = previous().value;
		auto rightCopy = parsePrimaryExpression();
		return std::make_unique<PrefixExpressionNode>(op, std::move(rightCopy));
	}
	else if (match(TokenType::OPERATOR, "!")) {
		auto rightCopy = parsePrimaryExpression();
		return std::make_unique<UnaryExpressionNode>("!", std::move(rightCopy));
	}
	else {
		return parseSimpleExpression();
	}
}

std::unique_ptr<ASTNode> Parser::parseMulDivExpression() {
	std::unique_ptr<ASTNode> expr = parsePrimaryExpression();
	while (match(TokenType::OPERATOR, "*") || match(TokenType::OPERATOR, "/") || match(TokenType::OPERATOR, "%")) {
		std::string op = previous().value;
		auto rightCopy = parsePrimaryExpression();
		expr = std::make_unique<BinaryExpressionNode>(std::move(expr), op, std::move(rightCopy));
	}
	return expr;
}

std::unique_ptr<ASTNode> Parser::parseAddSubExpression() {
	std::unique_ptr<ASTNode> expr = parseMulDivExpression();
	while (match(TokenType::OPERATOR, "+") || match(TokenType::OPERATOR, "-")) {
		std::string op = previous().value;
		auto rightCopy = parseMulDivExpression();
		expr = std::make_unique<BinaryExpressionNode>(std::move(expr), op, std::move(rightCopy));
	}
	return expr;
}

std::unique_ptr<ASTNode> Parser::parseComparisonExpression() {
	std::unique_ptr<ASTNode> expr = parseShiftExpression();
	while (match(TokenType::OPERATOR, "<") || match(TokenType::OPERATOR, ">") ||
		match(TokenType::OPERATOR, "<=") || match(TokenType::OPERATOR, ">=")) {
		std::string op = previous().value;
		auto rightCopy = parseShiftExpression();
		expr = std::make_unique<BinaryExpressionNode>(std::move(expr), op, std::move(rightCopy));
	}
	return expr;
}

std::unique_ptr<ASTNode> Parser::parseShiftExpression() {
	std::unique_ptr<ASTNode> expr = parseAddSubExpression();
	while (match(TokenType::OPERATOR, "<<") || match(TokenType::OPERATOR, ">>")) {
		std::string op = previous().value;
		auto rightCopy = parseAddSubExpression();
		expr = std::make_unique<BinaryExpressionNode>(std::move(expr), op, std::move(rightCopy));
	}
	return expr;
}

std::unique_ptr<ASTNode> Parser::parseEqualityExpression() {
	std::unique_ptr<ASTNode> expr = parseComparisonExpression();
	while (match(TokenType::OPERATOR, "==") || match(TokenType::OPERATOR, "!=")) {
		std::string op = previous().value;
		auto rightCopy = parseComparisonExpression();
		expr = std::make_unique<BinaryExpressionNode>(std::move(expr), op, std::move(rightCopy));
	}
	return expr;
}

std::unique_ptr<ASTNode> Parser::parseConditionExpression() {
	auto expr = parseEqualityExpression();
	while (match(TokenType::KEYWORD, "and") || match(TokenType::KEYWORD, "or") || match(TokenType::KEYWORD, "xor")) {
		std::string op = previous().value;
		auto rightCopy = parseEqualityExpression();
		expr = std::make_unique<BinaryExpressionNode>(std::move(expr), op, std::move(rightCopy));
	}
	return expr;
}

std::unique_ptr<ASTNode> Parser::parseOrExpression() {
	std::unique_ptr<ASTNode> expr = parseAndExpression();
	while (match(TokenType::KEYWORD, "or")) {
		std::string op = previous().value;
		auto rightCopy = parseAndExpression();
		expr = std::make_unique<BinaryExpressionNode>(std::move(expr), op, std::move(rightCopy));
	}
	return expr;
}

std::unique_ptr<ASTNode> Parser::parseAndExpression() {
	std::unique_ptr<ASTNode> expr = parseBitwiseOrExpression();
	while (match(TokenType::KEYWORD, "and")) {
		std::string op = previous().value;
		auto rightCopy = parseBitwiseOrExpression();
		expr = std::make_unique<BinaryExpressionNode>(std::move(expr), op, std::move(rightCopy));
	}
	return expr;
}

std::unique_ptr<ASTNode> Parser::parseXorExpression() {
	std::unique_ptr<ASTNode> expr = parseBitwiseAndExpression();
	while (match(TokenType::KEYWORD, "xor")) {
		std::string op = previous().value;
		auto rightCopy = parseBitwiseAndExpression();
		expr = std::make_unique<BinaryExpressionNode>(std::move(expr), op, std::move(rightCopy));
	}
	return expr;
}

std::unique_ptr<ASTNode> Parser::parseBitwiseOrExpression() {
	std::unique_ptr<ASTNode> expr = parseXorExpression();
	while (match(TokenType::OPERATOR, "|")) {
		std::string op = previous().value;
		auto rightCopy = parseXorExpression();
		expr = std::make_unique<BinaryExpressionNode>(std::move(expr), op, std::move(rightCopy));
	}
	return expr;
}

std::unique_ptr<ASTNode> Parser::parseBitwiseAndExpression() {
	std::unique_ptr<ASTNode> expr = parseEqualityExpression();
	while (match(TokenType::OPERATOR, "&")) {
		std::string op = previous().value;
		auto rightCopy = parseEqualityExpression();
		expr = std::make_unique<BinaryExpressionNode>(std::move(expr), op, std::move(rightCopy));
	}
	return expr;
}

std::unique_ptr<ASTNode> Parser::parseUnaryExpression() {
	if (match(TokenType::OPERATOR, "-") || match(TokenType::OPERATOR, "!")) {
		std::string op = previous().value;
		auto rightCopy = parseUnaryExpression();
		return std::make_unique<UnaryExpressionNode>(op, std::move(rightCopy));
	}
	else {
		return parseXorExpression();
	}
}

std::unique_ptr<ASTNode> Parser::parsePostfixExpression() {
	auto expr = parseUnaryExpression();
	while (match(TokenType::OPERATOR, "++") || match(TokenType::OPERATOR, "--")) {
		std::string op = previous().value;
		expr = std::make_unique<PostfixExpressionNode>(op, std::move(expr));
	}
	return expr;
}

std::unique_ptr<ASTNode> Parser::parsePrefixExpression()
{
	if (match(TokenType::OPERATOR, "++") || match(TokenType::OPERATOR, "--")) {
		std::string op = previous().value;
		auto rightCopy = parsePrefixExpression();
		return std::make_unique<PrefixExpressionNode>(op, std::move(rightCopy));
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

	expect(TokenType::OPERATOR, "->");
	if (match(TokenType::OPERATOR, "{")) {
		lambdaNode->body = parseBlock();
	}
	else {
		error("Expected '{' after '->' in lambda expression");
	}

	return lambdaNode;
}

