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
    const Token& peek(int pos = -1) const;
    const Token& advance();
    const Token& previous() const;
    bool check(TokenType type, const std::string& value = "") const;
    bool match(TokenType type, const std::string& value = "");

    // import, class, object, template....
	std::shared_ptr<ASTNode> parseTopStatement();

    std::shared_ptr<ASTNode> parseAttribute();
	std::shared_ptr<ASTNode> parseAttrSimpleExpression();
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
    std::shared_ptr<ASTNode> parseInlineMathLatex();
    std::shared_ptr<ASTNode> parseBlockMathLatex();
    std::shared_ptr<ASTNode> parseLatexCommand();
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

// LatexMathEqParser 클래스의 간단한 선언 및 정의 추가 (parser.cpp 상단 또는 별도 파일로 분리 가능)
class LatexMathEqParser {
public:
    LatexMathEqParser(const std::vector<Token>* tokens, size_t* position)
        : tokens(tokens), position(position) {
    }

private:
    const std::vector<Token>* tokens;
    size_t* position;

public:
    std::shared_ptr<ASTNode> parse() {
        // 실제 LaTeX 파싱 로직은 추후 구현
        // 임시로 ValueNode 반환
        auto node = std::make_shared<ValueNode>();
        node->value = "latex_equation";
        node->valueType = TokenType::STRING_LITERAL;
        return node;
    }

    bool isAtEnd() const {
        return *position >= (*tokens).size() || (*tokens)[*position].type == TokenType::END_OF_FILE;
    }

    const Token& peek(int pos) const {
        if (pos < 0)
            return (*tokens)[*position];
        else if (*position + pos < (*tokens).size())
            return (*tokens)[*position + pos];
        else {
            // END_OF_FILE
            return (*tokens)[(*tokens).size() - 1];
        }
    }

    const Token& advance() {
        if (!isAtEnd()) (*position)++;
        return previous();
    }

    const Token& previous() const {
        return (*tokens)[*position - 1];
    }

    bool check(TokenType type, const std::string& value) const {
        if (isAtEnd()) return false;
        if ((*tokens)[*position].type != type) return false;
        if (!value.empty() && (*tokens)[*position].value != value) return false;
        return true;
    }

    bool match(TokenType type, const std::string& value) {
        while ((*tokens)[*position].type == TokenType::COMMENT) {
            advance();
        }

        if (check(type, value)) {
            advance();
            return true;
        }
        return false;
    }

    std::shared_ptr<ASTNode> parseCmd() {
        // \command 형식의 것을 parsing합니다.
        if ((*tokens)[*position].type == TokenType::OPERATOR) {

        }

        return nullptr;
    }

    std::shared_ptr<ASTNode> parseMathExpression() {
        // +, * 등 체크

    }

};