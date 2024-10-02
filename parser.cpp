// parser.cpp
#include "parser.h"
#include "utils.h"

#include <iostream>
#include "utils.h"

Parser::Parser(const std::vector<Token>& tokens)
    : tokens(tokens), position(0) {}

// �� �Լ��� ���� (���� �ڵ�� ����)
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

const Token& Parser::peek() const {
    return tokens[position];
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
    if (check(type, value)) {
        advance();
        return true;
    }
    return false;
}

/* std::string Parser::parseType() {
    // ������ Ÿ�� �Ľ� (��: Int, String)
    if (match(TokenType::IDENTIFIER)) {
        std::string typeName = previous().value;
        // ���׸� Ÿ�� ó�� (��: Array[String])
        if (match(TokenType::OPERATOR, "[")) {
            std::string genericType = parseType();
            expect(TokenType::OPERATOR, "]");
            typeName += "[" + genericType + "]";
        }
        return typeName;
    }
    else {
        error("Expected type name");
        return "";
    }
}
*/
std::shared_ptr<Type> Parser::parseType() {
    if (match(TokenType::IDENTIFIER)) {
        std::string typeName = previous().value;

        // Handle basic types
		std::shared_ptr<Type> baseType;
        if (typeName == "Int" || typeName == "Float" || typeName == "Double" || typeName == "Unit") {
            baseType = std::make_shared<BasicType>(typeName);
        }
        else if (typeName == "String") {
			baseType = std::make_shared<ClassType>(typeName);
        }
        else {
            // User-defined types are treated as ClassType
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
	if (match(TokenType::KEYWORD, "import")) {
		// import �� ó��
		// �� ���������� import ���� ����
		while (!check(TokenType::OPERATOR, ";")) {
			if (isAtEnd()) {
				error("Unterminated import statement");
				return nullptr;
			}
			advance();
		}
		advance();  // �����ݷ� ��ŵ
		return nullptr;
	}
	else if (match(TokenType::KEYWORD, "class")) {
		// Ŭ���� ���� ó��
		// �� ���������� Ŭ���� ������ ����
        std::vector<std::shared_ptr<ASTNode>> stmts;

        // class �̸��� ����ϴ�. ���� ����� �������� �ʽ��ϴ�.
        if (!match(TokenType::IDENTIFIER)) {
            error("Expected class name");
            return nullptr;
        }

        std::string className = previous().value;

        // constructor parameters�� �Ľ�
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
				classBody->fields.push_back(fieldDecl);
			} else if (auto methodDecl = std::dynamic_pointer_cast<FunctionDeclarationNode>(stmt)) {
				classBody->methods.push_back(methodDecl);
			} else {
				error("Unexpected token in class body");
			}
		}

        // 생성자가 없는 경우 기본 생성자 추가
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
            defaultConstructor->body = std::make_shared<BlockNode>();
            classBody->methods.push_back(defaultConstructor);
        }

        std::shared_ptr<ClassDeclarationNode> classNode = std::make_shared<ClassDeclarationNode>();
        classNode->name = className;
		classNode->constructorParams = constructorParams;
        classNode->body = classBody;
        return classNode;
	}
    else if (match(TokenType::KEYWORD, "object")) {
        // ��ü ���� ó��
        return parseObjectDeclaration();
    } 
    else {
		return parseStatement();
	} 
}

std::shared_ptr<ASTNode> Parser::parseImportStatement() {
    // ���� ��� "import package.object" ������ ������ import ���� ó���մϴ�.
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

        // Ŭ���� �Ķ���� ��� �Ľ� (���� ����)
        std::vector<std::shared_ptr<ParameterNode>> constructorParams;
        if (match(TokenType::OPERATOR, "(")) {
            constructorParams = parseParameterList();
            expect(TokenType::OPERATOR, ")");
        }

        // ��� Ŭ���� �Ľ� (���� ����)
        std::string superClassName;
        if (match(TokenType::KEYWORD, "extends")) {
            if (match(TokenType::IDENTIFIER)) {
                superClassName = previous().value;
            }
            else {
                error("Expected superclass name after 'extends'");
            }
        }

        // Ŭ���� ���� �Ľ�
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

        // Ŭ���� ��� �Ľ� (�ʵ� �Ǵ� �޼���)
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
    // for �� ó��
    else if (match(TokenType::KEYWORD, "for")) {
        return parseForStatement();
    }
    // �Լ� ���� ó��
    else if (match(TokenType::KEYWORD, "def")) {
        return parseFunctionDeclaration();
    }
    // return �� ó��
    else if (match(TokenType::KEYWORD, "return")) {
        std::shared_ptr<ASTNode> expr = nullptr;
        if (!check(TokenType::END_OF_FILE) && !check(TokenType::OPERATOR, ";")) {
            expr = parseExpression();
        }
        auto returnNode = std::make_shared<ReturnStatementNode>();
        returnNode->expression = expr;
        return returnNode;
    }
    // ��ü ���� ó��
    else if (match(TokenType::KEYWORD, "object")) {
        return parseObjectDeclaration();
    }
    // �� ���������� �Լ��� ��ü ���� ó��
    else {
		return parseExpression();
		//error("Expected statement");
		//return nullptr;
     }
}

std::shared_ptr<VariableDeclarationNode> Parser::parseVariableDeclaration(bool isMutable) {
    if (match(TokenType::IDENTIFIER)) {
        std::string varName = previous().value;
        std::shared_ptr<Type> varType;
        std::shared_ptr<ASTNode> initializer;

        // Ÿ�� ������ �ִ��� Ȯ��
        if (match(TokenType::OPERATOR, ":")) {
            varType = parseType();
        }

        // �ʱ�ȭ ���� �ִ��� Ȯ��
        if (match(TokenType::OPERATOR, "=")) {
            initializer = parseSimpleExpression();
        }
        else {
            error("Expected '=' in variable declaration");
        }

        if (varType == nullptr) {
            // initializer의 평가 결과로부터 변수의 타입 추론
            if (initializer) {
                varType = initializer->getType();

                if (!varType) {
                    error("Cannot infer type of '" + varName + "'");
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

    // ��ȯ Ÿ�� �Ľ�
    std::shared_ptr<Type> returnType;
    if (match(TokenType::OPERATOR, ":")) {
        returnType = parseType();
    }
    else {
        // ��ȯ Ÿ���� ���õ��� ���� ��� �⺻ Ÿ������ ���� (��: void)
        returnType = std::make_shared<BasicType>("Unit");
    }

    // �Լ� ���� �Ľ�
    std::shared_ptr<BlockNode> body = nullptr;
    if (match(TokenType::OPERATOR, "{")) {
        body = parseBlock();
    }
    else if (match(TokenType::OPERATOR, "=")) {
        // ���� ǥ���� �Լ� ���� ó��
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
    functionDecl->returnType = returnType;  // ��ȯ Ÿ�� ����
    functionDecl->body = body;

    return functionDecl;
}

std::shared_ptr<ASTNode> Parser::parseObjectDeclaration() {
    // ��ü �̸�
    if (match(TokenType::IDENTIFIER)) {
        std::string objectName = previous().value;
        // ��ü ����
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
	// �Լ� ȣ�� �� ���޵Ǵ� �μ� ��� �Ľ�
	std::vector<std::shared_ptr<ASTNode>> arguments;
	while (true) {
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
        // �ʿ��� ��� ��Ÿ ���� �߰�
    default: return "token";
    }
}

std::shared_ptr<ASTNode> Parser::parseIfStatement() {
    auto ifNode = std::make_shared<IfStatementNode>();

    // ���ǽ� �Ľ� (���⼭�� ������ IDENTIFIER �Ǵ� ���ͷ��� ����)
    expect(TokenType::OPERATOR, "(");
    ifNode->condition = parseExpression();
    expect(TokenType::OPERATOR, ")");

    // then ���� �Ľ�
    if (match(TokenType::OPERATOR, "{")) {
        ifNode->thenBlock = parseBlock();
    }
    else {
        error("Expected '{' after 'if' condition");
    }

    // else ���� �Ľ� (������)
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

    // ���� �Ľ�
    if (match(TokenType::IDENTIFIER)) {
        forNode->variable = previous().value;

        if (match(TokenType::OPERATOR, "<-")) {
            // `to` �Ǵ� `until`�� �ִ��� Ȯ��
            auto startExpr = parseExpression();

            if (match(TokenType::KEYWORD, "to") || match(TokenType::KEYWORD, "until")) {
                forNode->isRange = true;
                forNode->isInclusive = previous().value == "to";

                auto endExpr = parseExpression();

                // ���� ǥ������ �����Ͽ� iterableExpr�� ����
                auto rangeExpr = std::make_shared<RangeExpressionNode>();
                rangeExpr->startExpr = startExpr;
                rangeExpr->endExpr = endExpr;
                rangeExpr->isInclusive = forNode->isInclusive;

                forNode->iterableExpr = rangeExpr;
            }
            else {
                // �÷��� ǥ�������� ����
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

    // for ���� �Ľ�
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
    // ������ ǥ���� �Ľ� �Լ� (IDENTIFIER �Ǵ� ���ͷ��� ó��)
    std::shared_ptr<ASTNode> expr;

    if (match(TokenType::IDENTIFIER)) {
        std::vector<std::string> pathComponents;
        pathComponents.push_back(previous().value);
        while (match(TokenType::OPERATOR, ".")) {
            // �ٷ� ������ id�� ���� ���� match clause�� ���� ��츦 ó���ؾ� �ϴµ�, ���⼭�� id�� ���� ���� ����
            if (match(TokenType::IDENTIFIER)) {
                pathComponents.push_back(previous().value);
            }
            else {
                error("Expected identifier after '.'");
                return nullptr;
            }
        }

        if (match(TokenType::OPERATOR, "(")) {
            // �Լ� ȣ�� ǥ���� �Ľ�
			if (pathComponents.size() == 1) {
				// ���� �Լ� ȣ�� (��: println())
				auto callNode = std::make_shared<FunctionCallNode>();
				callNode->functionName = pathComponents[0];
				callNode->arguments = parseCallParameterList();
				return callNode;
            }
            else {
                auto callNode = std::make_shared<MethodCallNode>();

                // TODO: template �Լ� ȣ�⿡ ���� ó���� ���߿� �ؾ��� �� 
                std::vector<std::string> result;
                std::copy(pathComponents.begin(), pathComponents.end() - 1, std::back_inserter(result));

                callNode->object = std::make_shared<IdentifierNode>(join(result, "."));
                callNode->methodName = pathComponents.back();
                callNode->arguments = parseCallParameterList();

                return callNode;
            }
        } 
        else if (match(TokenType::OPERATOR, "=")) {
			// �Ҵ� ǥ���� �Ľ�
			auto assignNode = std::make_shared<AssignmentExpressionNode>();
			assignNode->left = std::make_shared<IdentifierNode>(join(pathComponents, "."));
			assignNode->right = parseExpression();
			return assignNode;
        } 

        auto exprNode = std::make_shared<IdentifierNode>(pathComponents.back());
        expr = exprNode;
    }
    else if (match(TokenType::INTEGER_LITERAL) ||
        match(TokenType::FLOAT_LITERAL) ||
        match(TokenType::EXPONENTIAL_LITERAL) ||
        match(TokenType::HEX_LITERAL) ||
        match(TokenType::BINARY_LITERAL) ||
        match(TokenType::OCTAL_LITERAL) ||
        match(TokenType::STRING_LITERAL)) {
        auto exprNode = std::make_shared<ValueNode>(previous().value, previous().type);
        expr = exprNode;
    }
    else if (match(TokenType::OPERATOR, "_")) {
        expr = std::make_shared<UnitNode>();
    }
    else if (match(TokenType::OPERATOR, "{")) {
        // ���� ǥ���� �Ľ�
        expr = parseBlock();
    }
    else if (match(TokenType::KEYWORD, "new")) {
        // ��ü ���� ǥ���� �Ľ�
        if (match(TokenType::IDENTIFIER)) {
            //auto id = std::make_shared<IdentifierNode>(previous().value);
            // new keyword �ڿ��� argument list�� �迭�� ũ�⸦ �����ϴ� []�� ���� �� ����.
            // []�� 4�������� �⺻������ �����ϵ��� ����.
            // []�� ������ �迭�� �����ϰ�, argument list�� ������ ������ ȣ��� ��������.
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
        //error("Expected expression");
        // empty�� ��쵵 ����(��, println())
        // �̰� �´��� ���� �ʿ�
        return nullptr;
    }

    return expr;
}

std::shared_ptr<ASTNode> Parser::parseAssignmentExpression()
{
	if (match(TokenType::OPERATOR, "="))
	{
		auto assignNode = std::make_shared<AssignmentExpressionNode>();
        assignNode->left = parseExpression();
		assignNode->right = parseExpression();
		return assignNode;
	}
	else
	{
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

// ������ ǥ���� �Ľ� �Լ� (IDENTIFIER �Ǵ� ���ͷ��� ó��)
std::shared_ptr<ASTNode> Parser::parseExpression() {
    // c++�� ������ �켱������ ���� �ڵ带 �����մϴ�.
    std::shared_ptr<ASTNode> expr = parseOrExpression();

    // ���� ������ 'match' Ű���尡 ������ MatchExpression���� ó��
    if (match(TokenType::KEYWORD, "match")) {
        auto matchNode = std::make_shared<MatchExpressionNode>();
        matchNode->expression = expr;

        expect(TokenType::OPERATOR, "{");

        // ���̽� ��� �Ľ�
        while (!check(TokenType::OPERATOR, "}")) {
            if (isAtEnd()) {
                error("Unterminated 'match' block");
                return nullptr;
            }

            // 'case' Ű���� Ȯ��
            expect(TokenType::KEYWORD, "case");

            // ���̽� ���� �Ľ�
            auto casePattern = parseSimpleExpression();

            expect(TokenType::OPERATOR, "=>");

            // ��� ǥ���� �Ľ�
            auto caseResult = parseExpression();

            matchNode->cases.push_back(std::make_pair(casePattern, caseResult));
        }

        expect(TokenType::OPERATOR, "}");

        expr = matchNode;
    }

    return expr;
}
