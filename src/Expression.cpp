#include "parser.h"

#include "all_ast.h"
#include "utils.h"

#include <algorithm>
#include <cctype>

namespace {
std::string lowerAscii(std::string value) {
    std::transform(value.begin(), value.end(), value.begin(), [](unsigned char ch) {
        return static_cast<char>(std::tolower(ch));
    });
    return value;
}

std::string mapSystemPathToBuiltin(const std::vector<std::string>& pathComponents) {
    if (pathComponents.empty()) {
        return "";
    }

    auto equalsPath = [&](std::initializer_list<const char*> parts) {
        if (pathComponents.size() != parts.size()) return false;
        size_t index = 0;
        for (const char* part : parts) {
            if (pathComponents[index++] != part) return false;
        }
        return true;
    };

    auto mapMathName = [](const std::string& rawName) -> std::string {
        std::string name = lowerAscii(rawName);
        if (name == "ceiling") return "ceil";
        if (name == "log10") return "lg";
        if (name == "asin") return "arcsin";
        if (name == "acos") return "arccos";
        if (name == "atan") return "arctan";
        static const char* supported[] = {
            "sin", "cos", "tan", "cot", "sec", "csc", "arcsin", "arccos", "arctan",
            "sinh", "cosh", "tanh", "coth", "sqrt", "ln", "log", "lg", "exp",
            "frac", "binom", "min", "max", "gcd", "pow", "abs", "sign", "floor",
            "ceil", "round", "lcm", "approxeq", "clamp", "between"
        };
        for (const char* candidate : supported) {
            if (name == candidate) {
                return name == "approxeq" ? "approxEq" : name;
            }
        }
        return "";
    };

    const std::string& method = pathComponents.back();
    if (pathComponents.size() == 3 &&
        pathComponents[0] == "System" &&
        pathComponents[1] == "Console") {
        if (method == "Write" || method == "write" || method == "print") return "print";
        if (method == "WriteLine" || method == "writeln" || method == "println") return "println";
        if (method == "ReadLine" || method == "readLine") return "readLine";
        if (method == "Read" || method == "ReadKey" || method == "read" || method == "readChar") return "readChar";
        if (method == "ReadInt" || method == "readInt") return "readInt";
        if (method == "ReadDouble" || method == "readDouble") return "readDouble";
    }

    if (pathComponents.size() == 3 &&
        pathComponents[0] == "System" &&
        pathComponents[1] == "Math") {
        return mapMathName(method);
    }

    if (pathComponents.size() == 4 &&
        pathComponents[0] == "System" &&
        pathComponents[1] == "IO" &&
        pathComponents[2] == "File") {
        if (method == "ReadAllText" || method == "readAllText") return "systemFileReadAllText";
        if (method == "WriteAllText" || method == "writeAllText") return "systemFileWriteAllText";
        if (method == "AppendAllText" || method == "appendAllText") return "systemFileAppendAllText";
        if (method == "Exists" || method == "exists") return "systemFileExists";
        if (method == "Delete" || method == "delete") return "systemFileDelete";
    }

    if (pathComponents.size() == 3 &&
        pathComponents[0] == "System" &&
        pathComponents[1] == "Environment") {
        if (method == "GetEnvironmentVariable") return "posixGetenv";
        if (method == "CommandLineArgCount" || method == "commandLineArgCount") return "commandLineArgCount";
        if (method == "CommandLineArg" || method == "commandLineArg") return "commandLineArg";
    }

    if (pathComponents.size() == 4 &&
        pathComponents[0] == "System" &&
        pathComponents[1] == "Net" &&
        pathComponents[2] == "Tcp") {
        if (method == "Connect" || method == "connect") return "tcpConnect";
        if (method == "Listen" || method == "listen") return "tcpListen";
        if (method == "Accept" || method == "accept") return "tcpAccept";
        if (method == "Send" || method == "send") return "tcpSend";
        if (method == "Recv" || method == "recv") return "tcpRecv";
        if (method == "Close" || method == "close") return "tcpClose";
    }

    return "";
}
}

std::unique_ptr<ASTNode> Parser::parseSimpleExpression() {
	std::unique_ptr<ASTNode> expr;

	if (match(TokenType::KEYWORD, "if")) {
		return parseIfStatement();
	}
    else if (match(TokenType::KEYWORD, "molecule")) {
        return parseMoleculeSimulationExpression();
    }
    else if (match(TokenType::KEYWORD, "cfd")) {
        return parseCfdSimulationExpression();
    }
    else if (match(TokenType::KEYWORD, "protein")) {
        return parseProteinMcmcExpression();
    }
	else if (match(TokenType::KEYWORD, "ode")) {
        return parseOdeSimulationExpression();
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
    else if (match(TokenType::KEYWORD, "preduce")) {
        return parsePReduceStatement();
    }
    else if (match(TokenType::KEYWORD, "filter")) {
        return parseFilterStatement();
    }
	else if (check(TokenType::IDENTIFIER) ||
        (check(TokenType::KEYWORD, "this") ||
         check(TokenType::KEYWORD, "super") ||
         check(TokenType::KEYWORD, "box"))) {
        advance();
        if (previous().value == "_") {
            return std::make_unique<UnitNode>();
        }
		std::vector<std::string> pathComponents;
		pathComponents.push_back(previous().value);
		while (match(TokenType::OPERATOR, ".")) {
			if (matchIdentifierName()) {
				pathComponents.push_back(previous().value);
			}
			else {
				error("Expected identifier after '.'");
				return nullptr;
			}
		}

		// Check for explicit template arguments: identifier<Type, ...>(args)
		if (pathComponents.size() == 1 &&
            check(TokenType::OPERATOR, "<") &&
            (peek(1).type == TokenType::IDENTIFIER ||
             peek(1).type == TokenType::INTEGER_LITERAL ||
             peek(1).type == TokenType::FLOAT_LITERAL ||
             peek(1).type == TokenType::EXPONENTIAL_LITERAL ||
             peek(1).type == TokenType::HEX_LITERAL ||
             peek(1).type == TokenType::BINARY_LITERAL ||
             peek(1).type == TokenType::OCTAL_LITERAL ||
             peek(1).type == TokenType::BOOLEAN_LITERAL ||
             (peek(1).type == TokenType::OPERATOR && peek(1).value == "("))) {
			saveTokenPosition();
			advance(); // consume '<'
			std::vector<std::unique_ptr<Type>> typeArgs;
			bool isTemplateCall = false;
			// Try to parse template arg list followed by '>' and '('
			auto firstType = parseTemplateArgumentAsType();
			if (firstType && firstType->getKind() != Type::Kind::UNKNOWN) {
				typeArgs.push_back(std::move(firstType));
				while (match(TokenType::OPERATOR, ",")) {
					typeArgs.push_back(parseTemplateArgumentAsType());
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

        int derivativeOrder = 0;
        if (pathComponents.size() == 1) {
            while (match(TokenType::OPERATOR, "'")) {
                ++derivativeOrder;
            }
        }

        if (derivativeOrder > 0) {
            if (derivativeOrder > 2) {
                error("Only first and second derivative postfix syntax is supported");
            }
            expect(TokenType::OPERATOR, "(");
            auto derivativeArgs = parseCallParameterList();
            if (derivativeArgs.size() != 1) {
                error("Derivative call syntax requires exactly one argument");
                return nullptr;
            }

            auto callNode = std::make_unique<FunctionCallNode>();
            callNode->functionName = "numericDerivative";
            callNode->arguments.push_back(std::make_unique<IdentifierNode>(pathComponents[0]));
            callNode->arguments.push_back(std::make_unique<ValueNode>(std::to_string(derivativeOrder), TokenType::INTEGER_LITERAL));
            callNode->arguments.push_back(std::move(derivativeArgs[0]));
            return callNode;
        }

		if (match(TokenType::OPERATOR, "(")) {
            if (auto builtinName = mapSystemPathToBuiltin(pathComponents); !builtinName.empty()) {
                auto callNode = std::make_unique<FunctionCallNode>();
                callNode->functionName = builtinName;
                callNode->arguments = parseCallParameterList();
                return callNode;
            }
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
            std::string op = previous().value;
			auto assignNode = std::make_unique<AssignmentExpressionNode>();
            assignNode->op = op;
			assignNode->left = std::make_unique<IdentifierNode>(join(pathComponents, "."));
			assignNode->right = parseExpression();
			return assignNode;
		}
        else if (match(TokenType::OPERATOR, "+=") ||
            match(TokenType::OPERATOR, "-=") ||
            match(TokenType::OPERATOR, "*=") ||
            match(TokenType::OPERATOR, "/=") ||
            match(TokenType::OPERATOR, "%=")) {
            std::string op = previous().value.substr(0, 1);
            auto assignNode = std::make_unique<AssignmentExpressionNode>();
            auto leftName = join(pathComponents, ".");
            assignNode->left = std::make_unique<IdentifierNode>(leftName);
            assignNode->right = std::make_unique<BinaryExpressionNode>(
                std::make_unique<IdentifierNode>(leftName),
                op,
                parseExpression());
            return assignNode;
        }

        if (pathComponents.size() == 2) {
            return std::make_unique<AccessFieldNode>(
                std::make_unique<IdentifierNode>(pathComponents[0]),
                std::make_unique<IdentifierNode>(pathComponents[1]));
        }

		return std::make_unique<IdentifierNode>(join(pathComponents, "."));
	}
	else if (match(TokenType::INTEGER_LITERAL) ||
		match(TokenType::FLOAT_LITERAL) ||
		match(TokenType::EXPONENTIAL_LITERAL) ||
		match(TokenType::HEX_LITERAL) ||
		match(TokenType::BINARY_LITERAL) ||
		match(TokenType::OCTAL_LITERAL) ||
        match(TokenType::CHAR_LITERAL) ||
		match(TokenType::STRING_LITERAL) ||
        match(TokenType::REGEX_LITERAL) ||
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
        bool looksLikeLambda =
            peek(1).value == "&" ||
            peek(1).value == "=" ||
            peek(1).type == TokenType::IDENTIFIER ||
            peek(1).value == "]";

        if (looksLikeLambda) {
		    saveTokenPosition();
		    auto lambdaExpr = parseLambdaExpression();
		    if (lambdaExpr) {
			    discardTokenPosition();
			    return lambdaExpr;
		    }
            restoreTokenPosition();
        }

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
	else if (match(TokenType::KEYWORD, "new")) {
		if (match(TokenType::IDENTIFIER)) {
			auto id = previous().value;

			// Check for template arguments: new ClassName<Type, ...>(args)
			std::vector<std::unique_ptr<Type>> tmplArgs;
			if (match(TokenType::OPERATOR, "<")) {
				do {
					tmplArgs.push_back(parseTemplateArgumentAsType());
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
	else {
		return parseSimpleExpression();
	}
}

std::unique_ptr<ASTNode> Parser::parseMulDivExpression() {
	std::unique_ptr<ASTNode> expr = parsePrefixExpression();
	while (true) {
        bool matched = match(TokenType::OPERATOR, "*") ||
            match(TokenType::OPERATOR, "**") ||
            match(TokenType::OPERATOR, "/") ||
            match(TokenType::OPERATOR, "%") ||
            match(TokenType::OPERATOR, "@");
        if (!matched &&
            (check(TokenType::IDENTIFIER, "inner") ||
             check(TokenType::IDENTIFIER, "outer") ||
             check(TokenType::IDENTIFIER, "tensor") ||
             check(TokenType::IDENTIFIER, "intersect") ||
             check(TokenType::IDENTIFIER, "div") ||
             check(TokenType::IDENTIFIER, "mod"))) {
            advance();
            matched = true;
        }
        if (!matched) {
            break;
        }
		std::string op = previous().value;
		auto rightCopy = parsePrefixExpression();
		expr = std::make_unique<BinaryExpressionNode>(std::move(expr), op, std::move(rightCopy));
	}
	return expr;
}

std::unique_ptr<ASTNode> Parser::parseAddSubExpression() {
	std::unique_ptr<ASTNode> expr = parseMulDivExpression();
	while (true) {
        bool matched = match(TokenType::OPERATOR, "+") || match(TokenType::OPERATOR, "-");
        if (!matched &&
            (check(TokenType::IDENTIFIER, "union") ||
             check(TokenType::IDENTIFIER, "diff") ||
             check(TokenType::IDENTIFIER, "without") ||
             check(TokenType::IDENTIFIER, "symdiff"))) {
            advance();
            matched = true;
        }
        if (!matched) {
            break;
        }
		std::string op = previous().value;
		auto rightCopy = parseMulDivExpression();
		expr = std::make_unique<BinaryExpressionNode>(std::move(expr), op, std::move(rightCopy));
	}
	return expr;
}

std::unique_ptr<ASTNode> Parser::parseComparisonExpression() {
	std::unique_ptr<ASTNode> expr = parseShiftExpression();
	while (true) {
        bool matched = match(TokenType::OPERATOR, "<") || match(TokenType::OPERATOR, ">") ||
		    match(TokenType::OPERATOR, "<=") || match(TokenType::OPERATOR, ">=");
        if (!matched &&
            (check(TokenType::IDENTIFIER, "in") ||
             check(TokenType::IDENTIFIER, "notin") ||
             check(TokenType::IDENTIFIER, "subset") ||
             check(TokenType::IDENTIFIER, "superset") ||
             check(TokenType::IDENTIFIER, "properSubset") ||
             check(TokenType::IDENTIFIER, "properSuperset"))) {
            advance();
            matched = true;
        }
        if (!matched) {
            break;
        }
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
	while (match(TokenType::OPERATOR, "==") || match(TokenType::OPERATOR, "!=") || check(TokenType::IDENTIFIER, "iff")) {
        if (check(TokenType::IDENTIFIER, "iff")) {
            advance();
        }
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
	while (match(TokenType::KEYWORD, "or") || check(TokenType::IDENTIFIER, "implies")) {
        if (check(TokenType::IDENTIFIER, "implies")) {
            advance();
        }
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
	while (match(TokenType::KEYWORD, "xor") || match(TokenType::OPERATOR, "^")) {
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
	if (match(TokenType::OPERATOR, "-") ||
		match(TokenType::OPERATOR, "+") ||
		match(TokenType::OPERATOR, "*") ||
		match(TokenType::OPERATOR, "~") ||
		match(TokenType::OPERATOR, "!")) {
		std::string op = previous().value;
		auto rightCopy = parseUnaryExpression();
		return std::make_unique<UnaryExpressionNode>(op, std::move(rightCopy));
	}
	else {
		return parsePrimaryExpression();
	}
}

std::unique_ptr<ASTNode> Parser::parsePostfixExpression() {
	auto expr = parseUnaryExpression();
	while (true) {
		if (match(TokenType::OPERATOR, "++") || match(TokenType::OPERATOR, "--")) {
			std::string op = previous().value;
			expr = std::make_unique<PostfixExpressionNode>(op, std::move(expr));
		}
		else if (match(TokenType::OPERATOR, "[")) {
            if (check(TokenType::OPERATOR, "]") || check(TokenType::OPERATOR, ",")) {
                error("Expected index expression");
            }
            auto accessNode = std::make_unique<ArrayAccessNode>();
            accessNode->array = std::move(expr);
            do {
                auto spec = std::make_unique<ArrayIndexSpec>();
                if (match(TokenType::OPERATOR, ":")) {
                    spec->isSlice = true;
                    if (!check(TokenType::OPERATOR, "]") &&
                        !check(TokenType::OPERATOR, ",") &&
                        !check(TokenType::OPERATOR, ":")) {
                        spec->end = parseExpression();
                    }
                    if (match(TokenType::OPERATOR, ":")) {
                        if (!check(TokenType::OPERATOR, "]") && !check(TokenType::OPERATOR, ",")) {
                            spec->step = parseExpression();
                        }
                    }
                }
                else {
                    auto first = parseExpression();
                    if (match(TokenType::OPERATOR, ":")) {
                        spec->isSlice = true;
                        spec->start = std::move(first);
                        if (!check(TokenType::OPERATOR, "]") &&
                            !check(TokenType::OPERATOR, ",") &&
                            !check(TokenType::OPERATOR, ":")) {
                            spec->end = parseExpression();
                        }
                        if (match(TokenType::OPERATOR, ":")) {
                            if (!check(TokenType::OPERATOR, "]") && !check(TokenType::OPERATOR, ",")) {
                                spec->step = parseExpression();
                            }
                        }
                    }
                    else {
                        spec->index = std::move(first);
                    }
                }
                if (!accessNode->index && !spec->isSlice && spec->index) {
                    accessNode->index = spec->index->clone();
                }
                accessNode->indices.push_back(std::move(spec));
                if (check(TokenType::OPERATOR, "]")) {
                    break;
                }
                expect(TokenType::OPERATOR, ",");
                if (check(TokenType::OPERATOR, "]")) {
                    error("Expected index expression after ','");
                }
            } while (true);
			expect(TokenType::OPERATOR, "]");
            expr = std::move(accessNode);
		}
		else {
			break;
		}
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
	else if (match(TokenType::OPERATOR, "<-")) {
		auto rightCopy = parsePrefixExpression();
		return std::make_unique<PrefixExpressionNode>("<-", std::move(rightCopy));
	}
	else if (match(TokenType::OPERATOR, "&")) {
		std::string op = match(TokenType::KEYWORD, "mut") ? "&mut" : "&";
		auto rightCopy = parsePrefixExpression();
		return std::make_unique<PrefixExpressionNode>(op, std::move(rightCopy));
	}
	else {
		return parsePostfixExpression();
	}
}

std::unique_ptr<ASTNode> Parser::parseExpression() {
	std::unique_ptr<ASTNode> expr = parseOrExpression();
    if (!expr) {
        error("Expected expression");
    }

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
    if (!check(TokenType::OPERATOR, ")")) {
        do {
            expect(TokenType::IDENTIFIER);
            auto paramNode = std::make_unique<ParameterNode>();
            paramNode->name = previous().value;
            if (match(TokenType::OPERATOR, ":")) {
                paramNode->type = parseType();
            }
            else {
                paramNode->type = std::make_unique<UnknownType>();
            }
            lambdaNode->arguments.push_back(std::move(paramNode));
        } while (match(TokenType::OPERATOR, ","));
    }
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

