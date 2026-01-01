#include "LatexMathEqParser.h"

#include "BinaryExpressionNode.h"
#include "FunctionCallNode.h"
#include "IdentifierNode.h"
#include "ForStatementNode.h"
#include "ValueNode.h"
#include "UnitNode.h"
#include "UnaryExpressionNode.h"

#include <iostream>

std::shared_ptr<ASTNode> LatexMathEqParser::parse() {
	// 현재 위치의 토큰이 LATEX_INLINE임을 확인
	if (isAtEnd()) {
		throw std::runtime_error("Unexpected end of input while parsing LaTeX expression.");
	}

	return parseExpr();
}

bool LatexMathEqParser::isAtEnd() const {
	return *position >= tokens->size() || (*tokens)[*position].type == TokenType::END_OF_FILE;
}

const Token& LatexMathEqParser::peek(int pos) const {
	if (pos < 0)
		return (*tokens)[*position];
	else if (*position + pos < tokens->size())
		return (*tokens)[*position + pos];
	else {
		// END_OF_FILE
		return (*tokens)[tokens->size() - 1];
	}
}

const Token& LatexMathEqParser::advance() {
	if (!isAtEnd()) (*position)++;
	return previous();
}

const Token& LatexMathEqParser::previous() const {
	return (*tokens)[*position - 1];
}

bool LatexMathEqParser::check(TokenType type, const std::string& value) const {
	if (isAtEnd()) return false;
	if ((*tokens)[*position].type != type) return false;
	if (!value.empty() && (*tokens)[*position].value != value) return false;
	return true;
}

bool LatexMathEqParser::match(TokenType type, const std::string& value) {
	while ((*tokens)[*position].type == TokenType::COMMENT) {
		advance();
	}

	if (check(type, value)) {
		advance();
		return true;
	}

	return false;
}

// ===== Operator Symbol Tables =====
const char* operatorSymbolTable[] = {
	"+", "-", "*", "/", "^",
	"=", "<", ">", "<=", ">=", "!=",
	"times", "div", "pm", "mp",
	"cdot", "leq", "geq", "neq"
};

// ===== Constant Symbol Tables =====
const char* constantSymbolTable[] = {
	"pi", "e", "i", "phi", "gamma", "inf"
};

// ===== Greek Letter Symbol Tables =====
const char* greekLetterSymbolTable[] = {
	"alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta",
	"iota", "kappa", "lambda", "mu", "nu", "xi", "omicron", "pi",
	"rho", "sigma", "tau", "upsilon", "phi", "chi", "psi", "omega",
	"Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta", "Theta",
	"Iota", "Kappa", "Lambda", "Mu", "Nu", "Xi", "Omicron", "Pi",
	"Rho", "Sigma", "Tau", "Upsilon", "Phi", "Chi", "Psi", "Omega"
};

// ===== Aggregate Function Symbol Tables =====
const char* aggregateFunctionSymbolTable[] = {
	"sum", "int", "biguplus", "bigoplus", "bigvee", "prod", "oint", "bigcap", "bigotimes", "bigwedge", "coprod", "iint", "bigcup", "bigodot", "bigsqcup"
};

// ===== Function No-Arg Symbol Tables =====
const char* functionNoArgSymbolTable[] = {
	"inf", "NaN", "emptyset", "infty"
};

// ===== Function One-Arg Symbol Tables =====
const char* functionOneArgSymbolTable[] = {
	"arccos", "arcsin", "arctan", "arg",
	"cos", "cosh", "cot", "coth",
	"csc", "deg", "det", "dim",
	"exp", "gcd", "hom", "inf",
	"ker", "lg", "lim", "liminf",
	"limsup", "ln", "log", "max",
	"min", "Pr", "sec", "sin",
	"sinh", "sup", "tan", "tanh",
	"sqrt", "overline", "overrightarrow", "underline", "overleftarrow", "widehat", "overbrace", "widetilde", "underbrace"
};

// ===== Function Two-Arg Symbol Tables =====
const char* functionTwoArgSymbolTable[] = {
	"arctan2", "binom", "gcd", "lg", "log", "max", "min", "pow", "frac"
};

// ===== Relational Operators (관계 연산자) =====
// https://www.cmor-faculty.rice.edu/~heinken/latex/symbols.pdf 참고
const char* relationalOperatorSymbolTable[] = {
	"=", "<", ">", "leq", "geq", "neq",
	"approx", "sim", "simeq", "equiv", "cong",
	"ll", "gg", "doteq", "asymp", "propto",
	"perp", "parallel", "models", "mid", "vert"
};

// ===== Binary Operators (이항 연산자) =====
const char* binaryOperatorSymbolTable[] = {
	"+", "-", "*", "/", "^",
	"times", "div", "pm", "mp", "cdot",
	"ast", "star", "cap", "cup", "subseteq",
	"subset", "supseteq", "supset", "in", "notin",
	"bigcap", "bigcup", "circ", "bullet", "oplus",
	"ominus", "otimes", "oslash", "odot", "vee",
	"wedge", "setminus", "backslash", "wr", "sqcap",
	"sqcup", "triangleleft", "triangleright", "lhd", "rhd"
};

// ===== Arrows (화살표) =====
const char* arrowSymbolTable[] = {
	"rightarrow", "leftarrow", "leftrightarrow",
	"Rightarrow", "Leftarrow", "Leftrightarrow",
	"to", "gets", "mapsto", "longmapsto",
	"updownarrow", "Updownarrow", "uparrow", "downarrow",
	"nrightarrow", "nleftarrow", "dashrightarrow", "dashleftarrow",
	"leftharpoonup", "leftharpoondown", "rightharpoonup", "rightharpoondown",
	"leftrightharpoons", "rightleftharpoons", "nearrow", "searrow",
	"swarrow", "nwarrow", "Rrightarrow", "Lleftarrow"
};

// ===== Miscellaneous Symbols (기타 심볼) =====
const char* miscSymbolSymbolTable[] = {
	"infty", "emptyset", "varnothing", "partial", "nabla",
	"hbar", "ell", "imath", "jmath", "Re", "Im",
	"wp", "Bbbk", "oslash", "mho", "dagger", "ddagger",
	"heartsuit", "diamondsuit", "clubsuit", "spadesuit", "sharp",
	"flat", "natural", "smile", "frown", "wr",
	"dag", "ddag", "lozenge", "circledS", "top", "bot",
	"prime", "forall", "exists", "neg", "vert", "Vert",
	"angle", "therefore", "because", "checkmark", "square"
};

// ===== Logical Operators (논리 연산자) =====
const char* logicalOperatorSymbolTable[] = {
	"wedge", "vee", "neg", "forall", "exists",
	"therefore", "because", "Rightarrow", "Leftarrow",
	"Leftrightarrow"
};

// ===== Calligraphic Fonts (필기체 폰트) =====
const char* calligraphicFontSymbolTable[] = {
	"mathcal", "mathbf", "mathit", "mathtt",
	"mathsf", "mathfrak", "mathbb", "mathscr",
	"textit", "textbf", "texttt", "textsf"
};

std::shared_ptr<ASTNode> LatexMathEqParser::parseExpr() {
	auto left = parseSimpleExpr();

	while (true) {
		if (match(TokenType::OPERATOR, "$$") || match(TokenType::OPERATOR, "$") || isAtEnd()) {
			break;
		}

		std::string op = advance().value;

		// 연산자 인식
		bool isOperator = false;
		for (int i = 0; i < sizeof(operatorSymbolTable) / sizeof(operatorSymbolTable[0]); ++i) {
			if (op == operatorSymbolTable[i]) {
				isOperator = true;
				break;
			}
		}

		if (!isOperator) {
			// 인식되지 않은 연산자일 경우, 이전 위치로 되돌아감
			(*position)--;
			break;
		}

		auto right = parseSimpleExpr();

		auto binaryNode = std::make_shared<BinaryExpressionNode>();
		binaryNode->left = left;
		binaryNode->op = op;
		binaryNode->right = right;

		left = binaryNode;
	}

	return left;
}

std::shared_ptr<ASTNode> LatexMathEqParser::parseTerminal() {
	if (match(TokenType::OPERATOR, "\\")) {
		if (check(TokenType::IDENTIFIER)) {
			std::string command = advance().value;

			// 마지막이 '_'인 경우, 명령어에서 제거하고, 다음 token을 첨자 인자로 처리
			if (!command.empty() && command.back() == '_') {
				// *position 위치에 '_' 제거한거 넣기
				command = command.substr(0, command.size() - 1);
				// token 내용 변경
				(*const_cast<std::vector<Token>*>(tokens))[*position - 1].value = command;
				auto nonConstTokens = const_cast<std::vector<Token>*>(tokens);
				nonConstTokens->insert(nonConstTokens->begin() + *position, Token{ TokenType::OPERATOR, "_", peek().line, peek().column });
			}

			// 폰트 명령어 처리 (예: \mathbf, \mathcal)
			if (isCalligraphicFont(command)) {
				auto arg = parseArg(true);
				auto node = std::make_shared<FunctionCallNode>();
				node->functionName = command;
				node->arguments.push_back(arg);
				return node;
			}

			// 두 개 인자 함수 처리
			for (int i = 0; i < sizeof(functionTwoArgSymbolTable) / sizeof(functionTwoArgSymbolTable[0]); ++i) {
				if (command == functionTwoArgSymbolTable[i]) {
					auto firstArg = parseArg();
					auto secondArg = parseArg();

					auto node = std::make_shared<FunctionCallNode>();
					node->functionName = command;
					node->arguments.push_back(firstArg);
					node->arguments.push_back(secondArg);
					return node;
				}
			}

			// 한 개 인자 함수 처리
			for (int i = 0; i < sizeof(functionOneArgSymbolTable) / sizeof(functionOneArgSymbolTable[0]); ++i) {
				if (command == functionOneArgSymbolTable[i]) {
					auto arg = parseArg();

					auto node = std::make_shared<FunctionCallNode>();
					node->functionName = command;
					node->arguments.push_back(arg);
					return node;
				}
			}

			// 그릭 문자 처리
			for (int i = 0; i < sizeof(greekLetterSymbolTable) / sizeof(greekLetterSymbolTable[0]); ++i) {
				if (command == greekLetterSymbolTable[i]) {
					return std::make_shared<IdentifierNode>(command);
				}
			}

			// 상수 처리
			for (int i = 0; i < sizeof(constantSymbolTable) / sizeof(constantSymbolTable[0]); ++i) {
				if (command == constantSymbolTable[i]) {
					return std::make_shared<IdentifierNode>(command);
				}
			}

			// 관계 연산자 처리
			if (isRelationalOperator(command)) {
				return std::make_shared<IdentifierNode>(command);
			}

			// 이항 연산자 처리
			if (isBinaryOperator(command)) {
				return std::make_shared<IdentifierNode>(command);
			}

			// 화살표 처리
			if (isArrow(command)) {
				return std::make_shared<IdentifierNode>(command);
			}

			// 논리 연산자 처리
			if (isLogicalOperator(command)) {
				return std::make_shared<IdentifierNode>(command);
			}

			// 기타 심볼 처리 (infty, emptyset, partial, nabla 등)
			if (isMiscSymbol(command)) {
				return std::make_shared<IdentifierNode>(command);
			}

			// 집계 함수 처리 (sum, int, prod 등)
			for (int i = 0; i < sizeof(aggregateFunctionSymbolTable) / sizeof(aggregateFunctionSymbolTable[0]); ++i) {
				if (command == aggregateFunctionSymbolTable[i]) {
					if (command == "sum") {
						auto node = std::make_shared<ForStatementNode>();

						// upper / lower limit 처리
						std::unordered_map<std::string, std::shared_ptr<ASTNode>> argsMap;
						argsMap["upper"] = nullptr;
						argsMap["lower"] = nullptr;

						while (check(TokenType::OPERATOR, "^") || check(TokenType::OPERATOR, "_")) {
							if (match(TokenType::OPERATOR, "^")) {
								argsMap["upper"] = parseArg(true);
							}
							else if (match(TokenType::OPERATOR, "_")) {
								argsMap["lower"] = parseArg(true);
							}
						}

						if (argsMap["lower"]) {
							if (argsMap["lower"]->nodeType == ASTNodeType::BINARY_EXPRESSION) {
								auto binExpr = std::dynamic_pointer_cast<BinaryExpressionNode>(argsMap["lower"]);
								if (binExpr->op == "=") {
									if (binExpr->left->nodeType == ASTNodeType::IDENTIFIER) {
										auto idNode = std::dynamic_pointer_cast<IdentifierNode>(binExpr->left);
										node->variable = idNode->value;
										node->iterableExpr = binExpr->right;
									}
									else {
										throw std::runtime_error("Expected identifier on the left side of '=' in lower limit.");
									}
								}
								else {
									throw std::runtime_error("Expected '=' operator in lower limit.");
								}
							}
							else if (argsMap["lower"]->nodeType == ASTNodeType::IDENTIFIER) {
								auto forStmt = std::dynamic_pointer_cast<ForStatementNode>(argsMap["lower"]);
								node->variable = forStmt->variable;
								node->iterableExpr = forStmt->iterableExpr;
							}
							else {
								throw std::runtime_error("Expected binary expression in lower limit.");
							}
						}
						else {
							node->variable = "_";
							node->iterableExpr = std::make_shared<UnitNode>();
						}

						if (argsMap["upper"]) {
							node->iterableExpr = argsMap["upper"];
						}
						else {
							node->iterableExpr = std::make_shared<UnitNode>();
						}

						auto blockNode = std::make_shared<BlockNode>();
						blockNode->statements.push_back(parseSimpleExpr());
						node->body = blockNode;

						return node;
					}
					else {
						auto node = std::make_shared<FunctionCallNode>();

						node->functionName = command;

						// upper / lower limit 처리
						std::unordered_map<std::string, std::shared_ptr<ASTNode>> argsMap;
						argsMap["upper"] = nullptr;
						argsMap["lower"] = nullptr;

						while (check(TokenType::OPERATOR, "^") || check(TokenType::OPERATOR, "_")) {
							if (match(TokenType::OPERATOR, "^")) {
								argsMap["upper"] = parseArg(true);
							}
							else if (match(TokenType::OPERATOR, "_")) {
								argsMap["lower"] = parseArg(true);
							}
						}

						if (argsMap["lower"]) {
							node->arguments.push_back(argsMap["lower"]);
						}
						else {
							node->arguments.push_back(std::make_shared<UnitNode>());
						}

						if (argsMap["upper"]) {
							node->arguments.push_back(argsMap["upper"]);
						}
						else {
							node->arguments.push_back(std::make_shared<UnitNode>());
						}

						auto body = parseSimpleExpr();
						node->arguments.push_back(body);

						return node;
					}
				}
			}
		}
		else {
			throw std::runtime_error("Expected command name after '\\'");
		}
	}
	else if (match(TokenType::INTEGER_LITERAL) || match(TokenType::FLOAT_LITERAL) ||
		match(TokenType::EXPONENTIAL_LITERAL) || match(TokenType::HEX_LITERAL) ||
		match(TokenType::BINARY_LITERAL) || match(TokenType::OCTAL_LITERAL)) {
		// 숫자 리터럴 처리
		double v = 0.0;

		switch (previous().type) {
		case TokenType::INTEGER_LITERAL:
			v = (double)std::stoi(previous().value);
			break;
		case TokenType::FLOAT_LITERAL:
			v = std::stod(previous().value);
			break;
		case TokenType::EXPONENTIAL_LITERAL:
			v = std::stod(previous().value);
			break;
		case TokenType::HEX_LITERAL:
			v = (double)std::stoul(previous().value, nullptr, 16);
			break;
		case TokenType::BINARY_LITERAL:
			v = (double)std::stoul(previous().value, nullptr, 2);
			break;
		case TokenType::OCTAL_LITERAL:
			v = (double)std::stoul(previous().value, nullptr, 8);
			break;
		default:
			break;
		}

		std::string value = std::to_string(v);
		return std::make_shared<ValueNode>(value, TokenType::FLOAT_LITERAL);
	}
	else if (match(TokenType::IDENTIFIER)) {
		// 식별자 처리
		return std::make_shared<IdentifierNode>(previous().value);
	}
	return nullptr;
}

std::shared_ptr<ASTNode> LatexMathEqParser::parseSimpleExpr() {
	if (match(TokenType::OPERATOR, "(")) {
		auto expr = parseExpr();
		match(TokenType::OPERATOR, ")");
		return expr;
	}
	else if (match(TokenType::OPERATOR, "-") ||
		match(TokenType::OPERATOR, "+")) {
		auto unaryNode = std::make_shared<UnaryExpressionNode>();
		unaryNode->op = previous().value;
		unaryNode->expression = parseSimpleExpr();
		return unaryNode;
	}

	return parseTerminal();
}

std::shared_ptr<ASTNode> LatexMathEqParser::parseArg(bool isBrace) {
	// 파라미터 파싱 함수 선택
	if (isBrace && !check(TokenType::OPERATOR, "{")) {
		throw std::runtime_error("Expected '{' to start argument.");
		return nullptr;
	}

	if (match(TokenType::OPERATOR, "{")) {
		auto expr = parseExpr();
		match(TokenType::OPERATOR, "}");
		return expr;
	}
	else if (match(TokenType::OPERATOR, "(")) {
		auto expr = parseExpr();
		match(TokenType::OPERATOR, ")");
		return expr;
	}
	else {
		return parseTerminal();
	}

	return nullptr;
}

// ===== LaTeX 심볼 인식 함수들 =====

bool LatexMathEqParser::isRelationalOperator(const std::string& symbol) const {
	for (int i = 0; i < sizeof(relationalOperatorSymbolTable) / sizeof(relationalOperatorSymbolTable[0]); ++i) {
		if (symbol == relationalOperatorSymbolTable[i]) {
			return true;
		}
	}
	return false;
}

bool LatexMathEqParser::isBinaryOperator(const std::string& symbol) const {
	for (int i = 0; i < sizeof(binaryOperatorSymbolTable) / sizeof(binaryOperatorSymbolTable[0]); ++i) {
		if (symbol == binaryOperatorSymbolTable[i]) {
			return true;
		}
	}
	return false;
}

bool LatexMathEqParser::isArrow(const std::string& symbol) const {
	for (int i = 0; i < sizeof(arrowSymbolTable) / sizeof(arrowSymbolTable[0]); ++i) {
		if (symbol == arrowSymbolTable[i]) {
			return true;
		}
	}
	return false;
}

bool LatexMathEqParser::isMiscSymbol(const std::string& symbol) const {
	for (int i = 0; i < sizeof(miscSymbolSymbolTable) / sizeof(miscSymbolSymbolTable[0]); ++i) {
		if (symbol == miscSymbolSymbolTable[i]) {
			return true;
		}
	}
	return false;
}

bool LatexMathEqParser::isLogicalOperator(const std::string& symbol) const {
	for (int i = 0; i < sizeof(logicalOperatorSymbolTable) / sizeof(logicalOperatorSymbolTable[0]); ++i) {
		if (symbol == logicalOperatorSymbolTable[i]) {
			return true;
		}
	}
	return false;
}

bool LatexMathEqParser::isCalligraphicFont(const std::string& symbol) const {
	for (int i = 0; i < sizeof(calligraphicFontSymbolTable) / sizeof(calligraphicFontSymbolTable[0]); ++i) {
		if (symbol == calligraphicFontSymbolTable[i]) {
			return true;
		}
	}
	return false;
}
