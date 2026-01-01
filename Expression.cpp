#include "parser.h"

#include "all_ast.h"
#include "utils.h"

std::shared_ptr<ASTNode> Parser::parseSimpleExpression() {
	std::shared_ptr<ASTNode> expr;

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
				auto callNode = std::make_shared<FunctionCallNode>();
				callNode->functionName = pathComponents[0];
				callNode->arguments = parseCallParameterList();
				return callNode;
			}
			else {
				auto callNode = std::make_shared<MethodCallNode>();

				std::vector<std::string> result;
				std::copy(pathComponents.begin(), pathComponents.end() - 1, std::back_inserter(result));

				callNode->object = std::make_shared<IdentifierNode>(join(result, "."));
				callNode->methodName = pathComponents.back();
				callNode->arguments = parseCallParameterList();

				return callNode;
			}
		}
		else if (match(TokenType::OPERATOR, "=") || match(TokenType::OPERATOR, "<-")) {
			auto assignNode = std::make_shared<AssignmentExpressionNode>();
			assignNode->left = std::make_shared<IdentifierNode>(join(pathComponents, "."));
			assignNode->right = parseExpression();
			return assignNode;
		}

		expr = std::make_shared<IdentifierNode>(join(pathComponents, "."));
	}
	else if (match(TokenType::INTEGER_LITERAL) ||
		match(TokenType::FLOAT_LITERAL) ||
		match(TokenType::EXPONENTIAL_LITERAL) ||
		match(TokenType::HEX_LITERAL) ||
		match(TokenType::BINARY_LITERAL) ||
		match(TokenType::OCTAL_LITERAL) ||
		match(TokenType::STRING_LITERAL) ||
		match(TokenType::BOOLEAN_LITERAL)) {
		auto exprNode = std::make_shared<ValueNode>(previous().value, previous().type);
		expr = exprNode;
	}
	else if (match(TokenType::OPERATOR, "$")) {
		expr = parseInlineMathLatex();
		match(TokenType::OPERATOR, "$");
	}
	else if (match(TokenType::OPERATOR, "$$")) {
		expr = parseBlockMathLatex();
		match(TokenType::OPERATOR, "$$");
	}
	else if (match(TokenType::OPERATOR, "_")) {
		expr = std::make_shared<UnitNode>();
	}
	else if (match(TokenType::OPERATOR, "{")) {
		expr = parseBlock();
	}
	else if (check(TokenType::OPERATOR, "[")) {
		saveTokenPosition();
		auto lambdaExpr = parseLambdaExpression();
		if (lambdaExpr) {
			expr = lambdaExpr;
		}
		else {
			restoreTokenPosition();
			// Array literal parsing code commented out for future implementation
			advance(); // consume '['
			std::vector<std::shared_ptr<ASTNode>> elements;
			if (!check(TokenType::OPERATOR, "]")) {
				do {
					auto element = parseExpression();
					elements.push_back(element);
				} while (match(TokenType::OPERATOR, ","));
			}
			expect(TokenType::OPERATOR, "]");
			auto arrayNode = std::make_shared<ArrayLiteralNode>();
			arrayNode->elements = elements;
			expr = arrayNode;
		}
	}
	else if (match(TokenType::KEYWORD, "new")) {
		if (match(TokenType::IDENTIFIER)) {
			auto id = previous().value;
			if (match(TokenType::OPERATOR, "[")) {
				std::vector<std::shared_ptr<ASTNode>> sizes;
				while (!check(TokenType::OPERATOR, "]")) {
					auto size = parseExpression();
					sizes.push_back(size);
					if (!match(TokenType::OPERATOR, ",")) {
						break;
					}
				}
				expect(TokenType::OPERATOR, "]");
				auto newArrayExpr = std::make_shared<ArrayCreationExpressionNode>(id, sizes);
				return newArrayExpr;
			}
			else if (match(TokenType::OPERATOR, "(")) {
				std::shared_ptr<ClassInstanceCreationNode> newExpr = std::make_shared<ClassInstanceCreationNode>();
				newExpr->className = id;
				newExpr->arguments = parseArgumentList();
				return newExpr;
			}
			else {
				std::shared_ptr<ClassInstanceCreationNode> newExpr = std::make_shared<ClassInstanceCreationNode>();
				newExpr->className = id;
				return newExpr;
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

std::shared_ptr<ASTNode> Parser::parseAssignmentExpression() {
	if (match(TokenType::OPERATOR, "=")) {
		auto assignNode = std::make_shared<AssignmentExpressionNode>();
		assignNode->left = parseExpression();
		assignNode->right = parseExpression();
		return assignNode;
	}
	else {
		return parseSimpleExpression();
	}
}

std::shared_ptr<ASTNode> Parser::parsePrimaryExpression() {
	std::shared_ptr<ASTNode> expr = parseSimpleExpression();
	if (expr != nullptr) {
		return expr;
	}

	if (match(TokenType::OPERATOR, "(")) {
		auto casting = parseExpression();
		expect(TokenType::OPERATOR, ")");
		auto expr = parseExpression();

		auto castexpr = std::make_shared<CastingExpressionNode>();
		castexpr->type = casting;
		castexpr->expression = expr;
		return castexpr;
	}
	else if (match(TokenType::OPERATOR, "-") ||
		match(TokenType::OPERATOR, "+") ||
		match(TokenType::OPERATOR, "~")) {
		auto unaryNode = std::make_shared<UnaryExpressionNode>();
		unaryNode->op = previous().value;
		unaryNode->expression = parsePrimaryExpression();
		return unaryNode;
	}
	else if (match(TokenType::OPERATOR, "++") || match(TokenType::OPERATOR, "--")) {
		auto unaryNode = std::make_shared<PrefixExpressionNode>();
		unaryNode->op = previous().value;
		unaryNode->expression = parsePrimaryExpression();
		return unaryNode;
	}
	else if (match(TokenType::OPERATOR, "!")) {
		auto unaryNode = std::make_shared<UnaryExpressionNode>();
		unaryNode->op = "!";
		unaryNode->expression = parsePrimaryExpression();
		return unaryNode;
	}
	else {
		return parseSimpleExpression();
	}
}

std::shared_ptr<ASTNode> Parser::parseMulDivExpression() {
	std::shared_ptr<ASTNode> expr = parsePrimaryExpression();
	while (match(TokenType::OPERATOR, "*") || match(TokenType::OPERATOR, "/") || match(TokenType::OPERATOR, "%")) {
		auto binaryNode = std::make_shared<BinaryExpressionNode>();
		binaryNode->left = expr;
		binaryNode->op = previous().value;
		binaryNode->right = parsePrimaryExpression();
		expr = binaryNode;
	}
	return expr;
}

std::shared_ptr<ASTNode> Parser::parseAddSubExpression() {
	std::shared_ptr<ASTNode> expr = parseMulDivExpression();
	if (match(TokenType::OPERATOR, "+") || match(TokenType::OPERATOR, "-")) {
		auto binaryNode = std::make_shared<BinaryExpressionNode>();
		binaryNode->left = expr;
		binaryNode->op = previous().value;
		binaryNode->right = parseMulDivExpression();
		return binaryNode;
	}
	else {
		return expr;
	}
}

std::shared_ptr<ASTNode> Parser::parseComparisonExpression() {
	std::shared_ptr<ASTNode> expr = parseShiftExpression();
	if (match(TokenType::OPERATOR, "<") || match(TokenType::OPERATOR, ">") ||
		match(TokenType::OPERATOR, "<=") || match(TokenType::OPERATOR, ">=")) {
		auto binaryNode = std::make_shared<BinaryExpressionNode>();
		binaryNode->left = expr;
		binaryNode->op = previous().value;
		binaryNode->right = parseShiftExpression();
		return binaryNode;
	}
	else {
		return expr;
	}
}

std::shared_ptr<ASTNode> Parser::parseShiftExpression() {
	std::shared_ptr<ASTNode> expr = parseAddSubExpression();
	if (match(TokenType::OPERATOR, "<<") || match(TokenType::OPERATOR, ">>")) {
		auto binaryNode = std::make_shared<BinaryExpressionNode>();
		binaryNode->left = expr;
		binaryNode->op = previous().value;
		binaryNode->right = parseAddSubExpression();
		return binaryNode;
	}
	else {
		return expr;
	}
}

std::shared_ptr<ASTNode> Parser::parseEqualityExpression() {
	std::shared_ptr<ASTNode> expr = parseComparisonExpression();
	if (match(TokenType::OPERATOR, "==") || match(TokenType::OPERATOR, "!=")) {
		auto binaryNode = std::make_shared<BinaryExpressionNode>();
		binaryNode->left = expr;
		binaryNode->op = previous().value;
		binaryNode->right = parseComparisonExpression();
		return binaryNode;
	}
	else {
		return expr;
	}
}

std::shared_ptr<ASTNode> Parser::parseConditionExpression() {
	if (match(TokenType::KEYWORD, "and") || match(TokenType::KEYWORD, "or") || match(TokenType::KEYWORD, "xor")) {
		auto binaryNode = std::make_shared<BinaryExpressionNode>();
		binaryNode->left = parseEqualityExpression();
		binaryNode->op = previous().value;
		binaryNode->right = parseEqualityExpression();
		return binaryNode;
	}
	else {
		return parseEqualityExpression();
	}
}

std::shared_ptr<ASTNode> Parser::parseOrExpression() {
	std::shared_ptr<ASTNode> expr = parseAndExpression();
	if (match(TokenType::KEYWORD, "or")) {
		auto binaryNode = std::make_shared<BinaryExpressionNode>();
		binaryNode->left = expr;
		binaryNode->op = previous().value;
		binaryNode->right = parseAndExpression();
		return binaryNode;
	}
	else {
		return expr;
	}
}

std::shared_ptr<ASTNode> Parser::parseAndExpression() {
	std::shared_ptr<ASTNode> expr = parseBitwiseOrExpression();
	if (match(TokenType::KEYWORD, "and")) {
		auto binaryNode = std::make_shared<BinaryExpressionNode>();
		binaryNode->left = expr;
		binaryNode->op = previous().value;
		binaryNode->right = parseBitwiseOrExpression();
		return binaryNode;
	}
	else {
		return expr;
	}
}

std::shared_ptr<ASTNode> Parser::parseXorExpression() {
	std::shared_ptr<ASTNode> expr = parseBitwiseAndExpression();
	if (match(TokenType::KEYWORD, "xor")) {
		auto binaryNode = std::make_shared<BinaryExpressionNode>();
		binaryNode->left = expr;
		binaryNode->op = previous().value;
		binaryNode->right = parseBitwiseAndExpression();
		return binaryNode;
	}
	else {
		return expr;
	}
}

std::shared_ptr<ASTNode> Parser::parseBitwiseOrExpression() {
	std::shared_ptr<ASTNode> expr = parseXorExpression();
	if (match(TokenType::OPERATOR, "|")) {
		auto binaryNode = std::make_shared<BinaryExpressionNode>();
		binaryNode->left = expr;
		binaryNode->op = previous().value;
		binaryNode->right = parseXorExpression();
		return binaryNode;
	}
	else {
		return expr;
	}
}

std::shared_ptr<ASTNode> Parser::parseBitwiseAndExpression() {
	std::shared_ptr<ASTNode> expr = parseEqualityExpression();
	if (match(TokenType::OPERATOR, "|")) {
		auto binaryNode = std::make_shared<BinaryExpressionNode>();
		binaryNode->left = expr;
		binaryNode->op = previous().value;
		binaryNode->right = parseEqualityExpression();
		return binaryNode;
	}
	else {
		return expr;
	}
}

std::shared_ptr<ASTNode> Parser::parseUnaryExpression() {
	if (match(TokenType::OPERATOR, "-") || match(TokenType::OPERATOR, "!")) {
		auto unaryNode = std::make_shared<UnaryExpressionNode>();
		unaryNode->op = previous().value;
		unaryNode->expression = parseUnaryExpression();
		return unaryNode;
	}
	else {
		return parseXorExpression();
	}
}

std::shared_ptr<ASTNode> Parser::parsePostfixExpression() {
	if (match(TokenType::OPERATOR, "++") || match(TokenType::OPERATOR, "--")) {
		auto unaryNode = std::make_shared<PostfixExpressionNode>();
		unaryNode->op = previous().value;
		unaryNode->expression = parsePostfixExpression();
		return unaryNode;
	}
	else {
		return parseUnaryExpression();
	}
}

std::shared_ptr<ASTNode> Parser::parsePrefixExpression()
{
	if (match(TokenType::OPERATOR, "++") || match(TokenType::OPERATOR, "--")) {
		auto unaryNode = std::make_shared<PrefixExpressionNode>();
		unaryNode->op = previous().value;
		unaryNode->expression = parsePrefixExpression();
		return unaryNode;
	}
	else {
		return parsePostfixExpression();
	}
}

std::shared_ptr<ASTNode> Parser::parseExpression() {
	std::shared_ptr<ASTNode> expr = parseOrExpression();

	if (match(TokenType::KEYWORD, "match")) {
		auto matchNode = std::make_shared<MatchExpressionNode>();
		matchNode->expression = expr;

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

			matchNode->cases.push_back(std::make_pair(casePattern, caseResult));
		}

		expect(TokenType::OPERATOR, "}");

		expr = matchNode;
	}
	else {
		match(TokenType::OPERATOR, ";");
	}
	return expr;
}

std::shared_ptr<ASTNode> Parser::parseLambdaExpression() {
	// C++의 람다식과 유사한 구문을 가정
	// 예: [&](x: Int, y: Int) -> { x + y }
	auto lambdaNode = std::make_shared<LambdaExpressionNode>();

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
	lambdaNode->arguments = parseCallParameterList();
	expect(TokenType::OPERATOR, ")");

	expect(TokenType::OPERATOR, "->");
	if (match(TokenType::OPERATOR, "{")) {
		lambdaNode->body = parseBlock();
	}
	else {
		error("Expected '{' after '->' in lambda expression");
	}

	return lambdaNode;
}