#include "parser.h"
#include "utils.h"

#include <iostream>
#include "utils.h"

// parser에서는 parsing만 담당하고, symbol 등록 및 검색은 codegen할때 담당
Parser::Parser(const std::vector<Token>& tokens)
	: tokens(tokens), position(0) {}

std::shared_ptr<ProgramNode> Parser::parse() {
	auto program = std::make_shared<ProgramNode>();
	while (!isAtEnd()) {
		auto stmt = parseTopStatement();
		if (stmt) {
			program->statements.push_back(stmt);
		}
	}
	return program;
}

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
			return std::make_shared<GenericType>(baseType, std::vector<std::shared_ptr<Type>>{tempArgsType});
		}

		return baseType;
	}
	else {
		error("Expected type after ':'");
		return std::make_shared<UnknownType>();
	}
}

std::shared_ptr<ASTNode> Parser::parseTopStatement() {
	std::shared_ptr<ASTNode> attributeNode = parseAttribute();

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
		/*std::vector<std::shared_ptr<ASTNode>> stmts;

		if (!match(TokenType::IDENTIFIER)) {
			error("Expected class name");
			return nullptr;
		}

		std::string className = previous().value;

		std::vector<std::shared_ptr<ParameterNode>> constructorParams;
		if (match(TokenType::OPERATOR, "(")) {
			constructorParams = parseParameterList();
			expect(TokenType::OPERATOR, ")");
		}

		expect(TokenType::OPERATOR, "{");

		while (!match(TokenType::OPERATOR, "}")) {
			if (isAtEnd()) {
				error("Unterminated class declaration");
				return nullptr;
			}
			auto stmt = parseStatement();
			stmts.push_back(stmt);
		}

		std::shared_ptr<ClassBodyNode> classBody = std::make_shared<ClassBodyNode>();
		for (auto stmt : stmts) {
			if (auto fieldDecl = std::dynamic_pointer_cast<VariableDeclarationNode>(stmt)) {
				fieldDecl->isField = true;
				classBody->fields.push_back(fieldDecl);
			}
			else if (auto methodDecl = std::dynamic_pointer_cast<FunctionDeclarationNode>(stmt)) {
				classBody->methods.push_back(methodDecl);
			}
			else {
				error("Unexpected token in class body");
			}
		}

		bool hasConstructor = false;
		for (const auto& method : classBody->methods) {
			if (method->name == className) {
				hasConstructor = true;
				break;
			}
		}

		if (!hasConstructor) {
			auto defaultConstructor = std::make_shared<FunctionDeclarationNode>();
			defaultConstructor->name = className;
			defaultConstructor->parameters = constructorParams;
			defaultConstructor->returnType = std::make_shared<BasicType>("Unit");
			auto constructorBody = std::make_shared<BlockNode>();
			for (const auto& param : constructorParams) {
				auto assignment = std::make_shared<AssignmentExpressionNode>();
				assignment->left = std::make_shared<AccessFieldNode>(std::make_shared<IdentifierNode>("this"), std::make_shared<IdentifierNode>(param->name));
				assignment->right = std::make_shared<IdentifierNode>(param->name);
				constructorBody->statements.push_back(assignment);
			}
			defaultConstructor->body = constructorBody;
			classBody->methods.push_back(defaultConstructor);
		}

		std::shared_ptr<ClassDeclarationNode> classNode = std::make_shared<ClassDeclarationNode>();
		classNode->name = className;
		classNode->constructorParams = constructorParams;
		classNode->body = classBody;
		return classNode;*/
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
		// attributeNode의 expr를 node에 적용
		dynamic_cast<AttributeNode*>(attributeNode.get())->target = node;
		return attributeNode;
	}
}

std::shared_ptr<ASTNode> Parser::parseAttribute() {
	if (match(TokenType::OPERATOR, "[@")) {
		if (check(TokenType::IDENTIFIER)) {
			auto simpleExpr = parseAttrSimpleExpression();
			match(TokenType::OPERATOR, "]");
			auto attributeNode = std::make_shared<AttributeNode>();
			attributeNode->expr = simpleExpr;
			return attributeNode;
		}
		else {
			error("Expected identifier after '@' for attribute");
			return nullptr;
		}
	}

	// attribute는 optional이므로 없으면 그냥 nullptr 반환
	return nullptr;
}

std::shared_ptr<ASTNode> Parser::parseAttrSimpleExpression() {
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

std::shared_ptr<ASTNode> Parser::parseImportStatement() {
	std::vector<std::string> pathComponents;

	do {
		if (match(TokenType::IDENTIFIER)) {
			pathComponents.push_back(previous().value);
		}
		else {
			error("Expected identifier in import statement");
			return nullptr;
		}
	} while (match(TokenType::OPERATOR, "."));

	auto importNode = std::make_shared<ImportNode>();
	importNode->path = pathComponents;
	return importNode;
}

std::shared_ptr<ASTNode> Parser::parseClassDeclaration() {
	if (match(TokenType::IDENTIFIER)) {
		std::string className = previous().value;

		std::vector<std::shared_ptr<ParameterNode>> constructorParams;
		if (match(TokenType::OPERATOR, "(")) {
			constructorParams = parseParameterList();
			expect(TokenType::OPERATOR, ")");
		}

		std::string superClassName;
		if (match(TokenType::KEYWORD, "extends")) {
			if (match(TokenType::IDENTIFIER)) {
				superClassName = previous().value;
			}
			else {
				error("Expected superclass name after 'extends'");
			}
		}

		std::shared_ptr<ClassBodyNode> classBody;
		if (match(TokenType::OPERATOR, "{")) {
			classBody = parseClassBody();
			expect(TokenType::OPERATOR, "}");
		}
		else {
			error("Expected '{' after class declaration");
		}

		auto classDecl = std::make_shared<ClassDeclarationNode>();
		classDecl->name = className;
		classDecl->constructorParams = constructorParams;
		classDecl->superClassName = superClassName;
		classDecl->body = classBody;

		return classDecl;
	}
	else {
		error("Expected class name after 'class'");
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

std::shared_ptr<ASTNode> Parser::parseStatement() {
	if (match(TokenType::KEYWORD, "val") || match(TokenType::KEYWORD, "var")) {
		bool isMutable = previous().value == "var";
		return parseVariableDeclaration(isMutable);
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
		std::shared_ptr<ASTNode> expr = nullptr;
		if (!check(TokenType::END_OF_FILE) && !check(TokenType::OPERATOR, ";")) {
			expr = parseExpression();
		}
		auto returnNode = std::make_shared<ReturnStatementNode>();
		returnNode->expression = expr;
		return returnNode;
	}
	else if (match(TokenType::KEYWORD, "object")) {
		return parseObjectDeclaration();
	}
	else {
		return parseExpression();
	}
}

std::shared_ptr<VariableDeclarationNode> Parser::parseVariableDeclaration(bool isMutable) {
	if (match(TokenType::IDENTIFIER)) {
		std::string varName = previous().value;
		std::shared_ptr<Type> varType;
		std::shared_ptr<ASTNode> initializer;

		if (match(TokenType::OPERATOR, ":")) {
			varType = parseType();
		}
		else {
			varType = nullptr;
		}

		if (match(TokenType::OPERATOR, "=")) {
			if (match(TokenType::KEYWORD, "if")) {
				initializer = parseIfStatement();
			}
			else {
				initializer = parseSimpleExpression();
			}
		}
		else {
			error("Expected '=' in variable declaration");
		}

		// TODO: initializer로 부터 타입 추론코드가 오류가 남
		// if 구문일 경우 타입 추론이 안됨
		// then, else 구문에서 타입을 추론해야 함
		if (varType == nullptr) {
			if (initializer) {
				varType = initializer->getType();

				if (!varType) {
					//error("Cannot infer type of '" + varName + "'");
					varType = std::make_shared<UnknownType>();
				}
			}
		}

		auto varDecl = std::make_shared<VariableDeclarationNode>();
		varDecl->name = varName;
		varDecl->type = varType;
		varDecl->initializer = initializer;
		varDecl->isMutable = isMutable;

		return varDecl;
	}
	else {
		error("Expected identifier after 'val' or 'var'");
		return nullptr;
	}
}

std::shared_ptr<FunctionDeclarationNode> Parser::parseFunctionDeclaration() {
	expect(TokenType::IDENTIFIER);
	std::string functionName = previous().value;

	expect(TokenType::OPERATOR, "(");
	auto parameters = parseParameterList();
	expect(TokenType::OPERATOR, ")");

	std::shared_ptr<Type> returnType;
	if (match(TokenType::OPERATOR, ":")) {
		returnType = parseType();
	}
	else {
		returnType = std::make_shared<BasicType>("Unit");
	}

	std::shared_ptr<BlockNode> body = nullptr;
	if (match(TokenType::OPERATOR, "{")) {
		body = parseBlock();
	}
	else if (match(TokenType::OPERATOR, "=")) {
		auto expr = parseExpression();
		body = std::make_shared<BlockNode>();
		body->statements.push_back(expr);
	}
	else {
		error("Expected '{' or '=' after function declaration");
	}

	auto functionDecl = std::make_shared<FunctionDeclarationNode>();
	functionDecl->name = functionName;
	functionDecl->parameters = parameters;
	functionDecl->returnType = returnType;
	functionDecl->body = body;

	return functionDecl;
}

std::shared_ptr<ASTNode> Parser::parseObjectDeclaration() {
	if (match(TokenType::IDENTIFIER)) {
		std::string objectName = previous().value;
		std::shared_ptr<ASTNode> body;
		if (match(TokenType::OPERATOR, "{")) {
			body = parseBlock();
		}
		else {
			error("Expected '{' after object declaration");
		}
		auto objDecl = std::make_shared<ObjectDeclarationNode>();
		objDecl->name = objectName;
		objDecl->body = body;
		return objDecl;
	}
	else {
		error("Expected object name after 'object'");
		return nullptr;
	}
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
			paramNode->type = paramType;
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
		param->type = paramType;
		return param;
	}
	else {
		error("Expected parameter name");
		return nullptr;
	}
}

std::shared_ptr<BlockNode> Parser::parseBlock() {
	auto block = std::make_shared<BlockNode>();
	while (!match(TokenType::OPERATOR, "}")) {
		if (isAtEnd()) {
			error("Unterminated block");
			return nullptr;
		}
		auto stmt = parseStatement();
		if (stmt) {
			block->statements.push_back(stmt);
		}
	}
	return block;
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

std::shared_ptr<ASTNode> Parser::parseIfStatement() {
	auto ifNode = std::make_shared<IfStatementNode>();

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

std::shared_ptr<ASTNode> Parser::parseForStatement() {
	auto forNode = std::make_shared<ForStatementNode>();

	expect(TokenType::OPERATOR, "(");

	if (match(TokenType::IDENTIFIER)) {
		forNode->variable = previous().value;

		if (match(TokenType::OPERATOR, "<-")) {
			auto startExpr = parseExpression();

			if (match(TokenType::KEYWORD, "to") || match(TokenType::KEYWORD, "until")) {
				forNode->isRange = true;
				forNode->isInclusive = previous().value == "to";

				auto endExpr = parseExpression();

				auto rangeExpr = std::make_shared<RangeExpressionNode>();
				rangeExpr->startExpr = startExpr;
				rangeExpr->endExpr = endExpr;
				rangeExpr->isInclusive = forNode->isInclusive;

				forNode->iterableExpr = rangeExpr;
			}
			else {
				forNode->iterableExpr = startExpr;
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
		else if (match(TokenType::OPERATOR, "=")) {
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

std::shared_ptr<ASTNode> Parser::parseLatexCommand() {
	auto latexParser = LatexMathEqParser(&tokens, &position);
	return latexParser.parse();
}

std::shared_ptr<ASTNode> Parser::parseInlineMathLatex() {

}

std::shared_ptr<ASTNode> Parser::parseBlockMathLatex() {
}

std::shared_ptr<ASTNode> Parser::parseAssignmentExpression()
{
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

std::shared_ptr<ASTNode> Parser::parsePrimaryExpression()
{
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

const char* functionSymbolTable[] = {
	"sum", "int", "biguplus", "bigoplus", "bigvee", "prod", "oint", "bigcap", "bigotimes", "bigwedge", "coprod", "iint", "bigcup", "bigodot", "bigsqcup",
    "arccos", "arcsin", "arctan", "arg",
    "cos", "cosh", "cot", "coth",
    "csc", "deg", "det", "dim",
    "exp", "gcd", "hom", "inf",
    "ker", "lg", "lim", "liminf",
    "limsup", "ln", "log", "max",
    "min", "Pr", "sec", "sin",
    "sinh", "sup", "tan", "tanh"
};
