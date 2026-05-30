#pragma once

#include "ast.h"
#include "token.h"
#include "ArrayLiteralNode.h"

#include <vector>
#include <memory>

// LatexMathEqParser 클래스: LaTeX 수식을 AST로 파싱 (parser.cpp에서 호출)
class LatexMathEqParser {
public:
    LatexMathEqParser(std::vector<Token>* tokens, size_t* position)
        : tokens(tokens), position(position) {
    }

private:
    std::vector<Token>* tokens;
    size_t* position;

public:
    bool isAtEnd() const;
    const Token& peek(int pos = -1) const;
    const Token& advance();
    const Token& previous() const;
    bool check(TokenType type, const std::string& value = "") const;
    bool match(TokenType type, const std::string& value = "");

    // Latex 수식 파싱 메서드
    std::unique_ptr<ASTNode> parse();
	std::unique_ptr<ASTNode> parseExpr();
    std::unique_ptr<ASTNode> parseRelational();
    std::unique_ptr<ASTNode> parseAdditive();
    std::unique_ptr<ASTNode> parseMultiplicative();
    std::unique_ptr<ASTNode> parsePostfix();
    std::unique_ptr<ASTNode> parseTerminal();
	std::unique_ptr<ASTNode> parseArg(bool isBrace = false);
    std::unique_ptr<ASTNode> parseSimpleExpr();

    // LaTeX 명령어 피킹 (\ + command 형태 확인)
    std::string tryPeekLatexCommand() const;

    // Matrix 환경 파싱
    std::unique_ptr<ASTNode> parseMatrixEnvironment(const std::string& envType);
    bool isMatrixEnvironment(const std::string& name) const;

    // LaTeX 심볼 인식 함수
    bool isRelationalOperator(const std::string& symbol) const;
    bool isBinaryOperator(const std::string& symbol) const;
    bool isArrow(const std::string& symbol) const;
    bool isMiscSymbol(const std::string& symbol) const;
    bool isLogicalOperator(const std::string& symbol) const;
    bool isCalligraphicFont(const std::string& symbol) const;
};
