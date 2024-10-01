#pragma once

// parser.h
#pragma once

#include "token.h"
#include "ast.h"
#include <vector>
#include <memory>

class Parser {
public:
    Parser(const std::vector<Token>& tokens);
    std::shared_ptr<ProgramNode> parse();

private:
    const std::vector<Token>& tokens;
    size_t position;

    bool isAtEnd() const;
    const Token& peek() const;
    const Token& advance();
    const Token& previous() const;
    bool check(TokenType type, const std::string& value = "") const;
    bool match(TokenType type, const std::string& value = "");

    // import, class, object, template....
	std::shared_ptr<ASTNode> parseTopStatement();

	std::shared_ptr<ASTNode> parseImportStatement();
	std::shared_ptr<ASTNode> parseClassDeclaration();
    std::shared_ptr<ClassBodyNode> parseClassBody();
    std::shared_ptr<ASTNode> parseObjectDeclaration();


    std::shared_ptr<ASTNode> parseStatement();
    std::shared_ptr<FunctionDeclarationNode> parseFunctionDeclaration();

	std::shared_ptr<VariableDeclarationNode> parseVariableDeclaration(bool isMutable);
    std::shared_ptr<ASTNode> parseIfStatement();
    std::shared_ptr<ASTNode> parseForStatement();
    std::shared_ptr<ASTNode> parseSimpleExpression();
	std::shared_ptr<ASTNode> parseAssignmentExpression();
	std::shared_ptr<ASTNode> parsePrimaryExpression();
	std::shared_ptr<ASTNode> parseMulDivExpression();
	std::shared_ptr<ASTNode> parseAddSubExpression();
	std::shared_ptr<ASTNode> parseComparisonExpression();
    std::shared_ptr<ASTNode> parseShiftExpression();
	std::shared_ptr<ASTNode> parseEqualityExpression();
    std::shared_ptr<ASTNode> parseConditionExpression();
	std::shared_ptr<ASTNode> parseAndExpression();
	std::shared_ptr<ASTNode> parseOrExpression();
	std::shared_ptr<ASTNode> parseXorExpression();
    std::shared_ptr<ASTNode> parseBitwiseOrExpression();
    std::shared_ptr<ASTNode> parseBitwiseAndExpression();
	std::shared_ptr<ASTNode> parseUnaryExpression();
	std::shared_ptr<ASTNode> parsePostfixExpression();
	std::shared_ptr<ASTNode> parsePrefixExpression();
    std::shared_ptr<ASTNode> parseExpression();
    std::vector<std::shared_ptr<ASTNode>> parseArgumentList();

    std::vector<std::shared_ptr<ASTNode>> parseCallParameterList();
    std::vector<std::shared_ptr<ParameterNode>> parseParameterList();
    std::shared_ptr<ParameterNode> parseParameter();
    std::shared_ptr<Type> parseType();
    std::shared_ptr<BlockNode> parseBlock();

    void expect(TokenType type, const std::string& value = "");
    void error(const std::string& message);
    std::string tokenTypeToString(TokenType type) const;
};
