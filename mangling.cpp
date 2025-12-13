#include "mangling.h"
#include "utils.h"

#include <algorithm>
#include <iostream>
#include <map>
#include <memory>
#include <regex>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>


// --- Data Structures ---

struct TypeNode;

struct TypeNode {
    std::string base_name;
    std::vector<std::shared_ptr<TypeNode>> template_args;
    std::vector<std::string> modifiers; // "const", "*", "&", "const_pre"
    std::vector<std::shared_ptr<TypeNode>> scopes;

    TypeNode(std::string name) : base_name(name) {}
};

struct FunctionSignature {
    std::string name;
    std::vector<std::shared_ptr<TypeNode>> params;
    std::shared_ptr<TypeNode> return_type;
    std::vector<std::shared_ptr<TypeNode>> scopes;
    bool is_const_method = false;

    FunctionSignature(std::string n, std::vector<std::shared_ptr<TypeNode>> p)
        : name(n), params(p) {
    }
};

// --- Parser ---

/*class CppParser {
    std::vector<std::string> tokens;
    size_t pos = 0;

public:
    CppParser(const std::vector<std::string>& t) : tokens(t) {}

    std::string peek(int offset = 0) {
        if (pos + offset < tokens.size()) {
            return tokens[pos + offset];
        }
        return "";
    }

    std::string consume() {
        std::string t = peek();
        if (!t.empty())
            pos++;
        return t;
    }

    static std::vector<std::string> tokenize(const std::string& text) {
        std::vector<std::string> result;
        // Regex to match identifiers, scope operator ::, or punctuation
        std::regex re("(\\w+|::|[:<>,*&()])");
        auto words_begin = std::sregex_iterator(text.begin(), text.end(), re);
        auto words_end = std::sregex_iterator();

        for (std::sregex_iterator i = words_begin; i != words_end; ++i) {
            std::string match = i->str();
            if (!match.empty()) {
                result.push_back(match);
            }
        }
        return result;
    }

    std::shared_ptr<TypeNode> parse_type() {
        bool is_const = false;
        if (peek() == "const") {
            consume();
            is_const = true;
        }

        // Parse Scoped Types recursively
        std::vector<std::shared_ptr<TypeNode>> segments;

        while (true) {
            std::string name = consume();
            if (name.empty())
                throw std::runtime_error("Unexpected end of type");

            std::vector<std::shared_ptr<TypeNode>> args;
            if (peek() == "<") {
                consume();
                while (peek() != ">") {
                    args.push_back(parse_type());
                    if (peek() == ",")
                        consume();
                }
                consume(); // >
            }

            auto node = std::make_shared<TypeNode>(name);
            node->template_args = args;
            segments.push_back(node);

            if (peek() == "::") {
                consume();
            }
            else {
                break;
            }
        }

        auto final_node = segments.back();
        // Previous segments are scopes
        for (size_t i = 0; i < segments.size() - 1; ++i) {
            final_node->scopes.push_back(segments[i]);
        }

        std::vector<std::string> modifiers;
        if (is_const)
            modifiers.push_back("const_pre");

        while (true) {
            std::string t = peek();
            if (t == "*" || t == "&" || t == "const") {
                consume();
                modifiers.push_back(t);
            }
            else {
                break;
            }
        }
        final_node->modifiers = modifiers;
        return final_node;
    }

    FunctionSignature parse_signature() {
        std::vector<std::string> pre_parens;
        while (peek() != "(") {
            if (peek() == "")
                throw std::runtime_error("Invalid signature: No '(' found");
            pre_parens.push_back(consume());
        }

        if (pre_parens.empty())
            throw std::runtime_error("No function name found");

        std::vector<std::string> name_tokens;
        int idx = (int)pre_parens.size() - 1;
        int bracket_depth = 0;

        // Backward scan to separate Name from Return Type
        while (idx >= 0) {
            std::string t = pre_parens[idx];
            if (t == ">") {
                bracket_depth++;
                name_tokens.insert(name_tokens.begin(), t);
                idx--;
            }
            else if (t == "<") {
                bracket_depth--;
                name_tokens.insert(name_tokens.begin(), t);
                idx--;
            }
            else if (bracket_depth > 0) {
                name_tokens.insert(name_tokens.begin(), t);
                idx--;
            }
            else {
                if (t == "::") {
                    name_tokens.insert(name_tokens.begin(), t);
                    idx--;
                }
                else if (std::regex_match(t, std::regex("\\w+"))) {
                    // Check adjacent identifier boundary (Return Type vs Name)
                    if (!name_tokens.empty()) {
                        if (std::regex_match(name_tokens[0], std::regex("\\w+"))) {
                            // Found boundary: t is part of return type, name_tokens[0] is
                            // start of name
                            break;
                        }
                    }
                    name_tokens.insert(name_tokens.begin(), t);
                    idx--;
                }
                else {
                    break;
                }
            }
        }

        // Everything remaining in pre_parens from 0 to idx is Return Type
        std::vector<std::string> ret_tokens;
        for (int i = 0; i <= idx; ++i) {
            ret_tokens.push_back(pre_parens[i]);
        }

        std::string func_name = "";
        for (const auto& s : name_tokens)
            func_name += s;

        consume(); // (

        std::vector<std::shared_ptr<TypeNode>> params;
        if (peek() != ")") {
            while (true) {
                if (peek() == "void" && peek(1) == ")") {
                    consume();
                    break;
                }
                auto tp = parse_type();

                // Eat variable name if present
                if (peek() != "," && peek() != ")") {
                    consume();
                }

                params.push_back(tp);
                if (peek() == ",") {
                    consume();
                }
                else {
                    break;
                }
            }
        }
        consume(); // )

        FunctionSignature sig(func_name, params);

        // Check for 'const' method qualifier
        if (peek() == "const") {
            consume();
            sig.is_const_method = true;
        }

        // Parse SCOPES from func_name
        auto n_tokens = CppParser::tokenize(func_name);
        CppParser n_parser(n_tokens);
        std::vector<std::shared_ptr<TypeNode>> segments;

        while (true) {
            std::string s_name = n_parser.consume();
            std::vector<std::shared_ptr<TypeNode>> s_args;
            if (n_parser.peek() == "<") {
                n_parser.consume();
                while (n_parser.peek() != ">") {
                    s_args.push_back(n_parser.parse_type());
                    if (n_parser.peek() == ",")
                        n_parser.consume();
                }
                n_parser.consume();
            }
            auto tn = std::make_shared<TypeNode>(s_name);
            tn->template_args = s_args;
            segments.push_back(tn);

            if (n_parser.peek() == "::") {
                n_parser.consume();
            }
            else {
                break;
            }
        }

        if (!segments.empty()) {
            sig.name = segments.back()->base_name;
            for (size_t i = 0; i < segments.size() - 1; ++i) {
                sig.scopes.push_back(segments[i]);
            }
        }

        // Parse Return Type if exists
        if (!ret_tokens.empty()) {
            CppParser ret_parser(ret_tokens);
            // We assume return type is a valid type.
            // If multiple tokens, parse_type should handle it?
            // "unsigned int" -> unsigned is mod? No, "unsigned int" is 2 tokens.
            // Our TypeNode structure is simple base_name.
            // "unsigned int" needs mapping or collapsing?
            // Use parse_type recursively?

            // Simplification: Parse one type. If remaining, those are leading
            // modifiers? (e.g. static?) Or "unsigned int" case? Python version didn't
            // implement robust multi-word types. Let's rely on parse_type to consume
            // what it can.
            sig.return_type = ret_parser.parse_type();
        }

        return sig;
    }
};*/

// --- Itanium Mangler ---

std::map<std::string, std::string> ITANIUM_BASIC_TYPES = {
    {"void", "v"},
    {"bool", "b"},
    {"char", "c"},
    {"signed char", "a"},
    {"unsigned char", "h"},
    {"short", "s"},
    {"unsigned short", "t"},
    {"int", "i"},
    {"unsigned int", "j"},
    {"long", "l"},
    {"unsigned long", "m"},
    {"long long", "x"},
    {"unsigned long long", "y"},
    {"float", "f"},
    {"double", "d"} };

std::string mangle_itanium_type(std::shared_ptr<TypeNode> node);

std::string mangle_itanium_entity(std::shared_ptr<TypeNode> node) {
    std::string res = "";
    if (node->base_name == "std") {
        res += "St";
    }
    else {
        res += std::to_string(node->base_name.length()) + node->base_name;
    }

    if (!node->template_args.empty()) {
        res += "I";
        for (auto& arg : node->template_args) {
            res += mangle_itanium_type(arg);
        }
        res += "E";
    }
    return res;
}

std::string mangle_itanium_type(std::shared_ptr<TypeNode> node) {
    std::string res = "";
    // Modifiers reversed
    for (int i = (int)node->modifiers.size() - 1; i >= 0; --i) {
        std::string mod = node->modifiers[i];
        if (mod == "*")
            res += "P";
        else if (mod == "&")
            res += "R";
        else if (mod == "const" || mod == "const_pre")
            res += "K";
    }

    if (!node->scopes.empty()) {
        res += "N";
        for (auto& s : node->scopes) {
            res += mangle_itanium_entity(s);
        }
        res += mangle_itanium_entity(node);
        res += "E";
    }
    else {
        if (ITANIUM_BASIC_TYPES.count(node->base_name) &&
            node->template_args.empty()) {
            res += ITANIUM_BASIC_TYPES[node->base_name];
        }
        else {
            res += mangle_itanium_entity(node);
        }
    }
    return res;
}

std::string mangle_itanium(FunctionSignature& sig) {
    std::string res = "_Z";

    if (!sig.scopes.empty()) {
        res += "N";
        if (sig.is_const_method)
            res +=
            "K"; // Const method qualifier usually wraps function type in N...E ?
        // Actually for method: _ZN [Scope] [Name] E [Params]
        // Const method: The 'this' parameter is type 'cost Scope*'.
        // Itanium handles const methods by mangling the 'this' type?
        // No, standard Itanium: encoded as part of function type if strictly
        // needed, OR as 'K' after Name? GCC: `void Class::func() const` ->
        // `_ZNK5Class4funcEv` `K` is placed AFTER nested name prefix `N`. _Z N K
        // 5Class 4func E v

        for (auto& s : sig.scopes) {
            res += mangle_itanium_entity(s);
        }
        res += mangle_itanium_entity(std::make_shared<TypeNode>(sig.name));
        res += "E";
    }
    else {
        res += std::to_string(sig.name.length()) + sig.name;
    }

    // Note: My N..K..E implementation details above for scopes might be slightly
    // off. Correct logic: If const member, 'K' is emitted after 'N'.

    // Let's refine the Scope start:
    // If scopes exist, start with N. If const method, NK.
    // BUT we already wrote the loop. Let's fix loop logic.

    // This function body is getting replaced. I'll rewrite the string
    // construction below.
    return res;
}

// Rewriting mangle_itanium cleanly:
std::string mangle_itanium_final(FunctionSignature& sig) {
    std::string res = "_Z";

    if (!sig.scopes.empty()) {
        res += "N";
        if (sig.is_const_method)
            res += "K"; // Const method

        for (auto& s : sig.scopes) {
            res += mangle_itanium_entity(s);
        }
        res += std::to_string(sig.name.length()) + sig.name;
        res += "E";
    }
    else {
        res += std::to_string(sig.name.length()) + sig.name;
        // Global const function? Meaningless usually (parameters const?)
    }

    if (sig.params.empty()) {
        res += "v";
    }
    else {
        for (auto& p : sig.params) {
            res += mangle_itanium_type(p);
        }
    }
    return res;
}

// --- MSVC Mangler ---

std::map<std::string, std::string> MSVC_BASIC_TYPES = {
    {"void", "X"},          {"bool", "_N"},        {"char", "D"},
    {"unsigned char", "E"}, {"short", "F"},        {"unsigned short", "G"},
    {"int", "H"},           {"unsigned int", "I"}, {"long", "J"},
    {"unsigned long", "K"}, {"float", "M"},        {"double", "N"} };

std::string mangle_msvc_type(std::shared_ptr<TypeNode> node) {
    std::string res = "";
    if (node == nullptr)
        return "X"; // Safe guard, void

    for (int i = (int)node->modifiers.size() - 1; i >= 0; --i) {
        std::string mod = node->modifiers[i];
        if (mod == "*")
            res += "PA";
        else if (mod == "&")
            res += "AA";
    }

    if (!node->scopes.empty() || !node->template_args.empty()) {
        if (!node->template_args.empty()) {
            res += "?$" + node->base_name + "@";
            for (auto& arg : node->template_args) {
                res += mangle_msvc_type(arg);
            }
            res += "@";
        }
        else {
            res += node->base_name + "@";
        }

        for (int i = (int)node->scopes.size() - 1; i >= 0; --i) {
            auto s = node->scopes[i];
            if (!s->template_args.empty()) {
                res += "?$" + s->base_name + "@";
                for (auto& arg : s->template_args) {
                    res += mangle_msvc_type(arg);
                }
                res += "@";
            }
            else {
                res += s->base_name + "@";
            }
        }
        res += "@";
    }
    else {
        if (MSVC_BASIC_TYPES.count(node->base_name)) {
            res += MSVC_BASIC_TYPES[node->base_name];
        }
        else {
            res += node->base_name + "@@";
        }
    }
    return res;
}

std::string mangle_msvc(FunctionSignature& sig) {
    std::string res = "?";
    res += sig.name + "@";

    for (int i = (int)sig.scopes.size() - 1; i >= 0; --i) {
        auto s = sig.scopes[i];
        if (!s->template_args.empty()) {
            res += "?$" + s->base_name + "@";
            for (auto& arg : s->template_args) {
                res += mangle_msvc_type(arg);
            }
            res += "@";
        }
        else {
            res += s->base_name + "@";
        }
    }
    res += "@";

    // Calling Convention & Access Specifier
    if (!sig.scopes.empty()) {
        // Member Function
        // Public (Q) + ThisCall (E) -> QE.
        // If const?
        // A: private, Q: public.
        // B: private const, R: public const.
        if (sig.is_const_method) {
            res += "QB"; // Public Const? Wait.
            // Documentation:
            // Q = public near
            // R = public near const
            res += "R";
        }
        else {
            res += "Q"; // Public
        }
        res += "E"; // __thiscall
    }
    else {
        // Global Function
        res += "Y";
        res += "A"; // __cdecl
    }

    // Return Type
    if (sig.return_type) {
        res += mangle_msvc_type(sig.return_type);
    }
    else {
        res += "X"; // Default void
    }

    // Params
    if (sig.params.empty()) {
        res += "X";
    }
    else {
        for (auto& p : sig.params) {
            res += mangle_msvc_type(p);
        }
        res += "@";
    }
    res += "Z";
    return res;
}

#ifdef __TEST__
int main(int argc, char* argv[]) {
    if (argc < 3) {
        std::cout << "Usage: mangler --style [itanium|msvc] \"signature\""
            << std::endl;
        return 1;
    }

    std::string style_flag = argv[1];
    std::string style = "";
    std::string signature = "";

    if (style_flag == "--style") {
        style = argv[2];
        if (argc > 3)
            signature = argv[3];
    }
    else {
        signature = argv[1];
    }

    try {
        auto tokens = CppParser::tokenize(signature);
        CppParser parser(tokens);
        auto sig = parser.parse_signature();

        if (style == "itanium") {
            std::cout << mangle_itanium_final(sig) << std::endl;
        }
        else if (style == "msvc") {
            std::cout << mangle_msvc(sig) << std::endl;
        }
        else {
            std::cerr << "Unknown style: " << style << std::endl;
        }
    }
    catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }

    return 0;
}
#endif