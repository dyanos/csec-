#pragma once

// parser.h
#pragma once

#include "token.h"
#include "ast.h"
#include <vector>
#include <memory>

class ClassBodyNode;
class FunctionDeclarationNode;
class VariableDeclarationNode;
class ParameterNode;
class BlockNode;

class Parser {
public:
    Parser(const std::vector<Token>& tokens);
    std::unique_ptr<ASTNode> parse();

private:
    const std::vector<Token>& tokens;
    size_t position;
    std::vector<size_t> positionStack;

    bool isAtEnd() const;
    const Token& peek(int pos = -1) const;
    const Token& advance();
    const Token& previous() const;
    bool check(TokenType type, const std::string& value = "") const;
    bool match(TokenType type, const std::string& value = "");
    // 현재 Token position 저장/복원
    bool saveTokenPosition();
    void restoreTokenPosition();

    // import, class, object, template....
	std::unique_ptr<ASTNode> parseTopStatement();

    std::unique_ptr<ASTNode> parseAnnotationStatement();
	std::unique_ptr<ASTNode> parseAnnotationExpression();
	std::unique_ptr<ASTNode> parseImportStatement();
	std::unique_ptr<ASTNode> parseClassDeclaration(bool isExternal=false);
    std::unique_ptr<ClassBodyNode> parseClassBody();
    std::unique_ptr<ASTNode> parseObjectDeclaration(bool isExternal=false);


    std::unique_ptr<ASTNode> parseStatement();
    std::unique_ptr<FunctionDeclarationNode> parseFunctionDeclaration(bool isExternal=false);
	std::unique_ptr<VariableDeclarationNode> parseVariableDeclaration(bool isMutable);
    std::unique_ptr<ASTNode> parseIfStatement();
    std::unique_ptr<ASTNode> parseForStatement();
    std::unique_ptr<ASTNode> parseWhileStatement();
    std::unique_ptr<ASTNode> parseMapStatement();
    std::unique_ptr<ASTNode> parsePMapStatement();
    std::unique_ptr<ASTNode> parseReduceStatement();
    std::unique_ptr<ASTNode> parseFilterStatement();
    std::unique_ptr<ASTNode> parseLambdaExpression();
    std::unique_ptr<ASTNode> parseSimpleExpression();
    std::unique_ptr<ASTNode> parseInlineMathLatex();
    std::unique_ptr<ASTNode> parseBlockMathLatex();
    std::unique_ptr<ASTNode> parseLatexCommand();
    std::unique_ptr<ASTNode> parseAssignmentExpression();
	std::unique_ptr<ASTNode> parsePrimaryExpression();
	std::unique_ptr<ASTNode> parseMulDivExpression();
	std::unique_ptr<ASTNode> parseAddSubExpression();
	std::unique_ptr<ASTNode> parseComparisonExpression();
    std::unique_ptr<ASTNode> parseShiftExpression();
	std::unique_ptr<ASTNode> parseEqualityExpression();
    std::unique_ptr<ASTNode> parseConditionExpression();
	std::unique_ptr<ASTNode> parseAndExpression();
	std::unique_ptr<ASTNode> parseOrExpression();
	std::unique_ptr<ASTNode> parseXorExpression();
    std::unique_ptr<ASTNode> parseBitwiseOrExpression();
    std::unique_ptr<ASTNode> parseBitwiseAndExpression();
	std::unique_ptr<ASTNode> parseUnaryExpression();
	std::unique_ptr<ASTNode> parsePostfixExpression();
	std::unique_ptr<ASTNode> parsePrefixExpression();
    std::unique_ptr<ASTNode> parseExpression();
    std::vector<std::unique_ptr<ASTNode>> parseArgumentList();

    std::vector<std::unique_ptr<ASTNode>> parseCallParameterList();
    std::vector<std::unique_ptr<ParameterNode>> parseParameterList();
    std::unique_ptr<ParameterNode> parseParameter();
    std::unique_ptr<Type> parseType();
    std::unique_ptr<BlockNode> parseBlock();

    void expect(TokenType type, const std::string& value = "");
    void error(const std::string& message);
    std::string tokenTypeToString(TokenType type) const;
};
