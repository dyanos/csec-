#include "parser.h"
#include "LatexMathEqParser.h"
#include "utils.h"

#include <iostream>

#include "all_ast.h"


// parser占쏙옙占쏙옙占쏙옙 parsing占쏙옙 占쏙옙占쏙옙構占? symbol 占쏙옙占?占쏙옙 占싯삼옙占쏙옙 codegen占쌀띰옙 占쏙옙占?
Parser::Parser(std::vector<Token>& tokens)
	: tokens(tokens), position(0) {}

std::unique_ptr<ASTNode> Parser::parse() {
	auto program = std::make_unique<ProgramNode>();
	while (!isAtEnd()) {
		auto stmt = parseTopStatement();
		if (stmt) {
			program->statements.push_back(std::move(stmt));
		}
	}
	return program;
}

std::unique_ptr<Type> Parser::parseType() {
	if (match(TokenType::IDENTIFIER)) {
		std::string typeName = previous().value;

		// Check if this identifier is a template type parameter
		for (const auto& tp : templateTypeParams) {
			if (typeName == tp) {
				return std::make_unique<TypeVariableType>(typeName);
			}
		}

		std::unique_ptr<Type> baseType;
		if (typeName == "Int" ||
			typeName == "Float" ||
			typeName == "Double" ||
			typeName == "Unit" ||
			typeName == "Void" ||
			typeName == "Char" ||
			typeName == "Boolean" ||
			typeName == "Bool" ||
			typeName == "Long" ||
			typeName == "Short" ||
			typeName == "Byte" ||
			typeName == "String") {
			baseType = std::make_unique<BasicType>(typeName);
		}
		else {
			baseType = std::make_unique<ClassType>(typeName);
		}

		if (match(TokenType::OPERATOR, "[")) {
			auto tempArgsType = parseType();
			expect(TokenType::OPERATOR, "]");
			std::vector<std::unique_ptr<Type>> typeArgs;
			typeArgs.push_back(tempArgsType->clone());
			return std::make_unique<GenericType>(baseType, typeArgs);
		}

		// ClassName<Type, ...> syntax for template class instantiation types
		if (match(TokenType::OPERATOR, "<")) {
			std::vector<std::unique_ptr<Type>> typeArgs;
			do {
				typeArgs.push_back(parseType());
			} while (match(TokenType::OPERATOR, ","));
			expect(TokenType::OPERATOR, ">");
			return std::make_unique<GenericType>(baseType, typeArgs);
		}

		return baseType;
	}
	else if (match(TokenType::OPERATOR, "(")) {
		// ?⑥닔 ????뚯떛
		std::vector<std::unique_ptr<Type>> paramTypes;
		if (!check(TokenType::OPERATOR, ")")) {
			do {
				auto paramType = parseType();
				paramTypes.push_back(std::move(paramType));
			} while (match(TokenType::OPERATOR, ","));
		}
		expect(TokenType::OPERATOR, ")");
		expect(TokenType::OPERATOR, "=>");
		auto returnType = parseType();
		return std::make_unique<FunctionType>(paramTypes, returnType);
	}
	else {
		error("Expected type after ':'");
		return std::make_unique<UnknownType>();
	}
}

std::vector<std::string> Parser::parseTemplateParameters() {
	std::vector<std::string> params;
	currentTemplateParams.clear();
	expect(TokenType::OPERATOR, "<");
	do {
		if (match(TokenType::KEYWORD, "typename") || match(TokenType::KEYWORD, "class")) {
			expect(TokenType::IDENTIFIER);
			std::string name = previous().value;
			params.push_back(name);
			currentTemplateParams.push_back(TemplateParam(name));
		}
		else if (check(TokenType::IDENTIFIER)) {
			// Non-type template parameter: e.g. "Int N"
			std::string typeName = peek().value;
			// Check if it's a known type name (for non-type param)
			if (typeName == "Int" || typeName == "Long" || typeName == "Short" ||
				typeName == "Byte" || typeName == "Boolean" || typeName == "Bool") {
				advance(); // consume type name
				expect(TokenType::IDENTIFIER);
				std::string paramName = previous().value;
				params.push_back(paramName);
				currentTemplateParams.push_back(TemplateParam(paramName, std::make_unique<BasicType>(typeName)));
			}
			else {
				error("Expected 'typename', 'class', or a type name in template parameter list");
				break;
			}
		}
		else {
			error("Expected 'typename', 'class', or a type name in template parameter list");
			break;
		}
	} while (match(TokenType::OPERATOR, ","));
	expect(TokenType::OPERATOR, ">");
	return params;
}

std::unique_ptr<ASTNode> Parser::parseTopStatement() {
	std::unique_ptr<ASTNode> attributeNode = parseAnnotationStatement();

	// Handle template declarations
	if (match(TokenType::KEYWORD, "template")) {
		auto templateNode = std::make_unique<TemplateDeclarationNode>();
		templateNode->typeParameters = parseTemplateParameters();
		templateNode->templateParams = currentTemplateParams;

		// Set active template type params for parseType()
		templateTypeParams = templateNode->typeParameters;

		// Parse the inner declaration (def or class)
		if (match(TokenType::KEYWORD, "def")) {
			templateNode->declaration = parseFunctionDeclaration();
		}
		else if (match(TokenType::KEYWORD, "class")) {
			templateNode->declaration = parseClassDeclaration();
		}
		else {
			error("Expected 'def' or 'class' after template parameters");
		}

		// Clear active template type params
		templateTypeParams.clear();
		return templateNode;
	}

	// Handle constexpr modifier
	bool isConstexpr = false;
	if (check(TokenType::KEYWORD, "constexpr")) {
		isConstexpr = true;
		advance();
	}

	bool isExternal = false;
	if (check(TokenType::KEYWORD, "external")) {
		isExternal = true;
		advance();
	}

	std::unique_ptr<ASTNode> node = nullptr;
	if (match(TokenType::KEYWORD, "import")) {
		if (isExternal) {
			error("Import statement cannot be marked as external");
		}

		if (attributeNode) {
			error("Import statement cannot have attributes");
		}

		node = parseImportStatement();
	}
	else if (match(TokenType::KEYWORD, "class")) {
		node = parseClassDeclaration(isExternal);

		ClassDeclarationNode* classNode = dynamic_cast<ClassDeclarationNode*>(node.get());
		if (!classNode) {
			error("Expected class declaration node");
			return nullptr;
		}
		classNode->isExternal = isExternal;
	}
	else if (match(TokenType::KEYWORD, "object")) {
		node = parseObjectDeclaration(isExternal);

		ObjectDeclarationNode* objectNode = dynamic_cast<ObjectDeclarationNode*>(node.get());
		if (!objectNode) {
			error("Expected object declaration node");
			return nullptr;
		}
		objectNode->isExternal = isExternal;
	}
	else if (match(TokenType::KEYWORD, "def")) {
		auto targetNode = parseFunctionDeclaration(isExternal);
		targetNode->isExternal = isExternal;
		targetNode->isConstexpr = isConstexpr;
		node = std::move(targetNode);
	}
	else {
		// constexpr can precede val/var in top-level statements
		if (isConstexpr) {
			if (match(TokenType::KEYWORD, "val") || match(TokenType::KEYWORD, "var")) {
				bool isMutable = previous().value == "var";
				auto varDecl = parseVariableDeclaration(isMutable);
				varDecl->isConstexpr = isConstexpr;
				match(TokenType::OPERATOR, ";");
				return varDecl;
			}
		}
		return parseStatement();
	}

	if (attributeNode) {
		auto* attrNode = dynamic_cast<AttributeNode*>(attributeNode.get());
		if (!attrNode) {
			error("Expected attribute node");
			return nullptr;
		}
		attrNode->target = std::move(node);
		return attributeNode;
	}

	return node;
}

std::unique_ptr<ASTNode> Parser::parseAnnotationExpression() {
	if (match(TokenType::IDENTIFIER)) {
		auto identifierNode = std::make_unique<IdentifierNode>(previous().value);
		if (!match(TokenType::OPERATOR, "(")) {
			return identifierNode;
		}
		else {
			auto callNode = std::make_unique<FunctionCallNode>();
			callNode->functionName = identifierNode->value;
			callNode->arguments = parseCallParameterList();
			return callNode;
		}
	}
	else if (match(TokenType::STRING_LITERAL)) {
		auto stringNode = std::make_unique<ValueNode>(previous().value, previous().type);
		return stringNode;
	}
	else if (match(TokenType::INTEGER_LITERAL)) {
		auto intNode = std::make_unique<ValueNode>(previous().value, previous().type);
		return intNode;
	}
	else {
		error("Expected simple expression in attribute");
		return nullptr;
	}
}

std::unique_ptr<ClassBodyNode> Parser::parseClassBody() {
	auto classBody = std::make_unique<ClassBodyNode>();
	while (!check(TokenType::OPERATOR, "}")) {
		if (isAtEnd()) {
			error("Unterminated class body");
			return nullptr;
		}

		if (match(TokenType::KEYWORD, "def")) {
			classBody->methods.push_back(parseFunctionDeclaration());
		}
		else if (match(TokenType::KEYWORD, "val") || match(TokenType::KEYWORD, "var")) {
			bool isMutable = previous().value == "var";
			classBody->fields.push_back(parseVariableDeclaration(isMutable));
		}
		else {
			error("Unexpected token in class body");
			advance();
		}
	}
	return classBody;
}

std::vector<std::unique_ptr<ASTNode>> Parser::parseCallParameterList()
{
	std::vector<std::unique_ptr<ASTNode>> arguments;
	while (!check(TokenType::OPERATOR, ")")) {
		if (isAtEnd()) {
			error("Unterminated argument list");
			return std::vector<std::unique_ptr<ASTNode>>();
		}

		arguments.push_back(parseExpression());
		if (!match(TokenType::OPERATOR, ",")) {
			break;
		}
	}

	expect(TokenType::OPERATOR, ")");

	return arguments;
}

std::vector<std::unique_ptr<ParameterNode>> Parser::parseParameterList() {
	std::vector<std::unique_ptr<ParameterNode>> parameters;

	if (!check(TokenType::OPERATOR, ")")) {
		do {
			expect(TokenType::IDENTIFIER);
			std::string paramName = previous().value;

			expect(TokenType::OPERATOR, ":");
			std::unique_ptr<Type> paramType = parseType();

			parameters.push_back(std::make_unique<ParameterNode>(paramName, paramType->clone()));
		} while (match(TokenType::OPERATOR, ","));
	}

	return parameters;
}

std::unique_ptr<ParameterNode> Parser::parseParameter() {
	if (match(TokenType::IDENTIFIER)) {
		std::string paramName = previous().value;
		expect(TokenType::OPERATOR, ":");
		std::unique_ptr<Type> paramType = parseType();
		auto param = std::make_unique<ParameterNode>();
		param->name = paramName;
		param->type = paramType ? paramType->clone() : std::make_unique<UnknownType>();
		return param;
	}
	else {
		error("Expected parameter name");
		return nullptr;
	}
}

std::vector<std::unique_ptr<ASTNode>> Parser::parseArgumentList() {
	std::vector<std::unique_ptr<ASTNode>> arguments;
	if (!check(TokenType::OPERATOR, ")")) {
		do {
			arguments.push_back(parseExpression());
		} while (match(TokenType::OPERATOR, ","));
	}
	expect(TokenType::OPERATOR, ")");
	return arguments;
}

std::unique_ptr<ASTNode> Parser::parseLatexCommand() {
	auto latexParser = LatexMathEqParser(&tokens, &position);
	return latexParser.parse();
}

std::unique_ptr<ASTNode> Parser::parseInlineMathLatex() {
	auto latexParser = LatexMathEqParser(&tokens, &position);
	return latexParser.parse();
}

std::unique_ptr<ASTNode> Parser::parseBlockMathLatex() {
	auto latexParser = LatexMathEqParser(&tokens, &position);
	return latexParser.parse();
}
