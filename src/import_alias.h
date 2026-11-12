#pragma once

// Import aliases, shared by the native compiler (main.cpp) and the self-hosted compiler's import
// expansion (native_runtime/runtime_services.inc):
//
//     import std.dataframe = df;
//     val t = df.readParquet("sales.parquet");
//
// Imports are textual, so a module's top-level functions are always visible unqualified. An alias
// adds qualified access: in the importing file, `alias.name` is rewritten to `name` when `name` is a
// top-level function (def or external def) of the aliased module. Anything else is left alone, so a
// variable that happens to share the alias name keeps working (`df.length`). The rewrite skips
// comments, string and char literals (string contents are never rewritten), and the import lines.

#include <cctype>
#include <map>
#include <set>
#include <string>
#include <vector>

namespace csec_imports {

inline bool isIdentStart(unsigned char c) { return std::isalpha(c) || c == '_' || c >= 0x80; }
inline bool isIdentPart(unsigned char c) { return std::isalnum(c) || c == '_' || c >= 0x80; }

inline std::string trimAscii(const std::string& text) {
    const auto first = text.find_first_not_of(" \t\r\n");
    if (first == std::string::npos) return std::string();
    const auto last = text.find_last_not_of(" \t\r\n");
    return text.substr(first, last - first + 1);
}

inline bool isIdentifier(const std::string& text) {
    if (text.empty() || !isIdentStart(static_cast<unsigned char>(text[0]))) return false;
    for (unsigned char c : text) {
        if (!isIdentPart(c)) return false;
    }
    return true;
}

struct ImportSpec {
    std::string target;  // dotted name or path, quotes removed
    std::string alias;   // "" when the import has no alias
    std::string error;   // malformed alias
};

// Parse the text after the `import` keyword (any trailing ';' already removed or not):
//   std.dataframe            -> target
//   std.dataframe = df       -> target + alias
//   "lib/x.csec" = x         -> quoted target + alias
inline ImportSpec splitImport(std::string rest) {
    ImportSpec spec;
    rest = trimAscii(rest);
    if (!rest.empty() && rest.back() == ';') rest = trimAscii(rest.substr(0, rest.size() - 1));
    size_t equals = std::string::npos;
    if (!rest.empty() && (rest[0] == '"' || rest[0] == '\'')) {
        const auto close = rest.find(rest[0], 1);
        if (close != std::string::npos) equals = rest.find('=', close + 1);
    } else {
        equals = rest.find('=');
    }
    std::string target = equals == std::string::npos ? rest : trimAscii(rest.substr(0, equals));
    if (equals != std::string::npos) {
        spec.alias = trimAscii(rest.substr(equals + 1));
        if (!isIdentifier(spec.alias)) {
            spec.error = "invalid import alias '" + spec.alias + "' (expected an identifier after '=')";
            spec.alias.clear();
        }
    }
    if (target.size() >= 2 && ((target.front() == '"' && target.back() == '"') || (target.front() == '\'' && target.back() == '\''))) {
        target = target.substr(1, target.size() - 2);
    }
    spec.target = target;
    return spec;
}

// Is `line` (any indentation) an import line?
inline bool isImportLine(const std::string& line) {
    const std::string trimmed = trimAscii(line);
    if (trimmed.rfind("import", 0) != 0) return false;
    if (trimmed.size() == 6) return true;
    const char next = trimmed[6];
    return next == ' ' || next == '\t' || next == '"' || next == '\'';
}

// Scanner over csec source. Calls `onCode(pos, braceDepth)` at each position of code (not inside a
// comment, string, or char literal); it returns how many characters it consumed (0 = one). String
// contents, including "${...}" (which interpolates a plain variable), are never code.
template <typename OnCode>
void scanCode(const std::string& src, OnCode onCode) {
    int depth = 0;
    size_t i = 0;
    const size_t n = src.size();
    while (i < n) {
        const char c = src[i];
        if (c == '/' && i + 1 < n && src[i + 1] == '/') {
            const auto end = src.find('\n', i);
            i = end == std::string::npos ? n : end;
        } else if (c == '/' && i + 1 < n && src[i + 1] == '*') {
            const auto end = src.find("*/", i + 2);
            i = end == std::string::npos ? n : end + 2;
        } else if ((c == 'r' || c == 'R') && i + 1 < n && src[i + 1] == '"' && (i == 0 || !isIdentPart(static_cast<unsigned char>(src[i - 1])))) {
            const auto end = src.find('"', i + 2);  // raw string: no escapes
            i = end == std::string::npos ? n : end + 1;
        } else if (c == '"') {
            ++i;
            while (i < n && src[i] != '"') i += (src[i] == '\\' && i + 1 < n) ? 2 : 1;
            ++i;
        } else if (c == '\'') {
            // Char literal ('a', '\n'); a lone quote is skipped.
            size_t j = i + 1;
            j += (j < n && src[j] == '\\') ? 2 : 1;
            i = (j < n && src[j] == '\'') ? j + 1 : i + 1;
        } else if (c == '{') {
            ++depth;
            ++i;
        } else if (c == '}') {
            if (depth > 0) --depth;
            ++i;
        } else {
            const size_t used = onCode(i, depth);
            i += used > 0 ? used : 1;
        }
    }
}

// Top-level function names (`def f`, `external def f`, with or without attributes) of a module.
inline std::set<std::string> topLevelFunctions(const std::string& src) {
    std::set<std::string> names;
    scanCode(src, [&](size_t i, int depth) -> size_t {
        if (!isIdentStart(static_cast<unsigned char>(src[i])) || (i > 0 && isIdentPart(static_cast<unsigned char>(src[i - 1])))) return 0;
        size_t j = i;
        while (j < src.size() && isIdentPart(static_cast<unsigned char>(src[j]))) ++j;
        if (depth == 0 && src.compare(i, j - i, "def") == 0) {
            size_t k = j;
            while (k < src.size() && (src[k] == ' ' || src[k] == '\t')) ++k;
            size_t e = k;
            while (e < src.size() && isIdentPart(static_cast<unsigned char>(src[e]))) ++e;
            if (e > k) names.insert(src.substr(k, e - k));
        }
        return j - i;
    });
    return names;
}

struct Alias {
    std::string module;            // the import target, for messages
    std::set<std::string> members;  // its top-level functions
};

// Rewrite `alias.member` to `member` in `src` (import lines excluded). `alias.other`, where `other`
// is not a function of the module, is left unchanged (it may be a member access on a variable).
inline std::string rewriteAliases(const std::string& src, const std::map<std::string, Alias>& aliases) {
    if (aliases.empty()) return src;
    // Byte ranges of import lines, which are copied verbatim.
    std::vector<std::pair<size_t, size_t>> importLines;
    for (size_t start = 0; start <= src.size();) {
        size_t end = src.find('\n', start);
        if (end == std::string::npos) end = src.size();
        if (isImportLine(src.substr(start, end - start))) importLines.emplace_back(start, end);
        if (end == src.size()) break;
        start = end + 1;
    }
    auto inImportLine = [&](size_t pos) {
        for (const auto& range : importLines) {
            if (pos >= range.first && pos < range.second) return true;
        }
        return false;
    };
    std::vector<std::pair<size_t, size_t>> cuts;  // [start, end) to delete ("alias.")
    scanCode(src, [&](size_t i, int) -> size_t {
        const unsigned char c = static_cast<unsigned char>(src[i]);
        if (!isIdentStart(c) || (i > 0 && (isIdentPart(static_cast<unsigned char>(src[i - 1])) || src[i - 1] == '.'))) return 0;
        size_t j = i;
        while (j < src.size() && isIdentPart(static_cast<unsigned char>(src[j]))) ++j;
        if (j < src.size() && src[j] == '.' && j + 1 < src.size() && isIdentStart(static_cast<unsigned char>(src[j + 1])) && !inImportLine(i)) {
            const auto alias = aliases.find(src.substr(i, j - i));
            if (alias != aliases.end()) {
                size_t k = j + 1;
                while (k < src.size() && isIdentPart(static_cast<unsigned char>(src[k]))) ++k;
                const std::string member = src.substr(j + 1, k - j - 1);
                if (alias->second.members.count(member)) {
                    cuts.emplace_back(i, j + 1);
                    return k - i;
                }
            }
        }
        return j - i;
    });
    if (cuts.empty()) return src;
    std::string out;
    out.reserve(src.size());
    size_t from = 0;
    for (const auto& cut : cuts) {
        out.append(src, from, cut.first - from);
        from = cut.second;
    }
    out.append(src, from, std::string::npos);
    return out;
}


// The import target of an import line ("" if `line` is not one), without any alias.
inline std::string importTarget(const std::string& line) {
    if (!isImportLine(line)) return std::string();
    return splitImport(trimAscii(line).substr(6)).target;
}

// Collect the aliases that `source` declares and apply them to it. `resolve(target)` returns the
// module's path ("" if not found) and `read(path)` its text. Problems are appended to `errors`.
template <typename Resolve, typename Read>
std::string applyImportAliases(const std::string& source, Resolve resolve, Read read, std::vector<std::string>& errors) {
    if (source.find('=') == std::string::npos || source.find("import") == std::string::npos) return source;
    std::map<std::string, Alias> aliases;
    for (size_t start = 0; start <= source.size();) {
        size_t end = source.find('\n', start);
        if (end == std::string::npos) end = source.size();
        const std::string line = source.substr(start, end - start);
        if (isImportLine(line)) {
            const ImportSpec spec = splitImport(trimAscii(line).substr(6));
            if (!spec.error.empty()) {
                errors.push_back(spec.error);
            } else if (!spec.alias.empty()) {
                const std::string path = resolve(spec.target);
                if (path.empty()) {
                    errors.push_back("import alias '" + spec.alias + "': cannot find module '" + spec.target + "'");
                } else if (aliases.count(spec.alias)) {
                    errors.push_back("import alias '" + spec.alias + "' is already used for '" + aliases[spec.alias].module + "'");
                } else {
                    aliases[spec.alias] = Alias{spec.target, topLevelFunctions(read(path))};
                }
            }
        }
        if (end == source.size()) break;
        start = end + 1;
    }
    return rewriteAliases(source, aliases);
}

} // namespace csec_imports
