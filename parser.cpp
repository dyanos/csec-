#include "parser.h"
#include "LatexMathEqParser.h"
#include "utils.h"

#include <iostream>
#include "utils.h"

#include "all_ast.h"


// parser������ parsing�� ����ϰ�, symbol ��� �� �˻��� codegen�Ҷ� ���
Parser::Parser(const std::vector<Token>& tokens)
	: tokens(tokens), position(0) {}

std::shared_ptr<ASTNode> Parser::parse() {
	auto program = std::make_shared<ProgramNode>();
	while (!isAtEnd()) {
		auto stmt = parseTopStatement();
		if (stmt) {
			program->statements.push_back(stmt);
		}
	}
	return program;
}

std::shared_ptr<Type> Parser::parseType() {
	if (match(TokenType::IDENTIFIER)) {
		std::string typeName = previous().value;

		std::shared_ptr<Type> baseType;
		if (typeName == "Int" || typeName == "Float" || typeName == "Double" || typeName == "Unit") {
			baseType = std::make_shared<BasicType>(typeName);
		}
		else if (typeName == "String") {
			baseType = std::make_shared<ClassType>(typeName);
		}
		else {
			baseType = std::make_shared<ClassType>(typeName);
		}

		std::shared_ptr<Type> tempArgsType = nullptr;
		if (match(TokenType::OPERATOR, "[")) {
			auto tempArgsType = parseType();
			expect(TokenType::OPERATOR, "]");
			return std::make_shared<GenericType>(baseType.get(), std::vector<Type*>{tempArgsType.get()});
		}

		return baseType;
	}
	else {
		error("Expected type after ':'");
		return std::make_shared<UnknownType>();
	}
}

std::shared_ptr<ASTNode> Parser::parseTopStatement() {
	std::shared_ptr<ASTNode> attributeNode = parseAnnotationStatement();

	std::shared_ptr<ASTNode> node = nullptr;
	if (match(TokenType::KEYWORD, "import")) {
		while (!check(TokenType::OPERATOR, ";")) {
			if (isAtEnd()) {
				error("Unterminated import statement");
				return nullptr;
			}
			advance();
		}
		advance();
		return nullptr;
	}
	else if (match(TokenType::KEYWORD, "class")) {
		node = parseClassDeclaration();
	}
	else if (match(TokenType::KEYWORD, "object")) {
		node = parseObjectDeclaration();
	}
	else if (match(TokenType::KEYWORD, "def")) {
		node = parseFunctionDeclaration();
	}
	else {
		return parseStatement();
	}

	if (attributeNode) {
		// attributeNode�� expr�� node�� ����
		dynamic_cast<AttributeNode*>(attributeNode.get())->target = node;
		return attributeNode;
	}

	return node;
}

std::shared_ptr<ASTNode> Parser::parseAnnotationExpression() {
	if (match(TokenType::IDENTIFIER)) {
		auto identifierNode = std::make_shared<IdentifierNode>(previous().value);
		if (!match(TokenType::OPERATOR, "(")) {
			return identifierNode;
		}
		else {
			auto callNode = std::make_shared<FunctionCallNode>();
			callNode->functionName = identifierNode->value;
			callNode->arguments = parseCallParameterList();
			return callNode;
		}
	}
	else if (match(TokenType::STRING_LITERAL)) {
		auto stringNode = std::make_shared<ValueNode>();
		stringNode->value = previous().value;
		return stringNode;
	}
	else if (match(TokenType::INTEGER_LITERAL)) {
		auto intNode = std::make_shared<ValueNode>();
		intNode->value = std::stoi(previous().value);
		return intNode;
	}
	else {
		error("Expected simple expression in attribute");
		return nullptr;
	}
}

std::shared_ptr<ClassBodyNode> Parser::parseClassBody() {
	auto classBody = std::make_shared<ClassBodyNode>();
	while (!check(TokenType::OPERATOR, "}")) {
		if (isAtEnd()) {
			error("Unterminated class body");
			return nullptr;
		}

		if (match(TokenType::KEYWORD, "def")) {
			auto method = parseFunctionDeclaration();
			classBody->methods.push_back(method);
		}
		else if (match(TokenType::KEYWORD, "val") || match(TokenType::KEYWORD, "var")) {
			bool isMutable = previous().value == "var";
			auto field = parseVariableDeclaration(isMutable);
			classBody->fields.push_back(field);
		}
		else {
			error("Unexpected token in class body");
			advance();
		}
	}
	return classBody;
}

std::vector<std::shared_ptr<ASTNode>> Parser::parseCallParameterList()
{
	std::vector<std::shared_ptr<ASTNode>> arguments;
	while (!check(TokenType::OPERATOR, ")")) {
		if (isAtEnd()) {
			error("Unterminated argument list");
			return std::vector<std::shared_ptr<ASTNode>>();
		}
		auto arg = parseExpression();
		arguments.push_back(arg);
		if (!match(TokenType::OPERATOR, ",")) {
			break;
		}
	}

	expect(TokenType::OPERATOR, ")");

	return arguments;
}

std::vector<std::shared_ptr<ParameterNode>> Parser::parseParameterList() {
	std::vector<std::shared_ptr<ParameterNode>> parameters;

	if (!check(TokenType::OPERATOR, ")")) {
		do {
			expect(TokenType::IDENTIFIER);
			std::string paramName = previous().value;

			expect(TokenType::OPERATOR, ":");
			std::shared_ptr<Type> paramType = parseType();

			auto paramNode = std::make_shared<ParameterNode>();
			paramNode->name = paramName;
			paramNode->type = std::make_unique<Type>(paramType.get());
			parameters.push_back(paramNode);
		} while (match(TokenType::OPERATOR, ","));
	}

	return parameters;
}

std::shared_ptr<ParameterNode> Parser::parseParameter() {
	if (match(TokenType::IDENTIFIER)) {
		std::string paramName = previous().value;
		expect(TokenType::OPERATOR, ":");
		std::shared_ptr<Type> paramType = parseType();
		auto param = std::make_shared<ParameterNode>();
		param->name = paramName;
		param->type = std::make_unique<Type>(paramType.get());
		return param;
	}
	else {
		error("Expected parameter name");
		return nullptr;
	}
}

std::vector<std::shared_ptr<ASTNode>> Parser::parseArgumentList() {
	std::vector<std::shared_ptr<ASTNode>> arguments;
	if (!check(TokenType::OPERATOR, ")")) {
		do {
			auto arg = parseExpression();
			arguments.push_back(arg);
		} while (match(TokenType::OPERATOR, ","));
		expect(TokenType::OPERATOR, ")");
	}
	return arguments;
}

std::shared_ptr<ASTNode> Parser::parseLatexCommand() {
	auto latexParser = LatexMathEqParser(&tokens, &position);
	return latexParser.parse();
}

std::shared_ptr<ASTNode> Parser::parseInlineMathLatex() {
	auto latexParser = LatexMathEqParser(&tokens, &position);
	return latexParser.parse();
}

std::shared_ptr<ASTNode> Parser::parseBlockMathLatex() {
	auto latexParser = LatexMathEqParser(&tokens, &position);
	return latexParser.parse();
}
