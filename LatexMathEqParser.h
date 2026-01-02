#include "ast.h"
#include "token.h"

#include <vector>
#include <memory>

// LatexMathEqParser Ŭ������ ������ ���� �� ���� �߰� (parser.cpp ��� �Ǵ� ���� ���Ϸ� �и� ����)
class LatexMathEqParser {
public:
    LatexMathEqParser(const std::vector<Token>* tokens, size_t* position)
        : tokens(tokens), position(position) {
    }

private:
    const std::vector<Token>* tokens;
    size_t* position;

public:
    bool isAtEnd() const;
    const Token& peek(int pos = -1) const;
    const Token& advance();
    const Token& previous() const;
    bool check(TokenType type, const std::string& value = "") const;
    bool match(TokenType type, const std::string& value = "");

    // Latex ���� �Ľ� �޼���
    std::unique_ptr<ASTNode> parse();
	std::unique_ptr<ASTNode> parseExpr();
    std::unique_ptr<ASTNode> parseTerminal();
	std::unique_ptr<ASTNode> parseArg(bool isBrace = false);
    std::unique_ptr<ASTNode> parseSimpleExpr();

    // LaTeX 심볼 인식 함수
    bool isRelationalOperator(const std::string& symbol) const;
    bool isBinaryOperator(const std::string& symbol) const;
    bool isArrow(const std::string& symbol) const;
    bool isMiscSymbol(const std::string& symbol) const;
    bool isLogicalOperator(const std::string& symbol) const;
    bool isCalligraphicFont(const std::string& symbol) const;
};