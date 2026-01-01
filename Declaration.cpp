#include "parser.h"
#include "all_ast.h"

std::shared_ptr<ASTNode> Parser::parseAnnotationStatement() {
	if (match(TokenType::OPERATOR, "[@")) {
		if (check(TokenType::IDENTIFIER)) {
			auto simpleExpr = parseAnnotationExpression();
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

	// attribute�� optional�̹Ƿ� ������ �׳� nullptr ��ȯ
	return nullptr;
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

		// TODO: initializer�� ���� Ÿ�� �߷��ڵ尡 ������ ��
		// if ������ ��� Ÿ�� �߷��� �ȵ�
		// then, else �������� Ÿ���� �߷��ؾ� ��
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
		varDecl->type = std::unique_ptr<Type>(varType.get());
		varDecl->initializer = std::unique_ptr<ASTNode>(initializer.get());
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