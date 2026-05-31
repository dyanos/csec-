#include "mangling.h"

#include <algorithm>
#include <cctype>
#include <map>
#include <memory>
#include <sstream>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

namespace {

struct CppType {
    enum class Indirection { Pointer, LValueRef, RValueRef };
    std::vector<std::string> scopes;
    std::string name;
    std::vector<CppType> templateArgs;
    bool isConst = false;
    bool isVolatile = false;
    std::vector<std::pair<Indirection, bool>> indirections;
};

struct CppSignature {
    std::string name;
    std::vector<std::string> scopes;
    std::vector<CppType> params;
    std::unique_ptr<CppType> returnType;
    bool isConstMethod = false;
    bool isStaticMethod = false;
};

bool isIdentifierStart(char ch) {
    return std::isalpha(static_cast<unsigned char>(ch)) || ch == '_';
}

bool isIdentifierContinue(char ch) {
    return std::isalnum(static_cast<unsigned char>(ch)) || ch == '_';
}

std::vector<std::string> tokenize(const std::string& text) {
    std::vector<std::string> tokens;
    for (size_t i = 0; i < text.size();) {
        unsigned char ch = static_cast<unsigned char>(text[i]);
        if (std::isspace(ch)) {
            ++i;
            continue;
        }
        if (isIdentifierStart(text[i])) {
            size_t start = i++;
            while (i < text.size() && isIdentifierContinue(text[i])) ++i;
            tokens.push_back(text.substr(start, i - start));
            continue;
        }
        if (std::isdigit(ch)) {
            size_t start = i++;
            while (i < text.size() && std::isdigit(static_cast<unsigned char>(text[i]))) ++i;
            tokens.push_back(text.substr(start, i - start));
            continue;
        }
        if (i + 1 < text.size()) {
            std::string two = text.substr(i, 2);
            if (two == "::" || two == "&&" || two == "==" || two == "!=" ||
                two == "<=" || two == ">=" || two == "<<" || two == ">>" ||
                two == "++" || two == "--" || two == "->" || two == "[]" ||
                two == "+=" || two == "-=" || two == "*=" ||
                two == "/=" || two == "%=" || two == "&=" || two == "|=" ||
                two == "^=") {
                tokens.push_back(two);
                i += 2;
                continue;
            }
        }
        tokens.push_back(std::string(1, text[i++]));
    }
    return tokens;
}

std::string joinTypeWords(const std::vector<std::string>& words) {
    std::string out;
    for (size_t i = 0; i < words.size(); ++i) {
        if (i) out += " ";
        out += words[i];
    }
    return out;
}

std::string normalizeBuiltinType(std::string name) {
    if (name == "signed") return "int";
    if (name == "unsigned") return "unsigned int";
    if (name == "long int") return "long";
    if (name == "unsigned long int") return "unsigned long";
    if (name == "long long int") return "long long";
    if (name == "unsigned long long int") return "unsigned long long";
    if (name == "__int64") return "long long";
    if (name == "unsigned __int64") return "unsigned long long";
    return name;
}

bool isBuiltinTypeName(const std::string& name) {
    static const std::vector<std::string> names = {
        "void", "bool", "char", "signed char", "unsigned char", "wchar_t",
        "char16_t", "char32_t", "short", "unsigned short", "int", "unsigned int",
        "long", "unsigned long", "long long", "unsigned long long", "float",
        "double", "long double", "std::nullptr_t"
    };
    return std::find(names.begin(), names.end(), name) != names.end();
}

class Parser {
public:
    explicit Parser(std::vector<std::string> tokens) : tokens_(std::move(tokens)) {}

    const std::string& peek(size_t offset = 0) const {
        static const std::string empty;
        size_t index = pos_ + offset;
        return index < tokens_.size() ? tokens_[index] : empty;
    }

    bool consumeIf(const std::string& token) {
        if (peek() == token) {
            ++pos_;
            return true;
        }
        return false;
    }

    std::string consume() {
        if (pos_ >= tokens_.size()) throw std::runtime_error("unexpected end of C++ signature");
        return tokens_[pos_++];
    }

    bool eof() const { return pos_ >= tokens_.size(); }

    CppType parseType() {
        CppType type;
        while (peek() == "const" || peek() == "volatile") {
            if (consume() == "const") type.isConst = true;
            else type.isVolatile = true;
        }

        std::vector<std::string> nameWords;
        while (!eof()) {
            std::string token = peek();
            if (token == "," || token == ")" || token == "*" || token == "&" ||
                token == "&&" || token == "const" || token == "volatile") {
                break;
            }
            if (token == "::") {
                if (nameWords.empty()) throw std::runtime_error("expected scope name before '::'");
                type.scopes.push_back(joinTypeWords(nameWords));
                nameWords.clear();
                consume();
                continue;
            }
            if (token == "<") {
                consume();
                while (!consumeIf(">")) {
                    type.templateArgs.push_back(parseType());
                    consumeIf(",");
                }
                continue;
            }
            nameWords.push_back(consume());
        }

        if (nameWords.empty()) throw std::runtime_error("expected C++ type name");
        type.name = normalizeBuiltinType(joinTypeWords(nameWords));

        while (peek() == "const" || peek() == "volatile") {
            if (consume() == "const") type.isConst = true;
            else type.isVolatile = true;
        }

        while (peek() == "*" || peek() == "&" || peek() == "&&") {
            std::string token = consume();
            CppType::Indirection kind = CppType::Indirection::Pointer;
            if (token == "&") kind = CppType::Indirection::LValueRef;
            if (token == "&&") kind = CppType::Indirection::RValueRef;
            bool pointerConst = false;
            while (peek() == "const" || peek() == "volatile") {
                if (consume() == "const") pointerConst = true;
            }
            type.indirections.push_back({kind, pointerConst});
        }

        return type;
    }

private:
    std::vector<std::string> tokens_;
    size_t pos_ = 0;
};

CppType parseTypeTokens(std::vector<std::string> tokens, bool allowParameterName) {
    auto parse = [](const std::vector<std::string>& input) {
        Parser parser(input);
        CppType type = parser.parseType();
        if (!parser.eof()) throw std::runtime_error("unexpected token after C++ type");
        return type;
    };

    try {
        CppType type = parse(tokens);
        if (!allowParameterName || isBuiltinTypeName(type.name) || type.name.find(' ') == std::string::npos) {
            return type;
        }
    } catch (const std::exception&) {
    }

    if (allowParameterName && tokens.size() > 1 && isIdentifierStart(tokens.back()[0])) {
        tokens.pop_back();
        return parse(tokens);
    }

    return parse(tokens);
}

int findMatchingParen(const std::vector<std::string>& tokens, int openIndex) {
    int depth = 0;
    for (int i = openIndex; i < static_cast<int>(tokens.size()); ++i) {
        if (tokens[i] == "(") ++depth;
        if (tokens[i] == ")" && --depth == 0) return i;
    }
    return -1;
}

std::vector<std::string> slice(const std::vector<std::string>& tokens, int begin, int end) {
    if (begin < 0) begin = 0;
    if (end < begin) return {};
    return std::vector<std::string>(tokens.begin() + begin, tokens.begin() + end);
}

std::string compactNameToken(const std::vector<std::string>& tokens) {
    std::string out;
    for (const auto& token : tokens) out += token;
    return out;
}

std::vector<std::string> splitScopedName(const std::string& name) {
    std::vector<std::string> parts;
    size_t start = 0;
    while (start <= name.size()) {
        size_t pos = name.find("::", start);
        if (pos == std::string::npos) {
            parts.push_back(name.substr(start));
            break;
        }
        parts.push_back(name.substr(start, pos - start));
        start = pos + 2;
    }
    return parts;
}

bool tokenCanBeNamePart(const std::string& token) {
    return token == "::" || token == "~" || token == "operator" ||
           token == "[]" || token == "(" || token == ")" || (!token.empty() && isIdentifierContinue(token[0])) ||
           token == "+" || token == "-" || token == "*" || token == "/" || token == "%" ||
           token == "&" || token == "|" || token == "^" || token == "!" || token == "=" ||
           token == "<" || token == ">" || token == "," || token == "->" || token == "++" ||
           token == "--" || token == "==" || token == "!=" || token == "<=" || token == ">=" ||
           token == "<<" || token == ">>" || token == "+=" || token == "-=" || token == "*=" ||
           token == "/=" || token == "%=" || token == "&=" || token == "|=" || token == "^=";
}

bool isConstructorOrDestructor(const CppSignature& sig) {
    return !sig.scopes.empty() && (sig.name == sig.scopes.back() || sig.name == "~" + sig.scopes.back());
}

std::vector<std::vector<std::string>> splitParameterTokens(const std::vector<std::string>& tokens) {
    std::vector<std::vector<std::string>> params;
    std::vector<std::string> current;
    int templateDepth = 0;
    for (const auto& token : tokens) {
        if (token == "<") ++templateDepth;
        if (token == ">") --templateDepth;
        if (token == "," && templateDepth == 0) {
            params.push_back(current);
            current.clear();
            continue;
        }
        current.push_back(token);
    }
    if (!current.empty()) params.push_back(current);
    return params;
}

CppSignature parseSignature(const std::string& signature) {
    auto tokens = tokenize(signature);
    int open = -1;
    int close = -1;
    for (int i = static_cast<int>(tokens.size()) - 1; i >= 0; --i) {
        if (tokens[i] != "(") continue;
        int candidateClose = findMatchingParen(tokens, i);
        if (candidateClose >= 0) {
            open = i;
            close = candidateClose;
            break;
        }
    }
    if (open < 0) throw std::runtime_error("C++ signature must contain a parameter list");
    if (close < 0) throw std::runtime_error("unterminated C++ parameter list");

    CppSignature sig;
    std::vector<std::string> prefix = slice(tokens, 0, open);
    while (!prefix.empty() && (prefix.front() == "extern" || prefix.front() == "inline" ||
                              prefix.front() == "virtual" || prefix.front() == "constexpr" ||
                              prefix.front() == "friend")) {
        prefix.erase(prefix.begin());
    }
    if (!prefix.empty() && prefix.front() == "static") {
        sig.isStaticMethod = true;
        prefix.erase(prefix.begin());
    }
    if (prefix.empty()) throw std::runtime_error("missing C++ function name");

    int nameStart = static_cast<int>(prefix.size()) - 1;
    if (prefix.size() >= 3 && prefix[prefix.size() - 3] == "operator" &&
        prefix[prefix.size() - 2] == "(" && prefix[prefix.size() - 1] == ")") {
        nameStart = static_cast<int>(prefix.size()) - 3;
    }
    if (nameStart > 0 && prefix[nameStart - 1] == "~") --nameStart;
    if (nameStart > 0 && prefix[nameStart - 1] == "operator") --nameStart;
    while (nameStart > 1 && prefix[nameStart - 1] == "::" && tokenCanBeNamePart(prefix[nameStart - 2])) {
        nameStart -= 2;
    }

    std::string fullName = compactNameToken(slice(prefix, nameStart, static_cast<int>(prefix.size())));
    auto nameParts = splitScopedName(fullName);
    sig.name = nameParts.back();
    nameParts.pop_back();
    sig.scopes = std::move(nameParts);

    auto returnTokens = slice(prefix, 0, nameStart);
    if (!returnTokens.empty() && !isConstructorOrDestructor(sig)) {
        sig.returnType = std::make_unique<CppType>(parseTypeTokens(returnTokens, false));
    }

    auto paramTokens = slice(tokens, open + 1, close);
    if (!(paramTokens.size() == 1 && paramTokens[0] == "void") && !paramTokens.empty()) {
        for (const auto& param : splitParameterTokens(paramTokens)) {
            if (!param.empty()) sig.params.push_back(parseTypeTokens(param, true));
        }
    }

    for (int i = close + 1; i < static_cast<int>(tokens.size()); ++i) {
        if (tokens[i] == "const") sig.isConstMethod = true;
    }
    return sig;
}

const std::map<std::string, std::string> kItaniumBuiltin = {
    {"void", "v"}, {"bool", "b"}, {"char", "c"}, {"signed char", "a"},
    {"unsigned char", "h"}, {"wchar_t", "w"}, {"char16_t", "Ds"}, {"char32_t", "Di"},
    {"short", "s"}, {"unsigned short", "t"}, {"int", "i"}, {"unsigned int", "j"},
    {"long", "l"}, {"unsigned long", "m"}, {"long long", "x"}, {"unsigned long long", "y"},
    {"float", "f"}, {"double", "d"}, {"long double", "e"}, {"std::nullptr_t", "Dn"}
};

const std::map<std::string, std::string> kItaniumOperator = {
    {"operator+", "pl"}, {"operator-", "mi"}, {"operator*", "ml"}, {"operator/", "dv"},
    {"operator%", "rm"}, {"operator&", "an"}, {"operator|", "or"}, {"operator^", "eo"},
    {"operator~", "co"}, {"operator!", "nt"}, {"operator=", "aS"}, {"operator<", "lt"},
    {"operator>", "gt"}, {"operator+=", "pL"}, {"operator-=", "mI"}, {"operator*=", "mL"},
    {"operator/=", "dV"}, {"operator%=", "rM"}, {"operator&=", "aN"}, {"operator|=", "oR"},
    {"operator^=", "eO"}, {"operator<<", "ls"}, {"operator>>", "rs"}, {"operator<<=", "lS"},
    {"operator>>=", "rS"}, {"operator==", "eq"}, {"operator!=", "ne"}, {"operator<=", "le"},
    {"operator>=", "ge"}, {"operator&&", "aa"}, {"operator||", "oo"}, {"operator++", "pp"},
    {"operator--", "mm"}, {"operator,", "cm"}, {"operator->", "pt"}, {"operator()", "cl"},
    {"operator[]", "ix"}, {"operator new", "nw"}, {"operator delete", "dl"}
};

std::string itaniumName(const std::string& name) {
    auto opIt = kItaniumOperator.find(name);
    return opIt != kItaniumOperator.end() ? opIt->second : std::to_string(name.size()) + name;
}

std::string itaniumType(const CppType& type);

std::string itaniumTemplateArgs(const std::vector<CppType>& args) {
    if (args.empty()) return "";
    std::string out = "I";
    for (const auto& arg : args) out += itaniumType(arg);
    out += "E";
    return out;
}

std::string itaniumEntity(const CppType& type) {
    std::string encodedName = itaniumName(type.name) + itaniumTemplateArgs(type.templateArgs);
    if (type.scopes.empty()) return encodedName;
    std::string out = "N";
    for (const auto& scope : type.scopes) out += scope == "std" ? "St" : std::to_string(scope.size()) + scope;
    out += encodedName + "E";
    return out;
}

std::string itaniumFunctionName(const CppSignature& sig) {
    if (isConstructorOrDestructor(sig)) return sig.name[0] == '~' ? "D1" : "C1";
    return itaniumName(sig.name);
}

std::string itaniumType(const CppType& type) {
    std::string out;
    for (auto it = type.indirections.rbegin(); it != type.indirections.rend(); ++it) {
        if (it->second) out += "K";
        if (it->first == CppType::Indirection::Pointer) out += "P";
        else if (it->first == CppType::Indirection::LValueRef) out += "R";
        else out += "O";
    }
    if (type.isConst) out += "K";
    if (type.isVolatile) out += "V";
    auto builtin = kItaniumBuiltin.find(type.name);
    if (type.scopes.empty() && type.templateArgs.empty() && builtin != kItaniumBuiltin.end()) return out + builtin->second;
    return out + itaniumEntity(type);
}

std::string mangleItanium(const CppSignature& sig) {
    std::string out = "_Z";
    if (!sig.scopes.empty()) {
        out += "N";
        if (sig.isConstMethod) out += "K";
        for (const auto& scope : sig.scopes) out += scope == "std" ? "St" : std::to_string(scope.size()) + scope;
        out += itaniumFunctionName(sig) + "E";
    } else {
        out += itaniumName(sig.name);
    }
    if (sig.params.empty()) out += "v";
    else for (const auto& param : sig.params) out += itaniumType(param);
    return out;
}

const std::map<std::string, std::string> kMsvcBuiltin = {
    {"void", "X"}, {"bool", "_N"}, {"char", "D"}, {"signed char", "C"},
    {"unsigned char", "E"}, {"wchar_t", "_W"}, {"char16_t", "_S"}, {"char32_t", "_U"},
    {"short", "F"}, {"unsigned short", "G"}, {"int", "H"}, {"unsigned int", "I"},
    {"long", "J"}, {"unsigned long", "K"}, {"long long", "_J"}, {"unsigned long long", "_K"},
    {"float", "M"}, {"double", "N"}, {"long double", "O"}
};

const std::map<std::string, std::string> kMsvcOperator = {
    {"operator new", "??2"}, {"operator delete", "??3"}, {"operator=", "??4"},
    {"operator>>", "??5"}, {"operator<<", "??6"}, {"operator!", "??7"}, {"operator==", "??8"},
    {"operator!=", "??9"}, {"operator[]", "??A"}, {"operator->", "??C"}, {"operator*", "??D"},
    {"operator++", "??E"}, {"operator--", "??F"}, {"operator-", "??G"}, {"operator+", "??H"},
    {"operator&", "??I"}, {"operator/", "??K"}, {"operator%", "??L"}, {"operator<", "??M"},
    {"operator<=", "??N"}, {"operator>", "??O"}, {"operator>=", "??P"}, {"operator,", "??Q"},
    {"operator()", "??R"}, {"operator~", "??S"}, {"operator^", "??T"}, {"operator|", "??U"},
    {"operator&&", "??V"}, {"operator||", "??W"}, {"operator*=", "??X"}, {"operator+=", "??Y"},
    {"operator-=", "??Z"}, {"operator/=", "??_0"}, {"operator%=", "??_1"}, {"operator>>=", "??_2"},
    {"operator<<=", "??_3"}, {"operator&=", "??_4"}, {"operator|=", "??_5"}, {"operator^=", "??_6"}
};

std::string msvcQualifiedName(const std::string& name, const std::vector<std::string>& scopes) {
    if (!scopes.empty() && (name == scopes.back() || name == "~" + scopes.back())) {
        std::string out = name[0] == '~' ? "??1" : "??0";
        for (auto it = scopes.rbegin(); it != scopes.rend(); ++it) out += *it + "@";
        return out + "@";
    }
    auto opIt = kMsvcOperator.find(name);
    std::string out = opIt != kMsvcOperator.end() ? opIt->second : "?" + name;
    out += "@";
    for (auto it = scopes.rbegin(); it != scopes.rend(); ++it) out += *it + "@";
    return out + "@";
}

std::string msvcClassName(const CppType& type) {
    std::string out = type.name + "@";
    for (auto it = type.scopes.rbegin(); it != type.scopes.rend(); ++it) out += *it + "@";
    return out + "@";
}

std::string msvcType(const CppType& type) {
    if (!type.indirections.empty()) {
        const auto& ind = type.indirections.back();
        char cv = (type.isConst || ind.second) ? 'B' : 'A';
        std::string prefix = ind.first == CppType::Indirection::Pointer ? std::string("PE") + cv :
            (ind.first == CppType::Indirection::LValueRef ? std::string("AE") + cv : std::string("$$QE") + cv);
        CppType base = type;
        base.indirections.pop_back();
        base.isConst = false;
        return prefix + msvcType(base);
    }
    auto builtin = kMsvcBuiltin.find(type.name);
    if (type.scopes.empty() && type.templateArgs.empty() && builtin != kMsvcBuiltin.end()) return builtin->second;
    return "V" + msvcClassName(type);
}

std::string mangleMSVC(const CppSignature& sig) {
    std::string out = msvcQualifiedName(sig.name, sig.scopes);
    if (!sig.scopes.empty()) out += sig.isStaticMethod ? "SA" : (sig.isConstMethod ? "QEBA" : "QEAA");
    else out += "YA";
    out += sig.returnType ? msvcType(*sig.returnType) : "X";
    if (sig.params.empty()) out += "X";
    else {
        for (const auto& param : sig.params) out += msvcType(param);
        out += "@";
    }
    return out + "Z";
}

} // namespace

std::string mangleCppSignature(const std::string& signature, CppMangleStyle style) {
    CppSignature parsed = parseSignature(signature);
    return style == CppMangleStyle::Itanium ? mangleItanium(parsed) : mangleMSVC(parsed);
}

std::string mangleItaniumSignature(const std::string& signature) {
    return mangleCppSignature(signature, CppMangleStyle::Itanium);
}

std::string mangleMSVCSignature(const std::string& signature) {
    return mangleCppSignature(signature, CppMangleStyle::MSVC);
}

std::unordered_map<std::string, std::string> mangle(ClassDeclarationNode&) {
    return {};
}

std::string mangle(ObjectDeclarationNode& node) {
    return node.name;
}

std::string mangle(FunctionDeclarationNode& node) {
    std::ostringstream signature;
    signature << (node.returnType ? node.returnType->getName() : "void") << " " << node.name << "(";
    for (size_t i = 0; i < node.parameters.size(); ++i) {
        if (i) signature << ", ";
        auto type = node.parameters[i] ? node.parameters[i]->getType() : nullptr;
        signature << (type ? type->getName() : "void");
    }
    signature << ")";
#ifdef _WIN32
    return mangleMSVCSignature(signature.str());
#else
    return mangleItaniumSignature(signature.str());
#endif
}

std::string mangle(ParameterNode& node) {
    return node.type ? node.type->getName() : "";
}

#ifdef __TEST__
#include <iostream>
int main(int argc, char* argv[]) {
    if (argc < 3) {
        std::cerr << "Usage: mangler --style [itanium|msvc] \"signature\"\n";
        return 1;
    }
    std::string style = argv[1] == std::string("--style") && argc > 3 ? argv[2] : "itanium";
    std::string signature = argv[1] == std::string("--style") && argc > 3 ? argv[3] : argv[2];
    try {
        if (style == "itanium") std::cout << mangleItaniumSignature(signature) << "\n";
        else if (style == "msvc") std::cout << mangleMSVCSignature(signature) << "\n";
        else throw std::runtime_error("unknown style");
    } catch (const std::exception& ex) {
        std::cerr << ex.what() << "\n";
        return 1;
    }
    return 0;
}
#endif
