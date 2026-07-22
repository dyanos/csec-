#include "NativeRuntime.h"

#include <cmath>
#include <cctype>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include <filesystem>
#include <regex>
#include <string>
#include <thread>
#include <unordered_map>
#include <vector>

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#include <direct.h>
#include <fcntl.h>
#include <io.h>
#include <sys/stat.h>
#include <winsock2.h>
#include <ws2tcpip.h>
#include <windows.h>
#pragma comment(lib, "ws2_32.lib")
#else
#include <cerrno>
#include <fcntl.h>
#include <netdb.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <dlfcn.h>
#endif

namespace {
int g_argc = 0;
char** g_argv = nullptr;

std::string llvmStringGlobal(const std::string& name, const std::string& value) {
    static constexpr char hex[] = "0123456789ABCDEF";
    std::string escaped;
    escaped.reserve(value.size() * 2 + 4);
    for (unsigned char ch : value) {
        if (ch >= 32 && ch <= 126 && ch != '"' && ch != '\\') {
            escaped.push_back(static_cast<char>(ch));
        } else {
            escaped.push_back('\\');
            escaped.push_back(hex[ch >> 4]);
            escaped.push_back(hex[ch & 0x0f]);
        }
    }
    escaped += "\\00";
    return "@" + name + " = private unnamed_addr constant [" +
        std::to_string(value.size() + 1) + " x i8] c\"" + escaped + "\"\n";
}

struct TokenBuilder {
    char* data = nullptr;
    size_t length = 0;
    size_t capacity = 0;
};

struct StringBuilder {
    char* data = nullptr;
    size_t length = 0;
    size_t capacity = 0;
    FILE* file = nullptr;
};

struct FunctionRange {
    int declStart = -1;
    int bodyStart = -1;
    int bodyEnd = -1;
};

constexpr size_t kStringBuilderGrowQuantum = 10 * 1024;

size_t roundStringBuilderCapacity(size_t needed) {
    size_t capacity = kStringBuilderGrowQuantum;
    if (needed > capacity) {
        size_t remainder = needed % kStringBuilderGrowQuantum;
        capacity = remainder == 0
            ? needed
            : needed + (kStringBuilderGrowQuantum - remainder);
    }
    return capacity;
}

std::unordered_map<const char*, std::vector<int>>& tokenLineCache() {
    static std::unordered_map<const char*, std::vector<int>> cache;
    return cache;
}

std::unordered_map<const char*, std::vector<std::string>>& tokenTextCache() {
    static std::unordered_map<const char*, std::vector<std::string>> cache;
    return cache;
}

std::unordered_map<const char*, std::vector<FunctionRange>>& tokenFunctionRangeCache() {
    static std::unordered_map<const char*, std::vector<FunctionRange>> cache;
    return cache;
}

std::unordered_map<const char*, std::unordered_map<std::string, std::string>>& tokenFunctionReturnTypeCache() {
    static std::unordered_map<const char*, std::unordered_map<std::string, std::string>> cache;
    return cache;
}

void clearTokenCachesFor(const char* tokens) {
    if (!tokens) return;
    tokenLineCache().erase(tokens);
    tokenTextCache().erase(tokens);
    tokenFunctionRangeCache().erase(tokens);
    tokenFunctionReturnTypeCache().erase(tokens);
}

void clearAllTokenCaches() {
    tokenLineCache().clear();
    tokenTextCache().clear();
    tokenFunctionRangeCache().clear();
    tokenFunctionReturnTypeCache().clear();
}

const std::vector<int>& tokenLineStarts(const char* tokens) {
    const char* value = tokens ? tokens : "";
    auto& cache = tokenLineCache();
    auto found = cache.find(value);
    if (found != cache.end()) {
        return found->second;
    }

    std::vector<int> starts;
    starts.push_back(0);
    for (int i = 0; value[i] != '\0'; ++i) {
        if (value[i] == '\n' && value[i + 1] != '\0') {
            starts.push_back(i + 1);
        }
    }
    auto inserted = cache.emplace(value, std::move(starts));
    return inserted.first->second;
}

const std::vector<std::string>& tokenTexts(const char* tokens) {
    const char* value = tokens ? tokens : "";
    auto& cache = tokenTextCache();
    auto found = cache.find(value);
    if (found != cache.end()) {
        return found->second;
    }

    const auto& starts = tokenLineStarts(value);
    std::vector<std::string> texts;
    texts.reserve(starts.size());
    for (int start : starts) {
        int textStart = start + 2;
        int end = textStart;
        while (value[end] != '\0' && value[end] != '\n') {
            ++end;
        }
        if (textStart > end) textStart = end;
        texts.emplace_back(value + textStart, static_cast<size_t>(end - textStart));
    }

    auto inserted = cache.emplace(value, std::move(texts));
    return inserted.first->second;
}

char tokenKindCached(const char* tokens, int ordinal) {
    const char* value = tokens ? tokens : "";
    if (ordinal < 0) return 'E';
    const auto& starts = tokenLineStarts(value);
    if (static_cast<size_t>(ordinal) >= starts.size()) return 'E';
    int start = starts[static_cast<size_t>(ordinal)];
    return value[start] == '\0' ? 'E' : value[start];
}

const std::string& tokenTextCached(const char* tokens, int ordinal) {
    static const std::string empty;
    if (ordinal < 0) return empty;
    const auto& texts = tokenTexts(tokens ? tokens : "");
    if (static_cast<size_t>(ordinal) >= texts.size()) return empty;
    return texts[static_cast<size_t>(ordinal)];
}

int tokenCountCached(const char* tokens) {
    const auto& starts = tokenLineStarts(tokens ? tokens : "");
    return static_cast<int>(starts.size());
}

int findMatchingBraceToken(const char* tokens, int openBrace, int tokenCount) {
    int depth = 0;
    for (int cursor = openBrace; cursor < tokenCount; ++cursor) {
        if (tokenKindCached(tokens, cursor) != 'O') continue;
        const auto& text = tokenTextCached(tokens, cursor);
        if (text == "{") {
            ++depth;
        } else if (text == "}") {
            --depth;
            if (depth == 0) return cursor;
        }
    }
    return -1;
}

bool findFunctionAroundLimit(const char* tokens, int limit, int* declStart, int* bodyStart, int* bodyEnd) {
    const char* value = tokens ? tokens : "";
    auto& cache = tokenFunctionRangeCache();
    auto found = cache.find(value);
    if (found == cache.end()) {
        int tokenCount = tokenCountCached(value);
        std::vector<FunctionRange> ranges;
        for (int cursor = 0; cursor < tokenCount; ++cursor) {
            if (tokenKindCached(value, cursor) != 'K' || tokenTextCached(value, cursor) != "def") {
                continue;
            }

            int openBrace = -1;
            for (int probe = cursor + 1; probe < tokenCount; ++probe) {
                if (tokenKindCached(value, probe) != 'O') continue;
                const auto& text = tokenTextCached(value, probe);
                if (text == "{") {
                    openBrace = probe;
                    break;
                }
                if (text == ";") break;
            }
            if (openBrace < 0) continue;

            int closeBrace = findMatchingBraceToken(value, openBrace, tokenCount);
            if (closeBrace < 0) continue;
            ranges.push_back(FunctionRange{cursor, openBrace + 1, closeBrace});
            if (cursor < closeBrace) cursor = closeBrace;
        }
        found = cache.emplace(value, std::move(ranges)).first;
    }

    if (limit < 0) return false;
    const auto& ranges = found->second;
    int left = 0;
    int right = static_cast<int>(ranges.size()) - 1;
    while (left <= right) {
        int mid = left + (right - left) / 2;
        const auto& range = ranges[static_cast<size_t>(mid)];
        if (limit >= range.bodyStart && limit < range.bodyEnd) {
            if (declStart) *declStart = range.declStart;
            if (bodyStart) *bodyStart = range.bodyStart;
            if (bodyEnd) *bodyEnd = range.bodyEnd;
            return true;
        }
        if (limit < range.bodyStart) {
            right = mid - 1;
        }
        else {
            left = mid + 1;
        }
    }

    return false;
}

int findMatchingParenToken(const char* tokens, int openParen, int tokenCount) {
    int depth = 0;
    for (int cursor = openParen; cursor < tokenCount; ++cursor) {
        if (tokenKindCached(tokens, cursor) != 'O') continue;
        const auto& text = tokenTextCached(tokens, cursor);
        if (text == "(") {
            ++depth;
        } else if (text == ")") {
            --depth;
            if (depth == 0) return cursor;
        }
    }
    return -1;
}

std::string collectFunctionReturnTypeCached(const char* tokens, int typeStart, int tokenCount) {
    std::string output;
    for (int cursor = typeStart; cursor < tokenCount; ++cursor) {
        const auto& text = tokenTextCached(tokens, cursor);
        if (text == "{" || text == "=" || text == ";" || text == ",") {
            break;
        }
        if (!output.empty()) output += " ";
        output += text;
    }
    return output.empty() ? "Unit" : output;
}

const std::unordered_map<std::string, std::string>& functionReturnTypesCached(const char* tokens) {
    const char* value = tokens ? tokens : "";
    auto& cache = tokenFunctionReturnTypeCache();
    auto found = cache.find(value);
    if (found != cache.end()) {
        return found->second;
    }

    int tokenCount = tokenCountCached(value);
    std::unordered_map<std::string, std::string> types;
    for (int cursor = 0; cursor < tokenCount; ++cursor) {
        int defToken = -1;
        if (tokenKindCached(value, cursor) == 'K' && tokenTextCached(value, cursor) == "def") {
            defToken = cursor;
        } else if (tokenKindCached(value, cursor) == 'K' && tokenTextCached(value, cursor) == "external" &&
                   cursor + 1 < tokenCount && tokenKindCached(value, cursor + 1) == 'K' &&
                   tokenTextCached(value, cursor + 1) == "def") {
            defToken = cursor + 1;
        }
        if (defToken < 0 || defToken + 1 >= tokenCount) {
            continue;
        }
        if (tokenKindCached(value, defToken + 1) != 'I') {
            continue;
        }

        std::string name = tokenTextCached(value, defToken + 1);
        int openParen = -1;
        for (int probe = defToken + 2; probe < tokenCount; ++probe) {
            const auto& text = tokenTextCached(value, probe);
            if (tokenKindCached(value, probe) == 'O' && text == "(") {
                openParen = probe;
                break;
            }
            if (tokenKindCached(value, probe) == 'O' && (text == "{" || text == ";" || text == "=")) {
                break;
            }
        }
        if (openParen < 0) {
            continue;
        }
        int closeParen = findMatchingParenToken(value, openParen, tokenCount);
        if (closeParen < 0) {
            continue;
        }
        std::string returnType = "Unit";
        if (closeParen + 2 < tokenCount && tokenKindCached(value, closeParen + 1) == 'O' &&
            tokenTextCached(value, closeParen + 1) == ":") {
            returnType = collectFunctionReturnTypeCached(value, closeParen + 2, tokenCount);
        }
        types[name] = returnType;
    }

    return cache.emplace(value, std::move(types)).first->second;
}

int& configuredParallelThreads() {
    static int value = []() {
        unsigned int hardware = std::thread::hardware_concurrency();
        return hardware == 0 ? 1 : static_cast<int>(hardware);
    }();
    return value;
}

void setConfiguredParallelThreads(int count) {
    if (count < 1) count = 1;
    configuredParallelThreads() = count;
}

#ifdef _WIN32
bool ensureSocketRuntime() {
    static bool initialized = []() {
        WSADATA data;
        return WSAStartup(MAKEWORD(2, 2), &data) == 0;
    }();
    return initialized;
}

void closeSocketHandle(SOCKET socketHandle) {
    closesocket(socketHandle);
}
#else
using NativeSocket = int;
constexpr NativeSocket INVALID_SOCKET_HANDLE = -1;

void closeSocketHandle(NativeSocket socketHandle) {
    close(socketHandle);
}
#endif

std::string resolveSystemLibraryPath(const char* path) {
    if (!path) return "";
    std::string library(path);
    if (library.rfind("System.", 0) != 0) {
        return library;
    }

    const bool hasExtension =
        (library.size() >= 4 && library.compare(library.size() - 4, 4, ".dll") == 0) ||
        (library.size() >= 3 && library.compare(library.size() - 3, 3, ".so") == 0) ||
        (library.size() >= 4 && library.compare(library.size() - 4, 4, ".lib") == 0) ||
        (library.size() >= 6 && library.compare(library.size() - 6, 6, ".dylib") == 0);
    if (hasExtension) {
        return library;
    }

#ifdef _WIN32
    return library + ".dll";
#elif defined(__APPLE__)
    return "lib" + library + ".dylib";
#else
    return library + ".so";
#endif
}
}

extern "C" {

void csec_print_string(const char* value) {
    std::printf("%s", value ? value : "");
}

void csec_print_i64(long long value) {
    std::printf("%lld", value);
}

void csec_print_double(double value) {
    std::printf("%f", value);
}

void csec_print_bool(int value) {
    std::printf("%d", value ? 1 : 0);
}

void csec_print_char(char value) {
    std::printf("%c", value);
}

void csec_print_newline(void) {
    std::printf("\n");
}

char* csec_string_concat(const char* left, const char* right) {
    const char* lhs = left ? left : "";
    const char* rhs = right ? right : "";
    size_t lhsLen = std::strlen(lhs);
    size_t rhsLen = std::strlen(rhs);
    char* result = static_cast<char*>(std::malloc(lhsLen + rhsLen + 1));
    if (!result) return nullptr;
    std::memcpy(result, lhs, lhsLen);
    std::memcpy(result + lhsLen, rhs, rhsLen);
    result[lhsLen + rhsLen] = '\0';
    return result;
}

void csec_release_concat_strings(void) {
    clearAllTokenCaches();
}

int csec_lex_quoted(const char* source, int index) {
    if (!source || index < 0 || source[index] == '\0') return index;
    const char quote = source[index];
    int cursor = index + 1;
    while (source[cursor] != '\0' && source[cursor] != quote) {
        if (source[cursor] == '\\' && source[cursor + 1] != '\0') {
            cursor += 2;
        } else {
            ++cursor;
        }
    }
    return source[cursor] == quote ? cursor + 1 : cursor;
}

int csec_lex_number(const char* source, int index) {
    if (!source || index < 0) return index;
    int cursor = index;
    if (source[cursor] == '0' && (source[cursor + 1] == 'x' || source[cursor + 1] == 'X' ||
        source[cursor + 1] == 'b' || source[cursor + 1] == 'B' || source[cursor + 1] == 'o' || source[cursor + 1] == 'O')) cursor += 2;
    while (std::isalnum(static_cast<unsigned char>(source[cursor])) || source[cursor] == '_' || source[cursor] == '.') ++cursor;
    return cursor;
}

int csec_lex_identifier(const char* source, int index) {
    if (!source || index < 0) return index;
    int cursor = index + 1;
    while (std::isalnum(static_cast<unsigned char>(source[cursor])) || source[cursor] == '_') ++cursor;
    return cursor;
}

int csec_operator_length(const char* source, int index) {
    if (!source || index < 0 || source[index] == '\0') return 0;
    const char first = source[index];
    const char second = source[index + 1];
    if (first == '[' && second == '@') return 2;
    const bool pair =
        (first == '=' && (second == '>' || second == '=')) ||
        (first == '<' && (second == '-' || second == '=' || second == '<')) ||
        (first == '>' && (second == '=' || second == '>')) ||
        (first == '!' && second == '=') ||
        (first == '+' && (second == '+' || second == '=')) ||
        (first == '-' && (second == '-' || second == '=' || second == '>')) ||
        (first == '*' && (second == '*' || second == '=')) ||
        (first == '/' && second == '=') || (first == '%' && second == '=') ||
        (first == '&' && second == '&') || (first == '|' && second == '|') ||
        (first == '.' && second == '.') || (first == '$' && second == '$');
    return pair ? 2 : 1;
}

int csec_digit_value(char ch) {
    return ch >= '0' && ch <= '9' ? ch - '0' : 0;
}

int csec_is_keyword(const char* text) {
    if (!text) return 0;
    static const char* const keywords[] = {
        "import", "class", "extends", "object", "external", "def", "operator", "override", "return",
        "val", "var", "if", "else", "for", "while", "match", "case", "map", "pmap", "filter",
        "reduce", "preduce", "template", "typename", "new", "this", "super", "unsafe", "unatomic",
        "constexpr", "box", "mut", "null", "inner", "outer", "tensor", "to", "until", "and", "or",
        "xor", "ode", "molecule", "cfd", "protein", "cpu", "openmp", "gpu", "simd"
    };
    for (const char* keyword : keywords) {
        if (std::strcmp(text, keyword) == 0) return 1;
    }
    return 0;
}

int csec_to_int(const char* text) {
    return text ? static_cast<int>(std::strtol(text, nullptr, 10)) : 0;
}

int csec_line_start(const char* text, int ordinal) {
    if (!text || ordinal <= 0) return 0;
    int cursor = 0;
    int line = 0;
    while (text[cursor] && line < ordinal) {
        if (text[cursor] == '\n') ++line;
        ++cursor;
    }
    return cursor;
}

int csec_line_end(const char* text, int start) {
    if (!text || start < 0) return 0;
    int cursor = start;
    while (text[cursor] && text[cursor] != '\n') ++cursor;
    return cursor;
}

int csec_validate_balanced(const char* tokens) {
    int paren = 0;
    int brace = 0;
    int bracket = 0;
    for (int ordinal = 0; csec_token_kind_at(tokens, ordinal) != 'E'; ++ordinal) {
        if (csec_token_kind_at(tokens, ordinal) != 'O') continue;
        const char* text = csec_token_text_at(tokens, ordinal);
        if (!text) continue;
        if (std::strcmp(text, "(") == 0) ++paren;
        else if (std::strcmp(text, ")") == 0) --paren;
        else if (std::strcmp(text, "{") == 0) ++brace;
        else if (std::strcmp(text, "}") == 0) --brace;
        else if (std::strcmp(text, "[") == 0) ++bracket;
        else if (std::strcmp(text, "]") == 0) --bracket;
        if (paren < 0 || brace < 0 || bracket < 0) return 0;
    }
    return paren == 0 && brace == 0 && bracket == 0;
}

std::string llvmGenerateIRAssignmentDefinition() {
    return R"IR(define ptr @generateIRAssignment(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %op = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, i32 1)
  %valid.op = icmp sgt i32 %op, %arg.start
  br i1 %valid.op, label %kind, label %invalid
kind:
  %kind.value = call i8 @csec_token_kind_at(ptr %arg.tokens, i32 %arg.start)
  %is.identifier = icmp eq i8 %kind.value, 73
  br i1 %is.identifier, label %assignment, label %invalid
assignment:
  %name = call ptr @csec_token_text_at(ptr %arg.tokens, i32 %arg.start)
  %op.text = call ptr @csec_token_text_at(ptr %arg.tokens, i32 %op)
  %rhs.start = add i32 %op, 1
  %rhs = call ptr @generateIRExpression(ptr %arg.tokens, i32 %rhs.start, i32 %arg.end)
  %equals.raw = call i32 @csec_string_equals(ptr %op.text, ptr @.str.ir.assign.equals)
  %left.raw = call i32 @csec_string_equals(ptr %op.text, ptr @.str.ir.assign.left)
  %equals = icmp ne i32 %equals.raw, 0
  %left = icmp ne i32 %left.raw, 0
  %is.store = or i1 %equals, %left
  br i1 %is.store, label %store, label %compound
store:
  %s1 = call ptr @csec_string_concat(ptr @.str.ir.assign.store, ptr %rhs)
  %s2 = call ptr @csec_string_concat(ptr %s1, ptr @.str.ir.assign.ptr)
  %s3 = call ptr @csec_string_concat(ptr %s2, ptr %name)
  %s4 = call ptr @csec_string_concat(ptr %s3, ptr @.str.ir.assign.nl)
  ret ptr %s4
compound:
  %type.name = call ptr @inferExpressionType(ptr %arg.tokens, i32 %rhs.start, i32 %arg.end)
  %ir.type = call ptr @irTypeName(ptr %type.name)
  %operator = call ptr @csec_string_substring(ptr %op.text, i32 0, i32 1)
  %binary = call ptr @irOperatorName(ptr %operator)
  %a1 = call ptr @csec_string_concat(ptr @.str.ir.assign.old, ptr %name)
  %a2 = call ptr @csec_string_concat(ptr %a1, ptr @.str.ir.assign.load)
  %a3 = call ptr @csec_string_concat(ptr %a2, ptr %ir.type)
  %a4 = call ptr @csec_string_concat(ptr %a3, ptr @.str.ir.assign.ptr)
  %a5 = call ptr @csec_string_concat(ptr %a4, ptr %name)
  %a6 = call ptr @csec_string_concat(ptr %a5, ptr @.str.ir.assign.nl)
  %b1 = call ptr @csec_string_concat(ptr @.str.ir.assign.new, ptr %name)
  %b2 = call ptr @csec_string_concat(ptr %b1, ptr @.str.ir.assign.eqspace)
  %b3 = call ptr @csec_string_concat(ptr %b2, ptr %binary)
  %b4 = call ptr @csec_string_concat(ptr %b3, ptr @.str.ir.expr.space)
  %b5 = call ptr @csec_string_concat(ptr %b4, ptr %ir.type)
  %b6 = call ptr @csec_string_concat(ptr %b5, ptr @.str.ir.assign.oldref)
  %b7 = call ptr @csec_string_concat(ptr %b6, ptr %name)
  %b8 = call ptr @csec_string_concat(ptr %b7, ptr @.str.ir.expr.middle)
  %trimmed = call i32 @trimExpressionEnd(ptr %arg.tokens, i32 %rhs.start, i32 %arg.end)
  %raw = call ptr @appendExpressionUntil(ptr %arg.tokens, i32 %rhs.start, i32 %trimmed)
  %b9 = call ptr @csec_string_concat(ptr %b8, ptr %raw)
  %b10 = call ptr @csec_string_concat(ptr %b9, ptr @.str.ir.expr.close)
  %b11 = call ptr @csec_string_concat(ptr %b10, ptr @.str.ir.assign.nl)
  %c1 = call ptr @csec_string_concat(ptr @.str.ir.assign.store, ptr %ir.type)
  %c2 = call ptr @csec_string_concat(ptr %c1, ptr @.str.ir.assign.newref)
  %c3 = call ptr @csec_string_concat(ptr %c2, ptr %name)
  %c4 = call ptr @csec_string_concat(ptr %c3, ptr @.str.ir.assign.ptr)
  %c5 = call ptr @csec_string_concat(ptr %c4, ptr %name)
  %c6 = call ptr @csec_string_concat(ptr %c5, ptr @.str.ir.assign.nl)
  %result1 = call ptr @csec_string_concat(ptr %a6, ptr %b11)
  %result2 = call ptr @csec_string_concat(ptr %result1, ptr %c6)
  ret ptr %result2
invalid:
  ret ptr @.str.ir.assign.empty
}

@.str.ir.assign.empty = private unnamed_addr constant [1 x i8] c"\00"
@.str.ir.assign.equals = private unnamed_addr constant [2 x i8] c"=\00"
@.str.ir.assign.left = private unnamed_addr constant [3 x i8] c"<-\00"
@.str.ir.assign.store = private unnamed_addr constant [11 x i8] c"    store \00"
@.str.ir.assign.ptr = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.ir.assign.nl = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.ir.assign.old = private unnamed_addr constant [10 x i8] c"    %old.\00"
@.str.ir.assign.load = private unnamed_addr constant [9 x i8] c" = load \00"
@.str.ir.assign.new = private unnamed_addr constant [10 x i8] c"    %new.\00"
@.str.ir.assign.eqspace = private unnamed_addr constant [4 x i8] c" = \00"
@.str.ir.assign.oldref = private unnamed_addr constant [7 x i8] c" %old.\00"
@.str.ir.assign.newref = private unnamed_addr constant [7 x i8] c" %new.\00"

)IR";
}

std::string llvmGenerateIRIfDefinition() {
    return R"IR(define ptr @generateIRIf(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %open = call i32 @findStatementParenStart(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %close = call i32 @findStatementParenEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %then.open = call i32 @findStatementBlockStart(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %then.close = call i32 @findClosingToken(ptr %arg.tokens, i32 %then.open, i32 %arg.end, ptr @.str.ir.if.brace.open, ptr @.str.ir.if.brace.close)
  %open.ok = icmp sge i32 %open, 0
  %close.ok = icmp sgt i32 %close, %open
  %then.open.ok = icmp sge i32 %then.open, 0
  %then.close.ok = icmp sgt i32 %then.close, %then.open
  %ok.1 = and i1 %open.ok, %close.ok
  %ok.2 = and i1 %then.open.ok, %then.close.ok
  %ok = and i1 %ok.1, %ok.2
  br i1 %ok, label %build, label %malformed
malformed:
  ret ptr @.str.ir.if.malformed
build:
  %seed.i64 = sext i32 %arg.start to i64
  %seed = call ptr @csec_to_string_i64(i64 %seed.i64)
  %after.then = add i32 %then.close, 1
  %possible.else = call i32 @skipTrivia(ptr %arg.tokens, i32 %after.then)
  %before.end = icmp slt i32 %possible.else, %arg.end
  br i1 %before.end, label %else.test, label %else.none
else.test:
  %else.raw = call i32 @csec_token_is(ptr %arg.tokens, i32 %possible.else, i8 75, ptr @.str.ir.if.else.keyword)
  %else.bool = icmp ne i32 %else.raw, 0
  br label %else.join
else.none:
  br label %else.join
else.join:
  %has.else = phi i1 [ %else.bool, %else.test ], [ false, %else.none ]
  %expr.start = add i32 %open, 1
  %condition = call ptr @generateIRExpression(ptr %arg.tokens, i32 %expr.start, i32 %close)
  %then.start = add i32 %then.open, 1
  %then.body = call ptr @generateIRFlatBody(ptr %arg.tokens, i32 %then.start, i32 %then.close)
  %else.body = call ptr @generateIRElseFlatBody(ptr %arg.tokens, i32 %possible.else, i32 %arg.end, i1 %has.else)
  %a1 = call ptr @csec_string_concat(ptr @.str.ir.if.cond, ptr %seed)
  %a2 = call ptr @csec_string_concat(ptr %a1, ptr @.str.ir.if.equals)
  %a3 = call ptr @csec_string_concat(ptr %a2, ptr %condition)
  %a4 = call ptr @csec_string_concat(ptr %a3, ptr @.str.ir.if.newline)
  %a5 = call ptr @csec_string_concat(ptr %a4, ptr @.str.ir.if.branch)
  %a6 = call ptr @csec_string_concat(ptr %a5, ptr %seed)
  %a7 = call ptr @csec_string_concat(ptr %a6, ptr @.str.ir.if.then)
  %a8 = call ptr @csec_string_concat(ptr %a7, ptr %seed)
  %a9 = call ptr @csec_string_concat(ptr %a8, ptr @.str.ir.if.else)
  %a10 = call ptr @csec_string_concat(ptr %a9, ptr %seed)
  %a11 = call ptr @csec_string_concat(ptr %a10, ptr @.str.ir.if.colon)
  %a12 = call ptr @csec_string_concat(ptr %a11, ptr %then.body)
  %a13 = call ptr @csec_string_concat(ptr %a12, ptr @.str.ir.if.end.branch)
  %a14 = call ptr @csec_string_concat(ptr %a13, ptr %seed)
  %a15 = call ptr @csec_string_concat(ptr %a14, ptr @.str.ir.if.newline)
  %a16 = call ptr @csec_string_concat(ptr %a15, ptr @.str.ir.if.else.label)
  %a17 = call ptr @csec_string_concat(ptr %a16, ptr %seed)
  %a18 = call ptr @csec_string_concat(ptr %a17, ptr @.str.ir.if.colon)
  %a19 = call ptr @csec_string_concat(ptr %a18, ptr %else.body)
  %a20 = call ptr @csec_string_concat(ptr %a19, ptr @.str.ir.if.end.branch)
  %a21 = call ptr @csec_string_concat(ptr %a20, ptr %seed)
  %a22 = call ptr @csec_string_concat(ptr %a21, ptr @.str.ir.if.newline)
  %a23 = call ptr @csec_string_concat(ptr %a22, ptr @.str.ir.if.end.label)
  %a24 = call ptr @csec_string_concat(ptr %a23, ptr %seed)
  %ret = call ptr @csec_string_concat(ptr %a24, ptr @.str.ir.if.colon)
  ret ptr %ret
}

@.str.ir.if.malformed = private unnamed_addr constant [20 x i8] c"    ; malformed if\0A\00"
@.str.ir.if.brace.open = private unnamed_addr constant [2 x i8] c"{\00"
@.str.ir.if.brace.close = private unnamed_addr constant [2 x i8] c"}\00"
@.str.ir.if.else.keyword = private unnamed_addr constant [5 x i8] c"else\00"
@.str.ir.if.cond = private unnamed_addr constant [11 x i8] c"    %cond.\00"
@.str.ir.if.equals = private unnamed_addr constant [4 x i8] c" = \00"
@.str.ir.if.newline = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.ir.if.branch = private unnamed_addr constant [17 x i8] c"    br i1 %cond.\00"
@.str.ir.if.then = private unnamed_addr constant [18 x i8] c", label %if.then.\00"
@.str.ir.if.else = private unnamed_addr constant [18 x i8] c", label %if.else.\00"
@.str.ir.if.colon = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.ir.if.end.branch = private unnamed_addr constant [22 x i8] c"    br label %if.end.\00"
@.str.ir.if.else.label = private unnamed_addr constant [9 x i8] c"if.else.\00"
@.str.ir.if.end.label = private unnamed_addr constant [8 x i8] c"if.end.\00"
)IR";
}

std::string llvmGenerateIRWhileDefinition() {
    return R"WHILELLVM(define ptr @generateIRWhile(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %open = call i32 @findStatementParenStart(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %close = call i32 @findStatementParenEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %body.open = call i32 @findStatementBlockStart(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %body.close = call i32 @findClosingToken(ptr %arg.tokens, i32 %body.open, i32 %arg.end, ptr @.str.ir.while.brace.open, ptr @.str.ir.while.brace.close)
  %open.ok = icmp sge i32 %open, 0
  %close.ok = icmp sgt i32 %close, %open
  %body.open.ok = icmp sge i32 %body.open, 0
  %body.close.ok = icmp sgt i32 %body.close, %body.open
  %ok.1 = and i1 %open.ok, %close.ok
  %ok.2 = and i1 %body.open.ok, %body.close.ok
  %ok = and i1 %ok.1, %ok.2
  br i1 %ok, label %build, label %bad
bad:
  ret ptr @.str.ir.while.bad
build:
  %seed.i64 = sext i32 %arg.start to i64
  %seed = call ptr @csec_to_string_i64(i64 %seed.i64)
  %expr.start = add i32 %open, 1
  %expr = call ptr @generateIRExpression(ptr %arg.tokens, i32 %expr.start, i32 %close)
  %body.start = add i32 %body.open, 1
  %body = call ptr @generateIRFlatBody(ptr %arg.tokens, i32 %body.start, i32 %body.close)
  %a1 = call ptr @csec_string_concat(ptr @.str.ir.while.branch, ptr %seed)
  %a2 = call ptr @csec_string_concat(ptr %a1, ptr @.str.ir.while.nl)
  %a3 = call ptr @csec_string_concat(ptr %a2, ptr @.str.ir.while.cond.label)
  %a4 = call ptr @csec_string_concat(ptr %a3, ptr %seed)
  %a5 = call ptr @csec_string_concat(ptr %a4, ptr @.str.ir.while.colon)
  %a6 = call ptr @csec_string_concat(ptr %a5, ptr @.str.ir.while.value)
  %a7 = call ptr @csec_string_concat(ptr %a6, ptr %seed)
  %a8 = call ptr @csec_string_concat(ptr %a7, ptr @.str.ir.while.equals)
  %a9 = call ptr @csec_string_concat(ptr %a8, ptr %expr)
  %a10 = call ptr @csec_string_concat(ptr %a9, ptr @.str.ir.while.nl)
  %a11 = call ptr @csec_string_concat(ptr %a10, ptr @.str.ir.while.test)
  %a12 = call ptr @csec_string_concat(ptr %a11, ptr %seed)
  %a13 = call ptr @csec_string_concat(ptr %a12, ptr @.str.ir.while.body.label)
  %a14 = call ptr @csec_string_concat(ptr %a13, ptr %seed)
  %a15 = call ptr @csec_string_concat(ptr %a14, ptr @.str.ir.while.end.label)
  %a16 = call ptr @csec_string_concat(ptr %a15, ptr %seed)
  %a17 = call ptr @csec_string_concat(ptr %a16, ptr @.str.ir.while.nl)
  %a18 = call ptr @csec_string_concat(ptr %a17, ptr @.str.ir.while.body.name)
  %a19 = call ptr @csec_string_concat(ptr %a18, ptr %seed)
  %a20 = call ptr @csec_string_concat(ptr %a19, ptr @.str.ir.while.colon)
  %a21 = call ptr @csec_string_concat(ptr %a20, ptr %body)
  %a22 = call ptr @csec_string_concat(ptr %a21, ptr @.str.ir.while.branch)
  %a23 = call ptr @csec_string_concat(ptr %a22, ptr %seed)
  %a24 = call ptr @csec_string_concat(ptr %a23, ptr @.str.ir.while.nl)
  %a25 = call ptr @csec_string_concat(ptr %a24, ptr @.str.ir.while.end.name)
  %a26 = call ptr @csec_string_concat(ptr %a25, ptr %seed)
  %ret = call ptr @csec_string_concat(ptr %a26, ptr @.str.ir.while.colon)
  ret ptr %ret
}

@.str.ir.while.bad = private unnamed_addr constant [23 x i8] c"    ; malformed while\0A\00"
@.str.ir.while.brace.open = private unnamed_addr constant [2 x i8] c"{\00"
@.str.ir.while.brace.close = private unnamed_addr constant [2 x i8] c"}\00"
@.str.ir.while.branch = private unnamed_addr constant [26 x i8] c"    br label %while.cond.\00"
@.str.ir.while.nl = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.ir.while.cond.label = private unnamed_addr constant [12 x i8] c"while.cond.\00"
@.str.ir.while.colon = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.ir.while.value = private unnamed_addr constant [16 x i8] c"    %whilecond.\00"
@.str.ir.while.equals = private unnamed_addr constant [4 x i8] c" = \00"
@.str.ir.while.test = private unnamed_addr constant [22 x i8] c"    br i1 %whilecond.\00"
@.str.ir.while.body.label = private unnamed_addr constant [21 x i8] c", label %while.body.\00"
@.str.ir.while.end.label = private unnamed_addr constant [20 x i8] c", label %while.end.\00"
@.str.ir.while.body.name = private unnamed_addr constant [12 x i8] c"while.body.\00"
@.str.ir.while.end.name = private unnamed_addr constant [11 x i8] c"while.end.\00"
)WHILELLVM";
}

std::string llvmGenerateIRForDefinition() {
    return R"FORLLVM(define ptr @generateIRFor(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %open = call i32 @findStatementParenStart(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %close = call i32 @findStatementParenEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %body.open = call i32 @findStatementBlockStart(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %body.close = call i32 @findClosingToken(ptr %arg.tokens, i32 %body.open, i32 %arg.end, ptr @.str.ir.for.brace.open, ptr @.str.ir.for.brace.close)
  %open.ok = icmp sge i32 %open, 0
  %close.ok = icmp sgt i32 %close, %open
  %body.open.ok = icmp sge i32 %body.open, 0
  %body.close.ok = icmp sgt i32 %body.close, %body.open
  %ok.1 = and i1 %open.ok, %close.ok
  %ok.2 = and i1 %body.open.ok, %body.close.ok
  %ok = and i1 %ok.1, %ok.2
  br i1 %ok, label %arrow.find, label %malformed
malformed:
  ret ptr @.str.ir.for.malformed
arrow.find:
  %iterator.index = add i32 %open, 1
  %arrow = call i32 @findTokenTextInRange(ptr %arg.tokens, i32 %iterator.index, i32 %close, ptr @.str.ir.for.arrow)
  %arrow.ok = icmp sge i32 %arrow, 0
  br i1 %arrow.ok, label %build, label %source.malformed
source.malformed:
  ret ptr @.str.ir.for.source.malformed
build:
  %seed.i64 = sext i32 %arg.start to i64
  %seed = call ptr @csec_to_string_i64(i64 %seed.i64)
  %iterator = call ptr @tokenTextAt(ptr %arg.tokens, i32 %iterator.index)
  %expr.start = add i32 %arrow, 1
  %expr = call ptr @generateIRExpression(ptr %arg.tokens, i32 %expr.start, i32 %close)
  %body.start = add i32 %body.open, 1
  %body = call ptr @generateIRFlatBody(ptr %arg.tokens, i32 %body.start, i32 %body.close)
  %a1 = call ptr @csec_string_concat(ptr @.str.ir.for.source, ptr %expr)
  %a2 = call ptr @csec_string_concat(ptr %a1, ptr @.str.ir.for.nl)
  %a3 = call ptr @csec_string_concat(ptr %a2, ptr @.str.ir.for.local)
  %a4 = call ptr @csec_string_concat(ptr %a3, ptr %iterator)
  %a5 = call ptr @csec_string_concat(ptr %a4, ptr @.str.ir.for.alloca)
  %a6 = call ptr @csec_string_concat(ptr %a5, ptr @.str.ir.for.branch)
  %a7 = call ptr @csec_string_concat(ptr %a6, ptr %seed)
  %a8 = call ptr @csec_string_concat(ptr %a7, ptr @.str.ir.for.nl)
  %a9 = call ptr @csec_string_concat(ptr %a8, ptr @.str.ir.for.cond)
  %a10 = call ptr @csec_string_concat(ptr %a9, ptr %seed)
  %a11 = call ptr @csec_string_concat(ptr %a10, ptr @.str.ir.for.colon)
  %a12 = call ptr @csec_string_concat(ptr %a11, ptr @.str.ir.for.next)
  %a13 = call ptr @csec_string_concat(ptr %a12, ptr %iterator)
  %a14 = call ptr @csec_string_concat(ptr %a13, ptr @.str.ir.for.nl)
  %a15 = call ptr @csec_string_concat(ptr %a14, ptr @.str.ir.for.test)
  %a16 = call ptr @csec_string_concat(ptr %a15, ptr %seed)
  %a17 = call ptr @csec_string_concat(ptr %a16, ptr @.str.ir.for.body.label)
  %a18 = call ptr @csec_string_concat(ptr %a17, ptr %seed)
  %a19 = call ptr @csec_string_concat(ptr %a18, ptr @.str.ir.for.end.label)
  %a20 = call ptr @csec_string_concat(ptr %a19, ptr %seed)
  %a21 = call ptr @csec_string_concat(ptr %a20, ptr @.str.ir.for.nl)
  %a22 = call ptr @csec_string_concat(ptr %a21, ptr @.str.ir.for.body)
  %a23 = call ptr @csec_string_concat(ptr %a22, ptr %seed)
  %a24 = call ptr @csec_string_concat(ptr %a23, ptr @.str.ir.for.colon)
  %a25 = call ptr @csec_string_concat(ptr %a24, ptr %body)
  %a26 = call ptr @csec_string_concat(ptr %a25, ptr @.str.ir.for.branch)
  %a27 = call ptr @csec_string_concat(ptr %a26, ptr %seed)
  %a28 = call ptr @csec_string_concat(ptr %a27, ptr @.str.ir.for.nl)
  %a29 = call ptr @csec_string_concat(ptr %a28, ptr @.str.ir.for.end)
  %a30 = call ptr @csec_string_concat(ptr %a29, ptr %seed)
  %ret = call ptr @csec_string_concat(ptr %a30, ptr @.str.ir.for.colon)
  ret ptr %ret
}

@.str.ir.for.malformed = private unnamed_addr constant [21 x i8] c"    ; malformed for\0A\00"
@.str.ir.for.source.malformed = private unnamed_addr constant [28 x i8] c"    ; malformed for source\0A\00"
@.str.ir.for.brace.open = private unnamed_addr constant [2 x i8] c"{\00"
@.str.ir.for.brace.close = private unnamed_addr constant [2 x i8] c"}\00"
@.str.ir.for.arrow = private unnamed_addr constant [3 x i8] c"<-\00"
@.str.ir.for.source = private unnamed_addr constant [18 x i8] c"    ; for source \00"
@.str.ir.for.nl = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.ir.for.local = private unnamed_addr constant [6 x i8] c"    %\00"
@.str.ir.for.alloca = private unnamed_addr constant [15 x i8] c" = alloca ptr\0A\00"
@.str.ir.for.branch = private unnamed_addr constant [24 x i8] c"    br label %for.cond.\00"
@.str.ir.for.cond = private unnamed_addr constant [10 x i8] c"for.cond.\00"
@.str.ir.for.colon = private unnamed_addr constant [3 x i8] c":\0A\00"
@.str.ir.for.next = private unnamed_addr constant [21 x i8] c"    ; iterator next \00"
@.str.ir.for.test = private unnamed_addr constant [24 x i8] c"    br i1 %for.hasnext.\00"
@.str.ir.for.body.label = private unnamed_addr constant [19 x i8] c", label %for.body.\00"
@.str.ir.for.end.label = private unnamed_addr constant [18 x i8] c", label %for.end.\00"
@.str.ir.for.body = private unnamed_addr constant [10 x i8] c"for.body.\00"
@.str.ir.for.end = private unnamed_addr constant [9 x i8] c"for.end.\00"
)FORLLVM";
}

std::string llvmLoadForValueTypeDefinition() {
    return R"LOADLLVM(define ptr @llvmLoadForValueType(ptr %arg.tokens, i32 %arg.limit, ptr %arg.name, ptr %arg.valueType, ptr %arg.resultName) {
entry:
  %storage = call ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %arg.limit, ptr %arg.name)
  %is.bool = call i1 @strEq(ptr %arg.valueType, ptr @.str.load.type.boolean)
  br i1 %is.bool, label %bool, label %char.check
bool:
  %b1 = call ptr @csec_string_concat(ptr @.str.load.prefix, ptr %arg.resultName)
  %b2 = call ptr @csec_string_concat(ptr %b1, ptr @.str.load.i1)
  %b3 = call ptr @csec_string_concat(ptr %b2, ptr %storage)
  %b4 = call ptr @csec_string_concat(ptr %b3, ptr @.str.load.newline)
  ret ptr %b4
char.check:
  %is.char = call i1 @strEq(ptr %arg.valueType, ptr @.str.load.type.char)
  br i1 %is.char, label %char, label %double.check
char:
  %c1 = call ptr @csec_string_concat(ptr @.str.load.prefix, ptr %arg.resultName)
  %c2 = call ptr @csec_string_concat(ptr %c1, ptr @.str.load.i8)
  %c3 = call ptr @csec_string_concat(ptr %c2, ptr %storage)
  %c4 = call ptr @csec_string_concat(ptr %c3, ptr @.str.load.newline)
  ret ptr %c4
double.check:
  %is.double = call i1 @strEq(ptr %arg.valueType, ptr @.str.load.type.double)
  br i1 %is.double, label %double, label %long.check
double:
  %d1 = call ptr @csec_string_concat(ptr @.str.load.prefix, ptr %arg.resultName)
  %d2 = call ptr @csec_string_concat(ptr %d1, ptr @.str.load.double)
  %d3 = call ptr @csec_string_concat(ptr %d2, ptr %storage)
  %d4 = call ptr @csec_string_concat(ptr %d3, ptr @.str.load.newline)
  ret ptr %d4
long.check:
  %is.long = call i1 @strEq(ptr %arg.valueType, ptr @.str.load.type.long)
  br i1 %is.long, label %long, label %pointer.check
long:
  %l1 = call ptr @csec_string_concat(ptr @.str.load.prefix, ptr %arg.resultName)
  %l2 = call ptr @csec_string_concat(ptr %l1, ptr @.str.load.i64)
  %l3 = call ptr @csec_string_concat(ptr %l2, ptr %storage)
  %l4 = call ptr @csec_string_concat(ptr %l3, ptr @.str.load.newline)
  ret ptr %l4
pointer.check:
  %llvm.type = call ptr @irTypeName(ptr %arg.valueType)
  %is.pointer = call i1 @strEq(ptr %llvm.type, ptr @.str.load.type.ptr)
  br i1 %is.pointer, label %pointer, label %integer
pointer:
  %p1 = call ptr @csec_string_concat(ptr @.str.load.prefix, ptr %arg.resultName)
  %p2 = call ptr @csec_string_concat(ptr %p1, ptr @.str.load.ptr)
  %p3 = call ptr @csec_string_concat(ptr %p2, ptr %storage)
  %p4 = call ptr @csec_string_concat(ptr %p3, ptr @.str.load.newline)
  ret ptr %p4
integer:
  %i1 = call ptr @csec_string_concat(ptr @.str.load.prefix, ptr %arg.resultName)
  %i2 = call ptr @csec_string_concat(ptr %i1, ptr @.str.load.i32)
  %i3 = call ptr @csec_string_concat(ptr %i2, ptr %storage)
  %i4 = call ptr @csec_string_concat(ptr %i3, ptr @.str.load.newline)
  ret ptr %i4
}

@.str.load.type.boolean = private unnamed_addr constant [8 x i8] c"Boolean\00"
@.str.load.type.char = private unnamed_addr constant [5 x i8] c"Char\00"
@.str.load.type.double = private unnamed_addr constant [7 x i8] c"Double\00"
@.str.load.type.long = private unnamed_addr constant [5 x i8] c"Long\00"
@.str.load.type.ptr = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.load.prefix = private unnamed_addr constant [3 x i8] c"  \00"
@.str.load.i1 = private unnamed_addr constant [18 x i8] c" = load i1, ptr %\00"
@.str.load.i8 = private unnamed_addr constant [18 x i8] c" = load i8, ptr %\00"
@.str.load.double = private unnamed_addr constant [22 x i8] c" = load double, ptr %\00"
@.str.load.i64 = private unnamed_addr constant [19 x i8] c" = load i64, ptr %\00"
@.str.load.ptr = private unnamed_addr constant [19 x i8] c" = load ptr, ptr %\00"
@.str.load.i32 = private unnamed_addr constant [19 x i8] c" = load i32, ptr %\00"
@.str.load.newline = private unnamed_addr constant [2 x i8] c"\0A\00"
)LOADLLVM";
}

std::string llvmGenerateCallArgumentListI32Definition() {
    return R"CALLARGLISTLLVM(define ptr @generateLLVMCallArgumentListI32(ptr %arg.tokens, i32 %arg.argsStart, i32 %arg.argsEnd, ptr %arg.resultName) {
entry:
  %first = call i32 @skipTrivia(ptr %arg.tokens, i32 %arg.argsStart)
  %end = call i32 @trimExpressionEnd(ptr %arg.tokens, i32 %first, i32 %arg.argsEnd)
  %empty = icmp sge i32 %first, %end
  br i1 %empty, label %empty.return, label %last.find
empty.return:
  ret ptr @.str.callargs.empty
last.find:
  %last = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %first, i32 %end, i32 12)
  %one = icmp slt i32 %last, %first
  br i1 %one, label %one.return, label %second.find
one.return:
  %one.type = call ptr @llvmCallArgumentType(ptr %arg.tokens, i32 %first, i32 %end)
  %one.value = call ptr @llvmCallArgumentValue(ptr %arg.tokens, i32 %first, i32 %end, ptr %arg.resultName, i32 0)
  %one.join = call ptr @csec_string_concat(ptr %one.type, ptr @.str.callargs.space)
  %one.result = call ptr @csec_string_concat(ptr %one.join, ptr %one.value)
  ret ptr %one.result
second.find:
  %second.comma = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %first, i32 %last, i32 12)
  %two = icmp slt i32 %second.comma, %first
  br i1 %two, label %two.return, label %first.find
two.return:
  %second.start.raw = add i32 %last, 1
  %second.start = call i32 @skipTrivia(ptr %arg.tokens, i32 %second.start.raw)
  %two.type0 = call ptr @llvmCallArgumentType(ptr %arg.tokens, i32 %first, i32 %last)
  %two.value0 = call ptr @llvmCallArgumentValue(ptr %arg.tokens, i32 %first, i32 %last, ptr %arg.resultName, i32 0)
  %two.type1 = call ptr @llvmCallArgumentType(ptr %arg.tokens, i32 %second.start, i32 %end)
  %two.value1 = call ptr @llvmCallArgumentValue(ptr %arg.tokens, i32 %second.start, i32 %end, ptr %arg.resultName, i32 1)
  %two.a = call ptr @csec_string_concat(ptr %two.type0, ptr @.str.callargs.space)
  %two.b = call ptr @csec_string_concat(ptr %two.a, ptr %two.value0)
  %two.c = call ptr @csec_string_concat(ptr %two.b, ptr @.str.callargs.comma)
  %two.d = call ptr @csec_string_concat(ptr %two.c, ptr %two.type1)
  %two.e = call ptr @csec_string_concat(ptr %two.d, ptr @.str.callargs.space)
  %two.result = call ptr @csec_string_concat(ptr %two.e, ptr %two.value1)
  ret ptr %two.result
first.find:
  %first.comma = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %first, i32 %second.comma, i32 12)
  %three = icmp slt i32 %first.comma, %first
  br i1 %three, label %three.return, label %four.return
three.return:
  %three.start1.raw = add i32 %second.comma, 1
  %three.start1 = call i32 @skipTrivia(ptr %arg.tokens, i32 %three.start1.raw)
  %three.start2.raw = add i32 %last, 1
  %three.start2 = call i32 @skipTrivia(ptr %arg.tokens, i32 %three.start2.raw)
  %three.type0 = call ptr @llvmCallArgumentType(ptr %arg.tokens, i32 %first, i32 %second.comma)
  %three.value0 = call ptr @llvmCallArgumentValue(ptr %arg.tokens, i32 %first, i32 %second.comma, ptr %arg.resultName, i32 0)
  %three.type1 = call ptr @llvmCallArgumentType(ptr %arg.tokens, i32 %three.start1, i32 %last)
  %three.value1 = call ptr @llvmCallArgumentValue(ptr %arg.tokens, i32 %three.start1, i32 %last, ptr %arg.resultName, i32 1)
  %three.type2 = call ptr @llvmCallArgumentType(ptr %arg.tokens, i32 %three.start2, i32 %end)
  %three.value2 = call ptr @llvmCallArgumentValue(ptr %arg.tokens, i32 %three.start2, i32 %end, ptr %arg.resultName, i32 2)
  %three.a = call ptr @csec_string_concat(ptr %three.type0, ptr @.str.callargs.space)
  %three.b = call ptr @csec_string_concat(ptr %three.a, ptr %three.value0)
  %three.c = call ptr @csec_string_concat(ptr %three.b, ptr @.str.callargs.comma)
  %three.d = call ptr @csec_string_concat(ptr %three.c, ptr %three.type1)
  %three.e = call ptr @csec_string_concat(ptr %three.d, ptr @.str.callargs.space)
  %three.f = call ptr @csec_string_concat(ptr %three.e, ptr %three.value1)
  %three.g = call ptr @csec_string_concat(ptr %three.f, ptr @.str.callargs.comma)
  %three.h = call ptr @csec_string_concat(ptr %three.g, ptr %three.type2)
  %three.i = call ptr @csec_string_concat(ptr %three.h, ptr @.str.callargs.space)
  %three.result = call ptr @csec_string_concat(ptr %three.i, ptr %three.value2)
  ret ptr %three.result
four.return:
  %four.start1.raw = add i32 %first.comma, 1
  %four.start1 = call i32 @skipTrivia(ptr %arg.tokens, i32 %four.start1.raw)
  %four.start2.raw = add i32 %second.comma, 1
  %four.start2 = call i32 @skipTrivia(ptr %arg.tokens, i32 %four.start2.raw)
  %four.start3.raw = add i32 %last, 1
  %four.start3 = call i32 @skipTrivia(ptr %arg.tokens, i32 %four.start3.raw)
  %four.type0 = call ptr @llvmCallArgumentType(ptr %arg.tokens, i32 %first, i32 %first.comma)
  %four.value0 = call ptr @llvmCallArgumentValue(ptr %arg.tokens, i32 %first, i32 %first.comma, ptr %arg.resultName, i32 0)
  %four.type1 = call ptr @llvmCallArgumentType(ptr %arg.tokens, i32 %four.start1, i32 %second.comma)
  %four.value1 = call ptr @llvmCallArgumentValue(ptr %arg.tokens, i32 %four.start1, i32 %second.comma, ptr %arg.resultName, i32 1)
  %four.type2 = call ptr @llvmCallArgumentType(ptr %arg.tokens, i32 %four.start2, i32 %last)
  %four.value2 = call ptr @llvmCallArgumentValue(ptr %arg.tokens, i32 %four.start2, i32 %last, ptr %arg.resultName, i32 2)
  %four.type3 = call ptr @llvmCallArgumentType(ptr %arg.tokens, i32 %four.start3, i32 %end)
  %four.value3 = call ptr @llvmCallArgumentValue(ptr %arg.tokens, i32 %four.start3, i32 %end, ptr %arg.resultName, i32 3)
  %four.a = call ptr @csec_string_concat(ptr %four.type0, ptr @.str.callargs.space)
  %four.b = call ptr @csec_string_concat(ptr %four.a, ptr %four.value0)
  %four.c = call ptr @csec_string_concat(ptr %four.b, ptr @.str.callargs.comma)
  %four.d = call ptr @csec_string_concat(ptr %four.c, ptr %four.type1)
  %four.e = call ptr @csec_string_concat(ptr %four.d, ptr @.str.callargs.space)
  %four.f = call ptr @csec_string_concat(ptr %four.e, ptr %four.value1)
  %four.g = call ptr @csec_string_concat(ptr %four.f, ptr @.str.callargs.comma)
  %four.h = call ptr @csec_string_concat(ptr %four.g, ptr %four.type2)
  %four.i = call ptr @csec_string_concat(ptr %four.h, ptr @.str.callargs.space)
  %four.j = call ptr @csec_string_concat(ptr %four.i, ptr %four.value2)
  %four.k = call ptr @csec_string_concat(ptr %four.j, ptr @.str.callargs.comma)
  %four.l = call ptr @csec_string_concat(ptr %four.k, ptr %four.type3)
  %four.m = call ptr @csec_string_concat(ptr %four.l, ptr @.str.callargs.space)
  %four.result = call ptr @csec_string_concat(ptr %four.m, ptr %four.value3)
  ret ptr %four.result
}

@.str.callargs.empty = private unnamed_addr constant [1 x i8] c"\00"
@.str.callargs.space = private unnamed_addr constant [2 x i8] c" \00"
@.str.callargs.comma = private unnamed_addr constant [3 x i8] c", \00"
)CALLARGLISTLLVM";
}

std::string llvmI32CallArgumentValueDefinition() {
    return R"I32CALLARGLLVM(define ptr @llvmI32CallArgumentValue(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName, i32 %arg.index) {
entry:
  %end = call i32 @trimExpressionEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd)
  %empty = icmp sle i32 %end, %arg.start
  br i1 %empty, label %empty.return, label %integer.check
empty.return:
  ret ptr @.str.i32.callarg.zero
integer.check:
  %kind = call i8 @tokenKindAt(ptr %arg.tokens, i32 %arg.start)
  %integer.kind = call i8 @kindInteger()
  %is.integer = icmp eq i8 %kind, %integer.kind
  %single.end = add i32 %arg.start, 1
  %single = icmp eq i32 %end, %single.end
  %integer = and i1 %is.integer, %single
  br i1 %integer, label %integer.return, label %temporary.return
integer.return:
  %text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  ret ptr %text
temporary.return:
  %a = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.i32.callarg.arg)
  %index.i64 = sext i32 %arg.index to i64
  %index.text = call ptr @csec_to_string_i64(i64 %index.i64)
  %result = call ptr @csec_string_concat(ptr %a, ptr %index.text)
  ret ptr %result
}

@.str.i32.callarg.zero = private unnamed_addr constant [2 x i8] c"0\00"
@.str.i32.callarg.arg = private unnamed_addr constant [5 x i8] c".arg\00"
)I32CALLARGLLVM";
}

std::string llvmCallArgumentValueDefinition() {
    std::string output = R"(define ptr @llvmCallArgumentValue(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName, i32 %arg.index) {
entry:
  %end = call i32 @trimExpressionEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd)
  %empty = icmp sle i32 %end, %arg.start
  br i1 %empty, label %empty.return, label %integer.check
empty.return:
  ret ptr @.str.callarg.value.zero
integer.check:
  %kind = call i8 @tokenKindAt(ptr %arg.tokens, i32 %arg.start)
  %integer.kind = call i8 @kindInteger()
  %is.integer = icmp eq i8 %kind, %integer.kind
  %single.end = add i32 %arg.start, 1
  %single = icmp eq i32 %end, %single.end
  %integer = and i1 %is.integer, %single
  br i1 %integer, label %integer.return, label %char.check
integer.return:
  %integer.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  ret ptr %integer.text
char.check:
  %char.kind = call i8 @kindChar()
  %is.char = icmp eq i8 %kind, %char.kind
  %char = and i1 %is.char, %single
  br i1 %char, label %char.return, label %bool.check
char.return:
  %char.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %char.value = call ptr @llvmCharI8Value(ptr %char.text)
  ret ptr %char.value
bool.check:
  %bool.kind = call i8 @kindBool()
  %is.bool = icmp eq i8 %kind, %bool.kind
  %bool = and i1 %is.bool, %single
  br i1 %bool, label %bool.return, label %temporary.return
bool.return:
  %bool.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  ret ptr %bool.text
temporary.return:
  %prefix = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.callarg.value.arg)
  %index.i64 = sext i32 %arg.index to i64
  %index.text = call ptr @csec_to_string_i64(i64 %index.i64)
  %result = call ptr @csec_string_concat(ptr %prefix, ptr %index.text)
  ret ptr %result
}

)";
    output += llvmStringGlobal(".str.callarg.value.zero", "0");
    output += llvmStringGlobal(".str.callarg.value.arg", ".arg");
    return output;
}

std::string llvmGenerateCallArgumentLoadI32Definition() {
    std::string output = R"(define ptr @generateLLVMCallArgumentLoadI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName) {
entry:
  %end = call i32 @trimExpressionEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd)
  %empty = icmp sle i32 %end, %arg.start
  br i1 %empty, label %empty.return, label %string.check
empty.return:
  %e1 = call ptr @csec_string_concat(ptr @.str.callargload.prefix, ptr %arg.resultName)
  %e2 = call ptr @csec_string_concat(ptr %e1, ptr @.str.callargload.add.prefix)
  %empty.result = call ptr @csec_string_concat(ptr %e2, ptr @.str.callargload.zero)
  ret ptr %empty.result
string.check:
  %kind = call i8 @tokenKindAt(ptr %arg.tokens, i32 %arg.start)
  %string.kind = call i8 @kindString()
  %is.string = icmp eq i8 %kind, %string.kind
  %single.end = add i32 %arg.start, 1
  %single = icmp eq i32 %end, %single.end
  %string = and i1 %is.string, %single
  br i1 %string, label %string.return, label %integer.check
string.return:
  %text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %bytes = call i32 @csec_llvm_string_literal_byte_length(ptr %text)
  %bytes.i64 = sext i32 %bytes to i64
  %bytes.text = call ptr @csec_to_string_i64(i64 %bytes.i64)
  %start.i64 = sext i32 %arg.start to i64
  %start.text = call ptr @csec_to_string_i64(i64 %start.i64)
  %s1 = call ptr @csec_string_concat(ptr @.str.callargload.prefix, ptr %arg.resultName)
  %s2 = call ptr @csec_string_concat(ptr %s1, ptr @.str.callargload.gep.left)
  %s3 = call ptr @csec_string_concat(ptr %s2, ptr %bytes.text)
  %s4 = call ptr @csec_string_concat(ptr %s3, ptr @.str.callargload.gep.middle)
  %s5 = call ptr @csec_string_concat(ptr %s4, ptr %start.text)
  %result = call ptr @csec_string_concat(ptr %s5, ptr @.str.callargload.gep.right)
  ret ptr %result
integer.check:
  %integer.kind = call i8 @kindInteger()
  %is.integer = icmp eq i8 %kind, %integer.kind
  %integer = and i1 %is.integer, %single
  br i1 %integer, label %integer.return, label %char.check
integer.return:
  %integer.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %i1 = call ptr @csec_string_concat(ptr @.str.callargload.prefix, ptr %arg.resultName)
  %i2 = call ptr @csec_string_concat(ptr %i1, ptr @.str.callargload.add.prefix)
  %integer.result = call ptr @csec_string_concat(ptr %i2, ptr %integer.text)
  ret ptr %integer.result
char.check:
  %char.kind = call i8 @kindChar()
  %is.char = icmp eq i8 %kind, %char.kind
  %char = and i1 %is.char, %single
  br i1 %char, label %char.return, label %identifier.check
char.return:
  %char.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %char.value = call ptr @llvmCharI8Value(ptr %char.text)
  %c1 = call ptr @csec_string_concat(ptr @.str.callargload.prefix, ptr %arg.resultName)
  %c2 = call ptr @csec_string_concat(ptr %c1, ptr @.str.callargload.add.prefix)
  %char.result = call ptr @csec_string_concat(ptr %c2, ptr %char.value)
  ret ptr %char.result
identifier.check:
  %identifier.kind = call i8 @kindIdentifier()
  %is.identifier = icmp eq i8 %kind, %identifier.kind
  %identifier = and i1 %is.identifier, %single
  br i1 %identifier, label %identifier.return, label %expression.type
identifier.return:
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %value.type = call ptr @lookupVisibleValueType(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %load = call ptr @llvmLoadForValueType(ptr %arg.tokens, i32 %arg.start, ptr %name, ptr %value.type, ptr %arg.resultName)
  ret ptr %load
expression.type:
  %argument.type = call ptr @llvmCallArgumentType(ptr %arg.tokens, i32 %arg.start, i32 %end)
  %pointer.argument = call i1 @strEq(ptr %argument.type, ptr @.str.callargload.ptr)
  br i1 %pointer.argument, label %pointer.expression.return, label %expression.return
pointer.expression.return:
  %pointer.expression = call ptr @generateLLVMExpressionPtr(ptr %arg.tokens, i32 %arg.start, i32 %end, ptr %arg.resultName)
  ret ptr %pointer.expression
expression.return:
  %expression = call ptr @generateLLVMExpressionI32(ptr %arg.tokens, i32 %arg.start, i32 %end, ptr %arg.resultName)
  ret ptr %expression
}

)";
    output += llvmStringGlobal(".str.callargload.prefix", "  ");
    output += llvmStringGlobal(".str.callargload.zero", "0\n");
    output += llvmStringGlobal(".str.callargload.gep.left", " = getelementptr inbounds [");
    output += llvmStringGlobal(".str.callargload.gep.middle", " x i8], ptr @.str.");
    output += llvmStringGlobal(".str.callargload.gep.right", ", i32 0, i32 0\n");
    output += llvmStringGlobal(".str.callargload.add.prefix", " = add i32 0, ");
    output += llvmStringGlobal(".str.callargload.ptr", "ptr");
    return output;
}

std::string llvmGenerateCallArgumentLoadsI32Definition() {
    std::string output = R"(define ptr @generateLLVMCallArgumentLoadsI32(ptr %arg.tokens, i32 %arg.argsStart, i32 %arg.argsEnd, ptr %arg.resultName) {
entry:
  %first = call i32 @skipTrivia(ptr %arg.tokens, i32 %arg.argsStart)
  %end = call i32 @trimExpressionEnd(ptr %arg.tokens, i32 %first, i32 %arg.argsEnd)
  %empty = icmp sge i32 %first, %end
  br i1 %empty, label %empty.return, label %last.find
empty.return:
  ret ptr @.str.callargloads.empty
last.find:
  %last = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %first, i32 %end, i32 12)
  %one = icmp slt i32 %last, %first
  br i1 %one, label %one.return, label %second.find
one.return:
  %name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.callargloads.arg0)
  %one.result = call ptr @generateLLVMCallArgumentLoadI32(ptr %arg.tokens, i32 %first, i32 %end, ptr %name)
  ret ptr %one.result
second.find:
  %second.comma = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %first, i32 %last, i32 12)
  %two = icmp slt i32 %second.comma, %first
  br i1 %two, label %two.return, label %first.find
two.return:
  %name0 = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.callargloads.arg0)
  %left = call ptr @generateLLVMCallArgumentLoadI32(ptr %arg.tokens, i32 %first, i32 %last, ptr %name0)
  %second.start.raw = add i32 %last, 1
  %second.start = call i32 @skipTrivia(ptr %arg.tokens, i32 %second.start.raw)
  %name1 = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.callargloads.arg1)
  %right = call ptr @generateLLVMCallArgumentLoadI32(ptr %arg.tokens, i32 %second.start, i32 %end, ptr %name1)
  %two.result = call ptr @csec_string_concat(ptr %left, ptr %right)
  ret ptr %two.result
first.find:
  %first.comma = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %first, i32 %second.comma, i32 12)
  %three = icmp slt i32 %first.comma, %first
  br i1 %three, label %three.return, label %four.return
three.return:
  %name0.3 = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.callargloads.arg0)
  %part0 = call ptr @generateLLVMCallArgumentLoadI32(ptr %arg.tokens, i32 %first, i32 %second.comma, ptr %name0.3)
  %second.start.raw.3 = add i32 %second.comma, 1
  %second.start.3 = call i32 @skipTrivia(ptr %arg.tokens, i32 %second.start.raw.3)
  %name1.3 = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.callargloads.arg1)
  %part1 = call ptr @generateLLVMCallArgumentLoadI32(ptr %arg.tokens, i32 %second.start.3, i32 %last, ptr %name1.3)
  %third.start.raw = add i32 %last, 1
  %third.start = call i32 @skipTrivia(ptr %arg.tokens, i32 %third.start.raw)
  %name2.3 = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.callargloads.arg2)
  %part2 = call ptr @generateLLVMCallArgumentLoadI32(ptr %arg.tokens, i32 %third.start, i32 %end, ptr %name2.3)
  %join0 = call ptr @csec_string_concat(ptr %part0, ptr %part1)
  %result3 = call ptr @csec_string_concat(ptr %join0, ptr %part2)
  ret ptr %result3
four.return:
  %name0.4 = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.callargloads.arg0)
  %part0.4 = call ptr @generateLLVMCallArgumentLoadI32(ptr %arg.tokens, i32 %first, i32 %first.comma, ptr %name0.4)
  %second.start.raw.4 = add i32 %first.comma, 1
  %second.start.4 = call i32 @skipTrivia(ptr %arg.tokens, i32 %second.start.raw.4)
  %name1.4 = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.callargloads.arg1)
  %part1.4 = call ptr @generateLLVMCallArgumentLoadI32(ptr %arg.tokens, i32 %second.start.4, i32 %second.comma, ptr %name1.4)
  %third.start.raw.4 = add i32 %second.comma, 1
  %third.start.4 = call i32 @skipTrivia(ptr %arg.tokens, i32 %third.start.raw.4)
  %name2.4 = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.callargloads.arg2)
  %part2.4 = call ptr @generateLLVMCallArgumentLoadI32(ptr %arg.tokens, i32 %third.start.4, i32 %last, ptr %name2.4)
  %fourth.start.raw = add i32 %last, 1
  %fourth.start = call i32 @skipTrivia(ptr %arg.tokens, i32 %fourth.start.raw)
  %name3.4 = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.callargloads.arg3)
  %part3.4 = call ptr @generateLLVMCallArgumentLoadI32(ptr %arg.tokens, i32 %fourth.start, i32 %end, ptr %name3.4)
  %join1 = call ptr @csec_string_concat(ptr %part0.4, ptr %part1.4)
  %join2 = call ptr @csec_string_concat(ptr %join1, ptr %part2.4)
  %result4 = call ptr @csec_string_concat(ptr %join2, ptr %part3.4)
  ret ptr %result4
}

)";
    output += llvmStringGlobal(".str.callargloads.empty", "");
    output += llvmStringGlobal(".str.callargloads.arg0", ".arg0");
    output += llvmStringGlobal(".str.callargloads.arg1", ".arg1");
    output += llvmStringGlobal(".str.callargloads.arg2", ".arg2");
    output += llvmStringGlobal(".str.callargloads.arg3", ".arg3");
    return output;
}

std::string llvmGenerateAssignmentI32Definition() {
    std::string output = R"(define ptr @generateLLVMAssignmentI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %op = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, i32 1)
  %has.op = icmp sgt i32 %op, %arg.start
  br i1 %has.op, label %kind.check, label %empty.return
kind.check:
  %kind = call i8 @tokenKindAt(ptr %arg.tokens, i32 %arg.start)
  %identifier.kind = call i8 @kindIdentifier()
  %is.identifier = icmp eq i8 %kind, %identifier.kind
  br i1 %is.identifier, label %assignment.check, label %empty.return
assignment.check:
  %op.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %op)
  %equals = call i1 @strEq(ptr %op.text, ptr @.str.assignment.i32.equals)
  br i1 %equals, label %assignment.return, label %arrow.check
arrow.check:
  %arrow = call i1 @strEq(ptr %op.text, ptr @.str.assignment.i32.arrow)
  br i1 %arrow, label %assignment.return, label %empty.return
assignment.return:
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %storage = call ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %start.i64 = sext i32 %arg.start to i64
  %start.text = call ptr @csec_to_string_i64(i64 %start.i64)
  %a1 = call ptr @csec_string_concat(ptr @.str.assignment.i32.percent, ptr %name)
  %a2 = call ptr @csec_string_concat(ptr %a1, ptr @.str.assignment.i32.result)
  %result.name = call ptr @csec_string_concat(ptr %a2, ptr %start.text)
  %rhs.start = add i32 %op, 1
  %expression = call ptr @generateLLVMExpressionI32(ptr %arg.tokens, i32 %rhs.start, i32 %arg.end, ptr %result.name)
  %s1 = call ptr @csec_string_concat(ptr %expression, ptr @.str.assignment.i32.store)
  %s2 = call ptr @csec_string_concat(ptr %s1, ptr %result.name)
  %s3 = call ptr @csec_string_concat(ptr %s2, ptr @.str.assignment.i32.to)
  %assignment.result = call ptr @csec_string_concat(ptr %s3, ptr %storage)
  ret ptr %assignment.result
empty.return:
  ret ptr @.str.assignment.i32.empty
}

)";
    output += llvmStringGlobal(".str.assignment.i32.equals", "=");
    output += llvmStringGlobal(".str.assignment.i32.arrow", "<-");
    output += llvmStringGlobal(".str.assignment.i32.percent", "%");
    output += llvmStringGlobal(".str.assignment.i32.result", ".assign.");
    output += llvmStringGlobal(".str.assignment.i32.store", "  store i32 ");
    output += llvmStringGlobal(".str.assignment.i32.to", ", ptr %");
    output += llvmStringGlobal(".str.assignment.i32.empty", "");
    return output;
}

std::string llvmGenerateAssignmentI64Definition() {
    std::string output = R"(define ptr @generateLLVMAssignmentI64(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %op = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, i32 1)
  %has.op = icmp sgt i32 %op, %arg.start
  br i1 %has.op, label %kind.check, label %empty.return
kind.check:
  %kind = call i8 @tokenKindAt(ptr %arg.tokens, i32 %arg.start)
  %identifier.kind = call i8 @kindIdentifier()
  %is.identifier = icmp eq i8 %kind, %identifier.kind
  br i1 %is.identifier, label %assignment.check, label %empty.return
assignment.check:
  %op.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %op)
  %equals = call i1 @strEq(ptr %op.text, ptr @.str.assignment.i64.equals)
  br i1 %equals, label %assignment.return, label %arrow.check
arrow.check:
  %arrow = call i1 @strEq(ptr %op.text, ptr @.str.assignment.i64.arrow)
  br i1 %arrow, label %assignment.return, label %empty.return
assignment.return:
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %storage = call ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %start.i64 = sext i32 %arg.start to i64
  %start.text = call ptr @csec_to_string_i64(i64 %start.i64)
  %a1 = call ptr @csec_string_concat(ptr @.str.assignment.i64.percent, ptr %name)
  %a2 = call ptr @csec_string_concat(ptr %a1, ptr @.str.assignment.i64.result)
  %result.name = call ptr @csec_string_concat(ptr %a2, ptr %start.text)
  %rhs.start = add i32 %op, 1
  %expression = call ptr @generateLLVMExpressionI64(ptr %arg.tokens, i32 %rhs.start, i32 %arg.end, ptr %result.name)
  %s1 = call ptr @csec_string_concat(ptr %expression, ptr @.str.assignment.i64.store)
  %s2 = call ptr @csec_string_concat(ptr %s1, ptr %result.name)
  %s3 = call ptr @csec_string_concat(ptr %s2, ptr @.str.assignment.i64.to)
  %assignment.result = call ptr @csec_string_concat(ptr %s3, ptr %storage)
  ret ptr %assignment.result
empty.return:
  ret ptr @.str.assignment.i64.empty
}

)";
    output += llvmStringGlobal(".str.assignment.i64.equals", "=");
    output += llvmStringGlobal(".str.assignment.i64.arrow", "<-");
    output += llvmStringGlobal(".str.assignment.i64.percent", "%");
    output += llvmStringGlobal(".str.assignment.i64.result", ".lassign.");
    output += llvmStringGlobal(".str.assignment.i64.store", "  store i64 ");
    output += llvmStringGlobal(".str.assignment.i64.to", ", ptr %");
    output += llvmStringGlobal(".str.assignment.i64.empty", "");
    return output;
}

std::string llvmRuntimeCallNameDefinition() {
    return R"RUNTIMENAMELLVM(define ptr @llvmRuntimeCallName(ptr %arg.name) {
entry:
  %count = call i1 @strEq(ptr %arg.name, ptr @.str.runtime.name.count)
  br i1 %count, label %count.return, label %arg.check
count.return:
  ret ptr @.str.runtime.name.count.native
arg.check:
  %arg = call i1 @strEq(ptr %arg.name, ptr @.str.runtime.name.arg)
  br i1 %arg, label %arg.return, label %identity.return
arg.return:
  ret ptr @.str.runtime.name.arg.native
identity.return:
  ret ptr %arg.name
}

@.str.runtime.name.count = private unnamed_addr constant [20 x i8] c"commandLineArgCount\00"
@.str.runtime.name.count.native = private unnamed_addr constant [28 x i8] c"csec_command_line_arg_count\00"
@.str.runtime.name.arg = private unnamed_addr constant [15 x i8] c"commandLineArg\00"
@.str.runtime.name.arg.native = private unnamed_addr constant [22 x i8] c"csec_command_line_arg\00"
)RUNTIMENAMELLVM";
}

std::string llvmGenerateLocalI32Definition() {
    return R"LOCALI32LLVM(define ptr @generateLLVMLocalI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %initializer = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, i32 1)
  %name.index = add i32 %arg.start, 1
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %name.index)
  %start.i64 = sext i32 %arg.start to i64
  %start.text = call ptr @csec_to_string_i64(i64 %start.i64)
  %storage.a = call ptr @csec_string_concat(ptr %name, ptr @.str.local.i32.addr)
  %storage = call ptr @csec_string_concat(ptr %storage.a, ptr %start.text)
  %init.a = call ptr @csec_string_concat(ptr @.str.local.i32.percent, ptr %name)
  %init.b = call ptr @csec_string_concat(ptr %init.a, ptr @.str.local.i32.init)
  %init = call ptr @csec_string_concat(ptr %init.b, ptr %start.text)
  %has.initializer = icmp sge i32 %initializer, %arg.start
  br i1 %has.initializer, label %with.initializer, label %without.initializer
with.initializer:
  %expr.start = add i32 %initializer, 1
  %expr = call ptr @generateLLVMExpressionI32(ptr %arg.tokens, i32 %expr.start, i32 %arg.end, ptr %init)
  %a1 = call ptr @csec_string_concat(ptr @.str.local.i32.prefix, ptr %storage)
  %a2 = call ptr @csec_string_concat(ptr %a1, ptr @.str.local.i32.alloca)
  %a3 = call ptr @csec_string_concat(ptr %a2, ptr %expr)
  %a4 = call ptr @csec_string_concat(ptr %a3, ptr @.str.local.i32.store)
  %a5 = call ptr @csec_string_concat(ptr %a4, ptr %init)
  %a6 = call ptr @csec_string_concat(ptr %a5, ptr @.str.local.i32.to)
  %result = call ptr @csec_string_concat(ptr %a6, ptr %storage)
  ret ptr %result
without.initializer:
  %b1 = call ptr @csec_string_concat(ptr @.str.local.i32.prefix, ptr %storage)
  %b2 = call ptr @csec_string_concat(ptr %b1, ptr @.str.local.i32.alloca)
  %b3 = call ptr @csec_string_concat(ptr %b2, ptr @.str.local.i32.zero)
  %fallback = call ptr @csec_string_concat(ptr %b3, ptr %storage)
  ret ptr %fallback
}

@.str.local.i32.addr = private unnamed_addr constant [7 x i8] c".addr.\00"
@.str.local.i32.percent = private unnamed_addr constant [2 x i8] c"%\00"
@.str.local.i32.init = private unnamed_addr constant [7 x i8] c".init.\00"
@.str.local.i32.prefix = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.local.i32.alloca = private unnamed_addr constant [15 x i8] c" = alloca i32\0A\00"
@.str.local.i32.store = private unnamed_addr constant [13 x i8] c"  store i32 \00"
@.str.local.i32.to = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.local.i32.zero = private unnamed_addr constant [21 x i8] c"  store i32 0, ptr %\00"
)LOCALI32LLVM";
}

std::string llvmGenerateLocalI64Definition() {
    return R"LOCALI64LLVM(define ptr @generateLLVMLocalI64(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %initializer = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, i32 1)
  %name.index = add i32 %arg.start, 1
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %name.index)
  %start.i64 = sext i32 %arg.start to i64
  %start.text = call ptr @csec_to_string_i64(i64 %start.i64)
  %storage.a = call ptr @csec_string_concat(ptr %name, ptr @.str.local.i64.addr)
  %storage = call ptr @csec_string_concat(ptr %storage.a, ptr %start.text)
  %init.a = call ptr @csec_string_concat(ptr @.str.local.i64.percent, ptr %name)
  %init.b = call ptr @csec_string_concat(ptr %init.a, ptr @.str.local.i64.init)
  %init = call ptr @csec_string_concat(ptr %init.b, ptr %start.text)
  %has.initializer = icmp sge i32 %initializer, %arg.start
  br i1 %has.initializer, label %with.initializer, label %without.initializer
with.initializer:
  %expr.start = add i32 %initializer, 1
  %expr = call ptr @generateLLVMExpressionI64(ptr %arg.tokens, i32 %expr.start, i32 %arg.end, ptr %init)
  %a1 = call ptr @csec_string_concat(ptr @.str.local.i64.prefix, ptr %storage)
  %a2 = call ptr @csec_string_concat(ptr %a1, ptr @.str.local.i64.alloca)
  %a3 = call ptr @csec_string_concat(ptr %a2, ptr %expr)
  %a4 = call ptr @csec_string_concat(ptr %a3, ptr @.str.local.i64.store)
  %a5 = call ptr @csec_string_concat(ptr %a4, ptr %init)
  %a6 = call ptr @csec_string_concat(ptr %a5, ptr @.str.local.i64.to)
  %result = call ptr @csec_string_concat(ptr %a6, ptr %storage)
  ret ptr %result
without.initializer:
  %b1 = call ptr @csec_string_concat(ptr @.str.local.i64.prefix, ptr %storage)
  %b2 = call ptr @csec_string_concat(ptr %b1, ptr @.str.local.i64.alloca)
  %b3 = call ptr @csec_string_concat(ptr %b2, ptr @.str.local.i64.zero)
  %fallback = call ptr @csec_string_concat(ptr %b3, ptr %storage)
  ret ptr %fallback
}

@.str.local.i64.addr = private unnamed_addr constant [7 x i8] c".addr.\00"
@.str.local.i64.percent = private unnamed_addr constant [2 x i8] c"%\00"
@.str.local.i64.init = private unnamed_addr constant [8 x i8] c".linit.\00"
@.str.local.i64.prefix = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.local.i64.alloca = private unnamed_addr constant [15 x i8] c" = alloca i64\0A\00"
@.str.local.i64.store = private unnamed_addr constant [13 x i8] c"  store i64 \00"
@.str.local.i64.to = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.local.i64.zero = private unnamed_addr constant [21 x i8] c"  store i64 0, ptr %\00"
)LOCALI64LLVM";
}

std::string llvmGenerateLocalF64Definition() {
    return R"LOCALF64LLVM(define ptr @generateLLVMLocalF64(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %initializer = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, i32 1)
  %name.index = add i32 %arg.start, 1
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %name.index)
  %start.i64 = sext i32 %arg.start to i64
  %start.text = call ptr @csec_to_string_i64(i64 %start.i64)
  %storage.a = call ptr @csec_string_concat(ptr %name, ptr @.str.local.f64.addr)
  %storage = call ptr @csec_string_concat(ptr %storage.a, ptr %start.text)
  %init.a = call ptr @csec_string_concat(ptr @.str.local.f64.percent, ptr %name)
  %init.b = call ptr @csec_string_concat(ptr %init.a, ptr @.str.local.f64.init)
  %init = call ptr @csec_string_concat(ptr %init.b, ptr %start.text)
  %has.initializer = icmp sge i32 %initializer, %arg.start
  br i1 %has.initializer, label %with.initializer, label %without.initializer
with.initializer:
  %expr.start = add i32 %initializer, 1
  %expr = call ptr @generateLLVMExpressionF64(ptr %arg.tokens, i32 %expr.start, i32 %arg.end, ptr %init)
  %a1 = call ptr @csec_string_concat(ptr @.str.local.f64.prefix, ptr %storage)
  %a2 = call ptr @csec_string_concat(ptr %a1, ptr @.str.local.f64.alloca)
  %a3 = call ptr @csec_string_concat(ptr %a2, ptr %expr)
  %a4 = call ptr @csec_string_concat(ptr %a3, ptr @.str.local.f64.store)
  %a5 = call ptr @csec_string_concat(ptr %a4, ptr %init)
  %a6 = call ptr @csec_string_concat(ptr %a5, ptr @.str.local.f64.to)
  %result = call ptr @csec_string_concat(ptr %a6, ptr %storage)
  ret ptr %result
without.initializer:
  %b1 = call ptr @csec_string_concat(ptr @.str.local.f64.prefix, ptr %storage)
  %b2 = call ptr @csec_string_concat(ptr %b1, ptr @.str.local.f64.alloca)
  %b3 = call ptr @csec_string_concat(ptr %b2, ptr @.str.local.f64.zero)
  %fallback = call ptr @csec_string_concat(ptr %b3, ptr %storage)
  ret ptr %fallback
}

@.str.local.f64.addr = private unnamed_addr constant [7 x i8] c".addr.\00"
@.str.local.f64.percent = private unnamed_addr constant [2 x i8] c"%\00"
@.str.local.f64.init = private unnamed_addr constant [8 x i8] c".finit.\00"
@.str.local.f64.prefix = private unnamed_addr constant [4 x i8] c"  %\00"
@.str.local.f64.alloca = private unnamed_addr constant [18 x i8] c" = alloca double\0A\00"
@.str.local.f64.store = private unnamed_addr constant [16 x i8] c"  store double \00"
@.str.local.f64.to = private unnamed_addr constant [8 x i8] c", ptr %\00"
@.str.local.f64.zero = private unnamed_addr constant [35 x i8] c"  store double 0.000000e+00, ptr %\00"
)LOCALF64LLVM";
}

std::string llvmGenerateLocalI8Definition() {
    std::string output = R"(define ptr @generateLLVMLocalI8(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %initializer = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, i32 1)
  %name.index = add i32 %arg.start, 1
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %name.index)
  %start.i64 = sext i32 %arg.start to i64
  %start.text = call ptr @csec_to_string_i64(i64 %start.i64)
  %storage.a = call ptr @csec_string_concat(ptr %name, ptr @.str.local.i8.addr)
  %storage = call ptr @csec_string_concat(ptr %storage.a, ptr %start.text)
  %init.a = call ptr @csec_string_concat(ptr @.str.local.i8.percent, ptr %name)
  %init.b = call ptr @csec_string_concat(ptr %init.a, ptr @.str.local.i8.init)
  %init = call ptr @csec_string_concat(ptr %init.b, ptr %start.text)
  %has.initializer = icmp sge i32 %initializer, %arg.start
  br i1 %has.initializer, label %inspect.initializer, label %fallback
inspect.initializer:
  %expr.start.raw = add i32 %initializer, 1
  %expr.start = call i32 @skipTrivia(ptr %arg.tokens, i32 %expr.start.raw)
  %expr.end = call i32 @trimExpressionEnd(ptr %arg.tokens, i32 %expr.start, i32 %arg.end)
  %kind = call i8 @tokenKindAt(ptr %arg.tokens, i32 %expr.start)
  %char.kind = call i8 @kindChar()
  %is.char = icmp eq i8 %kind, %char.kind
  %single.end = add i32 %expr.start, 1
  %is.single = icmp eq i32 %expr.end, %single.end
  %char.literal = and i1 %is.char, %is.single
  br i1 %char.literal, label %char.return, label %identifier.check
char.return:
  %char.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %expr.start)
  %char.value = call ptr @llvmCharI8Value(ptr %char.text)
  %c1 = call ptr @csec_string_concat(ptr @.str.local.i8.prefix, ptr %storage)
  %c2 = call ptr @csec_string_concat(ptr %c1, ptr @.str.local.i8.alloca)
  %c3 = call ptr @csec_string_concat(ptr %c2, ptr @.str.local.i8.store)
  %c4 = call ptr @csec_string_concat(ptr %c3, ptr %char.value)
  %c5 = call ptr @csec_string_concat(ptr %c4, ptr @.str.local.i8.to)
  %char.result = call ptr @csec_string_concat(ptr %c5, ptr %storage)
  ret ptr %char.result
identifier.check:
  %identifier.kind = call i8 @kindIdentifier()
  %is.identifier = icmp eq i8 %kind, %identifier.kind
  br i1 %is.identifier, label %identifier.single.check, label %fallback
identifier.single.check:
  br i1 %is.single, label %identifier.return, label %charat.check
identifier.return:
  %source.name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %expr.start)
  %source.storage = call ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %expr.start, ptr %source.name)
  %i1 = call ptr @csec_string_concat(ptr @.str.local.i8.prefix, ptr %storage)
  %i2 = call ptr @csec_string_concat(ptr %i1, ptr @.str.local.i8.alloca)
  %i3 = call ptr @csec_string_concat(ptr %i2, ptr @.str.local.i8.prefix)
  %i4 = call ptr @csec_string_concat(ptr %i3, ptr %init)
  %i5 = call ptr @csec_string_concat(ptr %i4, ptr @.str.local.i8.load)
  %i6 = call ptr @csec_string_concat(ptr %i5, ptr %source.storage)
  %i7 = call ptr @csec_string_concat(ptr %i6, ptr @.str.local.i8.store)
  %i8 = call ptr @csec_string_concat(ptr %i7, ptr %init)
  %i9 = call ptr @csec_string_concat(ptr %i8, ptr @.str.local.i8.to)
  %identifier.result = call ptr @csec_string_concat(ptr %i9, ptr %storage)
  ret ptr %identifier.result
charat.check:
  %dot.index = add i32 %expr.start, 1
  %method.index = add i32 %expr.start, 2
  %open.index = add i32 %expr.start, 3
  %minimum.end = add i32 %expr.start, 4
  %has.charat = icmp slt i32 %minimum.end, %expr.end
  br i1 %has.charat, label %charat.tokens, label %call.check
charat.tokens:
  %operator.kind = call i8 @kindOperator()
  %dot.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %dot.index, i8 %operator.kind, ptr @.str.local.i8.dot)
  %dot = icmp ne i32 %dot.raw, 0
  %method.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %method.index, i8 %identifier.kind, ptr @.str.local.i8.charat)
  %method = icmp ne i32 %method.raw, 0
  %open.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %open.index, i8 %operator.kind, ptr @.str.local.i8.open)
  %open = icmp ne i32 %open.raw, 0
  %charat.a = and i1 %dot, %method
  %charat.b = and i1 %charat.a, %open
  br i1 %charat.b, label %charat.close, label %call.check
charat.close:
  %close = call i32 @findClosingToken(ptr %arg.tokens, i32 %open.index, i32 %expr.end, ptr @.str.local.i8.open, ptr @.str.local.i8.close)
  %last = sub i32 %expr.end, 1
  %is.charat = icmp eq i32 %close, %last
  br i1 %is.charat, label %charat.return, label %call.check
charat.return:
  %object.name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %expr.start)
  %object.storage = call ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %expr.start, ptr %object.name)
  %index.start = add i32 %expr.start, 4
  %index.a = call ptr @csec_string_concat(ptr %init, ptr @.str.local.i8.index)
  %index.code = call ptr @generateLLVMExpressionI32(ptr %arg.tokens, i32 %index.start, i32 %last, ptr %index.a)
  %o1 = call ptr @csec_string_concat(ptr @.str.local.i8.prefix, ptr %storage)
  %o2 = call ptr @csec_string_concat(ptr %o1, ptr @.str.local.i8.alloca)
  %o3 = call ptr @csec_string_concat(ptr %o2, ptr @.str.local.i8.prefix)
  %o4 = call ptr @csec_string_concat(ptr %o3, ptr %init)
  %o5 = call ptr @csec_string_concat(ptr %o4, ptr @.str.local.i8.object.load)
  %o6 = call ptr @csec_string_concat(ptr %o5, ptr %object.storage)
  %o7 = call ptr @csec_string_concat(ptr %o6, ptr %index.code)
  %o8 = call ptr @csec_string_concat(ptr %o7, ptr @.str.local.i8.prefix)
  %o9 = call ptr @csec_string_concat(ptr %o8, ptr %init)
  %o10 = call ptr @csec_string_concat(ptr %o9, ptr @.str.local.i8.call.prefix)
  %object.value = call ptr @csec_string_concat(ptr %init, ptr @.str.local.i8.object)
  %o11 = call ptr @csec_string_concat(ptr %o10, ptr %object.value)
  %o12 = call ptr @csec_string_concat(ptr %o11, ptr @.str.local.i8.call.middle)
  %o13 = call ptr @csec_string_concat(ptr %o12, ptr %index.a)
  %o14 = call ptr @csec_string_concat(ptr %o13, ptr @.str.local.i8.close)
  %o15 = call ptr @csec_string_concat(ptr %o14, ptr @.str.local.i8.store)
  %o16 = call ptr @csec_string_concat(ptr %o15, ptr %init)
  %o17 = call ptr @csec_string_concat(ptr %o16, ptr @.str.local.i8.to)
  %charat.result = call ptr @csec_string_concat(ptr %o17, ptr %storage)
  ret ptr %charat.result
call.check:
  %call.open.index = add i32 %expr.start, 1
  %call.before.end = icmp slt i32 %call.open.index, %expr.end
  br i1 %call.before.end, label %call.open.check, label %fallback
call.open.check:
  %operator.kind.call = call i8 @kindOperator()
  %call.open.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %call.open.index, i8 %operator.kind.call, ptr @.str.local.i8.open)
  %call.open = icmp ne i32 %call.open.raw, 0
  br i1 %call.open, label %call.close.check, label %fallback
call.close.check:
  %call.close = call i32 @findClosingToken(ptr %arg.tokens, i32 %call.open.index, i32 %expr.end, ptr @.str.local.i8.open, ptr @.str.local.i8.close)
  %call.last = sub i32 %expr.end, 1
  %is.call = icmp eq i32 %call.close, %call.last
  br i1 %is.call, label %call.return, label %fallback
call.return:
  %callee = call ptr @tokenTextAt(ptr %arg.tokens, i32 %expr.start)
  %args.start = add i32 %expr.start, 2
  %args.loads = call ptr @generateLLVMCallArgumentLoadsI32(ptr %arg.tokens, i32 %args.start, i32 %call.last, ptr %init)
  %args.list = call ptr @generateLLVMCallArgumentListI32(ptr %arg.tokens, i32 %args.start, i32 %call.last, ptr %init)
  %callee.native = call ptr @llvmRuntimeCallName(ptr %callee)
  %q1 = call ptr @csec_string_concat(ptr @.str.local.i8.prefix, ptr %storage)
  %q2 = call ptr @csec_string_concat(ptr %q1, ptr @.str.local.i8.alloca)
  %q3 = call ptr @csec_string_concat(ptr %q2, ptr %args.loads)
  %q4 = call ptr @csec_string_concat(ptr %q3, ptr @.str.local.i8.prefix)
  %q5 = call ptr @csec_string_concat(ptr %q4, ptr %init)
  %q6 = call ptr @csec_string_concat(ptr %q5, ptr @.str.local.i8.call.at)
  %q7 = call ptr @csec_string_concat(ptr %q6, ptr %callee.native)
  %q8 = call ptr @csec_string_concat(ptr %q7, ptr @.str.local.i8.open)
  %q9 = call ptr @csec_string_concat(ptr %q8, ptr %args.list)
  %q10 = call ptr @csec_string_concat(ptr %q9, ptr @.str.local.i8.close)
  %q11 = call ptr @csec_string_concat(ptr %q10, ptr @.str.local.i8.store)
  %q12 = call ptr @csec_string_concat(ptr %q11, ptr %init)
  %q13 = call ptr @csec_string_concat(ptr %q12, ptr @.str.local.i8.to)
  %call.result = call ptr @csec_string_concat(ptr %q13, ptr %storage)
  ret ptr %call.result
fallback:
  %f1 = call ptr @csec_string_concat(ptr @.str.local.i8.prefix, ptr %storage)
  %f2 = call ptr @csec_string_concat(ptr %f1, ptr @.str.local.i8.alloca)
  %f3 = call ptr @csec_string_concat(ptr %f2, ptr @.str.local.i8.zero)
  %fallback.result = call ptr @csec_string_concat(ptr %f3, ptr %storage)
  ret ptr %fallback.result
}

)";
    output += llvmStringGlobal(".str.local.i8.addr", ".addr.");
    output += llvmStringGlobal(".str.local.i8.percent", "%");
    output += llvmStringGlobal(".str.local.i8.init", ".cinit.");
    output += llvmStringGlobal(".str.local.i8.prefix", "  %");
    output += llvmStringGlobal(".str.local.i8.alloca", " = alloca i8\n");
    output += llvmStringGlobal(".str.local.i8.store", "  store i8 ");
    output += llvmStringGlobal(".str.local.i8.to", ", ptr %");
    output += llvmStringGlobal(".str.local.i8.zero", "  store i8 0, ptr %");
    output += llvmStringGlobal(".str.local.i8.load", " = load i8, ptr %");
    output += llvmStringGlobal(".str.local.i8.dot", ".");
    output += llvmStringGlobal(".str.local.i8.charat", "charAt");
    output += llvmStringGlobal(".str.local.i8.open", "(");
    output += llvmStringGlobal(".str.local.i8.close", ")");
    output += llvmStringGlobal(".str.local.i8.index", ".index");
    output += llvmStringGlobal(".str.local.i8.object", ".obj");
    output += llvmStringGlobal(".str.local.i8.object.load", " = load ptr, ptr %");
    output += llvmStringGlobal(".str.local.i8.call.prefix", " = call i8 @csec_string_char_at(ptr ");
    output += llvmStringGlobal(".str.local.i8.call.middle", ", i32 ");
    output += llvmStringGlobal(".str.local.i8.call.at", " = call i8 @");
    return output;
}

std::string llvmGenerateLocalI1Definition() {
    std::string output = R"(define ptr @generateLLVMLocalI1(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %initializer = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, i32 1)
  %name.index = add i32 %arg.start, 1
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %name.index)
  %start.i64 = sext i32 %arg.start to i64
  %start.text = call ptr @csec_to_string_i64(i64 %start.i64)
  %storage.a = call ptr @csec_string_concat(ptr %name, ptr @.str.local.i1.addr)
  %storage = call ptr @csec_string_concat(ptr %storage.a, ptr %start.text)
  %init.a = call ptr @csec_string_concat(ptr @.str.local.i1.percent, ptr %name)
  %init.b = call ptr @csec_string_concat(ptr %init.a, ptr @.str.local.i1.init)
  %init = call ptr @csec_string_concat(ptr %init.b, ptr %start.text)
  %has.initializer = icmp sge i32 %initializer, %arg.start
  br i1 %has.initializer, label %with.initializer, label %without.initializer
with.initializer:
  %expr.start = add i32 %initializer, 1
  %expr = call ptr @generateLLVMExpressionI1(ptr %arg.tokens, i32 %expr.start, i32 %arg.end, ptr %init)
  %a1 = call ptr @csec_string_concat(ptr @.str.local.i1.prefix, ptr %storage)
  %a2 = call ptr @csec_string_concat(ptr %a1, ptr @.str.local.i1.alloca)
  %a3 = call ptr @csec_string_concat(ptr %a2, ptr %expr)
  %a4 = call ptr @csec_string_concat(ptr %a3, ptr @.str.local.i1.store)
  %a5 = call ptr @csec_string_concat(ptr %a4, ptr %init)
  %a6 = call ptr @csec_string_concat(ptr %a5, ptr @.str.local.i1.to)
  %result = call ptr @csec_string_concat(ptr %a6, ptr %storage)
  ret ptr %result
without.initializer:
  %b1 = call ptr @csec_string_concat(ptr @.str.local.i1.prefix, ptr %storage)
  %b2 = call ptr @csec_string_concat(ptr %b1, ptr @.str.local.i1.alloca)
  %b3 = call ptr @csec_string_concat(ptr %b2, ptr @.str.local.i1.false)
  %fallback = call ptr @csec_string_concat(ptr %b3, ptr %storage)
  ret ptr %fallback
}

)";
    output += llvmStringGlobal(".str.local.i1.addr", ".addr.");
    output += llvmStringGlobal(".str.local.i1.percent", "%");
    output += llvmStringGlobal(".str.local.i1.init", ".binit.");
    output += llvmStringGlobal(".str.local.i1.prefix", "  %");
    output += llvmStringGlobal(".str.local.i1.alloca", " = alloca i1\n");
    output += llvmStringGlobal(".str.local.i1.store", "  store i1 ");
    output += llvmStringGlobal(".str.local.i1.to", ", ptr %");
    output += llvmStringGlobal(".str.local.i1.false", "  store i1 false, ptr %");
    return output;
}

std::string llvmGenerateExpressionI32Definition() {
    std::string output = R"(define ptr @generateLLVMExpressionI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName) {
entry:
  %end = call i32 @trimExpressionEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd)
  %empty = icmp sle i32 %end, %arg.start
  br i1 %empty, label %zero.return, label %integer.check
zero.return:
  %z1 = call ptr @csec_string_concat(ptr @.str.expr.i32.prefix, ptr %arg.resultName)
  %zero.result = call ptr @csec_string_concat(ptr %z1, ptr @.str.expr.i32.zero)
  ret ptr %zero.result
integer.check:
  %kind = call i8 @tokenKindAt(ptr %arg.tokens, i32 %arg.start)
  %integer.kind = call i8 @kindInteger()
  %is.integer = icmp eq i8 %kind, %integer.kind
  %single.end = add i32 %arg.start, 1
  %single = icmp eq i32 %end, %single.end
  %integer = and i1 %is.integer, %single
  br i1 %integer, label %integer.return, label %char.check
integer.return:
  %integer.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %i1 = call ptr @csec_string_concat(ptr @.str.expr.i32.prefix, ptr %arg.resultName)
  %i2 = call ptr @csec_string_concat(ptr %i1, ptr @.str.expr.i32.add)
  %integer.result = call ptr @csec_string_concat(ptr %i2, ptr %integer.text)
  ret ptr %integer.result
char.check:
  %char.kind = call i8 @kindChar()
  %is.char = icmp eq i8 %kind, %char.kind
  %char = and i1 %is.char, %single
  br i1 %char, label %char.return, label %identifier.check
char.return:
  %char.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %char.value = call ptr @llvmCharI8Value(ptr %char.text)
  %c1 = call ptr @csec_string_concat(ptr @.str.expr.i32.prefix, ptr %arg.resultName)
  %c2 = call ptr @csec_string_concat(ptr %c1, ptr @.str.expr.i32.add)
  %char.result = call ptr @csec_string_concat(ptr %c2, ptr %char.value)
  ret ptr %char.result
identifier.check:
  %identifier.kind = call i8 @kindIdentifier()
  %is.identifier = icmp eq i8 %kind, %identifier.kind
  br i1 %is.identifier, label %identifier.next, label %operator.find
identifier.next:
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  br i1 %single, label %identifier.return, label %length.check
identifier.return:
  %value.type = call ptr @lookupVisibleValueType(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %is.char.type = call i1 @strEq(ptr %value.type, ptr @.str.expr.i32.char)
  br i1 %is.char.type, label %identifier.char, label %identifier.i32
identifier.char:
  %storage.char = call ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %h1 = call ptr @csec_string_concat(ptr @.str.expr.i32.prefix, ptr %arg.resultName)
  %h2 = call ptr @csec_string_concat(ptr %h1, ptr @.str.expr.i32.char.load)
  %h3 = call ptr @csec_string_concat(ptr %h2, ptr %storage.char)
  %h4 = call ptr @csec_string_concat(ptr %h3, ptr @.str.expr.i32.prefix)
  %h5 = call ptr @csec_string_concat(ptr %h4, ptr %arg.resultName)
  %h6 = call ptr @csec_string_concat(ptr %h5, ptr @.str.expr.i32.zext)
  %h7 = call ptr @csec_string_concat(ptr %h6, ptr %arg.resultName)
  %identifier.char.result = call ptr @csec_string_concat(ptr %h7, ptr @.str.expr.i32.char.to.i32)
  ret ptr %identifier.char.result
identifier.i32:
  %storage.i32 = call ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %j1 = call ptr @csec_string_concat(ptr @.str.expr.i32.prefix, ptr %arg.resultName)
  %j2 = call ptr @csec_string_concat(ptr %j1, ptr @.str.expr.i32.i32.load)
  %identifier.i32.result = call ptr @csec_string_concat(ptr %j2, ptr %storage.i32)
  ret ptr %identifier.i32.result
length.check:
  %dot.index = add i32 %arg.start, 1
  %length.index = add i32 %arg.start, 2
  %operator.kind = call i8 @kindOperator()
  %dot.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %dot.index, i8 %operator.kind, ptr @.str.expr.i32.dot)
  %dot = icmp ne i32 %dot.raw, 0
  %length.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %length.index, i8 %identifier.kind, ptr @.str.expr.i32.length)
  %length = icmp ne i32 %length.raw, 0
  %is.length = and i1 %dot, %length
  br i1 %is.length, label %length.return, label %charat.check
length.return:
  %length.storage = call ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %l1 = call ptr @csec_string_concat(ptr @.str.expr.i32.prefix, ptr %arg.resultName)
  %l2 = call ptr @csec_string_concat(ptr %l1, ptr @.str.expr.i32.object.load)
  %l3 = call ptr @csec_string_concat(ptr %l2, ptr %length.storage)
  %l4 = call ptr @csec_string_concat(ptr %l3, ptr @.str.expr.i32.prefix)
  %l5 = call ptr @csec_string_concat(ptr %l4, ptr %arg.resultName)
  %l6 = call ptr @csec_string_concat(ptr %l5, ptr @.str.expr.i32.length.call)
  %object.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.i32.object)
  %l7 = call ptr @csec_string_concat(ptr %l6, ptr %object.name)
  %l8 = call ptr @csec_string_concat(ptr %l7, ptr @.str.expr.i32.prefix)
  %l9 = call ptr @csec_string_concat(ptr %l8, ptr %arg.resultName)
  %l10 = call ptr @csec_string_concat(ptr %l9, ptr @.str.expr.i32.trunc)
  %l11 = call ptr @csec_string_concat(ptr %l10, ptr %arg.resultName)
  %length.result = call ptr @csec_string_concat(ptr %l11, ptr @.str.expr.i32.i64.to.i32)
  ret ptr %length.result
charat.check:
  %open.index = add i32 %arg.start, 3
  %minimum.end = add i32 %arg.start, 4
  %has.charat = icmp slt i32 %minimum.end, %end
  br i1 %has.charat, label %charat.tokens, label %call.check
charat.tokens:
  %charat.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %length.index, i8 %identifier.kind, ptr @.str.expr.i32.charat)
  %charat = icmp ne i32 %charat.raw, 0
  %open.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %open.index, i8 %operator.kind, ptr @.str.expr.i32.open)
  %open = icmp ne i32 %open.raw, 0
  %charat.a = and i1 %dot, %charat
  %charat.b = and i1 %charat.a, %open
  br i1 %charat.b, label %charat.close, label %call.check
charat.close:
  %close = call i32 @findClosingToken(ptr %arg.tokens, i32 %open.index, i32 %end, ptr @.str.expr.i32.open, ptr @.str.expr.i32.close)
  %last = sub i32 %end, 1
  %is.charat = icmp eq i32 %close, %last
  br i1 %is.charat, label %charat.return, label %call.check
charat.return:
  %charat.storage = call ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %index.start = add i32 %arg.start, 4
  %index.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.i32.index)
  %index.code = call ptr @generateLLVMExpressionI32(ptr %arg.tokens, i32 %index.start, i32 %last, ptr %index.name)
  %q1 = call ptr @csec_string_concat(ptr @.str.expr.i32.prefix, ptr %arg.resultName)
  %q2 = call ptr @csec_string_concat(ptr %q1, ptr @.str.expr.i32.object.load)
  %q3 = call ptr @csec_string_concat(ptr %q2, ptr %charat.storage)
  %q4 = call ptr @csec_string_concat(ptr %q3, ptr %index.code)
  %q5 = call ptr @csec_string_concat(ptr %q4, ptr @.str.expr.i32.prefix)
  %q6 = call ptr @csec_string_concat(ptr %q5, ptr %arg.resultName)
  %q7 = call ptr @csec_string_concat(ptr %q6, ptr @.str.expr.i32.charat.call)
  %object.name.charat = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.i32.object)
  %q8 = call ptr @csec_string_concat(ptr %q7, ptr %object.name.charat)
  %q9 = call ptr @csec_string_concat(ptr %q8, ptr @.str.expr.i32.charat.middle)
  %q10 = call ptr @csec_string_concat(ptr %q9, ptr %index.name)
  %q11 = call ptr @csec_string_concat(ptr %q10, ptr @.str.expr.i32.close)
  %q12 = call ptr @csec_string_concat(ptr %q11, ptr @.str.expr.i32.prefix)
  %q13 = call ptr @csec_string_concat(ptr %q12, ptr %arg.resultName)
  %q14 = call ptr @csec_string_concat(ptr %q13, ptr @.str.expr.i32.zext)
  %q15 = call ptr @csec_string_concat(ptr %q14, ptr %arg.resultName)
  %charat.result = call ptr @csec_string_concat(ptr %q15, ptr @.str.expr.i32.i8.to.i32)
  ret ptr %charat.result
call.check:
  %call.open.index = add i32 %arg.start, 1
  %call.before.end = icmp slt i32 %call.open.index, %end
  br i1 %call.before.end, label %call.open.check, label %operator.find
call.open.check:
  %call.open.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %call.open.index, i8 %operator.kind, ptr @.str.expr.i32.open)
  %call.open = icmp ne i32 %call.open.raw, 0
  br i1 %call.open, label %call.close.check, label %operator.find
call.close.check:
  %call.close = call i32 @findClosingToken(ptr %arg.tokens, i32 %call.open.index, i32 %end, ptr @.str.expr.i32.open, ptr @.str.expr.i32.close)
  %call.last = sub i32 %end, 1
  %is.call = icmp eq i32 %call.close, %call.last
  br i1 %is.call, label %call.return, label %operator.find
call.return:
  %callee = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %args.start = add i32 %arg.start, 2
  %loads = call ptr @generateLLVMCallArgumentLoadsI32(ptr %arg.tokens, i32 %args.start, i32 %call.last, ptr %arg.resultName)
  %arguments = call ptr @generateLLVMCallArgumentListI32(ptr %arg.tokens, i32 %args.start, i32 %call.last, ptr %arg.resultName)
  %native.callee = call ptr @llvmRuntimeCallName(ptr %callee)
  %r1 = call ptr @csec_string_concat(ptr %loads, ptr @.str.expr.i32.prefix)
  %r2 = call ptr @csec_string_concat(ptr %r1, ptr %arg.resultName)
  %r3 = call ptr @csec_string_concat(ptr %r2, ptr @.str.expr.i32.call.i32)
  %r4 = call ptr @csec_string_concat(ptr %r3, ptr %native.callee)
  %r5 = call ptr @csec_string_concat(ptr %r4, ptr @.str.expr.i32.open)
  %r6 = call ptr @csec_string_concat(ptr %r5, ptr %arguments)
  %call.result = call ptr @csec_string_concat(ptr %r6, ptr @.str.expr.i32.close.nl)
  ret ptr %call.result
operator.find:
  %op = call i32 @expressionTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %end)
  %has.op = icmp sgt i32 %op, %arg.start
  br i1 %has.op, label %operator.return, label %zero.return
operator.return:
  %op.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %op)
  %mnemonic = call ptr @irOperatorName(ptr %op.text)
  %left.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.i32.left)
  %left = call ptr @generateLLVMExpressionI32(ptr %arg.tokens, i32 %arg.start, i32 %op, ptr %left.name)
  %right.start = add i32 %op, 1
  %right.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.i32.right)
  %right = call ptr @generateLLVMExpressionI32(ptr %arg.tokens, i32 %right.start, i32 %end, ptr %right.name)
  %b1 = call ptr @csec_string_concat(ptr %left, ptr %right)
  %b2 = call ptr @csec_string_concat(ptr %b1, ptr @.str.expr.i32.prefix)
  %b3 = call ptr @csec_string_concat(ptr %b2, ptr %arg.resultName)
  %b4 = call ptr @csec_string_concat(ptr %b3, ptr @.str.expr.i32.operator.prefix)
  %b5 = call ptr @csec_string_concat(ptr %b4, ptr %mnemonic)
  %b6 = call ptr @csec_string_concat(ptr %b5, ptr @.str.expr.i32.operator.middle)
  %b7 = call ptr @csec_string_concat(ptr %b6, ptr %left.name)
  %b8 = call ptr @csec_string_concat(ptr %b7, ptr @.str.expr.i32.operator.comma)
  %binary.result = call ptr @csec_string_concat(ptr %b8, ptr %right.name)
  ret ptr %binary.result
}

)";
    output += llvmStringGlobal(".str.expr.i32.prefix", "  ");
    output += llvmStringGlobal(".str.expr.i32.zero", " = add i32 0, 0\n");
    output += llvmStringGlobal(".str.expr.i32.add", " = add i32 0, ");
    output += llvmStringGlobal(".str.expr.i32.char", "Char");
    output += llvmStringGlobal(".str.expr.i32.char.load", " = load i8, ptr %");
    output += llvmStringGlobal(".str.expr.i32.zext", " = zext i8 ");
    output += llvmStringGlobal(".str.expr.i32.char.to.i32", ".c to i32\n");
    output += llvmStringGlobal(".str.expr.i32.i32.load", " = load i32, ptr %");
    output += llvmStringGlobal(".str.expr.i32.dot", ".");
    output += llvmStringGlobal(".str.expr.i32.length", "length");
    output += llvmStringGlobal(".str.expr.i32.charat", "charAt");
    output += llvmStringGlobal(".str.expr.i32.open", "(");
    output += llvmStringGlobal(".str.expr.i32.close", ")");
    output += llvmStringGlobal(".str.expr.i32.close.nl", ")\n");
    output += llvmStringGlobal(".str.expr.i32.object", ".obj");
    output += llvmStringGlobal(".str.expr.i32.index", ".index");
    output += llvmStringGlobal(".str.expr.i32.object.load", " = load ptr, ptr %");
    output += llvmStringGlobal(".str.expr.i32.length.call", " = call i64 @csec_string_length(ptr ");
    output += llvmStringGlobal(".str.expr.i32.trunc", " = trunc i64 ");
    output += llvmStringGlobal(".str.expr.i32.i64.to.i32", ".i64 to i32\n");
    output += llvmStringGlobal(".str.expr.i32.charat.call", " = call i8 @csec_string_char_at(ptr ");
    output += llvmStringGlobal(".str.expr.i32.charat.middle", ", i32 ");
    output += llvmStringGlobal(".str.expr.i32.i8.to.i32", ".i8 to i32\n");
    output += llvmStringGlobal(".str.expr.i32.call.i32", " = call i32 @");
    output += llvmStringGlobal(".str.expr.i32.left", ".left");
    output += llvmStringGlobal(".str.expr.i32.right", ".right");
    output += llvmStringGlobal(".str.expr.i32.operator.prefix", " = ");
    output += llvmStringGlobal(".str.expr.i32.operator.middle", " i32 ");
    output += llvmStringGlobal(".str.expr.i32.operator.comma", ", ");
    return output;
}

std::string llvmGenerateExpressionI64Definition() {
    std::string output = R"(define ptr @generateLLVMExpressionI64(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName) {
entry:
  %end = call i32 @trimExpressionEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd)
  %empty = icmp sle i32 %end, %arg.start
  br i1 %empty, label %zero.return, label %integer.check
zero.return:
  %z1 = call ptr @csec_string_concat(ptr @.str.expr.i64.prefix, ptr %arg.resultName)
  %zero.result = call ptr @csec_string_concat(ptr %z1, ptr @.str.expr.i64.zero)
  ret ptr %zero.result
integer.check:
  %kind = call i8 @tokenKindAt(ptr %arg.tokens, i32 %arg.start)
  %integer.kind = call i8 @kindInteger()
  %is.integer = icmp eq i8 %kind, %integer.kind
  %single.end = add i32 %arg.start, 1
  %single = icmp eq i32 %end, %single.end
  %integer = and i1 %is.integer, %single
  br i1 %integer, label %integer.return, label %identifier.check
integer.return:
  %integer.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %i1 = call ptr @csec_string_concat(ptr @.str.expr.i64.prefix, ptr %arg.resultName)
  %i2 = call ptr @csec_string_concat(ptr %i1, ptr @.str.expr.i64.add)
  %integer.result = call ptr @csec_string_concat(ptr %i2, ptr %integer.text)
  ret ptr %integer.result
identifier.check:
  %identifier.kind = call i8 @kindIdentifier()
  %is.identifier = icmp eq i8 %kind, %identifier.kind
  br i1 %is.identifier, label %identifier.next, label %operator.find
identifier.next:
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  br i1 %single, label %identifier.return, label %call.check
identifier.return:
  %storage = call ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %n1 = call ptr @csec_string_concat(ptr @.str.expr.i64.prefix, ptr %arg.resultName)
  %n2 = call ptr @csec_string_concat(ptr %n1, ptr @.str.expr.i64.load)
  %identifier.result = call ptr @csec_string_concat(ptr %n2, ptr %storage)
  ret ptr %identifier.result
call.check:
  %open.index = add i32 %arg.start, 1
  %before.end = icmp slt i32 %open.index, %end
  br i1 %before.end, label %open.check, label %operator.find
open.check:
  %operator.kind = call i8 @kindOperator()
  %open.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %open.index, i8 %operator.kind, ptr @.str.expr.i64.open)
  %open = icmp ne i32 %open.raw, 0
  br i1 %open, label %close.check, label %operator.find
close.check:
  %close = call i32 @findClosingToken(ptr %arg.tokens, i32 %open.index, i32 %end, ptr @.str.expr.i64.open, ptr @.str.expr.i64.close)
  %last = sub i32 %end, 1
  %is.call = icmp eq i32 %close, %last
  br i1 %is.call, label %call.return, label %operator.find
call.return:
  %args.start = add i32 %arg.start, 2
  %loads = call ptr @generateLLVMCallArgumentLoadsI32(ptr %arg.tokens, i32 %args.start, i32 %last, ptr %arg.resultName)
  %arguments = call ptr @generateLLVMCallArgumentListI32(ptr %arg.tokens, i32 %args.start, i32 %last, ptr %arg.resultName)
  %callee = call ptr @llvmRuntimeCallName(ptr %name)
  %c1 = call ptr @csec_string_concat(ptr %loads, ptr @.str.expr.i64.prefix)
  %c2 = call ptr @csec_string_concat(ptr %c1, ptr %arg.resultName)
  %c3 = call ptr @csec_string_concat(ptr %c2, ptr @.str.expr.i64.call)
  %c4 = call ptr @csec_string_concat(ptr %c3, ptr %callee)
  %c5 = call ptr @csec_string_concat(ptr %c4, ptr @.str.expr.i64.open)
  %c6 = call ptr @csec_string_concat(ptr %c5, ptr %arguments)
  %call.result = call ptr @csec_string_concat(ptr %c6, ptr @.str.expr.i64.close.nl)
  ret ptr %call.result
operator.find:
  %op = call i32 @expressionTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %end)
  %has.op = icmp sgt i32 %op, %arg.start
  br i1 %has.op, label %operator.return, label %zero.return
operator.return:
  %op.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %op)
  %mnemonic = call ptr @irOperatorName(ptr %op.text)
  %left.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.i64.left)
  %left = call ptr @generateLLVMExpressionI64(ptr %arg.tokens, i32 %arg.start, i32 %op, ptr %left.name)
  %right.start = add i32 %op, 1
  %right.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.i64.right)
  %right = call ptr @generateLLVMExpressionI64(ptr %arg.tokens, i32 %right.start, i32 %end, ptr %right.name)
  %b1 = call ptr @csec_string_concat(ptr %left, ptr %right)
  %b2 = call ptr @csec_string_concat(ptr %b1, ptr @.str.expr.i64.prefix)
  %b3 = call ptr @csec_string_concat(ptr %b2, ptr %arg.resultName)
  %b4 = call ptr @csec_string_concat(ptr %b3, ptr @.str.expr.i64.operator.prefix)
  %b5 = call ptr @csec_string_concat(ptr %b4, ptr %mnemonic)
  %b6 = call ptr @csec_string_concat(ptr %b5, ptr @.str.expr.i64.operator.middle)
  %b7 = call ptr @csec_string_concat(ptr %b6, ptr %left.name)
  %b8 = call ptr @csec_string_concat(ptr %b7, ptr @.str.expr.i64.operator.comma)
  %binary.result = call ptr @csec_string_concat(ptr %b8, ptr %right.name)
  ret ptr %binary.result
}

)";
    output += llvmStringGlobal(".str.expr.i64.prefix", "  ");
    output += llvmStringGlobal(".str.expr.i64.zero", " = add i64 0, 0\n");
    output += llvmStringGlobal(".str.expr.i64.add", " = add i64 0, ");
    output += llvmStringGlobal(".str.expr.i64.load", " = load i64, ptr %");
    output += llvmStringGlobal(".str.expr.i64.open", "(");
    output += llvmStringGlobal(".str.expr.i64.close", ")");
    output += llvmStringGlobal(".str.expr.i64.close.nl", ")\n");
    output += llvmStringGlobal(".str.expr.i64.call", " = call i64 @");
    output += llvmStringGlobal(".str.expr.i64.left", ".left");
    output += llvmStringGlobal(".str.expr.i64.right", ".right");
    output += llvmStringGlobal(".str.expr.i64.operator.prefix", " = ");
    output += llvmStringGlobal(".str.expr.i64.operator.middle", " i64 ");
    output += llvmStringGlobal(".str.expr.i64.operator.comma", ", ");
    return output;
}

std::string llvmBlockEndsWithTopLevelReturnDefinition() {
    std::string output = R"(define i1 @llvmBlockEndsWithTopLevelReturn(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {
entry:
  %first = call i32 @skipTrivia(ptr %arg.tokens, i32 %arg.bodyStart)
  br label %loop
loop:
  %cursor = phi i32 [ %first, %entry ], [ %next.cursor, %body ]
  %result = phi i1 [ false, %entry ], [ %is.return, %body ]
  %before.end = icmp slt i32 %cursor, %arg.bodyEnd
  br i1 %before.end, label %eof.check, label %done
eof.check:
  %kind = call i8 @tokenKindAt(ptr %arg.tokens, i32 %cursor)
  %eof.kind = call i8 @kindEof()
  %is.eof = icmp eq i8 %kind, %eof.kind
  br i1 %is.eof, label %done, label %body
body:
  %next = call i32 @advanceStatement(ptr %arg.tokens, i32 %cursor, i32 %arg.bodyEnd)
  %statement = call ptr @statementKind(ptr %arg.tokens, i32 %cursor)
  %is.return = call i1 @strEq(ptr %statement, ptr @.str.block.return)
  %next.cursor = call i32 @skipTrivia(ptr %arg.tokens, i32 %next)
  br label %loop
done:
  ret i1 %result
}

)";
    output += llvmStringGlobal(".str.block.return", "return");
    return output;
}

std::string llvmGenerateExpressionF64Definition() {
    std::string output = R"(define ptr @generateLLVMExpressionF64(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName) {
entry:
  %end = call i32 @trimExpressionEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd)
  %empty = icmp sle i32 %end, %arg.start
  br i1 %empty, label %zero.return, label %literal.check
zero.return:
  %z1 = call ptr @csec_string_concat(ptr @.str.expr.f64.prefix, ptr %arg.resultName)
  %zero.result = call ptr @csec_string_concat(ptr %z1, ptr @.str.expr.f64.zero)
  ret ptr %zero.result
literal.check:
  %kind = call i8 @tokenKindAt(ptr %arg.tokens, i32 %arg.start)
  %float.kind = call i8 @kindFloat()
  %is.float = icmp eq i8 %kind, %float.kind
  %integer.kind = call i8 @kindInteger()
  %is.integer = icmp eq i8 %kind, %integer.kind
  %number = or i1 %is.float, %is.integer
  %single.end = add i32 %arg.start, 1
  %single = icmp eq i32 %end, %single.end
  %literal = and i1 %number, %single
  br i1 %literal, label %literal.return, label %identifier.check
literal.return:
  %text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %l1 = call ptr @csec_string_concat(ptr @.str.expr.f64.prefix, ptr %arg.resultName)
  %l2 = call ptr @csec_string_concat(ptr %l1, ptr @.str.expr.f64.fadd)
  %literal.result = call ptr @csec_string_concat(ptr %l2, ptr %text)
  ret ptr %literal.result
identifier.check:
  %identifier.kind = call i8 @kindIdentifier()
  %is.identifier = icmp eq i8 %kind, %identifier.kind
  br i1 %is.identifier, label %identifier.next, label %operator.find
identifier.next:
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  br i1 %single, label %identifier.return, label %call.check
identifier.return:
  %storage = call ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %i1 = call ptr @csec_string_concat(ptr @.str.expr.f64.prefix, ptr %arg.resultName)
  %i2 = call ptr @csec_string_concat(ptr %i1, ptr @.str.expr.f64.load)
  %identifier.result = call ptr @csec_string_concat(ptr %i2, ptr %storage)
  ret ptr %identifier.result
call.check:
  %open.index = add i32 %arg.start, 1
  %before.end = icmp slt i32 %open.index, %end
  br i1 %before.end, label %open.check, label %operator.find
open.check:
  %operator.kind = call i8 @kindOperator()
  %open.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %open.index, i8 %operator.kind, ptr @.str.expr.f64.open)
  %open = icmp ne i32 %open.raw, 0
  br i1 %open, label %close.check, label %operator.find
close.check:
  %close = call i32 @findClosingToken(ptr %arg.tokens, i32 %open.index, i32 %end, ptr @.str.expr.f64.open, ptr @.str.expr.f64.close)
  %last = sub i32 %end, 1
  %is.call = icmp eq i32 %close, %last
  br i1 %is.call, label %call.return, label %operator.find
call.return:
  %args.start = add i32 %arg.start, 2
  %loads = call ptr @generateLLVMCallArgumentLoadsI32(ptr %arg.tokens, i32 %args.start, i32 %last, ptr %arg.resultName)
  %arguments = call ptr @generateLLVMCallArgumentListI32(ptr %arg.tokens, i32 %args.start, i32 %last, ptr %arg.resultName)
  %callee = call ptr @llvmRuntimeCallName(ptr %name)
  %c1 = call ptr @csec_string_concat(ptr %loads, ptr @.str.expr.f64.prefix)
  %c2 = call ptr @csec_string_concat(ptr %c1, ptr %arg.resultName)
  %c3 = call ptr @csec_string_concat(ptr %c2, ptr @.str.expr.f64.call)
  %c4 = call ptr @csec_string_concat(ptr %c3, ptr %callee)
  %c5 = call ptr @csec_string_concat(ptr %c4, ptr @.str.expr.f64.open)
  %c6 = call ptr @csec_string_concat(ptr %c5, ptr %arguments)
  %call.result = call ptr @csec_string_concat(ptr %c6, ptr @.str.expr.f64.close.nl)
  ret ptr %call.result
operator.find:
  %op = call i32 @expressionTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %end)
  %has.op = icmp sgt i32 %op, %arg.start
  br i1 %has.op, label %operator.check, label %zero.return
operator.check:
  %op.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %op)
  %add = call i1 @strEq(ptr %op.text, ptr @.str.expr.f64.add.symbol)
  br i1 %add, label %binary.add, label %sub.check
sub.check:
  %sub = call i1 @strEq(ptr %op.text, ptr @.str.expr.f64.sub.symbol)
  br i1 %sub, label %binary.sub, label %mul.check
mul.check:
  %mul = call i1 @strEq(ptr %op.text, ptr @.str.expr.f64.mul.symbol)
  br i1 %mul, label %binary.mul, label %div.check
div.check:
  %div = call i1 @strEq(ptr %op.text, ptr @.str.expr.f64.div.symbol)
  br i1 %div, label %binary.div, label %zero.return
binary.add:
  br label %binary
binary.sub:
  br label %binary
binary.mul:
  br label %binary
binary.div:
  br label %binary
binary:
  %mnemonic = phi ptr [ @.str.expr.f64.fadd.name, %binary.add ], [ @.str.expr.f64.fsub.name, %binary.sub ], [ @.str.expr.f64.fmul.name, %binary.mul ], [ @.str.expr.f64.fdiv.name, %binary.div ]
  %left.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.f64.left)
  %left = call ptr @generateLLVMExpressionF64(ptr %arg.tokens, i32 %arg.start, i32 %op, ptr %left.name)
  %right.start = add i32 %op, 1
  %right.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.f64.right)
  %right = call ptr @generateLLVMExpressionF64(ptr %arg.tokens, i32 %right.start, i32 %end, ptr %right.name)
  %b1 = call ptr @csec_string_concat(ptr %left, ptr %right)
  %b2 = call ptr @csec_string_concat(ptr %b1, ptr @.str.expr.f64.prefix)
  %b3 = call ptr @csec_string_concat(ptr %b2, ptr %arg.resultName)
  %b4 = call ptr @csec_string_concat(ptr %b3, ptr @.str.expr.f64.operator.prefix)
  %b5 = call ptr @csec_string_concat(ptr %b4, ptr %mnemonic)
  %b6 = call ptr @csec_string_concat(ptr %b5, ptr @.str.expr.f64.operator.middle)
  %b7 = call ptr @csec_string_concat(ptr %b6, ptr %left.name)
  %b8 = call ptr @csec_string_concat(ptr %b7, ptr @.str.expr.f64.operator.comma)
  %binary.result = call ptr @csec_string_concat(ptr %b8, ptr %right.name)
  ret ptr %binary.result
}

)";
    output += llvmStringGlobal(".str.expr.f64.prefix", "  ");
    output += llvmStringGlobal(".str.expr.f64.zero", " = fadd double 0.000000e+00, 0.000000e+00\n");
    output += llvmStringGlobal(".str.expr.f64.fadd", " = fadd double 0.000000e+00, ");
    output += llvmStringGlobal(".str.expr.f64.load", " = load double, ptr %");
    output += llvmStringGlobal(".str.expr.f64.open", "(");
    output += llvmStringGlobal(".str.expr.f64.close", ")");
    output += llvmStringGlobal(".str.expr.f64.close.nl", ")\n");
    output += llvmStringGlobal(".str.expr.f64.call", " = call double @");
    output += llvmStringGlobal(".str.expr.f64.add.symbol", "+");
    output += llvmStringGlobal(".str.expr.f64.sub.symbol", "-");
    output += llvmStringGlobal(".str.expr.f64.mul.symbol", "*");
    output += llvmStringGlobal(".str.expr.f64.div.symbol", "/");
    output += llvmStringGlobal(".str.expr.f64.fadd.name", "fadd");
    output += llvmStringGlobal(".str.expr.f64.fsub.name", "fsub");
    output += llvmStringGlobal(".str.expr.f64.fmul.name", "fmul");
    output += llvmStringGlobal(".str.expr.f64.fdiv.name", "fdiv");
    output += llvmStringGlobal(".str.expr.f64.left", ".left");
    output += llvmStringGlobal(".str.expr.f64.right", ".right");
    output += llvmStringGlobal(".str.expr.f64.operator.prefix", " = ");
    output += llvmStringGlobal(".str.expr.f64.operator.middle", " double ");
    output += llvmStringGlobal(".str.expr.f64.operator.comma", ", ");
    return output;
}

std::string llvmGenerateExpressionPtrDefinition() {
    std::string output = R"(define ptr @csecGenerateLLVMStringOperand(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName) {
entry:
  %end = call i32 @trimExpressionEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd)
  %kind = call i8 @tokenKindAt(ptr %arg.tokens, i32 %arg.start)
  %single.end = add i32 %arg.start, 1
  %single = icmp eq i32 %end, %single.end
  %string.kind = call i8 @kindString()
  %is.string = icmp eq i8 %kind, %string.kind
  %string = and i1 %is.string, %single
  br i1 %string, label %ptr.return, label %identifier.check
identifier.check:
  %identifier.kind = call i8 @kindIdentifier()
  %is.identifier = icmp eq i8 %kind, %identifier.kind
  br i1 %is.identifier, label %identifier.next, label %char.check
identifier.next:
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  br i1 %single, label %identifier.single, label %identifier.complex
identifier.single:
  %type = call ptr @lookupVisibleValueType(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %ir.type = call ptr @irTypeName(ptr %type)
  %ptr = call i1 @strEq(ptr %ir.type, ptr @.str.expr.ptr.ptr)
  br i1 %ptr, label %ptr.return, label %identifier.char.check
identifier.char.check:
  %character = call i1 @strEq(ptr %type, ptr @.str.expr.ptr.char)
  br i1 %character, label %char.identifier, label %i32.return
identifier.complex:
  %open.index = add i32 %arg.start, 1
  %operator.kind = call i8 @kindOperator()
  %open.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %open.index, i8 %operator.kind, ptr @.str.expr.ptr.open)
  %open = icmp ne i32 %open.raw, 0
  br i1 %open, label %call.close.check, label %substring.check
call.close.check:
  %close = call i32 @findClosingToken(ptr %arg.tokens, i32 %open.index, i32 %end, ptr @.str.expr.ptr.open, ptr @.str.expr.ptr.close)
  %last = sub i32 %end, 1
  %is.call = icmp eq i32 %close, %last
  br i1 %is.call, label %call.type.check, label %substring.check
call.type.check:
  %return.type = call ptr @lookupFunctionReturnType(ptr %arg.tokens, ptr %name)
  %call.ir.type = call ptr @irTypeName(ptr %return.type)
  %call.ptr = call i1 @strEq(ptr %call.ir.type, ptr @.str.expr.ptr.ptr)
  br i1 %call.ptr, label %ptr.return, label %i32.return
substring.check:
  %dot.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %open.index, i8 %operator.kind, ptr @.str.expr.ptr.dot)
  %dot = icmp ne i32 %dot.raw, 0
  br i1 %dot, label %substring.name.check, label %plus.check
substring.name.check:
  %substring.index = add i32 %arg.start, 2
  %substring.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %substring.index, i8 %identifier.kind, ptr @.str.expr.ptr.substring)
  %substring = icmp ne i32 %substring.raw, 0
  br i1 %substring, label %ptr.return, label %plus.check
char.check:
  %char.kind = call i8 @kindChar()
  %is.char = icmp eq i8 %kind, %char.kind
  %char = and i1 %is.char, %single
  br i1 %char, label %char.literal, label %plus.check
char.literal:
  %text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %value = call ptr @llvmCharI8Value(ptr %text)
  %c1 = call ptr @csec_string_concat(ptr @.str.expr.ptr.prefix, ptr %arg.resultName)
  %c2 = call ptr @csec_string_concat(ptr %c1, ptr @.str.expr.ptr.char.call)
  %c3 = call ptr @csec_string_concat(ptr %c2, ptr %text)
  %char.result = call ptr @csec_string_concat(ptr %c3, ptr @.str.expr.ptr.char.close)
  ret ptr %char.result
char.identifier:
  %storage = call ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %c4 = call ptr @csec_string_concat(ptr @.str.expr.ptr.prefix, ptr %arg.resultName)
  %c5 = call ptr @csec_string_concat(ptr %c4, ptr @.str.expr.ptr.char.load)
  %c6 = call ptr @csec_string_concat(ptr %c5, ptr %storage)
  %c7 = call ptr @csec_string_concat(ptr %c6, ptr @.str.expr.ptr.char.nl)
  %c8 = call ptr @csec_string_concat(ptr %c7, ptr @.str.expr.ptr.prefix)
  %c9 = call ptr @csec_string_concat(ptr %c8, ptr %arg.resultName)
  %c10 = call ptr @csec_string_concat(ptr %c9, ptr @.str.expr.ptr.char.call)
  %c11 = call ptr @csec_string_concat(ptr %c10, ptr %arg.resultName)
  %char.identifier.result = call ptr @csec_string_concat(ptr %c11, ptr @.str.expr.ptr.char.value.close)
  ret ptr %char.identifier.result
plus.check:
  %plus = call i32 @expressionTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %end)
  %has.plus = icmp sgt i32 %plus, %arg.start
  br i1 %has.plus, label %plus.text.check, label %i32.return
plus.text.check:
  %plus.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %plus)
  %is.plus = call i1 @strEq(ptr %plus.text, ptr @.str.expr.ptr.plus)
  br i1 %is.plus, label %ptr.return, label %i32.return
ptr.return:
  %ptr.code = call ptr @generateLLVMExpressionPtr(ptr %arg.tokens, i32 %arg.start, i32 %end, ptr %arg.resultName)
  ret ptr %ptr.code
i32.return:
  %i32.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.ptr.i32)
  %i32.code = call ptr @generateLLVMExpressionI32(ptr %arg.tokens, i32 %arg.start, i32 %end, ptr %i32.name)
  %i64.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.ptr.i64)
  %n1 = call ptr @csec_string_concat(ptr %i32.code, ptr @.str.expr.ptr.prefix)
  %n2 = call ptr @csec_string_concat(ptr %n1, ptr %i64.name)
  %n3 = call ptr @csec_string_concat(ptr %n2, ptr @.str.expr.ptr.sext)
  %n4 = call ptr @csec_string_concat(ptr %n3, ptr %i32.name)
  %n5 = call ptr @csec_string_concat(ptr %n4, ptr @.str.expr.ptr.to.i64)
  %n6 = call ptr @csec_string_concat(ptr %n5, ptr @.str.expr.ptr.prefix)
  %n7 = call ptr @csec_string_concat(ptr %n6, ptr %arg.resultName)
  %n8 = call ptr @csec_string_concat(ptr %n7, ptr @.str.expr.ptr.i64.call)
  %n9 = call ptr @csec_string_concat(ptr %n8, ptr %i64.name)
  %numeric.result = call ptr @csec_string_concat(ptr %n9, ptr @.str.expr.ptr.close.nl)
  ret ptr %numeric.result
}

define ptr @generateLLVMExpressionPtr(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName) {
entry:
  %end = call i32 @trimExpressionEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd)
  %empty = icmp sle i32 %end, %arg.start
  br i1 %empty, label %empty.return, label %string.check
empty.return:
  %e1 = call ptr @csec_string_concat(ptr @.str.expr.ptr.prefix, ptr %arg.resultName)
  %empty.result = call ptr @csec_string_concat(ptr %e1, ptr @.str.expr.ptr.null)
  ret ptr %empty.result
string.check:
  %kind = call i8 @tokenKindAt(ptr %arg.tokens, i32 %arg.start)
  %string.kind = call i8 @kindString()
  %is.string = icmp eq i8 %kind, %string.kind
  %single.end = add i32 %arg.start, 1
  %single = icmp eq i32 %end, %single.end
  %string = and i1 %is.string, %single
  br i1 %string, label %string.return, label %identifier.check
string.return:
  %text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %bytes = call i32 @csec_llvm_string_literal_byte_length(ptr %text)
  %bytes.i64 = sext i32 %bytes to i64
  %bytes.text = call ptr @csec_to_string_i64(i64 %bytes.i64)
  %start.i64 = sext i32 %arg.start to i64
  %start.text = call ptr @csec_to_string_i64(i64 %start.i64)
  %s1 = call ptr @csec_string_concat(ptr @.str.expr.ptr.prefix, ptr %arg.resultName)
  %s2 = call ptr @csec_string_concat(ptr %s1, ptr @.str.expr.ptr.gep.a)
  %s3 = call ptr @csec_string_concat(ptr %s2, ptr %bytes.text)
  %s4 = call ptr @csec_string_concat(ptr %s3, ptr @.str.expr.ptr.gep.b)
  %s5 = call ptr @csec_string_concat(ptr %s4, ptr %start.text)
  %string.result = call ptr @csec_string_concat(ptr %s5, ptr @.str.expr.ptr.gep.c)
  ret ptr %string.result
identifier.check:
  %identifier.kind = call i8 @kindIdentifier()
  %is.identifier = icmp eq i8 %kind, %identifier.kind
  br i1 %is.identifier, label %identifier.next, label %plus.find
identifier.next:
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  br i1 %single, label %identifier.return, label %call.check
identifier.return:
  %storage = call ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %i1 = call ptr @csec_string_concat(ptr @.str.expr.ptr.prefix, ptr %arg.resultName)
  %i2 = call ptr @csec_string_concat(ptr %i1, ptr @.str.expr.ptr.load)
  %identifier.result = call ptr @csec_string_concat(ptr %i2, ptr %storage)
  ret ptr %identifier.result
call.check:
  %open.index = add i32 %arg.start, 1
  %operator.kind = call i8 @kindOperator()
  %open.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %open.index, i8 %operator.kind, ptr @.str.expr.ptr.open)
  %open = icmp ne i32 %open.raw, 0
  br i1 %open, label %call.close.check, label %substring.check
call.close.check:
  %close = call i32 @findClosingToken(ptr %arg.tokens, i32 %open.index, i32 %end, ptr @.str.expr.ptr.open, ptr @.str.expr.ptr.close)
  %last = sub i32 %end, 1
  %is.call = icmp eq i32 %close, %last
  br i1 %is.call, label %call.return, label %substring.check
call.return:
  %args.start = add i32 %arg.start, 2
  %loads = call ptr @generateLLVMCallArgumentLoadsI32(ptr %arg.tokens, i32 %args.start, i32 %last, ptr %arg.resultName)
  %arguments = call ptr @generateLLVMCallArgumentListI32(ptr %arg.tokens, i32 %args.start, i32 %last, ptr %arg.resultName)
  %callee = call ptr @llvmRuntimeCallName(ptr %name)
  %c1 = call ptr @csec_string_concat(ptr %loads, ptr @.str.expr.ptr.prefix)
  %c2 = call ptr @csec_string_concat(ptr %c1, ptr %arg.resultName)
  %c3 = call ptr @csec_string_concat(ptr %c2, ptr @.str.expr.ptr.call)
  %c4 = call ptr @csec_string_concat(ptr %c3, ptr %callee)
  %c5 = call ptr @csec_string_concat(ptr %c4, ptr @.str.expr.ptr.open)
  %c6 = call ptr @csec_string_concat(ptr %c5, ptr %arguments)
  %call.result = call ptr @csec_string_concat(ptr %c6, ptr @.str.expr.ptr.close.nl)
  ret ptr %call.result
substring.check:
  %dot.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %open.index, i8 %operator.kind, ptr @.str.expr.ptr.dot)
  %dot = icmp ne i32 %dot.raw, 0
  br i1 %dot, label %substring.name.check, label %plus.find
substring.name.check:
  %substring.index = add i32 %arg.start, 2
  %substring.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %substring.index, i8 %identifier.kind, ptr @.str.expr.ptr.substring)
  %substring = icmp ne i32 %substring.raw, 0
  br i1 %substring, label %substring.open.check, label %plus.find
substring.open.check:
  %substring.open.index = add i32 %arg.start, 3
  %substring.open.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %substring.open.index, i8 %operator.kind, ptr @.str.expr.ptr.open)
  %substring.open = icmp ne i32 %substring.open.raw, 0
  br i1 %substring.open, label %substring.close.check, label %plus.find
substring.close.check:
  %substring.close = call i32 @findClosingToken(ptr %arg.tokens, i32 %substring.open.index, i32 %end, ptr @.str.expr.ptr.open, ptr @.str.expr.ptr.close)
  %substring.last = sub i32 %end, 1
  %substring.complete = icmp eq i32 %substring.close, %substring.last
  br i1 %substring.complete, label %substring.comma.find, label %plus.find
substring.comma.find:
  %arguments.start = add i32 %arg.start, 4
  %comma = call i32 @findTokenTextInRange(ptr %arg.tokens, i32 %arguments.start, i32 %substring.last, ptr @.str.expr.ptr.comma)
  %has.comma = icmp sgt i32 %comma, %arguments.start
  br i1 %has.comma, label %substring.return, label %plus.find
substring.return:
  %storage.name = call ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %object.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.ptr.object)
  %start.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.ptr.start)
  %length.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.ptr.length)
  %object.prefix = call ptr @csec_string_concat(ptr @.str.expr.ptr.prefix, ptr %object.name)
  %object.code = call ptr @csec_string_concat(ptr %object.prefix, ptr @.str.expr.ptr.object.load)
  %object.result = call ptr @csec_string_concat(ptr %object.code, ptr %storage.name)
  %start.code = call ptr @generateLLVMExpressionI32(ptr %arg.tokens, i32 %arguments.start, i32 %comma, ptr %start.name)
  %length.start = add i32 %comma, 1
  %length.code = call ptr @generateLLVMExpressionI32(ptr %arg.tokens, i32 %length.start, i32 %substring.last, ptr %length.name)
  %u1 = call ptr @csec_string_concat(ptr %object.result, ptr %start.code)
  %u2 = call ptr @csec_string_concat(ptr %u1, ptr %length.code)
  %u3 = call ptr @csec_string_concat(ptr %u2, ptr @.str.expr.ptr.prefix)
  %u4 = call ptr @csec_string_concat(ptr %u3, ptr %arg.resultName)
  %u5 = call ptr @csec_string_concat(ptr %u4, ptr @.str.expr.ptr.substring.call)
  %u6 = call ptr @csec_string_concat(ptr %u5, ptr %object.name)
  %u7 = call ptr @csec_string_concat(ptr %u6, ptr @.str.expr.ptr.substring.middle)
  %u8 = call ptr @csec_string_concat(ptr %u7, ptr %start.name)
  %u9 = call ptr @csec_string_concat(ptr %u8, ptr @.str.expr.ptr.substring.middle)
  %u10 = call ptr @csec_string_concat(ptr %u9, ptr %length.name)
  %substring.result = call ptr @csec_string_concat(ptr %u10, ptr @.str.expr.ptr.close.nl)
  ret ptr %substring.result
plus.find:
  %op = call i32 @expressionTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %end)
  %has.op = icmp sgt i32 %op, %arg.start
  br i1 %has.op, label %plus.check, label %fallback
plus.check:
  %op.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %op)
  %plus = call i1 @strEq(ptr %op.text, ptr @.str.expr.ptr.plus)
  br i1 %plus, label %plus.return, label %fallback
plus.return:
  %left.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.ptr.left)
  %left = call ptr @csecGenerateLLVMStringOperand(ptr %arg.tokens, i32 %arg.start, i32 %op, ptr %left.name)
  %right.start = add i32 %op, 1
  %right.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.ptr.right)
  %right = call ptr @csecGenerateLLVMStringOperand(ptr %arg.tokens, i32 %right.start, i32 %end, ptr %right.name)
  %p1 = call ptr @csec_string_concat(ptr %left, ptr %right)
  %p2 = call ptr @csec_string_concat(ptr %p1, ptr @.str.expr.ptr.prefix)
  %p3 = call ptr @csec_string_concat(ptr %p2, ptr %arg.resultName)
  %p4 = call ptr @csec_string_concat(ptr %p3, ptr @.str.expr.ptr.concat)
  %p5 = call ptr @csec_string_concat(ptr %p4, ptr %left.name)
  %p6 = call ptr @csec_string_concat(ptr %p5, ptr @.str.expr.ptr.concat.middle)
  %p7 = call ptr @csec_string_concat(ptr %p6, ptr %right.name)
  %plus.result = call ptr @csec_string_concat(ptr %p7, ptr @.str.expr.ptr.close.nl)
  ret ptr %plus.result
fallback:
  %f1 = call ptr @csec_string_concat(ptr @.str.expr.ptr.prefix, ptr %arg.resultName)
  %fallback.result = call ptr @csec_string_concat(ptr %f1, ptr @.str.expr.ptr.null)
  ret ptr %fallback.result
}

)";
    output += llvmStringGlobal(".str.expr.ptr.prefix", "  ");
    output += llvmStringGlobal(".str.expr.ptr.null", " = inttoptr i64 0 to ptr\n");
    output += llvmStringGlobal(".str.expr.ptr.ptr", "ptr");
    output += llvmStringGlobal(".str.expr.ptr.char", "Char");
    output += llvmStringGlobal(".str.expr.ptr.open", "(");
    output += llvmStringGlobal(".str.expr.ptr.close", ")");
    output += llvmStringGlobal(".str.expr.ptr.close.nl", ")\n");
    output += llvmStringGlobal(".str.expr.ptr.dot", ".");
    output += llvmStringGlobal(".str.expr.ptr.substring", "substring");
    output += llvmStringGlobal(".str.expr.ptr.plus", "+");
    output += llvmStringGlobal(".str.expr.ptr.i32", ".i32");
    output += llvmStringGlobal(".str.expr.ptr.i64", ".i64");
    output += llvmStringGlobal(".str.expr.ptr.sext", " = sext i32 ");
    output += llvmStringGlobal(".str.expr.ptr.to.i64", " to i64\n");
    output += llvmStringGlobal(".str.expr.ptr.i64.call", " = call ptr @csec_to_string_i64(i64 ");
    output += llvmStringGlobal(".str.expr.ptr.gep.a", " = getelementptr inbounds [");
    output += llvmStringGlobal(".str.expr.ptr.gep.b", " x i8], ptr @.str.");
    output += llvmStringGlobal(".str.expr.ptr.gep.c", ", i32 0, i32 0\n");
    output += llvmStringGlobal(".str.expr.ptr.load", " = load ptr, ptr %");
    output += llvmStringGlobal(".str.expr.ptr.call", " = call ptr @");
    output += llvmStringGlobal(".str.expr.ptr.comma", ",");
    output += llvmStringGlobal(".str.expr.ptr.object", ".obj");
    output += llvmStringGlobal(".str.expr.ptr.start", ".start");
    output += llvmStringGlobal(".str.expr.ptr.length", ".length");
    output += llvmStringGlobal(".str.expr.ptr.object.load", " = load ptr, ptr %");
    output += llvmStringGlobal(".str.expr.ptr.substring.call", " = call ptr @csec_string_substring(ptr ");
    output += llvmStringGlobal(".str.expr.ptr.substring.middle", ", i32 ");
    output += llvmStringGlobal(".str.expr.ptr.left", ".left");
    output += llvmStringGlobal(".str.expr.ptr.right", ".right");
    output += llvmStringGlobal(".str.expr.ptr.concat", " = call ptr @csec_string_concat(ptr ");
    output += llvmStringGlobal(".str.expr.ptr.concat.middle", ", ptr ");
    output += llvmStringGlobal(".str.expr.ptr.char.call", " = call ptr @csec_to_string_char(i8 ");
    output += llvmStringGlobal(".str.expr.ptr.char.close", ")\n");
    output += llvmStringGlobal(".str.expr.ptr.char.load", " = load i8, ptr %");
    output += llvmStringGlobal(".str.expr.ptr.char.nl", "\n");
    output += llvmStringGlobal(".str.expr.ptr.char.value.close", ")\n");
    return output;
}

std::string llvmGenerateLocalPtrDefinition() {
    std::string output = R"(define ptr @generateLLVMLocalPtr(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %initializer = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, i32 1)
  %name.index = add i32 %arg.start, 1
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %name.index)
  %start.i64 = sext i32 %arg.start to i64
  %start.text = call ptr @csec_to_string_i64(i64 %start.i64)
  %storage.a = call ptr @csec_string_concat(ptr %name, ptr @.str.local.ptr.addr)
  %storage = call ptr @csec_string_concat(ptr %storage.a, ptr %start.text)
  %init.a = call ptr @csec_string_concat(ptr @.str.local.ptr.percent, ptr %name)
  %init.b = call ptr @csec_string_concat(ptr %init.a, ptr @.str.local.ptr.init)
  %init = call ptr @csec_string_concat(ptr %init.b, ptr %start.text)
  %has.initializer = icmp sge i32 %initializer, %arg.start
  br i1 %has.initializer, label %with.initializer, label %without.initializer
with.initializer:
  %expr.start = add i32 %initializer, 1
  %expr = call ptr @generateLLVMExpressionPtr(ptr %arg.tokens, i32 %expr.start, i32 %arg.end, ptr %init)
  %a1 = call ptr @csec_string_concat(ptr @.str.local.ptr.prefix, ptr %storage)
  %a2 = call ptr @csec_string_concat(ptr %a1, ptr @.str.local.ptr.alloca)
  %a3 = call ptr @csec_string_concat(ptr %a2, ptr %expr)
  %a4 = call ptr @csec_string_concat(ptr %a3, ptr @.str.local.ptr.store)
  %a5 = call ptr @csec_string_concat(ptr %a4, ptr %init)
  %a6 = call ptr @csec_string_concat(ptr %a5, ptr @.str.local.ptr.to)
  %result = call ptr @csec_string_concat(ptr %a6, ptr %storage)
  ret ptr %result
without.initializer:
  %b1 = call ptr @csec_string_concat(ptr @.str.local.ptr.prefix, ptr %storage)
  %b2 = call ptr @csec_string_concat(ptr %b1, ptr @.str.local.ptr.alloca)
  %b3 = call ptr @csec_string_concat(ptr %b2, ptr @.str.local.ptr.null)
  %fallback = call ptr @csec_string_concat(ptr %b3, ptr %storage)
  ret ptr %fallback
}

)";
    output += llvmStringGlobal(".str.local.ptr.addr", ".addr.");
    output += llvmStringGlobal(".str.local.ptr.percent", "%");
    output += llvmStringGlobal(".str.local.ptr.init", ".pinit.");
    output += llvmStringGlobal(".str.local.ptr.prefix", "  %");
    output += llvmStringGlobal(".str.local.ptr.alloca", " = alloca ptr\n");
    output += llvmStringGlobal(".str.local.ptr.store", "  store ptr ");
    output += llvmStringGlobal(".str.local.ptr.to", ", ptr %");
    output += llvmStringGlobal(".str.local.ptr.null", "  store ptr null, ptr %");
    return output;
}

std::string llvmGenerateLLVMIfI32Definition() {
    std::string output = R"(define ptr @generateLLVMIfI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %open = call i32 @findStatementParenStart(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %close = call i32 @findStatementParenEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %then.open = call i32 @findStatementBlockStart(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %then.close = call i32 @findClosingToken(ptr %arg.tokens, i32 %then.open, i32 %arg.end, ptr @.str.llvm.if.brace.open, ptr @.str.llvm.if.brace.close)
  %open.ok = icmp sge i32 %open, 0
  %close.ok = icmp sgt i32 %close, %open
  %body.ok = icmp sgt i32 %then.close, %then.open
  %ok.a = and i1 %open.ok, %close.ok
  %ok = and i1 %ok.a, %body.ok
  br i1 %ok, label %build, label %bad
bad:
  ret ptr @.str.llvm.if.bad
build:
  %seed.i64 = sext i32 %arg.start to i64
  %seed = call ptr @csec_to_string_i64(i64 %seed.i64)
  %condition.name.a = call ptr @csec_string_concat(ptr @.str.llvm.if.condition.name, ptr %seed)
  %expr.start = add i32 %open, 1
  %condition = call ptr @generateLLVMExpressionI1(ptr %arg.tokens, i32 %expr.start, i32 %close, ptr %condition.name.a)
  %body.start = add i32 %then.open, 1
  %body = call ptr @generateLLVMFlatBodyI32(ptr %arg.tokens, i32 %body.start, i32 %then.close)
  %a1 = call ptr @csec_string_concat(ptr %condition, ptr @.str.llvm.if.branch)
  %a2 = call ptr @csec_string_concat(ptr %a1, ptr %seed)
  %a3 = call ptr @csec_string_concat(ptr %a2, ptr @.str.llvm.if.then.label)
  %a4 = call ptr @csec_string_concat(ptr %a3, ptr %seed)
  %a5 = call ptr @csec_string_concat(ptr %a4, ptr @.str.llvm.if.else.label)
  %a6 = call ptr @csec_string_concat(ptr %a5, ptr %seed)
  %a7 = call ptr @csec_string_concat(ptr %a6, ptr @.str.llvm.if.nl)
  %a8 = call ptr @csec_string_concat(ptr %a7, ptr @.str.llvm.if.then.name)
  %a9 = call ptr @csec_string_concat(ptr %a8, ptr %seed)
  %a10 = call ptr @csec_string_concat(ptr %a9, ptr @.str.llvm.if.colon)
  %a11 = call ptr @csec_string_concat(ptr %a10, ptr %body)
  %a12 = call ptr @csec_string_concat(ptr %a11, ptr @.str.llvm.if.end.branch)
  %a13 = call ptr @csec_string_concat(ptr %a12, ptr %seed)
  %a14 = call ptr @csec_string_concat(ptr %a13, ptr @.str.llvm.if.nl)
  %a15 = call ptr @csec_string_concat(ptr %a14, ptr @.str.llvm.if.else.name)
  %a16 = call ptr @csec_string_concat(ptr %a15, ptr %seed)
  %a17 = call ptr @csec_string_concat(ptr %a16, ptr @.str.llvm.if.colon)
  %a18 = call ptr @csec_string_concat(ptr %a17, ptr @.str.llvm.if.end.branch)
  %a19 = call ptr @csec_string_concat(ptr %a18, ptr %seed)
  %a20 = call ptr @csec_string_concat(ptr %a19, ptr @.str.llvm.if.nl)
  %a21 = call ptr @csec_string_concat(ptr %a20, ptr @.str.llvm.if.end.name)
  %a22 = call ptr @csec_string_concat(ptr %a21, ptr %seed)
  %result = call ptr @csec_string_concat(ptr %a22, ptr @.str.llvm.if.colon)
  ret ptr %result
}

)";
    output += llvmStringGlobal(".str.llvm.if.bad", "  ; malformed if\n");
    output += llvmStringGlobal(".str.llvm.if.brace.open", "{");
    output += llvmStringGlobal(".str.llvm.if.brace.close", "}");
    output += llvmStringGlobal(".str.llvm.if.condition.name", "%cond.");
    output += llvmStringGlobal(".str.llvm.if.branch", "  br i1 %cond.");
    output += llvmStringGlobal(".str.llvm.if.then.label", ", label %if.then.");
    output += llvmStringGlobal(".str.llvm.if.else.label", ", label %if.else.");
    output += llvmStringGlobal(".str.llvm.if.nl", "\n");
    output += llvmStringGlobal(".str.llvm.if.then.name", "if.then.");
    output += llvmStringGlobal(".str.llvm.if.else.name", "if.else.");
    output += llvmStringGlobal(".str.llvm.if.end.name", "if.end.");
    output += llvmStringGlobal(".str.llvm.if.colon", ":\n");
    output += llvmStringGlobal(".str.llvm.if.end.branch", "  br label %if.end.");
    return output;
}

std::string llvmGenerateLLVMWhileI32Definition() {
    std::string output = R"(define ptr @generateLLVMWhileI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %open = call i32 @findStatementParenStart(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %close = call i32 @findStatementParenEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %body.open = call i32 @findStatementBlockStart(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %body.close = call i32 @findClosingToken(ptr %arg.tokens, i32 %body.open, i32 %arg.end, ptr @.str.llvm.while.brace.open, ptr @.str.llvm.while.brace.close)
  %open.ok = icmp sge i32 %open, 0
  %close.ok = icmp sgt i32 %close, %open
  %body.ok = icmp sgt i32 %body.close, %body.open
  %ok.a = and i1 %open.ok, %close.ok
  %ok = and i1 %ok.a, %body.ok
  br i1 %ok, label %build, label %bad
bad:
  ret ptr @.str.llvm.while.bad
build:
  %seed.i64 = sext i32 %arg.start to i64
  %seed = call ptr @csec_to_string_i64(i64 %seed.i64)
  %condition.name.a = call ptr @csec_string_concat(ptr @.str.llvm.while.condition.name, ptr %seed)
  %expr.start = add i32 %open, 1
  %condition = call ptr @generateLLVMExpressionI1(ptr %arg.tokens, i32 %expr.start, i32 %close, ptr %condition.name.a)
  %body.start = add i32 %body.open, 1
  %body = call ptr @generateLLVMFlatBodyI32(ptr %arg.tokens, i32 %body.start, i32 %body.close)
  %a1 = call ptr @csec_string_concat(ptr @.str.llvm.while.initial.branch, ptr %seed)
  %a2 = call ptr @csec_string_concat(ptr %a1, ptr @.str.llvm.while.nl)
  %a3 = call ptr @csec_string_concat(ptr %a2, ptr @.str.llvm.while.condition.label)
  %a4 = call ptr @csec_string_concat(ptr %a3, ptr %seed)
  %a5 = call ptr @csec_string_concat(ptr %a4, ptr @.str.llvm.while.colon)
  %a6 = call ptr @csec_string_concat(ptr %a5, ptr %condition)
  %a7 = call ptr @csec_string_concat(ptr %a6, ptr @.str.llvm.while.test)
  %a8 = call ptr @csec_string_concat(ptr %a7, ptr %seed)
  %a9 = call ptr @csec_string_concat(ptr %a8, ptr @.str.llvm.while.body.label)
  %a10 = call ptr @csec_string_concat(ptr %a9, ptr %seed)
  %a11 = call ptr @csec_string_concat(ptr %a10, ptr @.str.llvm.while.end.label)
  %a12 = call ptr @csec_string_concat(ptr %a11, ptr %seed)
  %a13 = call ptr @csec_string_concat(ptr %a12, ptr @.str.llvm.while.nl)
  %a14 = call ptr @csec_string_concat(ptr %a13, ptr @.str.llvm.while.body.name)
  %a15 = call ptr @csec_string_concat(ptr %a14, ptr %seed)
  %a16 = call ptr @csec_string_concat(ptr %a15, ptr @.str.llvm.while.colon)
  %a17 = call ptr @csec_string_concat(ptr %a16, ptr %body)
  %a18 = call ptr @csec_string_concat(ptr %a17, ptr @.str.llvm.while.initial.branch)
  %a19 = call ptr @csec_string_concat(ptr %a18, ptr %seed)
  %a20 = call ptr @csec_string_concat(ptr %a19, ptr @.str.llvm.while.nl)
  %a21 = call ptr @csec_string_concat(ptr %a20, ptr @.str.llvm.while.end.name)
  %a22 = call ptr @csec_string_concat(ptr %a21, ptr %seed)
  %result = call ptr @csec_string_concat(ptr %a22, ptr @.str.llvm.while.colon)
  ret ptr %result
}

)";
    output += llvmStringGlobal(".str.llvm.while.bad", "  ; malformed while\n");
    output += llvmStringGlobal(".str.llvm.while.brace.open", "{");
    output += llvmStringGlobal(".str.llvm.while.brace.close", "}");
    output += llvmStringGlobal(".str.llvm.while.condition.name", "%whilecond.");
    output += llvmStringGlobal(".str.llvm.while.initial.branch", "  br label %while.cond.");
    output += llvmStringGlobal(".str.llvm.while.condition.label", "while.cond.");
    output += llvmStringGlobal(".str.llvm.while.body.label", ", label %while.body.");
    output += llvmStringGlobal(".str.llvm.while.end.label", ", label %while.end.");
    output += llvmStringGlobal(".str.llvm.while.body.name", "while.body.");
    output += llvmStringGlobal(".str.llvm.while.end.name", "while.end.");
    output += llvmStringGlobal(".str.llvm.while.colon", ":\n");
    output += llvmStringGlobal(".str.llvm.while.nl", "\n");
    output += llvmStringGlobal(".str.llvm.while.test", "  br i1 %whilecond.");
    return output;
}

std::string llvmGenerateLLVMForI32Definition() {
    std::string output = R"(define ptr @generateLLVMForI32(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {
entry:
  %open = call i32 @findStatementParenStart(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %close = call i32 @findStatementParenEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %body.open = call i32 @findStatementBlockStart(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)
  %body.close = call i32 @findClosingToken(ptr %arg.tokens, i32 %body.open, i32 %arg.end, ptr @.str.llvm.for.brace.open, ptr @.str.llvm.for.brace.close)
  %iterator.index = add i32 %open, 1
  %iterator = call ptr @tokenTextAt(ptr %arg.tokens, i32 %iterator.index)
  %arrow = call i32 @findTokenTextInRange(ptr %arg.tokens, i32 %iterator.index, i32 %close, ptr @.str.llvm.for.arrow)
  %range = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %arrow, i32 %close, i32 5)
  %valid.open = icmp sge i32 %open, 0
  %valid.arrow = icmp sgt i32 %arrow, %iterator.index
  %valid.range = icmp sgt i32 %range, %arrow
  %valid.a = and i1 %valid.open, %valid.arrow
  %valid = and i1 %valid.a, %valid.range
  br i1 %valid, label %build, label %bad
bad:
  ret ptr @.str.llvm.for.bad
build:
  %seed.i64 = sext i32 %arg.start to i64
  %seed = call ptr @csec_to_string_i64(i64 %seed.i64)
  %start.name.a = call ptr @csec_string_concat(ptr @.str.llvm.for.percent, ptr %iterator)
  %start.name.b = call ptr @csec_string_concat(ptr %start.name.a, ptr @.str.llvm.for.start)
  %end.name.a = call ptr @csec_string_concat(ptr @.str.llvm.for.percent, ptr %iterator)
  %end.name.b = call ptr @csec_string_concat(ptr %end.name.a, ptr @.str.llvm.for.end)
  %start.expr = add i32 %arrow, 1
  %start.code = call ptr @generateLLVMExpressionI32(ptr %arg.tokens, i32 %start.expr, i32 %range, ptr %start.name.b)
  %end.expr = add i32 %range, 1
  %end.code = call ptr @generateLLVMExpressionI32(ptr %arg.tokens, i32 %end.expr, i32 %close, ptr %end.name.b)
  %body.start = add i32 %body.open, 1
  %body = call ptr @generateLLVMFlatBodyI32(ptr %arg.tokens, i32 %body.start, i32 %body.close)
  %op.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %range)
  %inclusive.to = call i1 @strEq(ptr %op.text, ptr @.str.llvm.for.to)
  %inclusive.dots = call i1 @strEq(ptr %op.text, ptr @.str.llvm.for.dots)
  %inclusive = or i1 %inclusive.to, %inclusive.dots
  br i1 %inclusive, label %sle, label %slt
sle:
  br label %emit
slt:
  br label %emit
emit:
  %comparison = phi ptr [ @.str.llvm.for.sle, %sle ], [ @.str.llvm.for.slt, %slt ]
  %a1 = call ptr @csec_string_concat(ptr @.str.llvm.for.alloca.a, ptr %iterator)
  %a2 = call ptr @csec_string_concat(ptr %a1, ptr @.str.llvm.for.alloca.b)
  %a3 = call ptr @csec_string_concat(ptr %a2, ptr %start.code)
  %a4 = call ptr @csec_string_concat(ptr %a3, ptr @.str.llvm.for.store.a)
  %a5 = call ptr @csec_string_concat(ptr %a4, ptr %iterator)
  %a6 = call ptr @csec_string_concat(ptr %a5, ptr @.str.llvm.for.store.b)
  %a7 = call ptr @csec_string_concat(ptr %a6, ptr %start.name.b)
  %a8 = call ptr @csec_string_concat(ptr %a7, ptr @.str.llvm.for.cond.label)
  %a9 = call ptr @csec_string_concat(ptr %a8, ptr %seed)
  %a10 = call ptr @csec_string_concat(ptr %a9, ptr @.str.llvm.for.colon)
  %a11 = call ptr @csec_string_concat(ptr %a10, ptr @.str.llvm.for.value.a)
  %a12 = call ptr @csec_string_concat(ptr %a11, ptr %iterator)
  %a13 = call ptr @csec_string_concat(ptr %a12, ptr @.str.llvm.for.value.b)
  %a14 = call ptr @csec_string_concat(ptr %a13, ptr %iterator)
  %a15 = call ptr @csec_string_concat(ptr %a14, ptr %end.code)
  %a16 = call ptr @csec_string_concat(ptr %a15, ptr @.str.llvm.for.compare.a)
  %a17 = call ptr @csec_string_concat(ptr %a16, ptr %seed)
  %a18 = call ptr @csec_string_concat(ptr %a17, ptr %comparison)
  %a19 = call ptr @csec_string_concat(ptr %a18, ptr @.str.llvm.for.compare.b)
  %a20 = call ptr @csec_string_concat(ptr %a19, ptr %iterator)
  %a21 = call ptr @csec_string_concat(ptr %a20, ptr @.str.llvm.for.compare.c)
  %a22 = call ptr @csec_string_concat(ptr %a21, ptr %iterator)
  %a23 = call ptr @csec_string_concat(ptr %a22, ptr @.str.llvm.for.branch.a)
  %a24 = call ptr @csec_string_concat(ptr %a23, ptr %seed)
  %a25 = call ptr @csec_string_concat(ptr %a24, ptr @.str.llvm.for.branch.b)
  %a26 = call ptr @csec_string_concat(ptr %a25, ptr %seed)
  %a27 = call ptr @csec_string_concat(ptr %a26, ptr @.str.llvm.for.branch.c)
  %a28 = call ptr @csec_string_concat(ptr %a27, ptr %seed)
  %a29 = call ptr @csec_string_concat(ptr %a28, ptr @.str.llvm.for.body.label)
  %a30 = call ptr @csec_string_concat(ptr %a29, ptr %seed)
  %a31 = call ptr @csec_string_concat(ptr %a30, ptr @.str.llvm.for.colon)
  %a32 = call ptr @csec_string_concat(ptr %a31, ptr %body)
  %a33 = call ptr @csec_string_concat(ptr %a32, ptr @.str.llvm.for.step.a)
  %a34 = call ptr @csec_string_concat(ptr %a33, ptr %iterator)
  %a35 = call ptr @csec_string_concat(ptr %a34, ptr @.str.llvm.for.step.b)
  %a36 = call ptr @csec_string_concat(ptr %a35, ptr %seed)
  %a37 = call ptr @csec_string_concat(ptr %a36, ptr @.str.llvm.for.step.c)
  %a38 = call ptr @csec_string_concat(ptr %a37, ptr %iterator)
  %a39 = call ptr @csec_string_concat(ptr %a38, ptr @.str.llvm.for.step.d)
  %a40 = call ptr @csec_string_concat(ptr %a39, ptr %seed)
  %a41 = call ptr @csec_string_concat(ptr %a40, ptr @.str.llvm.for.step.e)
  %a42 = call ptr @csec_string_concat(ptr %a41, ptr %iterator)
  %a43 = call ptr @csec_string_concat(ptr %a42, ptr @.str.llvm.for.step.f)
  %a44 = call ptr @csec_string_concat(ptr %a43, ptr %seed)
  %a45 = call ptr @csec_string_concat(ptr %a44, ptr @.str.llvm.for.step.g)
  %a46 = call ptr @csec_string_concat(ptr %a45, ptr %iterator)
  %a47 = call ptr @csec_string_concat(ptr %a46, ptr @.str.llvm.for.cond.branch)
  %a48 = call ptr @csec_string_concat(ptr %a47, ptr %seed)
  %a49 = call ptr @csec_string_concat(ptr %a48, ptr @.str.llvm.for.nl)
  %a50 = call ptr @csec_string_concat(ptr %a49, ptr @.str.llvm.for.end.label)
  %a51 = call ptr @csec_string_concat(ptr %a50, ptr %seed)
  %result = call ptr @csec_string_concat(ptr %a51, ptr @.str.llvm.for.colon)
  ret ptr %result
}

)";
    output += llvmStringGlobal(".str.llvm.for.bad", "  ; malformed for\n");
    output += llvmStringGlobal(".str.llvm.for.brace.open", "{"); output += llvmStringGlobal(".str.llvm.for.brace.close", "}");
    output += llvmStringGlobal(".str.llvm.for.arrow", "<-"); output += llvmStringGlobal(".str.llvm.for.to", "to"); output += llvmStringGlobal(".str.llvm.for.dots", "..");
    output += llvmStringGlobal(".str.llvm.for.percent", "%"); output += llvmStringGlobal(".str.llvm.for.start", ".start"); output += llvmStringGlobal(".str.llvm.for.end", ".end");
    output += llvmStringGlobal(".str.llvm.for.slt", "slt"); output += llvmStringGlobal(".str.llvm.for.sle", "sle");
    output += llvmStringGlobal(".str.llvm.for.alloca.a", "  %"); output += llvmStringGlobal(".str.llvm.for.alloca.b", " = alloca i32\n");
    output += llvmStringGlobal(".str.llvm.for.store.a", "  store i32 %"); output += llvmStringGlobal(".str.llvm.for.store.b", ", ptr %");
    output += llvmStringGlobal(".str.llvm.for.cond.label", "  br label %for.cond."); output += llvmStringGlobal(".str.llvm.for.colon", ":\n");
    output += llvmStringGlobal(".str.llvm.for.value.a", "  %"); output += llvmStringGlobal(".str.llvm.for.value.b", ".val = load i32, ptr %");
    output += llvmStringGlobal(".str.llvm.for.compare.a", "  %forcond."); output += llvmStringGlobal(".str.llvm.for.compare.b", " = icmp "); output += llvmStringGlobal(".str.llvm.for.compare.c", " i32 %");
    output += llvmStringGlobal(".str.llvm.for.branch.a", ".val, %"); output += llvmStringGlobal(".str.llvm.for.branch.b", ".end\n  br i1 %forcond."); output += llvmStringGlobal(".str.llvm.for.branch.c", ", label %for.body.");
    output += llvmStringGlobal(".str.llvm.for.body.label", "for.body."); output += llvmStringGlobal(".str.llvm.for.end.label", "for.end.");
    output += llvmStringGlobal(".str.llvm.for.step.a", "  %"); output += llvmStringGlobal(".str.llvm.for.step.b", ".step."); output += llvmStringGlobal(".str.llvm.for.step.c", " = load i32, ptr %"); output += llvmStringGlobal(".str.llvm.for.step.d", "\n  %"); output += llvmStringGlobal(".str.llvm.for.step.e", ".next."); output += llvmStringGlobal(".str.llvm.for.step.f", " = add i32 %"); output += llvmStringGlobal(".str.llvm.for.step.g", ".step.");
    output += llvmStringGlobal(".str.llvm.for.cond.branch", ", 1\n  store i32 %"); output += llvmStringGlobal(".str.llvm.for.nl", ".next.");
    return output;
}

std::string llvmControlFlowDefinition(const char* name) {
    if (std::strcmp(name, "generateLLVMIfI32") == 0) return llvmGenerateLLVMIfI32Definition();
    if (std::strcmp(name, "generateLLVMWhileI32") == 0) return llvmGenerateLLVMWhileI32Definition();
    return llvmGenerateLLVMForI32Definition();
}

std::string llvmGenerateConditionI1Definition() {
    std::string output = R"(define ptr @generateLLVMConditionI1(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName) {
entry:
  %end = call i32 @trimExpressionEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd)
  %operator.kind = call i8 @kindOperator()
  %open.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %arg.start, i8 %operator.kind, ptr @.str.condition.open)
  %open = icmp ne i32 %open.raw, 0
  br i1 %open, label %paren.close, label %not.check
paren.close:
  %close = call i32 @findClosingToken(ptr %arg.tokens, i32 %arg.start, i32 %end, ptr @.str.condition.open, ptr @.str.condition.close)
  %last = sub i32 %end, 1
  %wrapped = icmp eq i32 %close, %last
  br i1 %wrapped, label %paren.return, label %not.check
paren.return:
  %inner.start = add i32 %arg.start, 1
  %inner = call ptr @generateLLVMConditionI1(ptr %arg.tokens, i32 %inner.start, i32 %last, ptr %arg.resultName)
  ret ptr %inner
not.check:
  %not.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %arg.start, i8 %operator.kind, ptr @.str.condition.not)
  %not = icmp ne i32 %not.raw, 0
  br i1 %not, label %not.return, label %comparison.find
not.return:
  %not.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.condition.not.name)
  %not.start = add i32 %arg.start, 1
  %not.code = call ptr @generateLLVMConditionI1(ptr %arg.tokens, i32 %not.start, i32 %end, ptr %not.name)
  %n1 = call ptr @csec_string_concat(ptr %not.code, ptr @.str.condition.prefix)
  %n2 = call ptr @csec_string_concat(ptr %n1, ptr %arg.resultName)
  %n3 = call ptr @csec_string_concat(ptr %n2, ptr @.str.condition.xor)
  %not.result = call ptr @csec_string_concat(ptr %n3, ptr %not.name)
  ret ptr %not.result
comparison.find:
  %op = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %end, i32 4)
  %has.op = icmp sgt i32 %op, %arg.start
  br i1 %has.op, label %comparison.return, label %bool.check
comparison.return:
  %op.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %op)
  %mnemonic = call ptr @irOperatorName(ptr %op.text)
  %mnemonic.length.i64 = call i64 @csec_string_length(ptr %mnemonic)
  %mnemonic.length = trunc i64 %mnemonic.length.i64 to i32
  %predicate.length = sub i32 %mnemonic.length, 5
  %predicate = call ptr @csec_string_substring(ptr %mnemonic, i32 5, i32 %predicate.length)
  %left.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.condition.left)
  %left = call ptr @generateLLVMExpressionI32(ptr %arg.tokens, i32 %arg.start, i32 %op, ptr %left.name)
  %right.start = add i32 %op, 1
  %right.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.condition.right)
  %right = call ptr @generateLLVMExpressionI32(ptr %arg.tokens, i32 %right.start, i32 %end, ptr %right.name)
  %c1 = call ptr @csec_string_concat(ptr %left, ptr %right)
  %c2 = call ptr @csec_string_concat(ptr %c1, ptr @.str.condition.prefix)
  %c3 = call ptr @csec_string_concat(ptr %c2, ptr %arg.resultName)
  %c4 = call ptr @csec_string_concat(ptr %c3, ptr @.str.condition.icmp)
  %c5 = call ptr @csec_string_concat(ptr %c4, ptr %predicate)
  %c6 = call ptr @csec_string_concat(ptr %c5, ptr @.str.condition.i32)
  %c7 = call ptr @csec_string_concat(ptr %c6, ptr %left.name)
  %c8 = call ptr @csec_string_concat(ptr %c7, ptr @.str.condition.comma)
  %comparison.result = call ptr @csec_string_concat(ptr %c8, ptr %right.name)
  ret ptr %comparison.result
bool.check:
  %kind = call i8 @tokenKindAt(ptr %arg.tokens, i32 %arg.start)
  %bool.kind = call i8 @kindBool()
  %is.bool = icmp eq i8 %kind, %bool.kind
  %single.end = add i32 %arg.start, 1
  %single = icmp eq i32 %end, %single.end
  %bool = and i1 %is.bool, %single
  br i1 %bool, label %bool.return, label %identifier.check
bool.return:
  %bool.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %is.true = call i1 @strEq(ptr %bool.text, ptr @.str.condition.true)
  br i1 %is.true, label %true.return, label %false.return
true.return:
  %t1 = call ptr @csec_string_concat(ptr @.str.condition.prefix, ptr %arg.resultName)
  %true.result = call ptr @csec_string_concat(ptr %t1, ptr @.str.condition.true.code)
  ret ptr %true.result
false.return:
  %f1 = call ptr @csec_string_concat(ptr @.str.condition.prefix, ptr %arg.resultName)
  %false.result = call ptr @csec_string_concat(ptr %f1, ptr @.str.condition.false.code)
  ret ptr %false.result
identifier.check:
  %identifier.kind = call i8 @kindIdentifier()
  %is.identifier = icmp eq i8 %kind, %identifier.kind
  br i1 %is.identifier, label %identifier.next, label %fallback
identifier.next:
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  br i1 %single, label %identifier.return, label %call.check
identifier.return:
  %storage = call ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %i1 = call ptr @csec_string_concat(ptr @.str.condition.prefix, ptr %arg.resultName)
  %i2 = call ptr @csec_string_concat(ptr %i1, ptr @.str.condition.load)
  %identifier.result = call ptr @csec_string_concat(ptr %i2, ptr %storage)
  ret ptr %identifier.result
call.check:
  %open.index = add i32 %arg.start, 1
  %before.end = icmp slt i32 %open.index, %end
  br i1 %before.end, label %call.open.check, label %fallback
call.open.check:
  %call.open.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %open.index, i8 %operator.kind, ptr @.str.condition.open)
  %call.open = icmp ne i32 %call.open.raw, 0
  br i1 %call.open, label %call.close.check, label %fallback
call.close.check:
  %call.close = call i32 @findClosingToken(ptr %arg.tokens, i32 %open.index, i32 %end, ptr @.str.condition.open, ptr @.str.condition.close)
  %call.last = sub i32 %end, 1
  %is.call = icmp eq i32 %call.close, %call.last
  br i1 %is.call, label %call.return, label %fallback
call.return:
  %args.start = add i32 %arg.start, 2
  %loads = call ptr @generateLLVMCallArgumentLoadsI32(ptr %arg.tokens, i32 %args.start, i32 %call.last, ptr %arg.resultName)
  %arguments = call ptr @generateLLVMCallArgumentListI32(ptr %arg.tokens, i32 %args.start, i32 %call.last, ptr %arg.resultName)
  %callee = call ptr @llvmRuntimeCallName(ptr %name)
  %r1 = call ptr @csec_string_concat(ptr %loads, ptr @.str.condition.prefix)
  %r2 = call ptr @csec_string_concat(ptr %r1, ptr %arg.resultName)
  %r3 = call ptr @csec_string_concat(ptr %r2, ptr @.str.condition.call)
  %r4 = call ptr @csec_string_concat(ptr %r3, ptr %callee)
  %r5 = call ptr @csec_string_concat(ptr %r4, ptr @.str.condition.open)
  %r6 = call ptr @csec_string_concat(ptr %r5, ptr %arguments)
  %call.result = call ptr @csec_string_concat(ptr %r6, ptr @.str.condition.close.nl)
  ret ptr %call.result
fallback:
  %x1 = call ptr @csec_string_concat(ptr @.str.condition.prefix, ptr %arg.resultName)
  %fallback.result = call ptr @csec_string_concat(ptr %x1, ptr @.str.condition.fallback)
  ret ptr %fallback.result
}

)";
    output += llvmStringGlobal(".str.condition.open", "(");
    output += llvmStringGlobal(".str.condition.close", ")");
    output += llvmStringGlobal(".str.condition.not", "!");
    output += llvmStringGlobal(".str.condition.not.name", ".not");
    output += llvmStringGlobal(".str.condition.prefix", "  ");
    output += llvmStringGlobal(".str.condition.xor", " = xor i1 ");
    output += llvmStringGlobal(".str.condition.left", ".left.i32");
    output += llvmStringGlobal(".str.condition.right", ".right.i32");
    output += llvmStringGlobal(".str.condition.icmp", " = icmp ");
    output += llvmStringGlobal(".str.condition.i32", " i32 ");
    output += llvmStringGlobal(".str.condition.comma", ", ");
    output += llvmStringGlobal(".str.condition.true", "true");
    output += llvmStringGlobal(".str.condition.true.code", " = icmp eq i1 true, true\n");
    output += llvmStringGlobal(".str.condition.false.code", " = icmp eq i1 false, true\n");
    output += llvmStringGlobal(".str.condition.load", " = load i1, ptr %");
    output += llvmStringGlobal(".str.condition.call", " = call i1 @");
    output += llvmStringGlobal(".str.condition.close.nl", ")\n");
    output += llvmStringGlobal(".str.condition.fallback", " = icmp eq i32 0, 0\n");
    return output;
}

std::string llvmGenerateExpressionI1Definition() {
    std::string output = R"(define ptr @generateLLVMExpressionI1(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd, ptr %arg.resultName) {
entry:
  %end = call i32 @trimExpressionEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd)
  %empty = icmp sle i32 %end, %arg.start
  br i1 %empty, label %false.return, label %paren.check
false.return:
  %f1 = call ptr @csec_string_concat(ptr @.str.expr.i1.prefix, ptr %arg.resultName)
  %false.result = call ptr @csec_string_concat(ptr %f1, ptr @.str.expr.i1.false)
  ret ptr %false.result
paren.check:
  %operator.kind = call i8 @kindOperator()
  %open.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %arg.start, i8 %operator.kind, ptr @.str.expr.i1.open)
  %open = icmp ne i32 %open.raw, 0
  br i1 %open, label %paren.close, label %not.check
paren.close:
  %close = call i32 @findClosingToken(ptr %arg.tokens, i32 %arg.start, i32 %end, ptr @.str.expr.i1.open, ptr @.str.expr.i1.close)
  %last = sub i32 %end, 1
  %wrapped = icmp eq i32 %close, %last
  br i1 %wrapped, label %paren.return, label %not.check
paren.return:
  %inner.start = add i32 %arg.start, 1
  %inner = call ptr @generateLLVMExpressionI1(ptr %arg.tokens, i32 %inner.start, i32 %last, ptr %arg.resultName)
  ret ptr %inner
not.check:
  %not.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %arg.start, i8 %operator.kind, ptr @.str.expr.i1.not)
  %not = icmp ne i32 %not.raw, 0
  br i1 %not, label %not.return, label %bool.check
not.return:
  %not.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.i1.not.name)
  %not.start = add i32 %arg.start, 1
  %not.code = call ptr @generateLLVMExpressionI1(ptr %arg.tokens, i32 %not.start, i32 %end, ptr %not.name)
  %n1 = call ptr @csec_string_concat(ptr %not.code, ptr @.str.expr.i1.prefix)
  %n2 = call ptr @csec_string_concat(ptr %n1, ptr %arg.resultName)
  %n3 = call ptr @csec_string_concat(ptr %n2, ptr @.str.expr.i1.xor)
  %n4 = call ptr @csec_string_concat(ptr %n3, ptr %not.name)
  %not.result = call ptr @csec_string_concat(ptr %n4, ptr @.str.expr.i1.not.suffix)
  ret ptr %not.result
bool.check:
  %kind = call i8 @tokenKindAt(ptr %arg.tokens, i32 %arg.start)
  %bool.kind = call i8 @kindBool()
  %is.bool = icmp eq i8 %kind, %bool.kind
  %single.end = add i32 %arg.start, 1
  %single = icmp eq i32 %end, %single.end
  %bool = and i1 %is.bool, %single
  br i1 %bool, label %bool.return, label %identifier.check
bool.return:
  %bool.text = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %is.true = call i1 @strEq(ptr %bool.text, ptr @.str.expr.i1.true)
  br i1 %is.true, label %true.return, label %false.value.return
true.return:
  %t1 = call ptr @csec_string_concat(ptr @.str.expr.i1.prefix, ptr %arg.resultName)
  %true.result = call ptr @csec_string_concat(ptr %t1, ptr @.str.expr.i1.true.code)
  ret ptr %true.result
false.value.return:
  %v1 = call ptr @csec_string_concat(ptr @.str.expr.i1.prefix, ptr %arg.resultName)
  %value.false.result = call ptr @csec_string_concat(ptr %v1, ptr @.str.expr.i1.false)
  ret ptr %value.false.result
identifier.check:
  %identifier.kind = call i8 @kindIdentifier()
  %is.identifier = icmp eq i8 %kind, %identifier.kind
  %identifier = and i1 %is.identifier, %single
  br i1 %identifier, label %identifier.return, label %or.find
identifier.return:
  %name = call ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.start)
  %storage = call ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %arg.start, ptr %name)
  %i1 = call ptr @csec_string_concat(ptr @.str.expr.i1.prefix, ptr %arg.resultName)
  %i2 = call ptr @csec_string_concat(ptr %i1, ptr @.str.expr.i1.load)
  %identifier.result = call ptr @csec_string_concat(ptr %i2, ptr %storage)
  ret ptr %identifier.result
or.find:
  %or.op = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %end, i32 2)
  %has.or = icmp sgt i32 %or.op, %arg.start
  br i1 %has.or, label %or.return, label %and.find
or.return:
  %or.left.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.i1.left)
  %or.left = call ptr @generateLLVMExpressionI1(ptr %arg.tokens, i32 %arg.start, i32 %or.op, ptr %or.left.name)
  %or.right.start = add i32 %or.op, 1
  %or.right.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.i1.right)
  %or.right = call ptr @generateLLVMExpressionI1(ptr %arg.tokens, i32 %or.right.start, i32 %end, ptr %or.right.name)
  %o1 = call ptr @csec_string_concat(ptr %or.left, ptr %or.right)
  %o2 = call ptr @csec_string_concat(ptr %o1, ptr @.str.expr.i1.prefix)
  %o3 = call ptr @csec_string_concat(ptr %o2, ptr %arg.resultName)
  %o4 = call ptr @csec_string_concat(ptr %o3, ptr @.str.expr.i1.or)
  %o5 = call ptr @csec_string_concat(ptr %o4, ptr %or.left.name)
  %o6 = call ptr @csec_string_concat(ptr %o5, ptr @.str.expr.i1.comma)
  %or.result = call ptr @csec_string_concat(ptr %o6, ptr %or.right.name)
  ret ptr %or.result
and.find:
  %and.op = call i32 @findTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %end, i32 3)
  %has.and = icmp sgt i32 %and.op, %arg.start
  br i1 %has.and, label %and.return, label %condition.return
and.return:
  %and.left.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.i1.left)
  %and.left = call ptr @generateLLVMExpressionI1(ptr %arg.tokens, i32 %arg.start, i32 %and.op, ptr %and.left.name)
  %and.right.start = add i32 %and.op, 1
  %and.right.name = call ptr @csec_string_concat(ptr %arg.resultName, ptr @.str.expr.i1.right)
  %and.right = call ptr @generateLLVMExpressionI1(ptr %arg.tokens, i32 %and.right.start, i32 %end, ptr %and.right.name)
  %a1 = call ptr @csec_string_concat(ptr %and.left, ptr %and.right)
  %a2 = call ptr @csec_string_concat(ptr %a1, ptr @.str.expr.i1.prefix)
  %a3 = call ptr @csec_string_concat(ptr %a2, ptr %arg.resultName)
  %a4 = call ptr @csec_string_concat(ptr %a3, ptr @.str.expr.i1.and)
  %a5 = call ptr @csec_string_concat(ptr %a4, ptr %and.left.name)
  %a6 = call ptr @csec_string_concat(ptr %a5, ptr @.str.expr.i1.comma)
  %and.result = call ptr @csec_string_concat(ptr %a6, ptr %and.right.name)
  ret ptr %and.result
condition.return:
  %condition = call ptr @generateLLVMConditionI1(ptr %arg.tokens, i32 %arg.start, i32 %end, ptr %arg.resultName)
  ret ptr %condition
}

)";
    output += llvmStringGlobal(".str.expr.i1.prefix", "  ");
    output += llvmStringGlobal(".str.expr.i1.false", " = icmp eq i1 false, true\n");
    output += llvmStringGlobal(".str.expr.i1.true", "true");
    output += llvmStringGlobal(".str.expr.i1.true.code", " = icmp eq i1 true, true\n");
    output += llvmStringGlobal(".str.expr.i1.open", "(");
    output += llvmStringGlobal(".str.expr.i1.close", ")");
    output += llvmStringGlobal(".str.expr.i1.not", "!");
    output += llvmStringGlobal(".str.expr.i1.not.name", ".not");
    output += llvmStringGlobal(".str.expr.i1.xor", " = xor i1 ");
    output += llvmStringGlobal(".str.expr.i1.not.suffix", ", true\n");
    output += llvmStringGlobal(".str.expr.i1.load", " = load i1, ptr %");
    output += llvmStringGlobal(".str.expr.i1.left", ".left");
    output += llvmStringGlobal(".str.expr.i1.right", ".right");
    output += llvmStringGlobal(".str.expr.i1.or", " = or i1 ");
    output += llvmStringGlobal(".str.expr.i1.and", " = and i1 ");
    output += llvmStringGlobal(".str.expr.i1.comma", ", ");
    return output;
}

char* csec_llvm_lexer_helper_definition(const char* name) {
    if (name) {
        if (FILE* trace = std::fopen("selfhost\\last_llvm_helper.txt", "w")) {
            std::fputs(name, trace);
            std::fclose(trace);
        }
    }
    const char* definition = "";
    char tokenKind = '\0';
    if (name && std::strcmp(name, "kindIdentifier") == 0) tokenKind = 'I';
    else if (name && std::strcmp(name, "kindKeyword") == 0) tokenKind = 'K';
    else if (name && std::strcmp(name, "kindInteger") == 0) tokenKind = 'N';
    else if (name && std::strcmp(name, "kindFloat") == 0) tokenKind = 'F';
    else if (name && std::strcmp(name, "kindString") == 0) tokenKind = 'S';
    else if (name && std::strcmp(name, "kindRegex") == 0) tokenKind = 'R';
    else if (name && std::strcmp(name, "kindChar") == 0) tokenKind = 'C';
    else if (name && std::strcmp(name, "kindBool") == 0) tokenKind = 'B';
    else if (name && std::strcmp(name, "kindOperator") == 0) tokenKind = 'O';
    else if (name && std::strcmp(name, "kindComment") == 0) tokenKind = 'M';
    else if (name && std::strcmp(name, "kindEof") == 0) tokenKind = 'E';
    if (tokenKind != '\0') {
        std::string generated = "define i8 @" + std::string(name) + "() {\nentry:\n  ret i8 " + std::to_string(static_cast<unsigned char>(tokenKind)) + "\n}\n\n";
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    }
    if (name && std::strcmp(name, "tokenIs") == 0) {
        definition = "define i1 @tokenIs(ptr %arg.tokens, i32 %arg.ordinal, i8 %arg.kind, ptr %arg.text) {\nentry:\n  %token.is = call i32 @csec_token_is(ptr %arg.tokens, i32 %arg.ordinal, i8 %arg.kind, ptr %arg.text)\n  %token.is.bool = icmp ne i32 %token.is, 0\n  ret i1 %token.is.bool\n}\n\n";
    } else if (name && std::strcmp(name, "repairLeadingRTokenText") == 0) {
        definition = "@.str.repair.r.eturn = private unnamed_addr constant [6 x i8] c\"eturn\\00\"\n@.str.repair.r.return = private unnamed_addr constant [7 x i8] c\"return\\00\"\n@.str.repair.r.atio = private unnamed_addr constant [5 x i8] c\"atio\\00\"\n@.str.repair.r.ratio = private unnamed_addr constant [6 x i8] c\"ratio\\00\"\n@.str.repair.r.educe = private unnamed_addr constant [6 x i8] c\"educe\\00\"\n@.str.repair.r.reduce = private unnamed_addr constant [7 x i8] c\"reduce\\00\"\n@.str.repair.r.ange = private unnamed_addr constant [5 x i8] c\"ange\\00\"\n@.str.repair.r.range = private unnamed_addr constant [6 x i8] c\"range\\00\"\n@.str.repair.r.egex = private unnamed_addr constant [5 x i8] c\"egex\\00\"\n@.str.repair.r.regex = private unnamed_addr constant [6 x i8] c\"regex\\00\"\n@.str.repair.r.Regex = private unnamed_addr constant [6 x i8] c\"Regex\\00\"\n\ndefine ptr @repairLeadingRTokenText(ptr %arg.text) {\nentry:\n  %case0 = call i32 @csec_string_equals(ptr %arg.text, ptr @.str.repair.r.eturn)\n  %is0 = icmp ne i32 %case0, 0\n  br i1 %is0, label %return0, label %check1\nreturn0:\n  ret ptr @.str.repair.r.return\ncheck1:\n  %case1 = call i32 @csec_string_equals(ptr %arg.text, ptr @.str.repair.r.atio)\n  %is1 = icmp ne i32 %case1, 0\n  br i1 %is1, label %return1, label %check2\nreturn1:\n  ret ptr @.str.repair.r.ratio\ncheck2:\n  %case2 = call i32 @csec_string_equals(ptr %arg.text, ptr @.str.repair.r.educe)\n  %is2 = icmp ne i32 %case2, 0\n  br i1 %is2, label %return2, label %check3\nreturn2:\n  ret ptr @.str.repair.r.reduce\ncheck3:\n  %case3 = call i32 @csec_string_equals(ptr %arg.text, ptr @.str.repair.r.ange)\n  %is3 = icmp ne i32 %case3, 0\n  br i1 %is3, label %return3, label %check4\nreturn3:\n  ret ptr @.str.repair.r.range\ncheck4:\n  %case4 = call i32 @csec_string_equals(ptr %arg.text, ptr @.str.repair.r.egex)\n  %is4 = icmp ne i32 %case4, 0\n  br i1 %is4, label %return4, label %check5\nreturn4:\n  ret ptr @.str.repair.r.regex\ncheck5:\n  %case5 = call i32 @csec_string_equals(ptr %arg.text, ptr @.str.repair.r.Regex)\n  %is5 = icmp ne i32 %case5, 0\n  br i1 %is5, label %return5, label %fallback\nreturn5:\n  ret ptr @.str.repair.r.Regex\nfallback:\n  ret ptr %arg.text\n}\n\n";
    } else if (name && std::strcmp(name, "isWhitespace") == 0) {
        definition = "define i1 @isWhitespace(i8 %arg.ch) {\nentry:\n  %space = icmp eq i8 %arg.ch, 32\n  %newline = icmp eq i8 %arg.ch, 10\n  %carriage = icmp eq i8 %arg.ch, 13\n  %tab = icmp eq i8 %arg.ch, 9\n  %space.or.newline = or i1 %space, %newline\n  %carriage.or.tab = or i1 %carriage, %tab\n  %ret = or i1 %space.or.newline, %carriage.or.tab\n  ret i1 %ret\n}\n\n";
    } else if (name && std::strcmp(name, "isDigit") == 0) {
        definition = "define i1 @isDigit(i8 %arg.ch) {\nentry:\n  %lower = icmp sge i8 %arg.ch, 48\n  %upper = icmp sle i8 %arg.ch, 57\n  %ret = and i1 %lower, %upper\n  ret i1 %ret\n}\n\n";
    } else if (name && std::strcmp(name, "strEq") == 0) {
        definition = "define i1 @strEq(ptr %arg.left, ptr %arg.right) {\nentry:\n  %left.length = call i64 @csec_string_length(ptr %arg.left)\n  %right.length = call i64 @csec_string_length(ptr %arg.right)\n  %same.length = icmp eq i64 %left.length, %right.length\n  %prefix = call i32 @csec_string_starts_with(ptr %arg.left, ptr %arg.right)\n  %same.text = icmp ne i32 %prefix, 0\n  %ret = and i1 %same.length, %same.text\n  ret i1 %ret\n}\n\n";
    } else if (name && std::strcmp(name, "isKeyword") == 0) {
        definition = "define i1 @isKeyword(ptr %arg.text) {\nentry:\n  %keyword = call i32 @csec_is_keyword(ptr %arg.text)\n  %ret = icmp ne i32 %keyword, 0\n  ret i1 %ret\n}\n\n";
    } else if (name && std::strcmp(name, "appendToken") == 0) {
        definition = "define ptr @appendToken(ptr %arg.tokens, i8 %arg.kind, ptr %arg.text) {\nentry:\n  %ret = call ptr @csec_token_append_owned(ptr %arg.tokens, i8 %arg.kind, ptr %arg.text)\n  ret ptr %ret\n}\n\n";
    } else if (name && std::strcmp(name, "appendTokenTo") == 0) {
        definition = "define i32 @appendTokenTo(i64 %arg.builder, i8 %arg.kind, ptr %arg.text) {\nentry:\n  %ret = call i32 @csec_token_builder_append(i64 %arg.builder, i8 %arg.kind, ptr %arg.text)\n  ret i32 %ret\n}\n\n";
    } else if (name && std::strcmp(name, "twoChars") == 0) {
        definition = "define i1 @twoChars(ptr %arg.source, i32 %arg.index, ptr %arg.text) {\nentry:\n  %length = call i64 @csec_string_length(ptr %arg.source)\n  %last = add i32 %arg.index, 1\n  %last64 = sext i32 %last to i64\n  %in.range = icmp slt i64 %last64, %length\n  br i1 %in.range, label %compare, label %false\ncompare:\n  %source0 = call i8 @csec_string_char_at(ptr %arg.source, i32 %arg.index)\n  %text0 = call i8 @csec_string_char_at(ptr %arg.text, i32 0)\n  %first = icmp eq i8 %source0, %text0\n  %source1 = call i8 @csec_string_char_at(ptr %arg.source, i32 %last)\n  %text1 = call i8 @csec_string_char_at(ptr %arg.text, i32 1)\n  %second = icmp eq i8 %source1, %text1\n  %ret = and i1 %first, %second\n  ret i1 %ret\nfalse:\n  ret i1 false\n}\n\n";
    } else if (name && std::strcmp(name, "threeChars") == 0) {
        definition = "define i1 @threeChars(ptr %arg.source, i32 %arg.index, ptr %arg.text) {\nentry:\n  %length = call i64 @csec_string_length(ptr %arg.source)\n  %last = add i32 %arg.index, 2\n  %last64 = sext i32 %last to i64\n  %in.range = icmp slt i64 %last64, %length\n  br i1 %in.range, label %compare, label %false\ncompare:\n  %source0 = call i8 @csec_string_char_at(ptr %arg.source, i32 %arg.index)\n  %text0 = call i8 @csec_string_char_at(ptr %arg.text, i32 0)\n  %first = icmp eq i8 %source0, %text0\n  %index1 = add i32 %arg.index, 1\n  %source1 = call i8 @csec_string_char_at(ptr %arg.source, i32 %index1)\n  %text1 = call i8 @csec_string_char_at(ptr %arg.text, i32 1)\n  %second = icmp eq i8 %source1, %text1\n  %source2 = call i8 @csec_string_char_at(ptr %arg.source, i32 %last)\n  %text2 = call i8 @csec_string_char_at(ptr %arg.text, i32 2)\n  %third = icmp eq i8 %source2, %text2\n  %first.two = and i1 %first, %second\n  %ret = and i1 %first.two, %third\n  ret i1 %ret\nfalse:\n  ret i1 false\n}\n\n";
    } else if (name && (std::strcmp(name, "operatorLength") == 0 || std::strcmp(name, "lexIdentifier") == 0 || std::strcmp(name, "classMemberKind") == 0 || std::strcmp(name, "classMemberName") == 0 || std::strcmp(name, "parseReturnIntegerInRange") == 0 || std::strcmp(name, "cTypeName") == 0 || std::strcmp(name, "llvmStringLiteralByteLength") == 0 || std::strcmp(name, "generateLLVMStringLiteralGlobals") == 0 || std::strcmp(name, "generateLLVMFunctionDefinition") == 0 || std::strcmp(name, "generateLLVMFlatBodyI32") == 0 || std::strcmp(name, "generateLLVMMainBodyFromRange") == 0 || std::strcmp(name, "generateLLVMBooleanBodyFromRange") == 0 || std::strcmp(name, "generateLLVMCharBodyFromRange") == 0 || std::strcmp(name, "generateLLVMDoubleBodyFromRange") == 0 || std::strcmp(name, "generateLLVMLongBodyFromRange") == 0 || std::strcmp(name, "generateLLVMPointerBodyFromRange") == 0)) {
        definition = std::strcmp(name, "generateLLVMBooleanBodyFromRange") == 0 || std::strcmp(name, "generateLLVMCharBodyFromRange") == 0 || std::strcmp(name, "generateLLVMDoubleBodyFromRange") == 0 || std::strcmp(name, "generateLLVMLongBodyFromRange") == 0 || std::strcmp(name, "generateLLVMPointerBodyFromRange") == 0
            ? (std::strcmp(name, "generateLLVMBooleanBodyFromRange") == 0
                ? "declare ptr @csec_llvm_body_fallback(i32)\n\ndefine ptr @generateLLVMBooleanBodyFromRange(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {\nentry:\n  %ret = call ptr @csec_llvm_body_fallback(i32 1)\n  ret ptr %ret\n}\n\n"
                : std::strcmp(name, "generateLLVMCharBodyFromRange") == 0
                ? "define ptr @generateLLVMCharBodyFromRange(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {\nentry:\n  %ret = call ptr @csec_llvm_body_fallback(i32 2)\n  ret ptr %ret\n}\n\n"
                : std::strcmp(name, "generateLLVMDoubleBodyFromRange") == 0
                ? "define ptr @generateLLVMDoubleBodyFromRange(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {\nentry:\n  %ret = call ptr @csec_llvm_body_fallback(i32 3)\n  ret ptr %ret\n}\n\n"
                : std::strcmp(name, "generateLLVMLongBodyFromRange") == 0
                ? "define ptr @generateLLVMLongBodyFromRange(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {\nentry:\n  %ret = call ptr @csec_llvm_body_fallback(i32 4)\n  ret ptr %ret\n}\n\n"
                : "define ptr @generateLLVMPointerBodyFromRange(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {\nentry:\n  %ret = call ptr @csec_llvm_body_fallback(i32 5)\n  ret ptr %ret\n}\n\n")
            : std::strcmp(name, "generateLLVMMainBodyFromRange") == 0
            ? "declare ptr @csec_llvm_main_body_fallback()\n\ndefine ptr @generateLLVMMainBodyFromRange(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {\nentry:\n  %ret = call ptr @csec_llvm_main_body_fallback()\n  ret ptr %ret\n}\n\n"
            : std::strcmp(name, "generateLLVMFlatBodyI32") == 0
            ? "declare ptr @csec_generate_llvm_flat_body_i32(ptr, i32, i32)\n\ndefine ptr @generateLLVMFlatBodyI32(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {\nentry:\n  %ret = call ptr @csec_generate_llvm_flat_body_i32(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd)\n  ret ptr %ret\n}\n\n"
            : std::strcmp(name, "generateLLVMStringLiteralGlobals") == 0
            ? "declare ptr @csec_generate_llvm_string_literal_globals(ptr)\n\ndefine ptr @generateLLVMStringLiteralGlobals(ptr %arg.tokens) {\nentry:\n  %ret = call ptr @csec_generate_llvm_string_literal_globals(ptr %arg.tokens)\n  ret ptr %ret\n}\n\n"
            : std::strcmp(name, "generateLLVMFunctionDefinition") == 0
            ? "declare ptr @csec_generate_llvm_function_definition(ptr, i32)\n\ndefine ptr @generateLLVMFunctionDefinition(ptr %arg.tokens, i32 %arg.declStart) {\nentry:\n  %ret = call ptr @csec_generate_llvm_function_definition(ptr %arg.tokens, i32 %arg.declStart)\n  ret ptr %ret\n}\n\n"
            : std::strcmp(name, "llvmStringLiteralByteLength") == 0
            ? "define i32 @llvmStringLiteralByteLength(ptr %arg.text) {\nentry:\n  %ret = call i32 @csec_llvm_string_literal_byte_length(ptr %arg.text)\n  ret i32 %ret\n}\n\n"
            : std::strcmp(name, "cTypeName") == 0
            ? "declare ptr @csec_c_type_name(ptr)\n\ndefine ptr @cTypeName(ptr %arg.typeName) {\nentry:\n  %ret = call ptr @csec_c_type_name(ptr %arg.typeName)\n  ret ptr %ret\n}\n\n"
            : std::strcmp(name, "parseReturnIntegerInRange") == 0
            ? "declare i32 @csec_parse_return_integer_in_range(ptr, i32, i32)\n\ndefine i32 @parseReturnIntegerInRange(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {\nentry:\n  %ret = call i32 @csec_parse_return_integer_in_range(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)\n  ret i32 %ret\n}\n\n"
            : std::strcmp(name, "classMemberKind") == 0
            ? "declare ptr @csec_class_member_kind(ptr, i32)\n\ndefine ptr @classMemberKind(ptr %arg.tokens, i32 %arg.ordinal) {\nentry:\n  %ret = call ptr @csec_class_member_kind(ptr %arg.tokens, i32 %arg.ordinal)\n  ret ptr %ret\n}\n\n"
            : std::strcmp(name, "classMemberName") == 0
            ? "declare ptr @csec_class_member_name(ptr, i32)\n\ndefine ptr @classMemberName(ptr %arg.tokens, i32 %arg.ordinal) {\nentry:\n  %ret = call ptr @csec_class_member_name(ptr %arg.tokens, i32 %arg.ordinal)\n  ret ptr %ret\n}\n\n"
            : std::strcmp(name, "operatorLength") == 0
            ? "declare i32 @csec_operator_length(ptr, i32)\n\ndefine i32 @operatorLength(ptr %arg.source, i32 %arg.index) {\nentry:\n  %ret = call i32 @csec_operator_length(ptr %arg.source, i32 %arg.index)\n  ret i32 %ret\n}\n\n"
            : "define i32 @lexIdentifier(ptr %arg.source, i32 %arg.index) {\nentry:\n  %ret = call i32 @csec_lex_identifier(ptr %arg.source, i32 %arg.index)\n  ret i32 %ret\n}\n\n";
    } else if (name && std::strcmp(name, "lexNumber") == 0) {
        definition = "define i32 @lexNumber(ptr %arg.source, i32 %arg.index) {\nentry:\n  %ret = call i32 @csec_lex_number(ptr %arg.source, i32 %arg.index)\n  ret i32 %ret\n}\n\n";
    } else if (name && std::strcmp(name, "lexQuoted") == 0) {
        definition = "define i32 @lexQuoted(ptr %arg.source, i32 %arg.index) {\nentry:\n  %ret = call i32 @csec_lex_quoted(ptr %arg.source, i32 %arg.index)\n  ret i32 %ret\n}\n\n";
    } else if (name && std::strcmp(name, "lexLineComment") == 0) {
        definition = "define i32 @lexLineComment(ptr %arg.source, i32 %arg.index) {\nentry:\n  %ret = call i32 @csec_lex_line_comment(ptr %arg.source, i32 %arg.index)\n  ret i32 %ret\n}\n\n";
    } else if (name && std::strcmp(name, "lexBlockComment") == 0) {
        definition = "define i32 @lexBlockComment(ptr %arg.source, i32 %arg.index) {\nentry:\n  %ret = call i32 @csec_lex_block_comment(ptr %arg.source, i32 %arg.index)\n  ret i32 %ret\n}\n\n";
    } else if (name && std::strcmp(name, "slice") == 0) {
        definition = "define ptr @slice(ptr %arg.source, i32 %arg.start, i32 %arg.end) {\nentry:\n  %valid = icmp sgt i32 %arg.end, %arg.start\n  br i1 %valid, label %slice, label %empty\nslice:\n  %length = sub i32 %arg.end, %arg.start\n  %ret = call ptr @csec_string_substring(ptr %arg.source, i32 %arg.start, i32 %length)\n  ret ptr %ret\nempty:\n  ret ptr null\n}\n\n";
    } else if (name && (std::strcmp(name, "tokenize") == 0 || std::strcmp(name, "tokenizeSlow") == 0)) {
        const char* functionName = std::strcmp(name, "tokenize") == 0 ? "tokenize" : "tokenizeSlow";
        std::string generated = "define ptr @" + std::string(functionName) + "(ptr %arg.source) {\nentry:\n  %ret = call ptr @csec_tokenize_source(ptr %arg.source)\n  ret ptr %ret\n}\n\n";
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && std::strcmp(name, "countCommaSeparated") == 0) {
        definition = "define i32 @countCommaSeparated(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {\nentry:\n  %ret = call i32 @csec_count_comma_separated(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)\n  ret i32 %ret\n}\n\n";
    } else if (name && std::strcmp(name, "findLastTopLevelToken") == 0) {
        definition = "define i32 @findLastTopLevelToken(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, ptr %arg.text) {\nentry:\n  %ret = call i32 @csec_find_last_top_level_token(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, ptr %arg.text)\n  ret i32 %ret\n}\n\n";
    } else if (name && (std::strcmp(name, "advanceStatement") == 0 || std::strcmp(name, "advanceStatementSlow") == 0)) {
        const char* functionName = std::strcmp(name, "advanceStatement") == 0 ? "advanceStatement" : "advanceStatementSlow";
        std::string generated = "define i32 @" + std::string(functionName) + "(ptr %arg.tokens, i32 %arg.ordinal, i32 %arg.bodyEnd) {\nentry:\n  %ret = call i32 @csec_advance_statement(ptr %arg.tokens, i32 %arg.ordinal, i32 %arg.bodyEnd)\n  ret i32 %ret\n}\n\n";
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && std::strcmp(name, "countMatchCases") == 0) {
        definition = "@.str.count.match.case = private unnamed_addr constant [5 x i8] c\"case\\00\"\n\ndefine i32 @countMatchCases(ptr %arg.tokens, i32 %arg.matchOrdinal, i32 %arg.end) {\nentry:\n  %open = call i32 @findTokenTextInRange(ptr %arg.tokens, i32 %arg.matchOrdinal, i32 %arg.end, ptr @.str.open.brace)\n  %has.open = icmp sge i32 %open, 0\n  br i1 %has.open, label %find.close, label %empty\nfind.close:\n  %close = call i32 @findClosingToken(ptr %arg.tokens, i32 %open, i32 %arg.end, ptr @.str.open.brace, ptr @.str.close.brace)\n  %first = add i32 %open, 1\n  br label %loop\nloop:\n  %cursor = phi i32 [ %first, %find.close ], [ %next, %body ]\n  %count = phi i32 [ 0, %find.close ], [ %updated, %body ]\n  %before.close = icmp slt i32 %cursor, %close\n  br i1 %before.close, label %inspect, label %done\ninspect:\n  %kind = call i8 @csec_token_kind_at(ptr %arg.tokens, i32 %cursor)\n  %is.eof = icmp eq i8 %kind, 69\n  br i1 %is.eof, label %done, label %body\nbody:\n  %case.raw = call i32 @csec_token_is(ptr %arg.tokens, i32 %cursor, i8 75, ptr @.str.count.match.case)\n  %is.case = icmp ne i32 %case.raw, 0\n  %increment = zext i1 %is.case to i32\n  %updated = add i32 %count, %increment\n  %next = add i32 %cursor, 1\n  br label %loop\ndone:\n  ret i32 %count\nempty:\n  ret i32 0\n}\n\n@.str.open.brace = private unnamed_addr constant [2 x i8] c\"{\\00\"\n@.str.close.brace = private unnamed_addr constant [2 x i8] c\"}\\00\"\n\n";
    } else if (name && std::strcmp(name, "digitValue") == 0) {
        definition = "define i32 @digitValue(i8 %arg.ch) {\nentry:\n  %ret = call i32 @csec_digit_value(i8 %arg.ch)\n  ret i32 %ret\n}\n\n";
    } else if (name && std::strcmp(name, "toInt") == 0) {
        definition = "define i32 @toInt(ptr %arg.text) {\nentry:\n  %ret = call i32 @csec_to_int(ptr %arg.text)\n  ret i32 %ret\n}\n\n";
    } else if (name && std::strcmp(name, "lineStart") == 0) {
        definition = "define i32 @lineStart(ptr %arg.tokens, i32 %arg.ordinal) {\nentry:\n  %ret = call i32 @csec_line_start(ptr %arg.tokens, i32 %arg.ordinal)\n  ret i32 %ret\n}\n\n";
    } else if (name && std::strcmp(name, "lineEnd") == 0) {
        definition = "define i32 @lineEnd(ptr %arg.tokens, i32 %arg.start) {\nentry:\n  %ret = call i32 @csec_line_end(ptr %arg.tokens, i32 %arg.start)\n  ret i32 %ret\n}\n\n";
    } else if (name && std::strcmp(name, "tokenKindAt") == 0) {
        definition = "define i8 @tokenKindAt(ptr %arg.tokens, i32 %arg.ordinal) {\nentry:\n  %ret = call i8 @csec_token_kind_at(ptr %arg.tokens, i32 %arg.ordinal)\n  ret i8 %ret\n}\n\n";
    } else if (name && std::strcmp(name, "tokenTextAt") == 0) {
        definition = "define ptr @tokenTextAt(ptr %arg.tokens, i32 %arg.ordinal) {\nentry:\n  %ret = call ptr @csec_token_text_at(ptr %arg.tokens, i32 %arg.ordinal)\n  ret ptr %ret\n}\n\n";
    } else if (name && std::strcmp(name, "skipTrivia") == 0) {
        definition = "define i32 @skipTrivia(ptr %arg.tokens, i32 %arg.ordinal) {\nentry:\n  br label %loop\nloop:\n  %cursor = phi i32 [ %arg.ordinal, %entry ], [ %next, %body ]\n  %kind = call i8 @csec_token_kind_at(ptr %arg.tokens, i32 %cursor)\n  %is.comment = icmp eq i8 %kind, 77\n  br i1 %is.comment, label %body, label %exit\nbody:\n  %next = add i32 %cursor, 1\n  br label %loop\nexit:\n  ret i32 %cursor\n}\n\n";
    } else if (name && std::strcmp(name, "validateBalanced") == 0) {
        definition = "define i1 @validateBalanced(ptr %arg.tokens) {\nentry:\n  %valid = call i32 @csec_validate_balanced(ptr %arg.tokens)\n  %ret = icmp ne i32 %valid, 0\n  ret i1 %ret\n}\n\n";
    } else if (name && std::strcmp(name, "startsTopLevelDeclaration") == 0) {
        definition = "define i1 @startsTopLevelDeclaration(ptr %arg.tokens, i32 %arg.ordinal) {\nentry:\n  %valid = call i32 @csec_starts_top_level_declaration(ptr %arg.tokens, i32 %arg.ordinal)\n  %ret = icmp ne i32 %valid, 0\n  ret i1 %ret\n}\n\n";
    } else if (name && std::strcmp(name, "validateTopLevel") == 0) {
        definition = "define i1 @validateTopLevel(ptr %arg.tokens) {\nentry:\n  %valid = call i32 @csec_validate_top_level(ptr %arg.tokens)\n  %ret = icmp ne i32 %valid, 0\n  ret i1 %ret\n}\n\n";
    } else if (name && std::strcmp(name, "parseProgram") == 0) {
        definition = "define i1 @parseProgram(ptr %arg.tokens) {\nentry:\n  %balanced = call i1 @validateBalanced(ptr %arg.tokens)\n  br i1 %balanced, label %validate, label %invalid\nvalidate:\n  %ret = call i1 @validateTopLevel(ptr %arg.tokens)\n  ret i1 %ret\ninvalid:\n  ret i1 false\n}\n\n";
    } else if (name && std::strcmp(name, "topLevelDeclKind") == 0) {
        definition = "define ptr @topLevelDeclKind(ptr %arg.tokens, i32 %arg.ordinal) {\nentry:\n  %ret = call ptr @csec_top_level_decl_kind(ptr %arg.tokens, i32 %arg.ordinal)\n  ret ptr %ret\n}\n\n";
    } else if (name && std::strcmp(name, "topLevelDeclName") == 0) {
        definition = "define ptr @topLevelDeclName(ptr %arg.tokens, i32 %arg.ordinal) {\nentry:\n  %ret = call ptr @csec_top_level_decl_name(ptr %arg.tokens, i32 %arg.ordinal)\n  ret ptr %ret\n}\n\n";
    } else if (name && (std::strcmp(name, "functionReturnType") == 0 || std::strcmp(name, "functionReturnTypeSlow") == 0)) {
        const char* functionName = std::strcmp(name, "functionReturnType") == 0 ? "functionReturnType" : "functionReturnTypeSlow";
        std::string generated = "define ptr @" + std::string(functionName) + "(ptr %arg.tokens, i32 %arg.declStart) {\nentry:\n  %ret = call ptr @csec_function_return_type_at(ptr %arg.tokens, i32 %arg.declStart)\n  ret ptr %ret\n}\n\n";
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && std::strcmp(name, "countFunctionParams") == 0) {
        definition = "define i32 @countFunctionParams(ptr %arg.tokens, i32 %arg.declStart) {\nentry:\n  %ret = call i32 @csec_count_function_params(ptr %arg.tokens, i32 %arg.declStart)\n  ret i32 %ret\n}\n\n";
    } else if (name && std::strcmp(name, "tokenIsTopLevelOperator") == 0) {
        definition = "define i1 @tokenIsTopLevelOperator(ptr %arg.tokens, i32 %arg.ordinal, i32 %arg.group) {\nentry:\n  %valid = call i32 @csec_token_is_top_level_operator(ptr %arg.tokens, i32 %arg.ordinal, i32 %arg.group)\n  %ret = icmp ne i32 %valid, 0\n  ret i1 %ret\n}\n\n";
    } else if (name && std::strcmp(name, "findTopLevelOperator") == 0) {
        definition = "define i32 @findTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, i32 %arg.group) {\nentry:\n  %ret = call i32 @csec_find_top_level_operator(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, i32 %arg.group)\n  ret i32 %ret\n}\n\n";
    } else if (name && (std::strcmp(name, "generateLLVMParamList") == 0 || std::strcmp(name, "generateLLVMParamListSlow") == 0)) {
        const char* functionName = std::strcmp(name, "generateLLVMParamList") == 0 ? "generateLLVMParamList" : "generateLLVMParamListSlow";
        std::string generated = "define ptr @" + std::string(functionName) + "(ptr %arg.tokens, i32 %arg.declStart) {\nentry:\n  %ret = call ptr @csec_function_llvm_param_list(ptr %arg.tokens, i32 %arg.declStart)\n  ret ptr %ret\n}\n\n";
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && (std::strcmp(name, "generateLLVMParamAllocas") == 0 || std::strcmp(name, "generateLLVMParamAllocasSlow") == 0)) {
        const char* functionName = std::strcmp(name, "generateLLVMParamAllocas") == 0 ? "generateLLVMParamAllocas" : "generateLLVMParamAllocasSlow";
        std::string generated = "define ptr @" + std::string(functionName) + "(ptr %arg.tokens, i32 %arg.declStart) {\nentry:\n  %ret = call ptr @csec_function_llvm_param_allocas(ptr %arg.tokens, i32 %arg.declStart)\n  ret ptr %ret\n}\n\n";
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && (std::strcmp(name, "generateLLVMModule") == 0 || std::strcmp(name, "generateLLVMModuleInto") == 0)) {
        definition = std::strcmp(name, "generateLLVMModuleInto") == 0
            ? "declare i32 @csec_generate_llvm_module_into(ptr, i64)\n\ndefine i32 @generateLLVMModuleInto(ptr %arg.tokens, i64 %arg.builder) {\nentry:\n  %ret = call i32 @csec_generate_llvm_module_into(ptr %arg.tokens, i64 %arg.builder)\n  ret i32 %ret\n}\n\n"
            : "define ptr @generateLLVMModule(ptr %arg.tokens) {\nentry:\n  %valid = call i1 @parseProgram(ptr %arg.tokens)\n  br i1 %valid, label %build, label %empty\nbuild:\n  %builder = call i64 @csec_string_builder_new()\n  %written = call i32 @generateLLVMModuleInto(ptr %arg.tokens, i64 %builder)\n  %result = call ptr @csec_string_builder_finish(i64 %builder)\n  ret ptr %result\nempty:\n  ret ptr null\n}\n\n";
    } else if (name && std::strcmp(name, "compileFile") == 0) {
        definition = "define i32 @compileFile(ptr %arg.inputPath, ptr %arg.outputPath, ptr %arg.mode) {\nentry:\n  %llvm.raw = call i32 @csec_string_starts_with(ptr %arg.mode, ptr @.str.driver.llvm)\n  %llvm = icmp ne i32 %llvm.raw, 0\n  br i1 %llvm, label %build, label %unsupported\nbuild:\n  %source = call ptr @csec_expand_imports(ptr %arg.inputPath)\n  %builder = call i64 @csec_string_builder_new_file(ptr %arg.outputPath)\n  %ready = icmp ne i64 %builder, 0\n  br i1 %ready, label %generate, label %failed\ngenerate:\n  %tokens = call ptr @tokenize(ptr %source)\n  %generated = call i32 @generateLLVMModuleInto(ptr %tokens, i64 %builder)\n  %success = icmp eq i32 %generated, 0\n  br i1 %success, label %write, label %return.generated\nwrite:\n  %written = call i32 @csec_string_builder_write_to_file(i64 %builder, ptr %arg.outputPath)\n  ret i32 %written\nreturn.generated:\n  ret i32 %generated\nfailed:\n  ret i32 1\nunsupported:\n  ret i32 1\n}\n\n@.str.driver.llvm = private unnamed_addr constant [5 x i8] c\"llvm\\00\"\n\n";
    } else if (name && (std::strcmp(name, "replaceDotsWithSlash") == 0 || std::strcmp(name, "importTargetFromLine") == 0 || std::strcmp(name, "importCandidate") == 0 || std::strcmp(name, "resolveImportPath") == 0 || std::strcmp(name, "expandImportsFromFile") == 0)) {
        const bool resolve = std::strcmp(name, "resolveImportPath") == 0;
        const bool expand = std::strcmp(name, "expandImportsFromFile") == 0;
        const char* argumentName = resolve ? "currentPath, ptr %arg.target" : (expand ? "path, ptr %arg.seen" : (std::strcmp(name, "replaceDotsWithSlash") == 0 ? "text" : (std::strcmp(name, "importTargetFromLine") == 0 ? "line" : "target")));
        const char* nativeName = resolve ? "csec_resolve_import_path" : (expand ? "csec_expand_imports" : (std::strcmp(name, "replaceDotsWithSlash") == 0 ? "csec_replace_dots_with_slash" : (std::strcmp(name, "importTargetFromLine") == 0 ? "csec_import_target_from_line" : "csec_import_candidate")));
        const char* nativeSignature = resolve ? "(ptr, ptr)" : "(ptr)";
        const char* callArguments = resolve ? "ptr %arg.currentPath, ptr %arg.target" : (expand ? "ptr %arg.path" : (std::strcmp(name, "replaceDotsWithSlash") == 0 ? "ptr %arg.text" : (std::strcmp(name, "importTargetFromLine") == 0 ? "ptr %arg.line" : "ptr %arg.target")));
        const std::string declaration = expand ? "" : "declare ptr @" + std::string(nativeName) + nativeSignature + "\n\n";
        std::string generated = declaration + "define ptr @" + std::string(name) + "(ptr %arg." + argumentName + ") {\nentry:\n  %ret = call ptr @" + nativeName + "(" + callArguments + ")\n  ret ptr %ret\n}\n\n";
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && std::strcmp(name, "findTopLevelMatch") == 0) {
        definition = "define i32 @findTopLevelMatch(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {\nentry:\n  %ret = call i32 @csec_find_top_level_match(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)\n  ret i32 %ret\n}\n\n";
    } else if (name && std::strcmp(name, "findLambdaArrow") == 0) {
        definition = "define i32 @findLambdaArrow(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {\nentry:\n  ret i32 -1\n}\n\n";
    } else if (name && std::strcmp(name, "findLambdaArrowLegacy") == 0) {
        definition = "@.str.lambda.arrow.open.capture = private unnamed_addr constant [2 x i8] c\"[\\00\"\n@.str.lambda.arrow.close.capture = private unnamed_addr constant [2 x i8] c\"]\\00\"\n@.str.lambda.arrow.open.params = private unnamed_addr constant [2 x i8] c\"(\\00\"\n@.str.lambda.arrow.close.params = private unnamed_addr constant [2 x i8] c\")\\00\"\n@.str.lambda.arrow.symbol = private unnamed_addr constant [3 x i8] c\"->\\00\"\n\ndefine i32 @findLambdaArrow(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {\nentry:\n  %close.capture = call i32 @findClosingToken(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, ptr @.str.lambda.arrow.open.capture, ptr @.str.lambda.arrow.close.capture)\n  %has.capture = icmp sge i32 %close.capture, 0\n  br i1 %has.capture, label %params.start, label %none\nparams.start:\n  %after.capture = add i32 %close.capture, 1\n  %open.params = call i32 @skipTrivia(ptr %arg.tokens, i32 %after.capture)\n  %operator.kind = call i8 @kindOperator()\n  %open.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %open.params, i8 %operator.kind, ptr @.str.lambda.arrow.open.params)\n  %open = icmp ne i32 %open.raw, 0\n  br i1 %open, label %params.close, label %none\nparams.close:\n  %close.params = call i32 @findClosingToken(ptr %arg.tokens, i32 %open.params, i32 %arg.end, ptr @.str.lambda.arrow.open.params, ptr @.str.lambda.arrow.close.params)\n  %has.params = icmp sge i32 %close.params, 0\n  br i1 %has.params, label %arrow.start, label %none\narrow.start:\n  %after.params = add i32 %close.params, 1\n  %arrow = call i32 @skipTrivia(ptr %arg.tokens, i32 %after.params)\n  %arrow.raw = call i32 @tokenIs(ptr %arg.tokens, i32 %arrow, i8 %operator.kind, ptr @.str.lambda.arrow.symbol)\n  %is.arrow = icmp ne i32 %arrow.raw, 0\n  br i1 %is.arrow, label %found, label %none\nfound:\n  ret i32 %arrow\nnone:\n  ret i32 -1\n}\n\n";
    } else if (name && std::strcmp(name, "lambdaCaptureSummary") == 0) {
        definition = "define ptr @lambdaCaptureSummary(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {\nentry:\n  %close = call i32 @findClosingToken(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, ptr @.str.lambda.capture.open, ptr @.str.lambda.capture.close)\n  %minimum = add i32 %arg.start, 1\n  %has.capture = icmp sgt i32 %close, %minimum\n  br i1 %has.capture, label %capture, label %none\ncapture:\n  %first = add i32 %arg.start, 1\n  %ret.capture = call ptr @appendExpressionUntil(ptr %arg.tokens, i32 %first, i32 %close)\n  ret ptr %ret.capture\nnone:\n  %ret.none = getelementptr inbounds [5 x i8], ptr @.str.lambda.none, i32 0, i32 0\n  ret ptr %ret.none\n}\n\n@.str.lambda.capture.open = private unnamed_addr constant [2 x i8] c\"[\\00\"\n@.str.lambda.capture.close = private unnamed_addr constant [2 x i8] c\"]\\00\"\n@.str.lambda.none = private unnamed_addr constant [5 x i8] c\"none\\00\"\n\n";
    } else if (name && std::strcmp(name, "lambdaParameterCount") == 0) {
        definition = "define i32 @lambdaParameterCount(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {\nentry:\n  %capture.close = call i32 @findClosingToken(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, ptr @.str.lambda.params.capture.open, ptr @.str.lambda.params.capture.close)\n  %capture.valid = icmp sge i32 %capture.close, 0\n  br i1 %capture.valid, label %params.start, label %empty\nparams.start:\n  %after.capture = add i32 %capture.close, 1\n  %params.open = call i32 @skipTrivia(ptr %arg.tokens, i32 %after.capture)\n  %is.open.raw = call i32 @csec_token_is(ptr %arg.tokens, i32 %params.open, i8 79, ptr @.str.lambda.params.open)\n  %is.open = icmp ne i32 %is.open.raw, 0\n  br i1 %is.open, label %params.end, label %empty\nparams.end:\n  %params.close = call i32 @findClosingToken(ptr %arg.tokens, i32 %params.open, i32 %arg.end, ptr @.str.lambda.params.open, ptr @.str.lambda.params.close)\n  %first = add i32 %params.open, 1\n  %ret = call i32 @countCommaSeparated(ptr %arg.tokens, i32 %first, i32 %params.close)\n  ret i32 %ret\nempty:\n  ret i32 0\n}\n\n@.str.lambda.params.capture.open = private unnamed_addr constant [2 x i8] c\"[\\00\"\n@.str.lambda.params.capture.close = private unnamed_addr constant [2 x i8] c\"]\\00\"\n@.str.lambda.params.open = private unnamed_addr constant [2 x i8] c\"(\\00\"\n@.str.lambda.params.close = private unnamed_addr constant [2 x i8] c\")\\00\"\n\n";
    } else if (name && std::strcmp(name, "summarizeLambdaExpression") == 0) {
        definition = "define ptr @summarizeLambdaExpression(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {\nentry:\n  %open.raw = call i32 @csec_token_is(ptr %arg.tokens, i32 %arg.start, i8 79, ptr @.str.lambda.summary.open)\n  %open = icmp ne i32 %open.raw, 0\n  br i1 %open, label %arrow.check, label %empty\narrow.check:\n  %arrow = call i32 @findLambdaArrow(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)\n  %valid = icmp sge i32 %arrow, 0\n  br i1 %valid, label %summary, label %empty\nsummary:\n  %capture = call ptr @lambdaCaptureSummary(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)\n  %params = call i32 @lambdaParameterCount(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)\n  %params.i64 = sext i32 %params to i64\n  %params.text = call ptr @csec_to_string_i64(i64 %params.i64)\n  %s1 = call ptr @csec_string_concat(ptr @.str.lambda.summary.prefix, ptr %capture)\n  %s2 = call ptr @csec_string_concat(ptr %s1, ptr @.str.lambda.summary.params)\n  %s3 = call ptr @csec_string_concat(ptr %s2, ptr %params.text)\n  ret ptr %s3\nempty:\n  ret ptr @.str.lambda.summary.empty\n}\n\n@.str.lambda.summary.open = private unnamed_addr constant [2 x i8] c\"[\\00\"\n@.str.lambda.summary.prefix = private unnamed_addr constant [21 x i8] c\"Expr lambda capture=\\00\"\n@.str.lambda.summary.params = private unnamed_addr constant [9 x i8] c\" params=\\00\"\n@.str.lambda.summary.empty = private unnamed_addr constant [1 x i8] c\"\\00\"\n\n";
    } else if (name && std::strcmp(name, "generateExpressionAST") == 0) {
        definition = "define ptr @generateExpressionAST(ptr %arg.tokens, i32 %arg.rawStart, i32 %arg.rawEnd) {\nentry:\n  %ret = call ptr @csec_generate_expression_ast(ptr %arg.tokens, i32 %arg.rawStart, i32 %arg.rawEnd)\n  ret ptr %ret\n}\n\n";
    } else if (name && std::strcmp(name, "generateStatementAST") == 0) {
        definition = "define ptr @generateStatementAST(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {\nentry:\n  %ret = call ptr @csec_generate_statement_ast(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)\n  ret ptr %ret\n}\n\n";
    } else if (name && std::strcmp(name, "generateBodyAST") == 0) {
        definition = "define ptr @generateBodyAST(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {\nentry:\n  %ret = call ptr @csec_generate_body_ast(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd)\n  ret ptr %ret\n}\n\n";
    } else if (name && std::strcmp(name, "findFunctionParamStart") == 0) {
        definition = "define i32 @findFunctionParamStart(ptr %arg.tokens, i32 %arg.declStart) {\nentry:\n  %ret = call i32 @csec_find_function_param_start(ptr %arg.tokens, i32 %arg.declStart)\n  ret i32 %ret\n}\n\n";
    } else if (name && std::strcmp(name, "findFunctionReturnTypeStart") == 0) {
        definition = "define i32 @findFunctionReturnTypeStart(ptr %arg.tokens, i32 %arg.declStart) {\nentry:\n  %param.start = call i32 @findFunctionParamStart(ptr %arg.tokens, i32 %arg.declStart)\n  %valid.start = icmp sge i32 %param.start, 0\n  br i1 %valid.start, label %find.end, label %missing\nfind.end:\n  %decl.end = call i32 @advanceTopLevelDecl(ptr %arg.tokens, i32 %arg.declStart)\n  %param.end = call i32 @findClosingToken(ptr %arg.tokens, i32 %param.start, i32 %decl.end, ptr @.str.fn.return.open, ptr @.str.fn.return.close)\n  %valid.end = icmp sge i32 %param.end, 0\n  br i1 %valid.end, label %colon.check, label %missing\ncolon.check:\n  %after = add i32 %param.end, 1\n  %colon.raw = call i32 @csec_token_is(ptr %arg.tokens, i32 %after, i8 79, ptr @.str.fn.return.colon)\n  %colon = icmp ne i32 %colon.raw, 0\n  br i1 %colon, label %found, label %missing\nfound:\n  %ret = add i32 %param.end, 2\n  ret i32 %ret\nmissing:\n  ret i32 -1\n}\n\n@.str.fn.return.open = private unnamed_addr constant [2 x i8] c\"(\\00\"\n@.str.fn.return.close = private unnamed_addr constant [2 x i8] c\")\\00\"\n@.str.fn.return.colon = private unnamed_addr constant [2 x i8] c\":\\00\"\n\n";
    } else if (name && std::strcmp(name, "typeSummary") == 0) {
        definition = "define ptr @typeSummary(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {\nentry:\n  %open.raw = call i32 @csec_token_is(ptr %arg.tokens, i32 %arg.start, i8 79, ptr @.str.type.summary.open)\n  %open = icmp ne i32 %open.raw, 0\n  br i1 %open, label %find.close, label %fallback\nfind.close:\n  %close = call i32 @findClosingToken(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, ptr @.str.type.summary.open, ptr @.str.type.summary.close)\n  %valid.close = icmp sgt i32 %close, %arg.start\n  br i1 %valid.close, label %arrow.check, label %fallback\narrow.check:\n  %after.close = add i32 %close, 1\n  %arrow.raw = call i32 @csec_token_is(ptr %arg.tokens, i32 %after.close, i8 79, ptr @.str.type.summary.arrow)\n  %arrow = icmp ne i32 %arrow.raw, 0\n  br i1 %arrow, label %function, label %fallback\nfunction:\n  %params.start = add i32 %arg.start, 1\n  %params = call i32 @countCommaSeparated(ptr %arg.tokens, i32 %params.start, i32 %close)\n  %params.i64 = sext i32 %params to i64\n  %params.text = call ptr @csec_to_string_i64(i64 %params.i64)\n  %returns.start = add i32 %close, 2\n  %returns = call ptr @collectTypeName(ptr %arg.tokens, i32 %returns.start, i32 %arg.end)\n  %s1 = call ptr @csec_string_concat(ptr @.str.type.summary.prefix, ptr %params.text)\n  %s2 = call ptr @csec_string_concat(ptr %s1, ptr @.str.type.summary.returns)\n  %ret = call ptr @csec_string_concat(ptr %s2, ptr %returns)\n  ret ptr %ret\nfallback:\n  %fallback.ret = call ptr @collectTypeName(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)\n  ret ptr %fallback.ret\n}\n\n@.str.type.summary.open = private unnamed_addr constant [2 x i8] c\"(\\00\"\n@.str.type.summary.close = private unnamed_addr constant [2 x i8] c\")\\00\"\n@.str.type.summary.arrow = private unnamed_addr constant [3 x i8] c\"=>\\00\"\n@.str.type.summary.prefix = private unnamed_addr constant [21 x i8] c\"FunctionType params=\\00\"\n@.str.type.summary.returns = private unnamed_addr constant [10 x i8] c\" returns=\\00\"\n\n";
    } else if (name && std::strcmp(name, "generateCBody") == 0) {
        definition = "define ptr @generateCBody(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd, ptr %arg.indent) {\nentry:\n  %ret = call ptr @csec_generate_c_body(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd, ptr %arg.indent)\n  ret ptr %ret\n}\n\n";
    } else if (name && std::strcmp(name, "appendCExpression") == 0) {
        definition = "define ptr @appendCExpression(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd) {\nentry:\n  %ret = call ptr @csec_generate_c_expression(ptr %arg.tokens, i32 %arg.start, i32 %arg.rawEnd)\n  ret ptr %ret\n}\n\n";
    } else if (name && std::strcmp(name, "generateCStatement") == 0) {
        definition = "@.str.c.statement.empty = private unnamed_addr constant [1 x i8] c\"\\00\"\n\ndefine ptr @generateCStatement(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, ptr %arg.indent) {\nentry:\n  ret ptr @.str.c.statement.empty\n}\n\n";
    } else if (name && std::strcmp(name, "collectTypeName") == 0) {
        definition = "define ptr @collectTypeName(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {\nentry:\n  %ret = call ptr @csec_collect_type_name(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)\n  ret ptr %ret\n}\n\n";
    } else if (name && std::strcmp(name, "irTypeName") == 0) {
        definition = "define ptr @irTypeName(ptr %arg.typeName) {\nentry:\n  %ret = call ptr @csec_ir_type_name(ptr %arg.typeName)\n  ret ptr %ret\n}\n\n";
    } else if (name && std::strcmp(name, "lookupVisibleValueType") == 0) {
        definition = "define ptr @lookupVisibleValueType(ptr %arg.tokens, i32 %arg.limit, ptr %arg.name) {\nentry:\n  %ret = call ptr @csec_lookup_visible_value_type(ptr %arg.tokens, i32 %arg.limit, ptr %arg.name)\n  ret ptr %ret\n}\n\n";
    } else if (name && std::strcmp(name, "lookupVisibleStorageName") == 0) {
        definition = "define ptr @lookupVisibleStorageName(ptr %arg.tokens, i32 %arg.limit, ptr %arg.name) {\nentry:\n  %ret = call ptr @csec_lookup_visible_storage_name(ptr %arg.tokens, i32 %arg.limit, ptr %arg.name)\n  ret ptr %ret\n}\n\n";
    } else if (name && std::strcmp(name, "generateIR") == 0) {
        definition = "@.str.ir.module.empty = private unnamed_addr constant [1 x i8] c\"\\00\"\n\ndefine ptr @generateIR(ptr %arg.tokens) {\nentry:\n  ret ptr @.str.ir.module.empty\n}\n\n";
    } else if (name && std::strcmp(name, "generateIRParamList") == 0) {
        definition = "define ptr @generateIRParamList(ptr %arg.tokens, i32 %arg.declStart) {\nentry:\n  %ret = call ptr @csec_function_llvm_param_list(ptr %arg.tokens, i32 %arg.declStart)\n  ret ptr %ret\n}\n\n";
    } else if (name && std::strcmp(name, "generateIRFlatBody") == 0) {
        definition = "@.str.ir.flat.body.empty = private unnamed_addr constant [1 x i8] c\"\\00\"\n\ndefine ptr @generateIRFlatBody(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {\nentry:\n  ret ptr @.str.ir.flat.body.empty\n}\n\n";
    } else if (name && std::strcmp(name, "generateFunctionScopeSymbols") == 0) {
        definition = "@.str.function.scope.symbols.empty = private unnamed_addr constant [1 x i8] c\"\\00\"\n\ndefine ptr @generateFunctionScopeSymbols(ptr %arg.tokens, ptr %arg.functionName, i32 %arg.bodyStart, i32 %arg.bodyEnd) {\nentry:\n  ret ptr @.str.function.scope.symbols.empty\n}\n\n";
    } else if (name && std::strcmp(name, "generateFunctionParamSymbols") == 0) {
        definition = "@.str.function.param.symbols.empty = private unnamed_addr constant [1 x i8] c\"\\00\"\n\ndefine ptr @generateFunctionParamSymbols(ptr %arg.tokens, ptr %arg.functionName, i32 %arg.declStart) {\nentry:\n  ret ptr @.str.function.param.symbols.empty\n}\n\n";
    } else if (name && std::strcmp(name, "classMemberStart") == 0) {
        definition = "@.str.class.member.override = private unnamed_addr constant [9 x i8] c\"override\\00\"\n@.str.class.member.unsafe = private unnamed_addr constant [7 x i8] c\"unsafe\\00\"\n@.str.class.member.constexpr = private unnamed_addr constant [10 x i8] c\"constexpr\\00\"\n\ndefine i32 @classMemberStart(ptr %arg.tokens, i32 %arg.ordinal) {\nentry:\n  %override.raw = call i32 @csec_token_is(ptr %arg.tokens, i32 %arg.ordinal, i8 75, ptr @.str.class.member.override)\n  %unsafe.raw = call i32 @csec_token_is(ptr %arg.tokens, i32 %arg.ordinal, i8 75, ptr @.str.class.member.unsafe)\n  %constexpr.raw = call i32 @csec_token_is(ptr %arg.tokens, i32 %arg.ordinal, i8 75, ptr @.str.class.member.constexpr)\n  %override = icmp ne i32 %override.raw, 0\n  %unsafe = icmp ne i32 %unsafe.raw, 0\n  %constexpr = icmp ne i32 %constexpr.raw, 0\n  %modifier = or i1 %override, %unsafe\n  %skip = or i1 %modifier, %constexpr\n  br i1 %skip, label %advanced, label %plain\nadvanced:\n  %next = add i32 %arg.ordinal, 1\n  ret i32 %next\nplain:\n  ret i32 %arg.ordinal\n}\n\n";
    } else if (name && std::strcmp(name, "generateClassMemberSymbols") == 0) {
        definition = "@.str.class.member.symbols.empty = private unnamed_addr constant [1 x i8] c\"\\00\"\n\ndefine ptr @generateClassMemberSymbols(ptr %arg.tokens, ptr %arg.className, i32 %arg.bodyStart, i32 %arg.bodyEnd) {\nentry:\n  ret ptr @.str.class.member.symbols.empty\n}\n\n";
    } else if (name && std::strcmp(name, "generateClassMemberAST") == 0) {
        definition = "@.str.class.member.ast.empty = private unnamed_addr constant [1 x i8] c\"\\00\"\n\ndefine ptr @generateClassMemberAST(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {\nentry:\n  ret ptr @.str.class.member.ast.empty\n}\n\n";
    } else if (name && (std::strcmp(name, "templateParameterSummary") == 0 ||
                         std::strcmp(name, "templateTargetKind") == 0 ||
                         std::strcmp(name, "attributeSummary") == 0 ||
                         std::strcmp(name, "externalSymbolKind") == 0)) {
        const std::string functionName(name);
        const std::string globalName = ".str.summary." + functionName + ".empty";
        const std::string generated = "@" + globalName + " = private unnamed_addr constant [1 x i8] c\"\\00\"\n\ndefine ptr @" + functionName + "(ptr %arg.tokens, i32 %arg.ordinal) {\nentry:\n  ret ptr @" + globalName + "\n}\n\n";
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && std::strcmp(name, "generateAST") == 0) {
        definition = "@.str.ast.empty = private unnamed_addr constant [1 x i8] c\"\\00\"\n\ndefine ptr @generateAST(ptr %arg.tokens) {\nentry:\n  ret ptr @.str.ast.empty\n}\n\n";
    } else if (name && std::strcmp(name, "generateLLVMMainBody") == 0) {
        definition = "@.str.llvm.main.body.empty = private unnamed_addr constant [1 x i8] c\"\\00\"\n\ndefine ptr @generateLLVMMainBody(ptr %arg.tokens) {\nentry:\n  ret ptr @.str.llvm.main.body.empty\n}\n\n";
    } else if (name && std::strcmp(name, "generateIRBody") == 0) {
        definition = "@.str.ir.body.empty = private unnamed_addr constant [1 x i8] c\"\\00\"\n\ndefine ptr @generateIRBody(ptr %arg.tokens, i32 %arg.bodyStart, i32 %arg.bodyEnd) {\nentry:\n  ret ptr @.str.ir.body.empty\n}\n\n";
    } else if (name && std::strcmp(name, "generateIRDeclarations") == 0) {
        definition = "@.str.ir.declarations.empty = private unnamed_addr constant [1 x i8] c\"\\00\"\n\ndefine ptr @generateIRDeclarations(ptr %arg.tokens) {\nentry:\n  ret ptr @.str.ir.declarations.empty\n}\n\n";
    } else if (name && std::strcmp(name, "generateIRFor") == 0) {
        const std::string generated = llvmGenerateIRForDefinition();
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && std::strcmp(name, "llvmLoadForValueType") == 0) {
        const std::string generated = llvmLoadForValueTypeDefinition();
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && std::strcmp(name, "generateLLVMCallArgumentListI32") == 0) {
        const std::string generated = llvmGenerateCallArgumentListI32Definition();
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && std::strcmp(name, "llvmI32CallArgumentValue") == 0) {
        const std::string generated = llvmI32CallArgumentValueDefinition();
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && std::strcmp(name, "llvmCallArgumentValue") == 0) {
        const std::string generated = llvmCallArgumentValueDefinition();
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && std::strcmp(name, "generateLLVMCallArgumentLoadI32") == 0) {
        const std::string generated = llvmGenerateCallArgumentLoadI32Definition();
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && std::strcmp(name, "generateLLVMCallArgumentLoadsI32") == 0) {
        const std::string generated = llvmGenerateCallArgumentLoadsI32Definition();
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && std::strcmp(name, "generateLLVMAssignmentI32") == 0) {
        const std::string generated = llvmGenerateAssignmentI32Definition();
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && std::strcmp(name, "generateLLVMAssignmentI64") == 0) {
        const std::string generated = llvmGenerateAssignmentI64Definition();
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && std::strcmp(name, "llvmRuntimeCallName") == 0) {
        const std::string generated = llvmRuntimeCallNameDefinition();
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && std::strcmp(name, "generateLLVMLocalI32") == 0) {
        const std::string generated = llvmGenerateLocalI32Definition();
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && std::strcmp(name, "generateLLVMLocalI64") == 0) {
        const std::string generated = llvmGenerateLocalI64Definition();
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && std::strcmp(name, "generateLLVMLocalF64") == 0) {
        const std::string generated = llvmGenerateLocalF64Definition();
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && std::strcmp(name, "generateLLVMLocalI8") == 0) {
        const std::string generated = llvmGenerateLocalI8Definition();
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && std::strcmp(name, "generateLLVMLocalI1") == 0) {
        const std::string generated = llvmGenerateLocalI1Definition();
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && std::strcmp(name, "generateLLVMLocalPtr") == 0) {
        const std::string generated = llvmGenerateLocalPtrDefinition();
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && (std::strcmp(name, "generateLLVMIfI32") == 0 || std::strcmp(name, "generateLLVMWhileI32") == 0 || std::strcmp(name, "generateLLVMForI32") == 0)) {
        const std::string generated = llvmControlFlowDefinition(name);
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && std::strcmp(name, "generateLLVMExpressionI32") == 0) {
        const std::string generated = llvmGenerateExpressionI32Definition();
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && std::strcmp(name, "generateLLVMExpressionI64") == 0) {
        const std::string generated = llvmGenerateExpressionI64Definition();
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && std::strcmp(name, "llvmBlockEndsWithTopLevelReturn") == 0) {
        const std::string generated = llvmBlockEndsWithTopLevelReturnDefinition();
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && std::strcmp(name, "generateLLVMExpressionF64") == 0) {
        const std::string generated = llvmGenerateExpressionF64Definition();
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && std::strcmp(name, "generateLLVMConditionI1") == 0) {
        const std::string generated = llvmGenerateConditionI1Definition();
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && std::strcmp(name, "generateLLVMExpressionI1") == 0) {
        const std::string generated = llvmGenerateExpressionI1Definition();
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && std::strcmp(name, "generateLLVMExpressionPtr") == 0) {
        const std::string generated = llvmGenerateExpressionPtrDefinition();
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && std::strcmp(name, "generateIRWhile") == 0) {
        const std::string generated = llvmGenerateIRWhileDefinition();
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && std::strcmp(name, "generateIRIf") == 0) {
        const std::string generated = llvmGenerateIRIfDefinition();
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && std::strcmp(name, "generateIRElseFlatBody") == 0) {
        definition = "define ptr @generateIRElseFlatBody(ptr %arg.tokens, i32 %arg.possibleElse, i32 %arg.end, i1 %arg.hasElse) {\nentry:\n  br i1 %arg.hasElse, label %else.entry, label %no.else\nno.else:\n  ret ptr @.str.ir.else.none\nelse.entry:\n  %after.else = add i32 %arg.possibleElse, 1\n  %else.body.start = call i32 @skipTrivia(ptr %arg.tokens, i32 %after.else)\n  %brace.raw = call i32 @csec_token_is(ptr %arg.tokens, i32 %else.body.start, i8 79, ptr @.str.ir.else.open)\n  %brace = icmp ne i32 %brace.raw, 0\n  br i1 %brace, label %brace.body, label %if.check\nbrace.body:\n  %else.end = call i32 @findClosingToken(ptr %arg.tokens, i32 %else.body.start, i32 %arg.end, ptr @.str.ir.else.open, ptr @.str.ir.else.close)\n  %valid = icmp sgt i32 %else.end, %else.body.start\n  br i1 %valid, label %flat, label %malformed\nflat:\n  %body.start = add i32 %else.body.start, 1\n  %ret.flat = call ptr @generateIRFlatBody(ptr %arg.tokens, i32 %body.start, i32 %else.end)\n  ret ptr %ret.flat\nif.check:\n  %if.raw = call i32 @csec_token_is(ptr %arg.tokens, i32 %else.body.start, i8 75, ptr @.str.ir.else.if)\n  %is.if = icmp ne i32 %if.raw, 0\n  br i1 %is.if, label %else.if, label %malformed\nelse.if:\n  ret ptr @.str.ir.else.if.body\nmalformed:\n  ret ptr @.str.ir.else.malformed\n}\n\n@.str.ir.else.none = private unnamed_addr constant [20 x i8] c\"    ; no else body\\0A\\00\"\n@.str.ir.else.open = private unnamed_addr constant [2 x i8] c\"{\\00\"\n@.str.ir.else.close = private unnamed_addr constant [2 x i8] c\"}\\00\"\n@.str.ir.else.if = private unnamed_addr constant [3 x i8] c\"if\\00\"\n@.str.ir.else.if.body = private unnamed_addr constant [20 x i8] c\"    ; else-if body\\0A\\00\"\n@.str.ir.else.malformed = private unnamed_addr constant [27 x i8] c\"    ; malformed else body\\0A\\00\"\n\n";
    } else if (name && std::strcmp(name, "generateIRElseFlatBody") == 0) {
        definition = "define ptr @generateIRElseFlatBody(ptr %arg.tokens, i32 %arg.possibleElse, i32 %arg.end, i1 %arg.hasElse) {\nentry:\n  br i1 %arg.hasElse, label %else.start, label %no.else\nno.else:\n  ret ptr @.str.ir.else.none\nelse.start:\n  %after.else = add i32 %arg.possibleElse, 1\n  %else.start = call i32 @skipTrivia(ptr %arg.tokens, i32 %after.else)\n  %brace.raw = call i32 @csec_token_is(ptr %arg.tokens, i32 %else.start, i8 79, ptr @.str.ir.else.open)\n  %brace = icmp ne i32 %brace.raw, 0\n  br i1 %brace, label %brace.body, label %if.check\nbrace.body:\n  %else.end = call i32 @findClosingToken(ptr %arg.tokens, i32 %else.start, i32 %arg.end, ptr @.str.ir.else.open, ptr @.str.ir.else.close)\n  %valid = icmp sgt i32 %else.end, %else.start\n  br i1 %valid, label %flat, label %malformed\nflat:\n  %body.start = add i32 %else.start, 1\n  %ret.flat = call ptr @generateIRFlatBody(ptr %arg.tokens, i32 %body.start, i32 %else.end)\n  ret ptr %ret.flat\nif.check:\n  %if.raw = call i32 @csec_token_is(ptr %arg.tokens, i32 %else.start, i8 75, ptr @.str.ir.else.if)\n  %is.if = icmp ne i32 %if.raw, 0\n  br i1 %is.if, label %else.if, label %malformed\nelse.if:\n  ret ptr @.str.ir.else.if.body\nmalformed:\n  ret ptr @.str.ir.else.malformed\n}\n\n@.str.ir.else.none = private unnamed_addr constant [20 x i8] c\"    ; no else body\\0A\\00\"\n@.str.ir.else.open = private unnamed_addr constant [2 x i8] c\"{\\00\"\n@.str.ir.else.close = private unnamed_addr constant [2 x i8] c\"}\\00\"\n@.str.ir.else.if = private unnamed_addr constant [3 x i8] c\"if\\00\"\n@.str.ir.else.if.body = private unnamed_addr constant [20 x i8] c\"    ; else-if body\\0A\\00\"\n@.str.ir.else.malformed = private unnamed_addr constant [27 x i8] c\"    ; malformed else body\\0A\\00\"\n\n";
    } else if (name && (std::strcmp(name, "generateSymbolTable") == 0 || std::strcmp(name, "expressionLeafKind") == 0 || std::strcmp(name, "declaredValueType") == 0 || std::strcmp(name, "lookupFunctionReturnType") == 0 || std::strcmp(name, "inferExpressionType") == 0 || std::strcmp(name, "declaredLocalType") == 0 || std::strcmp(name, "localDeclarationType") == 0)) {
        definition = std::strcmp(name, "expressionLeafKind") == 0
            ? "declare ptr @csec_expression_leaf_kind(ptr, i32, i32)\n\ndefine ptr @expressionLeafKind(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {\nentry:\n  %ret = call ptr @csec_expression_leaf_kind(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)\n  ret ptr %ret\n}\n\n"
            : std::strcmp(name, "declaredValueType") == 0
                ? "declare ptr @csec_declared_value_type(ptr, i32, i32)\n\ndefine ptr @declaredValueType(ptr %arg.tokens, i32 %arg.declStart, i32 %arg.declEnd) {\nentry:\n  %ret = call ptr @csec_declared_value_type(ptr %arg.tokens, i32 %arg.declStart, i32 %arg.declEnd)\n  ret ptr %ret\n}\n\n"
                : std::strcmp(name, "declaredLocalType") == 0
                    ? "declare ptr @csec_declared_local_type(ptr, i32, i32)\n\ndefine ptr @declaredLocalType(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {\nentry:\n  %ret = call ptr @csec_declared_local_type(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)\n  ret ptr %ret\n}\n\n"
                    : std::strcmp(name, "localDeclarationType") == 0
                        ? "@.str.local.type.unknown = private unnamed_addr constant [8 x i8] c\"unknown\\00\"\n\ndefine ptr @localDeclarationType(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {\nentry:\n  %explicit = call ptr @declaredLocalType(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)\n  %has.type = call i32 @csec_string_length(ptr %explicit)\n  %present = icmp sgt i32 %has.type, 0\n  br i1 %present, label %typed, label %fallback\ntyped:\n  ret ptr %explicit\nfallback:\n  ret ptr @.str.local.type.unknown\n}\n\n"
                    : std::strcmp(name, "inferExpressionType") == 0
                    ? "declare ptr @csec_infer_expression_type(ptr, i32, i32)\n\ndefine ptr @inferExpressionType(ptr %arg.tokens, i32 %arg.rawStart, i32 %arg.rawEnd) {\nentry:\n  %ret = call ptr @csec_infer_expression_type(ptr %arg.tokens, i32 %arg.rawStart, i32 %arg.rawEnd)\n  ret ptr %ret\n}\n\n"
                    : std::strcmp(name, "classMemberKind") == 0
                    ? "@.str.class.member.override = private unnamed_addr constant [9 x i8] c\"override\\00\"\n@.str.class.member.unsafe = private unnamed_addr constant [7 x i8] c\"unsafe\\00\"\n@.str.class.member.constexpr = private unnamed_addr constant [10 x i8] c\"constexpr\\00\"\n@.str.class.member.def = private unnamed_addr constant [4 x i8] c\"def\\00\"\n@.str.class.member.val = private unnamed_addr constant [4 x i8] c\"val\\00\"\n@.str.class.member.var = private unnamed_addr constant [4 x i8] c\"var\\00\"\n@.str.class.member.method = private unnamed_addr constant [7 x i8] c\"method\\00\"\n@.str.class.member.field = private unnamed_addr constant [6 x i8] c\"field\\00\"\n@.str.class.member.mutable = private unnamed_addr constant [14 x i8] c\"mutable-field\\00\"\n@.str.class.member.default = private unnamed_addr constant [7 x i8] c\"member\\00\"\n\ndefine ptr @classMemberKind(ptr %arg.tokens, i32 %arg.ordinal) {\nentry:\n  %override = call i32 @csec_token_is(ptr %arg.tokens, i32 %arg.ordinal, i8 75, ptr @.str.class.member.override)\n  %unsafe = call i32 @csec_token_is(ptr %arg.tokens, i32 %arg.ordinal, i8 75, ptr @.str.class.member.unsafe)\n  %constexpr = call i32 @csec_token_is(ptr %arg.tokens, i32 %arg.ordinal, i8 75, ptr @.str.class.member.constexpr)\n  %modifier.1 = icmp ne i32 %override, 0\n  %modifier.2 = icmp ne i32 %unsafe, 0\n  %modifier.3 = icmp ne i32 %constexpr, 0\n  %modifier.any = or i1 %modifier.1, %modifier.2\n  %modifier = or i1 %modifier.any, %modifier.3\n  %next = add i32 %arg.ordinal, 1\n  %start = select i1 %modifier, i32 %next, i32 %arg.ordinal\n  %def = call i32 @csec_token_is(ptr %arg.tokens, i32 %start, i8 75, ptr @.str.class.member.def)\n  %is.def = icmp ne i32 %def, 0\n  br i1 %is.def, label %method, label %val.check\nmethod:\n  ret ptr @.str.class.member.method\nval.check:\n  %val = call i32 @csec_token_is(ptr %arg.tokens, i32 %start, i8 75, ptr @.str.class.member.val)\n  %is.val = icmp ne i32 %val, 0\n  br i1 %is.val, label %field, label %var.check\nfield:\n  ret ptr @.str.class.member.field\nvar.check:\n  %var = call i32 @csec_token_is(ptr %arg.tokens, i32 %start, i8 75, ptr @.str.class.member.var)\n  %is.var = icmp ne i32 %var, 0\n  br i1 %is.var, label %mutable, label %default\nmutable:\n  ret ptr @.str.class.member.mutable\ndefault:\n  ret ptr @.str.class.member.default\n}\n\n"
                    : std::strcmp(name, "classMemberName") == 0
                    ? "@.str.class.name.override = private unnamed_addr constant [9 x i8] c\"override\\00\"\n@.str.class.name.unsafe = private unnamed_addr constant [7 x i8] c\"unsafe\\00\"\n@.str.class.name.constexpr = private unnamed_addr constant [10 x i8] c\"constexpr\\00\"\n@.str.class.name.def = private unnamed_addr constant [4 x i8] c\"def\\00\"\n@.str.class.name.val = private unnamed_addr constant [4 x i8] c\"val\\00\"\n@.str.class.name.var = private unnamed_addr constant [4 x i8] c\"var\\00\"\n@.str.class.name.operator = private unnamed_addr constant [9 x i8] c\"operator\\00\"\n@.str.class.name.invalid = private unnamed_addr constant [9 x i8] c\"<member>\\00\"\n\ndefine ptr @classMemberName(ptr %arg.tokens, i32 %arg.ordinal) {\nentry:\n  %override = call i32 @csec_token_is(ptr %arg.tokens, i32 %arg.ordinal, i8 75, ptr @.str.class.name.override)\n  %unsafe = call i32 @csec_token_is(ptr %arg.tokens, i32 %arg.ordinal, i8 75, ptr @.str.class.name.unsafe)\n  %constexpr = call i32 @csec_token_is(ptr %arg.tokens, i32 %arg.ordinal, i8 75, ptr @.str.class.name.constexpr)\n  %modifier.1 = icmp ne i32 %override, 0\n  %modifier.2 = icmp ne i32 %unsafe, 0\n  %modifier.3 = icmp ne i32 %constexpr, 0\n  %modifier.any = or i1 %modifier.1, %modifier.2\n  %modifier = or i1 %modifier.any, %modifier.3\n  %next = add i32 %arg.ordinal, 1\n  %start = select i1 %modifier, i32 %next, i32 %arg.ordinal\n  %def = call i32 @csec_token_is(ptr %arg.tokens, i32 %start, i8 75, ptr @.str.class.name.def)\n  %is.def = icmp ne i32 %def, 0\n  br i1 %is.def, label %def.name, label %field.check\ndef.name:\n  %after.def = add i32 %start, 1\n  %operator = call i32 @csec_token_is(ptr %arg.tokens, i32 %after.def, i8 75, ptr @.str.class.name.operator)\n  %is.operator = icmp ne i32 %operator, 0\n  br i1 %is.operator, label %operator.name, label %plain.name\noperator.name:\n  %operator.token = add i32 %after.def, 1\n  %operator.text = call ptr @csec_token_text_at(ptr %arg.tokens, i32 %operator.token)\n  %operator.result = call ptr @csec_string_concat(ptr @.str.class.name.operator, ptr %operator.text)\n  ret ptr %operator.result\nplain.name:\n  %plain = call ptr @csec_token_text_at(ptr %arg.tokens, i32 %after.def)\n  ret ptr %plain\nfield.check:\n  %val = call i32 @csec_token_is(ptr %arg.tokens, i32 %start, i8 75, ptr @.str.class.name.val)\n  %var = call i32 @csec_token_is(ptr %arg.tokens, i32 %start, i8 75, ptr @.str.class.name.var)\n  %is.val = icmp ne i32 %val, 0\n  %is.var = icmp ne i32 %var, 0\n  %is.field = or i1 %is.val, %is.var\n  br i1 %is.field, label %field.name, label %invalid\nfield.name:\n  %after.field = add i32 %start, 1\n  %field = call ptr @csec_token_text_at(ptr %arg.tokens, i32 %after.field)\n  ret ptr %field\ninvalid:\n  ret ptr @.str.class.name.invalid\n}\n\n"
                    : std::strcmp(name, "lookupFunctionReturnType") == 0
                    ? "define ptr @lookupFunctionReturnType(ptr %arg.tokens, ptr %arg.name) {\nentry:\n  %ret = call ptr @csec_lookup_function_return_type(ptr %arg.tokens, ptr %arg.name)\n  ret ptr %ret\n}\n\n"
                    : "define ptr @generateSymbolTable(ptr %arg.tokens) {\nentry:\n  %ret = call ptr @csec_generate_symbol_table(ptr %arg.tokens)\n  ret ptr %ret\n}\n\n";
    } else if (name && (std::strcmp(name, "appendExpressionUntil") == 0 || std::strcmp(name, "statementKind") == 0 || std::strcmp(name, "expressionLeafKind") == 0 || std::strcmp(name, "statementHeaderExpression") == 0 || std::strcmp(name, "summarizePostfixExpression") == 0)) {
        definition = std::strcmp(name, "statementKind") == 0
            ? "declare ptr @csec_statement_kind(ptr, i32)\n\ndefine ptr @statementKind(ptr %arg.tokens, i32 %arg.ordinal) {\nentry:\n  %ret = call ptr @csec_statement_kind(ptr %arg.tokens, i32 %arg.ordinal)\n  ret ptr %ret\n}\n\n"
            : std::strcmp(name, "expressionLeafKind") == 0
                ? "@.str.leaf.empty = private unnamed_addr constant [6 x i8] c\"empty\\00\"\n@.str.leaf.integer = private unnamed_addr constant [8 x i8] c\"integer\\00\"\n@.str.leaf.float = private unnamed_addr constant [6 x i8] c\"float\\00\"\n@.str.leaf.string = private unnamed_addr constant [7 x i8] c\"string\\00\"\n@.str.leaf.regex = private unnamed_addr constant [6 x i8] c\"regex\\00\"\n@.str.leaf.char = private unnamed_addr constant [5 x i8] c\"char\\00\"\n@.str.leaf.bool = private unnamed_addr constant [5 x i8] c\"bool\\00\"\n@.str.leaf.identifier = private unnamed_addr constant [11 x i8] c\"identifier\\00\"\n@.str.leaf.unknown = private unnamed_addr constant [8 x i8] c\"unknown\\00\"\n\ndefine ptr @expressionLeafKind(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {\nentry:\n  %nonempty = icmp sgt i32 %arg.end, %arg.start\n  br i1 %nonempty, label %kind, label %empty\nkind:\n  %value = call i8 @csec_token_kind_at(ptr %arg.tokens, i32 %arg.start)\n  %is.integer = icmp eq i8 %value, 78\n  br i1 %is.integer, label %integer, label %float.check\nfloat.check:\n  %is.float = icmp eq i8 %value, 70\n  br i1 %is.float, label %float, label %string.check\nstring.check:\n  %is.string = icmp eq i8 %value, 83\n  br i1 %is.string, label %string, label %regex.check\nregex.check:\n  %is.regex = icmp eq i8 %value, 82\n  br i1 %is.regex, label %regex, label %char.check\nchar.check:\n  %is.char = icmp eq i8 %value, 67\n  br i1 %is.char, label %char, label %bool.check\nbool.check:\n  %is.bool = icmp eq i8 %value, 66\n  br i1 %is.bool, label %bool, label %identifier.check\nidentifier.check:\n  %is.identifier = icmp eq i8 %value, 73\n  br i1 %is.identifier, label %identifier, label %unknown\nempty:\n  ret ptr @.str.leaf.empty\ninteger:\n  ret ptr @.str.leaf.integer\nfloat:\n  ret ptr @.str.leaf.float\nstring:\n  ret ptr @.str.leaf.string\nregex:\n  ret ptr @.str.leaf.regex\nchar:\n  ret ptr @.str.leaf.char\nbool:\n  ret ptr @.str.leaf.bool\nidentifier:\n  ret ptr @.str.leaf.identifier\nunknown:\n  ret ptr @.str.leaf.unknown\n}\n\n"
                : std::strcmp(name, "statementHeaderExpression") == 0
                    ? "@.str.statement.header.empty = private unnamed_addr constant [1 x i8] c\"\\00\"\n\ndefine ptr @statementHeaderExpression(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {\nentry:\n  %open = call i32 @findStatementParenStart(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)\n  %close = call i32 @findStatementParenEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)\n  %has.open = icmp sge i32 %open, 0\n  %after.open = icmp sgt i32 %close, %open\n  %valid = and i1 %has.open, %after.open\n  br i1 %valid, label %body, label %empty\nbody:\n  %body.start = add i32 %open, 1\n  %ret = call ptr @appendExpressionUntil(ptr %arg.tokens, i32 %body.start, i32 %close)\n  ret ptr %ret\nempty:\n  ret ptr @.str.statement.header.empty\n}\n\n"
                    : std::strcmp(name, "summarizePostfixExpression") == 0
                        ? "@.str.postfix.summary.empty = private unnamed_addr constant [1 x i8] c\"\\00\"\n\ndefine ptr @summarizePostfixExpression(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {\nentry:\n  ret ptr @.str.postfix.summary.empty\n}\n\n"
                        : "define ptr @appendExpressionUntil(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {\nentry:\n  %ret = call ptr @csec_append_expression_until(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)\n  ret ptr %ret\n}\n\n";
    } else if (name && std::strcmp(name, "generateIRAssignment") == 0) {
        const std::string generated = llvmGenerateIRAssignmentDefinition();
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && std::strcmp(name, "generateIRExpression") == 0) {
        definition = "define ptr @generateIRExpression(ptr %arg.tokens, i32 %arg.rawStart, i32 %arg.rawEnd) {\nentry:\n  %start = call i32 @skipTrivia(ptr %arg.tokens, i32 %arg.rawStart)\n  %end = call i32 @trimExpressionEnd(ptr %arg.tokens, i32 %start, i32 %arg.rawEnd)\n  %nonempty = icmp sgt i32 %end, %start\n  br i1 %nonempty, label %classify, label %empty\nempty:\n  %empty.value = getelementptr inbounds [5 x i8], ptr @.str.ir.expr.void, i32 0, i32 0\n  ret ptr %empty.value\nclassify:\n  %type.name = call ptr @inferExpressionType(ptr %arg.tokens, i32 %start, i32 %end)\n  %ir.type = call ptr @irTypeName(ptr %type.name)\n  %op = call i32 @expressionTopLevelOperator(ptr %arg.tokens, i32 %start, i32 %end)\n  %has.op = icmp sgt i32 %op, %start\n  br i1 %has.op, label %binary, label %identifier.check\nbinary:\n  %op.text = call ptr @csec_token_text_at(ptr %arg.tokens, i32 %op)\n  %op.name = call ptr @irOperatorName(ptr %op.text)\n  %b1 = call ptr @csec_string_concat(ptr %op.name, ptr @.str.ir.expr.space)\n  %b2 = call ptr @csec_string_concat(ptr %b1, ptr %ir.type)\n  %b3 = call ptr @csec_string_concat(ptr %b2, ptr @.str.ir.expr.open)\n  %left = call ptr @appendExpressionUntil(ptr %arg.tokens, i32 %start, i32 %op)\n  %b4 = call ptr @csec_string_concat(ptr %b3, ptr %left)\n  %b5 = call ptr @csec_string_concat(ptr %b4, ptr @.str.ir.expr.middle)\n  %right.start = add i32 %op, 1\n  %right = call ptr @appendExpressionUntil(ptr %arg.tokens, i32 %right.start, i32 %end)\n  %b6 = call ptr @csec_string_concat(ptr %b5, ptr %right)\n  %b7 = call ptr @csec_string_concat(ptr %b6, ptr @.str.ir.expr.close)\n  ret ptr %b7\nidentifier.check:\n  %kind = call i8 @csec_token_kind_at(ptr %arg.tokens, i32 %start)\n  %is.identifier = icmp eq i8 %kind, 73\n  br i1 %is.identifier, label %call.check, label %fallback\ncall.check:\n  %next = add i32 %start, 1\n  %before.end = icmp slt i32 %next, %end\n  br i1 %before.end, label %open.check, label %single.check\nopen.check:\n  %is.open.raw = call i32 @csec_token_is(ptr %arg.tokens, i32 %next, i8 79, ptr @.str.ir.expr.paren.open)\n  %is.open = icmp ne i32 %is.open.raw, 0\n  br i1 %is.open, label %close.check, label %single.check\nclose.check:\n  %close = call i32 @findClosingToken(ptr %arg.tokens, i32 %next, i32 %end, ptr @.str.ir.expr.paren.open, ptr @.str.ir.expr.paren.close)\n  %last = sub i32 %end, 1\n  %is.call = icmp eq i32 %close, %last\n  br i1 %is.call, label %call, label %single.check\ncall:\n  %c1 = call ptr @csec_string_concat(ptr @.str.ir.expr.call, ptr %ir.type)\n  %c2 = call ptr @csec_string_concat(ptr %c1, ptr @.str.ir.expr.at)\n  %name = call ptr @csec_token_text_at(ptr %arg.tokens, i32 %start)\n  %c3 = call ptr @csec_string_concat(ptr %c2, ptr %name)\n  %c4 = call ptr @csec_string_concat(ptr %c3, ptr @.str.ir.expr.paren.open)\n  %args.start = add i32 %start, 2\n  %args = call ptr @appendExpressionUntil(ptr %arg.tokens, i32 %args.start, i32 %last)\n  %c5 = call ptr @csec_string_concat(ptr %c4, ptr %args)\n  %c6 = call ptr @csec_string_concat(ptr %c5, ptr @.str.ir.expr.paren.close)\n  ret ptr %c6\nsingle.check:\n  %single.end = add i32 %start, 1\n  %is.single = icmp eq i32 %end, %single.end\n  br i1 %is.single, label %single, label %fallback\nsingle:\n  %s1 = call ptr @csec_string_concat(ptr @.str.ir.expr.load, ptr %ir.type)\n  %s2 = call ptr @csec_string_concat(ptr %s1, ptr @.str.ir.expr.load.middle)\n  %single.name = call ptr @csec_token_text_at(ptr %arg.tokens, i32 %start)\n  %s3 = call ptr @csec_string_concat(ptr %s2, ptr %single.name)\n  ret ptr %s3\nfallback:\n  %f1 = call ptr @csec_string_concat(ptr %ir.type, ptr @.str.ir.expr.space)\n  %f2 = call ptr @appendExpressionUntil(ptr %arg.tokens, i32 %start, i32 %end)\n  %f3 = call ptr @csec_string_concat(ptr %f1, ptr %f2)\n  ret ptr %f3\n}\n\n@.str.ir.expr.void = private unnamed_addr constant [5 x i8] c\"void\\00\"\n@.str.ir.expr.space = private unnamed_addr constant [2 x i8] c\" \\00\"\n@.str.ir.expr.open = private unnamed_addr constant [3 x i8] c\" (\\00\"\n@.str.ir.expr.middle = private unnamed_addr constant [5 x i8] c\"), (\\00\"\n@.str.ir.expr.close = private unnamed_addr constant [2 x i8] c\")\\00\"\n@.str.ir.expr.paren.open = private unnamed_addr constant [2 x i8] c\"(\\00\"\n@.str.ir.expr.paren.close = private unnamed_addr constant [2 x i8] c\")\\00\"\n@.str.ir.expr.call = private unnamed_addr constant [6 x i8] c\"call \\00\"\n@.str.ir.expr.at = private unnamed_addr constant [2 x i8] c\"@\\00\"\n@.str.ir.expr.load = private unnamed_addr constant [6 x i8] c\"load \\00\"\n@.str.ir.expr.load.middle = private unnamed_addr constant [8 x i8] c\", ptr %\\00\"\n\n";
    } else if (name && std::strcmp(name, "irOperatorName") == 0) {
        definition = "define ptr @irOperatorName(ptr %arg.text) {\nentry:\n  %ret = call ptr @csec_ir_operator_name(ptr %arg.text)\n  ret ptr %ret\n}\n\n";
    } else if (name && std::strcmp(name, "expressionTopLevelOperator") == 0) {
        definition = "define i32 @expressionTopLevelOperator(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {\nentry:\n  %ret = call i32 @csec_expression_top_level_operator(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)\n  ret i32 %ret\n}\n\n";
    } else if (name && std::strcmp(name, "trimExpressionEnd") == 0) {
        definition = "define i32 @trimExpressionEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {\nentry:\n  br label %trim.loop\ntrim.loop:\n  %last = phi i32 [ %arg.end, %entry ], [ %previous, %trim.comment ]\n  %has.previous = icmp sgt i32 %last, %arg.start\n  br i1 %has.previous, label %trim.inspect, label %trim.check\ntrim.inspect:\n  %index = sub i32 %last, 1\n  %kind = call i8 @csec_token_kind_at(ptr %arg.tokens, i32 %index)\n  %is.comment = icmp eq i8 %kind, 77\n  br i1 %is.comment, label %trim.comment, label %trim.check\ntrim.comment:\n  %previous = sub i32 %last, 1\n  br label %trim.loop\ntrim.check:\n  %has.token = icmp sgt i32 %last, %arg.start\n  br i1 %has.token, label %trim.semicolon, label %trim.return\ntrim.semicolon:\n  %candidate = sub i32 %last, 1\n  %is.semicolon = call i32 @csec_token_is(ptr %arg.tokens, i32 %candidate, i8 79, ptr @.str.trim.semicolon)\n  %has.semicolon = icmp ne i32 %is.semicolon, 0\n  br i1 %has.semicolon, label %trim.without.semicolon, label %trim.return\ntrim.without.semicolon:\n  %result = sub i32 %last, 1\n  ret i32 %result\ntrim.return:\n  ret i32 %last\n}\n\n@.str.trim.semicolon = private unnamed_addr constant [2 x i8] c\";\\00\"\n\n";
    } else if (name && std::strcmp(name, "findTokenTextInRange") == 0) {
        definition = "define i32 @findTokenTextInRange(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, ptr %arg.text) {\nentry:\n  %ret = call i32 @csec_find_token_text_in_range(ptr %arg.tokens, i32 %arg.start, i32 %arg.end, ptr %arg.text)\n  ret i32 %ret\n}\n\n";
    } else if (name && std::strcmp(name, "findClosingToken") == 0) {
        definition = "define i32 @findClosingToken(ptr %arg.tokens, i32 %arg.openOrdinal, i32 %arg.end, ptr %arg.openText, ptr %arg.closeText) {\nentry:\n  %ret = call i32 @csec_find_closing_token(ptr %arg.tokens, i32 %arg.openOrdinal, i32 %arg.end, ptr %arg.openText, ptr %arg.closeText)\n  ret i32 %ret\n}\n\n";
    } else if (name && std::strcmp(name, "findStatementParenStart") == 0) {
        definition = "define i32 @findStatementParenStart(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {\nentry:\n  %ret = call i32 @csec_find_statement_paren_start(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)\n  ret i32 %ret\n}\n\n";
    } else if (name && std::strcmp(name, "findStatementParenEnd") == 0) {
        definition = "define i32 @findStatementParenEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {\nentry:\n  %ret = call i32 @csec_find_statement_paren_end(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)\n  ret i32 %ret\n}\n\n";
    } else if (name && std::strcmp(name, "findStatementBlockStart") == 0) {
        definition = "define i32 @findStatementBlockStart(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {\nentry:\n  %ret = call i32 @csec_find_statement_block_start(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)\n  ret i32 %ret\n}\n\n";
    } else if (name && std::strcmp(name, "findStatementBlockEnd") == 0) {
        definition = "define i32 @findStatementBlockEnd(ptr %arg.tokens, i32 %arg.start, i32 %arg.end) {\nentry:\n  %ret = call i32 @csec_find_statement_block_end(ptr %arg.tokens, i32 %arg.start, i32 %arg.end)\n  ret i32 %ret\n}\n\n";
    } else if (name && (std::strcmp(name, "advanceTopLevelDecl") == 0 || std::strcmp(name, "advanceTopLevelDeclSlow") == 0)) {
        const char* functionName = std::strcmp(name, "advanceTopLevelDecl") == 0 ? "advanceTopLevelDecl" : "advanceTopLevelDeclSlow";
        std::string generated = "define i32 @" + std::string(functionName) + "(ptr %arg.tokens, i32 %arg.ordinal) {\nentry:\n  %ret = call i32 @csec_advance_top_level_decl(ptr %arg.tokens, i32 %arg.ordinal)\n  ret i32 %ret\n}\n\n";
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && (std::strcmp(name, "findDeclBodyStart") == 0 || std::strcmp(name, "findDeclBodyStartSlow") == 0)) {
        const char* functionName = std::strcmp(name, "findDeclBodyStart") == 0 ? "findDeclBodyStart" : "findDeclBodyStartSlow";
        std::string generated = "define i32 @" + std::string(functionName) + "(ptr %arg.tokens, i32 %arg.ordinal) {\nentry:\n  %ret = call i32 @csec_find_decl_body_start(ptr %arg.tokens, i32 %arg.ordinal)\n  ret i32 %ret\n}\n\n";
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && (std::strcmp(name, "findDeclBodyEnd") == 0 || std::strcmp(name, "findDeclBodyEndSlow") == 0)) {
        const char* functionName = std::strcmp(name, "findDeclBodyEnd") == 0 ? "findDeclBodyEnd" : "findDeclBodyEndSlow";
        std::string generated = "define i32 @" + std::string(functionName) + "(ptr %arg.tokens, i32 %arg.bodyStart) {\nentry:\n  %ret = call i32 @csec_find_decl_body_end(ptr %arg.tokens, i32 %arg.bodyStart)\n  ret i32 %ret\n}\n\n";
        char* result = static_cast<char*>(std::malloc(generated.size() + 1));
        if (!result) return nullptr;
        std::memcpy(result, generated.c_str(), generated.size() + 1);
        return result;
    } else if (name && std::strcmp(name, "isAlpha") == 0) {
        definition = "define i1 @isAlpha(i8 %arg.ch) {\nentry:\n  %lower = icmp sge i8 %arg.ch, 97\n  %lower.end = icmp sle i8 %arg.ch, 122\n  %lower.match = and i1 %lower, %lower.end\n  %upper = icmp sge i8 %arg.ch, 65\n  %upper.end = icmp sle i8 %arg.ch, 90\n  %upper.match = and i1 %upper, %upper.end\n  %ret = or i1 %lower.match, %upper.match\n  ret i1 %ret\n}\n\n";
    } else if (name && std::strcmp(name, "isIdentifierStart") == 0) {
        definition = "define i1 @isIdentifierStart(i8 %arg.ch) {\nentry:\n  %alpha = call i1 @isAlpha(i8 %arg.ch)\n  %underscore = icmp eq i8 %arg.ch, 95\n  %ret = or i1 %alpha, %underscore\n  ret i1 %ret\n}\n\n";
    } else if (name && std::strcmp(name, "isIdentifierPart") == 0) {
        definition = "define i1 @isIdentifierPart(i8 %arg.ch) {\nentry:\n  %start = call i1 @isIdentifierStart(i8 %arg.ch)\n  %digit = call i1 @isDigit(i8 %arg.ch)\n  %ret = or i1 %start, %digit\n  ret i1 %ret\n}\n\n";
    }
    const size_t length = std::strlen(definition);
    char* result = static_cast<char*>(std::malloc(length + 1));
    if (!result) return nullptr;
    std::memcpy(result, definition, length + 1);
    return result;
}

int csec_lex_line_comment(const char* source, int index) {
    if (!source || index < 0) return index;
    int cursor = index + 2;
    while (source[cursor] && source[cursor] != '\n') ++cursor;
    return cursor;
}

int csec_lex_block_comment(const char* source, int index) {
    if (!source || index < 0) return index;
    int cursor = index + 2, depth = 1;
    while (source[cursor] && source[cursor + 1] && depth > 0) {
        if (source[cursor] == '/' && source[cursor + 1] == '*') { ++depth; cursor += 2; }
        else if (source[cursor] == '*' && source[cursor + 1] == '/') { --depth; cursor += 2; }
        else ++cursor;
    }
    return cursor;
}

long long csec_string_builder_new(void) {
    auto* builder = new StringBuilder();
    builder->capacity = kStringBuilderGrowQuantum;
    builder->data = static_cast<char*>(std::malloc(builder->capacity));
    if (!builder->data) {
        delete builder;
        return 0;
    }
    builder->data[0] = '\0';
    return reinterpret_cast<long long>(builder);
}

long long csec_string_builder_new_file(const char* path) {
    if (!path) return 0;
    auto* builder = new StringBuilder();
    builder->file = std::fopen(path, "wb");
    if (!builder->file) {
        delete builder;
        return 0;
    }
    std::setvbuf(builder->file, nullptr, _IOFBF, kStringBuilderGrowQuantum);
    return reinterpret_cast<long long>(builder);
}

int csec_string_builder_append(long long handle, const char* text) {
    auto* builder = reinterpret_cast<StringBuilder*>(handle);
    if (!builder) return -1;

    const char* value = text ? text : "";
    size_t valueLen = std::strlen(value);
    if (builder->file) {
        if (std::fwrite(value, 1, valueLen, builder->file) != valueLen) return -1;
        return 0;
    }
    if (!builder->data) return -1;
    size_t needed = builder->length + valueLen + 1;
    if (needed > builder->capacity) {
        size_t nextCapacity = roundStringBuilderCapacity(needed);
        char* next = static_cast<char*>(std::realloc(builder->data, nextCapacity));
        if (!next) return -1;
        builder->data = next;
        builder->capacity = nextCapacity;
    }

    std::memcpy(builder->data + builder->length, value, valueLen);
    builder->length += valueLen;
    builder->data[builder->length] = '\0';
    return 0;
}

char* csec_string_builder_finish(long long handle) {
    auto* builder = reinterpret_cast<StringBuilder*>(handle);
    if (!builder) {
        char* empty = static_cast<char*>(std::malloc(1));
        if (empty) empty[0] = '\0';
        return empty;
    }

    char* result = builder->data;
    builder->data = nullptr;
    delete builder;
    if (!result) {
        char* empty = static_cast<char*>(std::malloc(1));
        if (empty) empty[0] = '\0';
        return empty;
    }
    return result;
}

int csec_string_builder_write_to_file(long long handle, const char* path) {
    auto* builder = reinterpret_cast<StringBuilder*>(handle);
    if (!builder || !path) {
        return -1;
    }

    if (builder->file) {
        int closeResult = std::fclose(builder->file);
        builder->file = nullptr;
        delete builder;
        return closeResult == 0 ? 0 : -1;
    }

    FILE* file = std::fopen(path, "wb");
    if (!file) {
        if (builder->data) {
            std::free(builder->data);
            builder->data = nullptr;
        }
        delete builder;
        return -1;
    }

    size_t written = 0;
    if (builder->data && builder->length > 0) {
        written = std::fwrite(builder->data, 1, builder->length, file);
    }
    int closeResult = std::fclose(file);
    int ok = (written == builder->length && closeResult == 0) ? 0 : -1;

    if (builder->data) {
        std::free(builder->data);
        builder->data = nullptr;
    }
    delete builder;
    return ok;
}

char* csec_token_append_owned(const char* tokens, char kind, const char* text) {
    const char* lhs = tokens ? tokens : "";
    const char* tokenText = text ? text : "";
    size_t lhsLen = std::strlen(lhs);
    size_t textLen = std::strlen(tokenText);
    char* result = static_cast<char*>(std::malloc(lhsLen + textLen + 4));
    if (!result) return nullptr;

    std::memcpy(result, lhs, lhsLen);
    result[lhsLen] = kind;
    result[lhsLen + 1] = ':';
    std::memcpy(result + lhsLen + 2, tokenText, textLen);
    result[lhsLen + textLen + 2] = '\n';
    result[lhsLen + textLen + 3] = '\0';

    if (tokens && lhsLen > 0) {
        clearTokenCachesFor(tokens);
    }
    return result;
}

long long csec_token_builder_new(void) {
    auto* builder = new TokenBuilder();
    builder->capacity = 4096;
    builder->data = static_cast<char*>(std::malloc(builder->capacity));
    if (!builder->data) {
        delete builder;
        return 0;
    }
    builder->data[0] = '\0';
    return reinterpret_cast<long long>(builder);
}

int csec_token_builder_append(long long handle, char kind, const char* text) {
    auto* builder = reinterpret_cast<TokenBuilder*>(handle);
    if (!builder || !builder->data) return -1;

    const char* tokenText = text ? text : "";
    size_t textLen = std::strlen(tokenText);
    size_t needed = builder->length + textLen + 4;
    if (needed > builder->capacity) {
        size_t nextCapacity = builder->capacity;
        while (nextCapacity < needed) {
            nextCapacity *= 2;
        }
        char* next = static_cast<char*>(std::realloc(builder->data, nextCapacity));
        if (!next) return -1;
        builder->data = next;
        builder->capacity = nextCapacity;
    }

    builder->data[builder->length] = kind;
    builder->data[builder->length + 1] = ':';
    std::memcpy(builder->data + builder->length + 2, tokenText, textLen);
    builder->length += textLen + 2;
    builder->data[builder->length] = '\n';
    builder->length += 1;
    builder->data[builder->length] = '\0';
    return 0;
}

char* csec_token_builder_finish(long long handle) {
    auto* builder = reinterpret_cast<TokenBuilder*>(handle);
    if (!builder) {
        char* empty = static_cast<char*>(std::malloc(1));
        if (empty) empty[0] = '\0';
        return empty;
    }

    char* result = builder->data;
    builder->data = nullptr;
    delete builder;
    if (!result) {
        char* empty = static_cast<char*>(std::malloc(1));
        if (empty) empty[0] = '\0';
        return empty;
    }
    return result;
}

}

static bool csec_lex_starts_with(const std::string& source, size_t index, const char* text) {
    size_t len = std::strlen(text);
    return index + len <= source.size() && source.compare(index, len, text) == 0;
}

static bool csec_lex_is_alpha(char ch) {
    unsigned char value = static_cast<unsigned char>(ch);
    return std::isalpha(value) != 0;
}

static bool csec_lex_is_digit(char ch) {
    unsigned char value = static_cast<unsigned char>(ch);
    return std::isdigit(value) != 0;
}

static bool csec_lex_is_identifier_start(char ch) {
    return csec_lex_is_alpha(ch) || ch == '_';
}

static bool csec_lex_is_identifier_part(char ch) {
    return csec_lex_is_identifier_start(ch) || csec_lex_is_digit(ch);
}

static bool csec_lex_is_keyword(const std::string& text) {
    static const char* const keywords[] = {
        "as", "break", "case", "class", "constexpr", "continue", "def", "else",
        "external", "false", "filter", "for", "if", "import", "in", "map",
        "match", "new", "object", "operator", "override", "pmap", "preduce",
        "reduce", "return", "super", "template", "this", "true", "typename",
        "unatomic", "unsafe", "val", "var", "while", "xor", "and", "or",
        "to", "until", "inner", "outer", "tensor", "box", "extends", "mut",
        "null", "ode", "molecule", "cfd", "protein", "cpu", "openmp", "gpu",
        "simd"
    };
    for (const char* keyword : keywords) {
        if (text == keyword) return true;
    }
    return false;
}

static size_t csec_lex_line_comment_end(const std::string& source, size_t index) {
    size_t cursor = index + 2;
    while (cursor < source.size() && source[cursor] != '\n') {
        ++cursor;
    }
    return cursor;
}

static size_t csec_lex_block_comment_end(const std::string& source, size_t index) {
    size_t cursor = index + 2;
    int depth = 1;
    while (cursor + 1 < source.size() && depth > 0) {
        if (csec_lex_starts_with(source, cursor, "/*")) {
            ++depth;
            cursor += 2;
        } else if (csec_lex_starts_with(source, cursor, "*/")) {
            --depth;
            cursor += 2;
        } else {
            ++cursor;
        }
    }
    return cursor;
}

static size_t csec_lex_quoted_end(const std::string& source, size_t index) {
    char quote = source[index];
    size_t cursor = index + 1;
    while (cursor < source.size() && source[cursor] != quote) {
        if (source[cursor] == '\\' && cursor + 1 < source.size()) {
            cursor += 2;
        } else {
            ++cursor;
        }
    }
    if (cursor < source.size()) return cursor + 1;
    return cursor;
}

static size_t csec_lex_identifier_end(const std::string& source, size_t index) {
    size_t cursor = index + 1;
    while (cursor < source.size() && csec_lex_is_identifier_part(source[cursor])) {
        ++cursor;
    }
    return cursor;
}

static size_t csec_lex_number_end(const std::string& source, size_t index) {
    size_t cursor = index;
    if (csec_lex_starts_with(source, cursor, "0x") || csec_lex_starts_with(source, cursor, "0X") ||
        csec_lex_starts_with(source, cursor, "0b") || csec_lex_starts_with(source, cursor, "0B") ||
        csec_lex_starts_with(source, cursor, "0o") || csec_lex_starts_with(source, cursor, "0O")) {
        cursor += 2;
    }
    while (cursor < source.size() &&
           (csec_lex_is_digit(source[cursor]) || csec_lex_is_alpha(source[cursor]) ||
            source[cursor] == '_' || source[cursor] == '.')) {
        ++cursor;
    }
    return cursor;
}

static size_t csec_lex_operator_width(const std::string& source, size_t index) {
    static const char* const operators[] = {
        "[@", "=>", "<-", "->", "<=", ">=", "==", "&&", "||", "++", "--",
        "!=", "+=", "-=", "*=", "/=", "%=", "<<", ">>", "..", "$$", "**"
    };
    for (const char* op : operators) {
        if (csec_lex_starts_with(source, index, op)) return 2;
    }
    return 1;
}

static std::string csec_lex_slice(const std::string& source, size_t start, size_t end) {
    if (end <= start || start >= source.size()) return std::string();
    if (end > source.size()) end = source.size();
    return source.substr(start, end - start);
}

static std::string csec_lex_repair_leading_r_token(const std::string& text) {
    if (text == "eturn") return "return";
    if (text == "atio") return "ratio";
    if (text == "educe") return "reduce";
    if (text == "ange") return "range";
    if (text == "egex") return "regex";
    if (text == "Regex") return "Regex";
    return text;
}

extern "C" {

char* csec_tokenize_source(const char* sourceText) {
    std::string source = sourceText ? sourceText : "";
    long long builder = csec_token_builder_new();
    if (!builder) {
        char* empty = static_cast<char*>(std::malloc(1));
        if (empty) empty[0] = '\0';
        return empty;
    }

    size_t cursor = 0;
    while (cursor < source.size()) {
        char ch = source[cursor];
        if (ch == ' ' || ch == '\n' || ch == '\r' || ch == '\t') {
            ++cursor;
        } else if (csec_lex_starts_with(source, cursor, "//")) {
            cursor = csec_lex_line_comment_end(source, cursor);
        } else if (csec_lex_starts_with(source, cursor, "/*")) {
            cursor = csec_lex_block_comment_end(source, cursor);
        } else if ((ch == 'r' || ch == 'R') && cursor + 1 < source.size() &&
                   csec_lex_is_identifier_part(source[cursor + 1])) {
            size_t end = csec_lex_identifier_end(source, cursor);
            std::string text(1, ch);
            text += csec_lex_slice(source, cursor + 1, end);
            text = csec_lex_repair_leading_r_token(text);
            char kind = (text == "true" || text == "false") ? 'B' : (csec_lex_is_keyword(text) ? 'K' : 'I');
            csec_token_builder_append(builder, kind, text.c_str());
            cursor = end;
        } else if ((ch == 'r' || ch == 'R') && cursor + 1 < source.size() &&
                   !csec_lex_is_identifier_part(source[cursor + 1]) && source[cursor + 1] == '"') {
            size_t end = csec_lex_quoted_end(source, cursor + 1);
            std::string text = csec_lex_slice(source, cursor + 2, end > 0 ? end - 1 : end);
            csec_token_builder_append(builder, 'R', text.c_str());
            cursor = end;
        } else if ((ch == 'u' || ch == 'U') && cursor + 1 < source.size() && source[cursor + 1] == '"') {
            size_t end = csec_lex_quoted_end(source, cursor + 1);
            std::string text = csec_lex_slice(source, cursor + 2, end > 0 ? end - 1 : end);
            csec_token_builder_append(builder, 'S', text.c_str());
            cursor = end;
        } else if (ch == '"') {
            size_t end = csec_lex_quoted_end(source, cursor);
            std::string text = csec_lex_slice(source, cursor + 1, end > 0 ? end - 1 : end);
            csec_token_builder_append(builder, 'S', text.c_str());
            cursor = end;
        } else if (ch == '\'') {
            size_t end = csec_lex_quoted_end(source, cursor);
            std::string text = csec_lex_slice(source, cursor + 1, end > 0 ? end - 1 : end);
            csec_token_builder_append(builder, 'C', text.c_str());
            cursor = end;
        } else if (csec_lex_is_digit(ch)) {
            size_t end = csec_lex_number_end(source, cursor);
            std::string text = csec_lex_slice(source, cursor, end);
            char kind = (text.find('.') != std::string::npos || text.find('e') != std::string::npos ||
                         text.find('E') != std::string::npos) ? 'F' : 'N';
            csec_token_builder_append(builder, kind, text.c_str());
            cursor = end;
        } else if (csec_lex_is_identifier_start(ch)) {
            size_t end = csec_lex_identifier_end(source, cursor);
            std::string text = csec_lex_slice(source, cursor, end);
            if (ch == 'r' || ch == 'R') {
                text = std::string(1, ch) + csec_lex_slice(source, cursor + 1, end);
            }
            text = csec_lex_repair_leading_r_token(text);
            char kind = (text == "true" || text == "false") ? 'B' : (csec_lex_is_keyword(text) ? 'K' : 'I');
            csec_token_builder_append(builder, kind, text.c_str());
            cursor = end;
        } else {
            size_t width = csec_lex_operator_width(source, cursor);
            std::string text = csec_lex_slice(source, cursor, cursor + width);
            csec_token_builder_append(builder, 'O', text.c_str());
            cursor += width;
        }
    }

    csec_token_builder_append(builder, 'E', "<eof>");
    return csec_token_builder_finish(builder);
}

char csec_token_kind_at(const char* tokens, int ordinal) {
    const char* value = tokens ? tokens : "";
    if (ordinal < 0) return 'E';
    const auto& starts = tokenLineStarts(value);
    if (static_cast<size_t>(ordinal) >= starts.size()) {
        return 'E';
    }
    int start = starts[static_cast<size_t>(ordinal)];
    return value[start] == '\0' ? 'E' : value[start];
}

char* csec_token_text_at(const char* tokens, int ordinal) {
    const char* value = tokens ? tokens : "";
    if (ordinal < 0) {
        return const_cast<char*>("");
    }

    const auto& texts = tokenTexts(value);
    if (static_cast<size_t>(ordinal) >= texts.size()) {
        return const_cast<char*>("");
    }
    return const_cast<char*>(texts[static_cast<size_t>(ordinal)].c_str());
}

static bool csec_native_token_is(const char* tokens, int ordinal, char kind, const char* text) {
    if (csec_token_kind_at(tokens, ordinal) != kind) return false;
    const char* tokenText = csec_token_text_at(tokens, ordinal);
    return std::strcmp(tokenText ? tokenText : "", text ? text : "") == 0;
}

int csec_token_is(const char* tokens, int ordinal, char kind, const char* text) {
    return csec_native_token_is(tokens, ordinal, kind, text) ? 1 : 0;
}

static char* csec_copy_literal(const char* text) {
    return const_cast<char*>(text);
}

char* csec_statement_kind(const char* tokens, int ordinal) {
    const char kind = csec_token_kind_at(tokens, ordinal);
    const char* text = csec_token_text_at(tokens, ordinal);
    if (kind == 'K') {
        if (std::strcmp(text, "return") == 0) return csec_copy_literal("return");
        if (std::strcmp(text, "val") == 0) return csec_copy_literal("value");
        if (std::strcmp(text, "var") == 0) return csec_copy_literal("variable");
        if (std::strcmp(text, "if") == 0) return csec_copy_literal("if");
        if (std::strcmp(text, "for") == 0) return csec_copy_literal("for");
        if (std::strcmp(text, "while") == 0) return csec_copy_literal("while");
        if (std::strcmp(text, "map") == 0) return csec_copy_literal("map");
        if (std::strcmp(text, "pmap") == 0) return csec_copy_literal("pmap");
        if (std::strcmp(text, "reduce") == 0) return csec_copy_literal("reduce");
        if (std::strcmp(text, "preduce") == 0) return csec_copy_literal("preduce");
        if (std::strcmp(text, "filter") == 0) return csec_copy_literal("filter");
        if (std::strcmp(text, "def") == 0) return csec_copy_literal("function");
        if (std::strcmp(text, "object") == 0) return csec_copy_literal("object");
        if (std::strcmp(text, "unsafe") == 0) return csec_copy_literal("unsafe");
        if (std::strcmp(text, "unatomic") == 0) return csec_copy_literal("unatomic");
        if (std::strcmp(text, "constexpr") == 0) return csec_copy_literal("constexpr");
    }
    if (kind == 'E') return csec_copy_literal("eof");
    return csec_copy_literal("expression");
}

char* csec_expression_leaf_kind(const char* tokens, int start, int end) {
    if (end <= start) return csec_copy_literal("empty");
    switch (csec_token_kind_at(tokens, start)) {
        case 'N': return csec_copy_literal("integer");
        case 'F': return csec_copy_literal("float");
        case 'S': return csec_copy_literal("string");
        case 'R': return csec_copy_literal("regex");
        case 'C': return csec_copy_literal("char");
        case 'B': return csec_copy_literal("bool");
        case 'I': return csec_copy_literal("identifier");
        case 'K': {
            const char* text = csec_token_text_at(tokens, start);
            if (std::strcmp(text, "this") == 0) return csec_copy_literal("this");
            if (std::strcmp(text, "super") == 0) return csec_copy_literal("super");
            if (std::strcmp(text, "new") == 0) return csec_copy_literal("new");
            if (std::strcmp(text, "match") == 0) return csec_copy_literal("match");
            break;
        }
        default: break;
    }
    return csec_copy_literal("unknown");
}

char* csec_declared_value_type(const char* tokens, int declStart, int declEnd) {
    for (int cursor = declStart; cursor < declEnd && csec_token_kind_at(tokens, cursor) != 'E'; ++cursor) {
        if (csec_native_token_is(tokens, cursor, 'O', ":")) {
            return csec_token_text_at(tokens, cursor + 1);
        }
        if (csec_native_token_is(tokens, cursor, 'O', "=") || csec_native_token_is(tokens, cursor, 'O', ";")) {
            return csec_copy_literal("infer");
        }
    }
    return csec_copy_literal("infer");
}

char* csec_infer_expression_type(const char* tokens, int start, int end) {
    while (start < end && csec_token_kind_at(tokens, start) == 'M') ++start;
    while (end > start && csec_token_kind_at(tokens, end - 1) == 'M') --end;
    if (end <= start) return csec_copy_literal("Unit");
    switch (csec_token_kind_at(tokens, start)) {
        case 'N': return csec_copy_literal("Int");
        case 'F': return csec_copy_literal("Double");
        case 'S': return csec_copy_literal("String");
        case 'C': return csec_copy_literal("Char");
        case 'B': return csec_copy_literal("Boolean");
        case 'R': return csec_copy_literal("Regex");
        case 'I': {
            const char* name = csec_token_text_at(tokens, start);
            char* cached = csec_lookup_function_return_type(tokens, name);
            if (cached && std::strcmp(cached, "unknown") != 0) return cached;
            break;
        }
        default: break;
    }
    return csec_copy_literal("unknown");
}

char* csec_declared_local_type(const char* tokens, int start, int end) {
    for (int cursor = start; cursor < end && csec_token_kind_at(tokens, cursor) != 'E'; ++cursor) {
        if (csec_native_token_is(tokens, cursor, 'O', ":")) return csec_token_text_at(tokens, cursor + 1);
        if (csec_native_token_is(tokens, cursor, 'O', "=") || csec_native_token_is(tokens, cursor, 'O', ";")) break;
    }
    return csec_copy_literal("");
}

static int csec_class_member_start(const char* tokens, int ordinal) {
    if (csec_native_token_is(tokens, ordinal, 'K', "override") ||
        csec_native_token_is(tokens, ordinal, 'K', "unsafe") ||
        csec_native_token_is(tokens, ordinal, 'K', "constexpr")) return ordinal + 1;
    return ordinal;
}

char* csec_class_member_kind(const char* tokens, int ordinal) {
    const int start = csec_class_member_start(tokens, ordinal);
    if (csec_native_token_is(tokens, start, 'K', "def")) return csec_copy_literal("method");
    if (csec_native_token_is(tokens, start, 'K', "val")) return csec_copy_literal("field");
    if (csec_native_token_is(tokens, start, 'K', "var")) return csec_copy_literal("mutable-field");
    return csec_copy_literal("member");
}

char* csec_class_member_name(const char* tokens, int ordinal) {
    const int start = csec_class_member_start(tokens, ordinal);
    if (csec_native_token_is(tokens, start, 'K', "def")) {
        if (csec_native_token_is(tokens, start + 1, 'K', "operator")) {
            return csec_string_concat("operator", csec_token_text_at(tokens, start + 2));
        }
        return csec_token_text_at(tokens, start + 1);
    }
    if (csec_native_token_is(tokens, start, 'K', "val") || csec_native_token_is(tokens, start, 'K', "var")) {
        return csec_token_text_at(tokens, start + 1);
    }
    return csec_copy_literal("<member>");
}

int csec_parse_return_integer_in_range(const char* tokens, int start, int end) {
    for (int cursor = start; cursor < end && csec_token_kind_at(tokens, cursor) != 'E'; ++cursor) {
        if (csec_native_token_is(tokens, cursor, 'K', "return") && csec_token_kind_at(tokens, cursor + 1) == 'N') {
            return csec_to_int(csec_token_text_at(tokens, cursor + 1));
        }
    }
    return 0;
}

static int csec_native_find_closing_token(const char* tokens, int openOrdinal, int limit, const char* openText, const char* closeText) {
    int depth = 0;
    int cursor = openOrdinal;
    while (cursor < limit && csec_token_kind_at(tokens, cursor) != 'E') {
        const char* text = csec_token_text_at(tokens, cursor);
        if (std::strcmp(text, openText) == 0) {
            ++depth;
        } else if (std::strcmp(text, closeText) == 0) {
            --depth;
            if (depth == 0) return cursor;
        }
        ++cursor;
    }
    return -1;
}

int csec_advance_statement(const char* tokens, int ordinal, int bodyEnd) {
    int cursor = ordinal;
    int paren = 0;
    int brace = 0;
    int bracket = 0;
    while (cursor < bodyEnd && csec_token_kind_at(tokens, cursor) != 'E') {
        const char* text = csec_token_text_at(tokens, cursor);
        if (csec_token_kind_at(tokens, cursor) == 'O') {
            if (std::strcmp(text, "(") == 0) {
                ++paren;
            }
            if (std::strcmp(text, ")") == 0) {
                --paren;
            }
            if (std::strcmp(text, "{") == 0) {
                ++brace;
            }
            if (std::strcmp(text, "}") == 0) {
                if (brace == 0 && paren == 0 && bracket == 0) {
                    return cursor;
                }
                --brace;
                if (brace == 0 && paren == 0 && bracket == 0) {
                    int possibleElse = cursor + 1;
                    while (possibleElse < bodyEnd && csec_token_kind_at(tokens, possibleElse) == 'M') {
                        ++possibleElse;
                    }
                    if (csec_native_token_is(tokens, ordinal, 'K', "if") &&
                        csec_native_token_is(tokens, possibleElse, 'K', "else")) {
                        int afterElse = possibleElse + 1;
                        while (afterElse < bodyEnd && csec_token_kind_at(tokens, afterElse) == 'M') {
                            ++afterElse;
                        }
                        if (csec_native_token_is(tokens, afterElse, 'K', "if")) {
                            return csec_advance_statement(tokens, afterElse, bodyEnd);
                        }
                        if (csec_native_token_is(tokens, afterElse, 'O', "{")) {
                            int elseEnd = csec_native_find_closing_token(tokens, afterElse, bodyEnd, "{", "}");
                            if (elseEnd > afterElse) return elseEnd + 1;
                        }
                    }
                    return cursor + 1;
                }
            }
            if (std::strcmp(text, "[") == 0) {
                ++bracket;
            }
            if (std::strcmp(text, "]") == 0) {
                --bracket;
            }
            if (std::strcmp(text, ";") == 0 && brace == 0 && paren == 0 && bracket == 0) {
                return cursor + 1;
            }
        }
        ++cursor;
    }
    return cursor;
}

static bool csec_native_starts_top_level_declaration(const char* tokens, int ordinal) {
    char kind = csec_token_kind_at(tokens, ordinal);
    const char* text = csec_token_text_at(tokens, ordinal);
    if (kind == 'E') return true;
    if (kind == 'O' && std::strcmp(text, "[@") == 0) return true;
    if (kind != 'K') return false;
    return std::strcmp(text, "import") == 0 || std::strcmp(text, "class") == 0 ||
           std::strcmp(text, "object") == 0 || std::strcmp(text, "external") == 0 ||
           std::strcmp(text, "def") == 0 || std::strcmp(text, "template") == 0 ||
           std::strcmp(text, "val") == 0 || std::strcmp(text, "var") == 0 ||
           std::strcmp(text, "unsafe") == 0 || std::strcmp(text, "unatomic") == 0 ||
           std::strcmp(text, "constexpr") == 0;
}

int csec_starts_top_level_declaration(const char* tokens, int ordinal) {
    return csec_native_starts_top_level_declaration(tokens, ordinal) ? 1 : 0;
}

int csec_validate_top_level(const char* tokens) {
    int cursor = 0;
    while (csec_token_kind_at(tokens, cursor) == 'M') ++cursor;
    int paren = 0;
    int brace = 0;
    int bracket = 0;
    bool expectingDecl = true;
    while (csec_token_kind_at(tokens, cursor) != 'E') {
        char kind = csec_token_kind_at(tokens, cursor);
        const char* text = csec_token_text_at(tokens, cursor);
        if (expectingDecl && paren == 0 && brace == 0 && bracket == 0 &&
            !csec_native_starts_top_level_declaration(tokens, cursor)) {
            return 0;
        }
        if (expectingDecl && paren == 0 && brace == 0 && bracket == 0) expectingDecl = false;
        if (kind == 'O') {
            if (std::strcmp(text, "(") == 0) ++paren;
            if (std::strcmp(text, ")") == 0) --paren;
            if (std::strcmp(text, "{") == 0) ++brace;
            if (std::strcmp(text, "}") == 0) {
                --brace;
                if (brace == 0 && paren == 0 && bracket == 0) expectingDecl = true;
            }
            if (std::strcmp(text, "[") == 0) ++bracket;
            if (std::strcmp(text, "]") == 0) --bracket;
            if (std::strcmp(text, ";") == 0 && brace == 0 && paren == 0 && bracket == 0) expectingDecl = true;
        }
        ++cursor;
        while (csec_token_kind_at(tokens, cursor) == 'M') ++cursor;
    }
    return 1;
}

char* csec_top_level_decl_kind(const char* tokens, int ordinal) {
    for (;;) {
        const char* text = csec_token_text_at(tokens, ordinal);
        const char kind = csec_token_kind_at(tokens, ordinal);
        if (kind == 'O' && std::strcmp(text, "[@") == 0) return const_cast<char*>("attribute");
        if (kind != 'K') return const_cast<char*>("unknown");
        if (std::strcmp(text, "external") == 0) {
            const char* next = csec_token_text_at(tokens, ordinal + 1);
            if (std::strcmp(next, "class") == 0) return const_cast<char*>("external-class");
            if (std::strcmp(next, "object") == 0) return const_cast<char*>("external-object");
            if (std::strcmp(next, "def") == 0) return const_cast<char*>("external-function");
            return const_cast<char*>("external");
        }
        if (std::strcmp(text, "unsafe") == 0 || std::strcmp(text, "unatomic") == 0 ||
            std::strcmp(text, "constexpr") == 0) {
            ++ordinal;
            continue;
        }
        if (std::strcmp(text, "template") == 0) return const_cast<char*>("template");
        if (std::strcmp(text, "import") == 0) return const_cast<char*>("import");
        if (std::strcmp(text, "class") == 0) return const_cast<char*>("class");
        if (std::strcmp(text, "object") == 0) return const_cast<char*>("object");
        if (std::strcmp(text, "def") == 0) return const_cast<char*>("function");
        if (std::strcmp(text, "val") == 0) return const_cast<char*>("value");
        if (std::strcmp(text, "var") == 0) return const_cast<char*>("variable");
        return const_cast<char*>("unknown");
    }
}

char* csec_top_level_decl_name(const char* tokens, int ordinal) {
    const char* kind = csec_top_level_decl_kind(tokens, ordinal);
    if (std::strcmp(kind, "external-class") == 0 || std::strcmp(kind, "external-object") == 0 ||
        std::strcmp(kind, "external-function") == 0) {
        return csec_top_level_decl_name(tokens, ordinal + 1);
    }
    if (std::strcmp(kind, "template") == 0) {
        int depth = 0;
        for (int cursor = ordinal + 1; csec_token_kind_at(tokens, cursor) != 'E'; ++cursor) {
            const char* text = csec_token_text_at(tokens, cursor);
            if (std::strcmp(text, "<") == 0) ++depth;
            if (std::strcmp(text, ">") == 0 && --depth == 0) return csec_top_level_decl_name(tokens, cursor + 1);
        }
        return const_cast<char*>("<template>");
    }
    if (std::strcmp(kind, "import") == 0) return csec_token_text_at(tokens, ordinal + 1);
    if (std::strcmp(kind, "function") == 0) {
        if (std::strcmp(csec_token_text_at(tokens, ordinal + 1), "operator") != 0) {
            return csec_token_text_at(tokens, ordinal + 1);
        }
        const char* suffix = csec_token_text_at(tokens, ordinal + 2);
        const size_t length = std::strlen(suffix) + 9;
        char* result = static_cast<char*>(std::malloc(length));
        if (!result) return const_cast<char*>("operator");
        std::snprintf(result, length, "operator%s", suffix);
        return result;
    }
    if (std::strcmp(kind, "class") == 0 || std::strcmp(kind, "object") == 0 ||
        std::strcmp(kind, "value") == 0 || std::strcmp(kind, "variable") == 0) {
        return csec_token_text_at(tokens, ordinal + 1);
    }
    return const_cast<char*>("<anonymous>");
}

int csec_count_function_params(const char* tokens, int declStart) {
    const int paramStart = csec_function_param_end(tokens, declStart) < 0
        ? -1
        : csec_find_token_text_in_range(tokens, declStart, csec_function_param_end(tokens, declStart), "(");
    if (paramStart < 0) return 0;
    const int paramEnd = csec_function_param_end(tokens, declStart);
    if (paramEnd <= paramStart + 1) return 0;
    int count = 1;
    for (int cursor = paramStart + 1; cursor < paramEnd; ++cursor) {
        if (csec_native_token_is(tokens, cursor, 'O', ",")) ++count;
    }
    return count;
}

int csec_token_is_top_level_operator(const char* tokens, int ordinal, int group) {
    const char kind = csec_token_kind_at(tokens, ordinal);
    const char* text = csec_token_text_at(tokens, ordinal);
    const auto is = [text](const char* candidate) { return std::strcmp(text, candidate) == 0; };
    if (group == 1 && kind == 'O') return is("=") || is("<-") || is("+=") || is("-=") || is("*=") || is("/=") || is("%=");
    if (group == 2) return (kind == 'K' && is("or")) || (kind == 'O' && (is("||") || is("|")));
    if (group == 3) return (kind == 'K' && is("and")) || (kind == 'O' && is("&&"));
    if (group == 8) return (kind == 'K' && is("xor")) || (kind == 'O' && is("^"));
    if (group == 9 && kind == 'O') return is("&");
    if (group == 4 && kind == 'O') return is("==") || is("!=") || is("<") || is(">") || is("<=") || is(">=");
    if (group == 10 && kind == 'O') return is("<<") || is(">>");
    if (group == 5) return (kind == 'O' && is("..")) || (kind == 'K' && (is("to") || is("until")));
    if (group == 6 && kind == 'O') return is("+") || is("-");
    if (group == 7 && kind == 'O') return is("*") || is("/") || is("%") || is("@");
    if (group == 11 && kind == 'K') return is("inner") || is("outer") || is("tensor");
    return group == 12 && kind == 'O' && is(",");
}

int csec_find_top_level_operator(const char* tokens, int start, int end, int group) {
    int paren = 0;
    int brace = 0;
    int bracket = 0;
    for (int cursor = end - 1; cursor >= start; --cursor) {
        const char* text = csec_token_text_at(tokens, cursor);
        if (csec_token_kind_at(tokens, cursor) == 'O') {
            if (std::strcmp(text, ")") == 0) ++paren;
            else if (std::strcmp(text, "(") == 0) --paren;
            else if (std::strcmp(text, "}") == 0) ++brace;
            else if (std::strcmp(text, "{") == 0) --brace;
            else if (std::strcmp(text, "]") == 0) ++bracket;
            else if (std::strcmp(text, "[") == 0) --bracket;
        }
        if (paren == 0 && brace == 0 && bracket == 0 &&
            csec_token_is_top_level_operator(tokens, cursor, group)) {
            return cursor;
        }
    }
    return -1;
}

int csec_find_top_level_match(const char* tokens, int start, int end) {
    int paren = 0;
    int brace = 0;
    int bracket = 0;
    for (int cursor = start; cursor < end && csec_token_kind_at(tokens, cursor) != 'E'; ++cursor) {
        const char* text = csec_token_text_at(tokens, cursor);
        if (csec_token_kind_at(tokens, cursor) == 'O') {
            if (std::strcmp(text, "(") == 0) ++paren;
            else if (std::strcmp(text, ")") == 0) --paren;
            else if (std::strcmp(text, "{") == 0) ++brace;
            else if (std::strcmp(text, "}") == 0) --brace;
            else if (std::strcmp(text, "[") == 0) ++bracket;
            else if (std::strcmp(text, "]") == 0) --bracket;
        }
        if (paren == 0 && brace == 0 && bracket == 0 &&
            csec_token_is(tokens, cursor, 'K', "match")) {
            return cursor;
        }
    }
    return -1;
}

int csec_find_lambda_arrow(const char* tokens, int start, int end) {
    if (!tokens || start < 0 || end <= start) return -1;
    const int tokenCount = tokenCountCached(tokens);
    if (start >= tokenCount) return -1;
    if (end > tokenCount) end = tokenCount;
    if (end <= start) return -1;
    if (!csec_token_is(tokens, start, 'O', "[")) return -1;
    const int closeCapture = csec_find_closing_token(tokens, start, end, "[", "]");
    if (closeCapture < start || closeCapture + 1 >= end) return -1;
    int openParams = closeCapture + 1;
    while (openParams < end && csec_token_kind_at(tokens, openParams) == 'M') ++openParams;
    if (openParams >= end || !csec_token_is(tokens, openParams, 'O', "(")) return -1;
    const int closeParams = csec_find_closing_token(tokens, openParams, end, "(", ")");
    if (closeParams < openParams || closeParams + 1 >= end) return -1;
    int arrow = closeParams + 1;
    while (arrow < end && csec_token_kind_at(tokens, arrow) == 'M') ++arrow;
    return arrow < end && csec_token_is(tokens, arrow, 'O', "->") ? arrow : -1;
}

char* csec_generate_symbol_table(const char* tokens) {
    std::string output;
    if (!csec_validate_top_level(tokens)) {
        output = "error: parse failed\n";
    } else {
        output = "Symbols\n";
        int cursor = 0;
        while (csec_token_kind_at(tokens, cursor) == 'M') ++cursor;
        while (csec_token_kind_at(tokens, cursor) != 'E') {
            const char* kind = csec_top_level_decl_kind(tokens, cursor);
            const char* name = csec_top_level_decl_name(tokens, cursor);
            const int declEnd = csec_advance_top_level_decl(tokens, cursor);
            if (std::strcmp(kind, "function") == 0 || std::strcmp(kind, "external-function") == 0) {
                output += "Symbol function ";
                output += name;
                output += " params=" + std::to_string(csec_count_function_params(tokens, cursor));
                output += " returns=";
                output += csec_function_return_type_at(tokens, cursor);
                output += "\n";
                if (std::strcmp(kind, "external-function") == 0) {
                    output += "  External function ";
                    output += name;
                    output += "\n";
                }
            } else if (std::strcmp(kind, "value") == 0 || std::strcmp(kind, "variable") == 0) {
                output += "Symbol ";
                output += kind;
                output += " ";
                output += name;
                output += "\n";
            } else if (std::strcmp(kind, "import") == 0) {
                output += "Symbol import ";
                output += name;
                output += "\n";
            } else if (std::strcmp(kind, "class") == 0 || std::strcmp(kind, "object") == 0 ||
                       std::strcmp(kind, "external-class") == 0 || std::strcmp(kind, "external-object") == 0) {
                output += "Symbol type ";
                output += name;
                output += " kind=";
                output += kind;
                output += "\n";
            } else {
                output += "Symbol ";
                output += kind;
                output += " ";
                output += name;
                output += "\n";
            }
            cursor = declEnd;
            while (csec_token_kind_at(tokens, cursor) == 'M') ++cursor;
        }
    }
    char* result = static_cast<char*>(std::malloc(output.size() + 1));
    if (!result) return nullptr;
    std::memcpy(result, output.c_str(), output.size() + 1);
    return result;
}

char* csec_append_expression_until(const char* tokens, int start, int end) {
    std::string output;
    for (int cursor = start; cursor < end && csec_token_kind_at(tokens, cursor) != 'E'; ++cursor) {
        output += csec_token_text_at(tokens, cursor);
        if (cursor + 1 < end) output += " ";
    }
    char* result = static_cast<char*>(std::malloc(output.size() + 1));
    if (!result) return nullptr;
    std::memcpy(result, output.c_str(), output.size() + 1);
    return result;
}

char* csec_ir_operator_name(const char* text) {
    const char* value = text ? text : "";
    if (std::strcmp(value, "+") == 0) return const_cast<char*>("add");
    if (std::strcmp(value, "-") == 0) return const_cast<char*>("sub");
    if (std::strcmp(value, "*") == 0) return const_cast<char*>("mul");
    if (std::strcmp(value, "/") == 0) return const_cast<char*>("sdiv");
    if (std::strcmp(value, "%") == 0) return const_cast<char*>("srem");
    if (std::strcmp(value, "<<") == 0) return const_cast<char*>("shl");
    if (std::strcmp(value, ">>") == 0) return const_cast<char*>("ashr");
    if (std::strcmp(value, "&") == 0 || std::strcmp(value, "and") == 0 || std::strcmp(value, "&&") == 0) return const_cast<char*>("and");
    if (std::strcmp(value, "|") == 0 || std::strcmp(value, "or") == 0 || std::strcmp(value, "||") == 0) return const_cast<char*>("or");
    if (std::strcmp(value, "^") == 0 || std::strcmp(value, "xor") == 0) return const_cast<char*>("xor");
    if (std::strcmp(value, "==") == 0) return const_cast<char*>("icmp_eq");
    if (std::strcmp(value, "!=") == 0) return const_cast<char*>("icmp_ne");
    if (std::strcmp(value, "<") == 0) return const_cast<char*>("icmp_slt");
    if (std::strcmp(value, "<=") == 0) return const_cast<char*>("icmp_sle");
    if (std::strcmp(value, ">") == 0) return const_cast<char*>("icmp_sgt");
    if (std::strcmp(value, ">=") == 0) return const_cast<char*>("icmp_sge");
    if (std::strcmp(value, "..") == 0) return const_cast<char*>("range");
    if (std::strcmp(value, "to") == 0) return const_cast<char*>("range_to");
    if (std::strcmp(value, "until") == 0) return const_cast<char*>("range_until");
    if (std::strcmp(value, "@") == 0) return const_cast<char*>("matmul");
    return const_cast<char*>(value);
}

int csec_expression_top_level_operator(const char* tokens, int start, int end) {
    static const int groups[] = {1, 2, 3, 8, 9, 4, 10, 5, 6, 7, 11};
    for (int group : groups) {
        const int ordinal = csec_find_top_level_operator(tokens, start, end, group);
        if (ordinal >= start) return ordinal;
    }
    return -1;
}

int csec_advance_top_level_decl(const char* tokens, int ordinal) {
    int cursor = ordinal;
    int paren = 0;
    int brace = 0;
    int bracket = 0;
    while (csec_token_kind_at(tokens, cursor) != 'E') {
        if (cursor > ordinal && paren == 0 && brace == 0 && bracket == 0 &&
            csec_native_starts_top_level_declaration(tokens, cursor)) {
            return cursor;
        }
        if (csec_token_kind_at(tokens, cursor) == 'O') {
            const char* text = csec_token_text_at(tokens, cursor);
            if (std::strcmp(text, "(") == 0) ++paren;
            if (std::strcmp(text, ")") == 0) --paren;
            if (std::strcmp(text, "{") == 0) ++brace;
            if (std::strcmp(text, "}") == 0) {
                --brace;
                if (brace == 0 && paren == 0 && bracket == 0) return cursor + 1;
            }
            if (std::strcmp(text, "[") == 0) ++bracket;
            if (std::strcmp(text, "]") == 0) --bracket;
            if (std::strcmp(text, ";") == 0 && brace == 0 && paren == 0 && bracket == 0) {
                return cursor + 1;
            }
        }
        ++cursor;
    }
    return cursor;
}

int csec_find_decl_body_start(const char* tokens, int ordinal) {
    int tokenCount = tokenCountCached(tokens ? tokens : "");
    for (int cursor = ordinal; cursor < tokenCount; ++cursor) {
        if (cursor > ordinal && csec_native_starts_top_level_declaration(tokens, cursor)) return -1;
        if (csec_native_token_is(tokens, cursor, 'O', "{")) return cursor + 1;
        if (csec_native_token_is(tokens, cursor, 'O', ";")) return -1;
    }
    return -1;
}

int csec_find_decl_body_end(const char* tokens, int bodyStart) {
    if (bodyStart < 0) return -1;
    int tokenCount = tokenCountCached(tokens ? tokens : "");
    int openBrace = bodyStart - 1;
    if (!csec_native_token_is(tokens, openBrace, 'O', "{")) return -1;
    int closeBrace = findMatchingBraceToken(tokens ? tokens : "", openBrace, tokenCount);
    return closeBrace;
}

int csec_find_token_text_in_range(const char* tokens, int start, int end, const char* text) {
    if (!tokens || !text) return -1;
    for (int ordinal = start < 0 ? 0 : start; ordinal < end && csec_token_kind_at(tokens, ordinal) != 'E'; ++ordinal) {
        const char* candidate = csec_token_text_at(tokens, ordinal);
        if (candidate && std::strcmp(candidate, text) == 0) return ordinal;
    }
    return -1;
}

int csec_find_closing_token(const char* tokens, int openOrdinal, int end, const char* openText, const char* closeText) {
    return csec_native_find_closing_token(tokens, openOrdinal, end, openText, closeText);
}

int csec_find_statement_paren_start(const char* tokens, int start, int end) {
    return csec_find_token_text_in_range(tokens, start, end, "(");
}

int csec_find_statement_paren_end(const char* tokens, int start, int end) {
    int openParen = csec_find_statement_paren_start(tokens, start, end);
    return openParen < 0 ? -1 : csec_native_find_closing_token(tokens, openParen, end, "(", ")");
}

int csec_find_statement_block_start(const char* tokens, int start, int end) {
    int closeParen = csec_find_statement_paren_end(tokens, start, end);
    return closeParen >= 0
        ? csec_find_token_text_in_range(tokens, closeParen + 1, end, "{")
        : csec_find_token_text_in_range(tokens, start, end, "{");
}

int csec_find_statement_block_end(const char* tokens, int start, int end) {
    int openBrace = csec_find_statement_block_start(tokens, start, end);
    return openBrace < 0 ? -1 : csec_native_find_closing_token(tokens, openBrace, end, "{", "}");
}

int csec_count_comma_separated(const char* tokens, int start, int end) {
    if (!tokens || end <= start) return 0;
    int count = 1;
    int paren = 0;
    int bracket = 0;
    int brace = 0;
    for (int cursor = start; cursor < end && csec_token_kind_at(tokens, cursor) != 'E'; ++cursor) {
        if (csec_token_kind_at(tokens, cursor) != 'O') continue;
        const char* text = csec_token_text_at(tokens, cursor);
        if (!text) continue;
        if (std::strcmp(text, "(") == 0) ++paren;
        else if (std::strcmp(text, ")") == 0) --paren;
        else if (std::strcmp(text, "[") == 0) ++bracket;
        else if (std::strcmp(text, "]") == 0) --bracket;
        else if (std::strcmp(text, "{") == 0) ++brace;
        else if (std::strcmp(text, "}") == 0) --brace;
        else if (std::strcmp(text, ",") == 0 && paren == 0 && bracket == 0 && brace == 0) ++count;
    }
    return count;
}

int csec_find_last_top_level_token(const char* tokens, int start, int end, const char* text) {
    if (!tokens || !text) return -1;
    int paren = 0;
    int bracket = 0;
    int brace = 0;
    for (int cursor = end - 1; cursor >= start; --cursor) {
        const char* current = csec_token_text_at(tokens, cursor);
        if (csec_token_kind_at(tokens, cursor) == 'O' && current) {
            if (std::strcmp(current, ")") == 0) ++paren;
            else if (std::strcmp(current, "(") == 0) --paren;
            else if (std::strcmp(current, "]") == 0) ++bracket;
            else if (std::strcmp(current, "[") == 0) --bracket;
            else if (std::strcmp(current, "}") == 0) ++brace;
            else if (std::strcmp(current, "{") == 0) --brace;
        }
        if (paren == 0 && bracket == 0 && brace == 0 && current && std::strcmp(current, text) == 0) return cursor;
    }
    return -1;
}

int csec_function_param_end(const char* tokens, int declStart) {
    int declEnd = csec_advance_top_level_decl(tokens, declStart);
    for (int cursor = declStart; cursor < declEnd && csec_token_kind_at(tokens, cursor) != 'E'; ++cursor) {
        if (csec_native_token_is(tokens, cursor, 'O', "(")) {
            return csec_native_find_closing_token(tokens, cursor, declEnd, "(", ")");
        }
        if (csec_native_token_is(tokens, cursor, 'O', "{") || csec_native_token_is(tokens, cursor, 'O', ";")) {
            break;
        }
    }
    return -1;
}

int csec_find_function_param_start(const char* tokens, int declStart) {
    for (int cursor = declStart; csec_token_kind_at(tokens, cursor) != 'E'; ++cursor) {
        if (csec_native_token_is(tokens, cursor, 'O', "(")) return cursor;
        if (csec_native_token_is(tokens, cursor, 'O', "{") || csec_native_token_is(tokens, cursor, 'O', ";")) return -1;
    }
    return -1;
}

}

static const char* csec_llvm_type_for_name(const std::string& typeName) {
    if (typeName == "Int" || typeName == "Short" || typeName == "Byte") return "i32";
    if (typeName == "Long") return "i64";
    if (typeName == "Boolean") return "i1";
    if (typeName == "Char") return "i8";
    if (typeName == "Double") return "double";
    if (typeName == "Float") return "float";
    return "ptr";
}

static char* csec_owned_string(const std::string& text) {
    char* result = static_cast<char*>(std::malloc(text.size() + 1));
    if (!result) return const_cast<char*>("");
    std::memcpy(result, text.c_str(), text.size() + 1);
    return result;
}

static int csec_expression_ast_skip_trivia(const char* tokens, int ordinal) {
    while (csec_token_kind_at(tokens, ordinal) == 'M') ++ordinal;
    return ordinal;
}

static int csec_expression_ast_trim_end(const char* tokens, int start, int end) {
    while (end > start && csec_token_kind_at(tokens, end - 1) == 'M') --end;
    return end > start && csec_native_token_is(tokens, end - 1, 'O', ";") ? end - 1 : end;
}

static std::string csec_expression_ast_leaf_kind(const char* tokens, int start, int end) {
    if (end <= start) return "empty";
    switch (csec_token_kind_at(tokens, start)) {
    case 'N': return "integer";
    case 'F': return "float";
    case 'S': return "string";
    case 'R': return "regex";
    case 'C': return "char";
    case 'B': return "bool";
    case 'I': return "identifier";
    case 'K': {
        const char* text = csec_token_text_at(tokens, start);
        if (std::strcmp(text, "this") == 0 || std::strcmp(text, "super") == 0 ||
            std::strcmp(text, "new") == 0 || std::strcmp(text, "match") == 0) return text;
        break;
    }
    default: break;
    }
    return "unknown";
}

static std::string csec_expression_ast_postfix(const char* tokens, int start, int end) {
    if (end <= start) return "";
    if (csec_native_token_is(tokens, end - 1, 'O', ")")) {
        const int open = csec_find_last_top_level_token(tokens, start, end, "(");
        if (open > start) return "Expr call target=" + std::string(csec_append_expression_until(tokens, start, open)) +
            " argc=" + std::to_string(csec_count_comma_separated(tokens, open + 1, end - 1));
    }
    if (csec_native_token_is(tokens, end - 1, 'O', "]")) {
        const int open = csec_find_last_top_level_token(tokens, start, end, "[");
        if (open > start) return "Expr index target=" + std::string(csec_append_expression_until(tokens, start, open)) +
            " argc=" + std::to_string(csec_count_comma_separated(tokens, open + 1, end - 1));
    }
    const int dot = csec_find_last_top_level_token(tokens, start, end, ".");
    if (dot > start) return "Expr member " + std::string(csec_append_expression_until(tokens, start, dot)) + "." +
        csec_append_expression_until(tokens, dot + 1, end);
    return "";
}

static std::string csec_generate_expression_ast_impl(const char* tokens, int rawStart, int rawEnd) {
    const int start = csec_expression_ast_skip_trivia(tokens, rawStart);
    const int end = csec_expression_ast_trim_end(tokens, start, rawEnd);
    if (end <= start) return "Expr empty";
    const auto expressionText = [&] { return std::string(csec_append_expression_until(tokens, start, end)); };
    if (end - start > 32) return "Expr " + csec_expression_ast_leaf_kind(tokens, start, end) + " " + expressionText();

    if (csec_native_token_is(tokens, start, 'O', "[")) {
        const int arrow = csec_find_lambda_arrow(tokens, start, end);
        if (arrow >= 0) {
            const int captureClose = csec_find_closing_token(tokens, start, end, "[", "]");
            const std::string capture = captureClose <= start + 1 ? "none" : csec_append_expression_until(tokens, start + 1, captureClose);
            const int paramOpen = csec_expression_ast_skip_trivia(tokens, captureClose + 1);
            const int paramClose = csec_find_closing_token(tokens, paramOpen, end, "(", ")");
            return "Expr lambda capture=" + capture + " params=" + std::to_string(csec_count_comma_separated(tokens, paramOpen + 1, paramClose));
        }
    }

    const int matchAt = csec_find_top_level_match(tokens, start, end);
    if (matchAt > start) {
        const int open = csec_find_token_text_in_range(tokens, matchAt, end, "{");
        int cases = 0;
        if (open >= 0) {
            const int close = csec_find_closing_token(tokens, open, end, "{", "}");
            for (int cursor = open + 1; cursor < close && csec_token_kind_at(tokens, cursor) != 'E'; ++cursor) {
                if (csec_native_token_is(tokens, cursor, 'K', "case")) ++cases;
            }
        }
        return "Expr match cases=" + std::to_string(cases) + " [" + csec_generate_expression_ast_impl(tokens, start, matchAt) + "]";
    }
    if (csec_native_token_is(tokens, start, 'O', "(")) {
        const int close = csec_find_closing_token(tokens, start, end, "(", ")");
        if (close == end - 1) return "Expr group (" + csec_generate_expression_ast_impl(tokens, start + 1, end - 1) + ")";
    }

    const int groups[] = {1, 2, 3, 8, 9, 4, 10, 5, 6, 7, 11};
    for (const int group : groups) {
        const int op = csec_find_top_level_operator(tokens, start, end, group);
        if (op < start || ((group == 6 || group == 7 || group == 11) && op <= start)) continue;
        const char* category = group == 1 ? "assign" : group == 4 ? "compare" : group == 10 ? "shift" :
            group == 5 ? "range" : group == 11 ? "tensor" : "binary";
        return "Expr " + std::string(category) + " " + csec_token_text_at(tokens, op) + " [" +
            csec_generate_expression_ast_impl(tokens, start, op) + "] [" + csec_generate_expression_ast_impl(tokens, op + 1, end) + "]";
    }

    if (csec_token_kind_at(tokens, start) == 'O') {
        const char* text = csec_token_text_at(tokens, start);
        if (std::strcmp(text, "!") == 0 || std::strcmp(text, "-") == 0 || std::strcmp(text, "+") == 0 ||
            std::strcmp(text, "~") == 0 || std::strcmp(text, "*") == 0 || std::strcmp(text, "&") == 0 ||
            std::strcmp(text, "<-") == 0 || std::strcmp(text, "++") == 0 || std::strcmp(text, "--") == 0) {
            return "Expr unary " + std::string(text) + " [" + csec_generate_expression_ast_impl(tokens, start + 1, end) + "]";
        }
    }
    if (end > start + 1 && csec_token_kind_at(tokens, end - 1) == 'O') {
        const char* text = csec_token_text_at(tokens, end - 1);
        if (std::strcmp(text, "++") == 0 || std::strcmp(text, "--") == 0) {
            return "Expr postfix " + std::string(text) + " [" + csec_generate_expression_ast_impl(tokens, start, end - 1) + "]";
        }
    }
    const std::string postfix = csec_expression_ast_postfix(tokens, start, end);
    if (!postfix.empty()) return postfix;
    if (csec_token_kind_at(tokens, start) == 'I' && start + 1 < end && csec_native_token_is(tokens, start + 1, 'O', "(") &&
        csec_find_closing_token(tokens, start + 1, end, "(", ")") == end - 1) {
        return "Expr call " + std::string(csec_token_text_at(tokens, start)) + "(" + csec_append_expression_until(tokens, start + 2, end - 1) + ")";
    }
    if (csec_native_token_is(tokens, start, 'O', "[")) return "Expr array count=" +
        std::to_string(csec_count_comma_separated(tokens, start + 1, end - 1)) + " [" + csec_append_expression_until(tokens, start + 1, end - 1) + "]";
    if (csec_native_token_is(tokens, start, 'K', "new")) return "Expr new " + expressionText();
    if (csec_native_token_is(tokens, start, 'K', "match")) return "Expr match";
    return "Expr " + csec_expression_ast_leaf_kind(tokens, start, end) + " " + expressionText();
}

static std::string csec_generate_statement_ast_impl(const char* tokens, int start, int end) {
    const bool keyword = csec_token_kind_at(tokens, start) == 'K';
    const std::string kind = keyword ? csec_token_text_at(tokens, start) : "expression";
    if (kind == "return") return "  Stmt return " + csec_generate_expression_ast_impl(tokens, start + 1, end) + "\n";
    if (kind == "val" || kind == "var") {
        const int initializer = csec_find_top_level_operator(tokens, start, end, 1);
        std::string output = "  Stmt " + std::string(kind == "val" ? "value" : "variable") + " " + csec_token_text_at(tokens, start + 1);
        if (initializer >= start) output += " = " + csec_generate_expression_ast_impl(tokens, initializer + 1, end);
        return output + "\n";
    }
    if (kind == "if" || kind == "for" || kind == "while" || kind == "map" || kind == "pmap" || kind == "reduce" || kind == "preduce" || kind == "filter") {
        const int open = csec_find_statement_paren_start(tokens, start, end);
        const int close = csec_find_statement_paren_end(tokens, start, end);
        return "  Stmt " + kind + " (" + (open >= 0 && close > open ? csec_append_expression_until(tokens, open + 1, close) : "") + ")\n";
    }
    if (kind == "unsafe" || kind == "unatomic" || kind == "constexpr") return "  Stmt " + kind + "\n";
    if (kind == "def" || kind == "object") return "  Stmt " + std::string(kind == "def" ? "function" : "object") + " " + csec_token_text_at(tokens, start + 1) + "\n";
    return "  Stmt expression " + csec_generate_expression_ast_impl(tokens, start, end) + "\n";
}

static std::string csec_generate_body_ast_impl(const char* tokens, int bodyStart, int bodyEnd) {
    std::string output;
    int cursor = csec_expression_ast_skip_trivia(tokens, bodyStart);
    while (cursor >= 0 && cursor < bodyEnd && csec_token_kind_at(tokens, cursor) != 'E') {
        const int next = csec_advance_statement(tokens, cursor, bodyEnd);
        if (next <= cursor) return output + "  Stmt error\n";
        output += csec_generate_statement_ast_impl(tokens, cursor, next);
        cursor = csec_expression_ast_skip_trivia(tokens, next);
    }
    return output;
}

static std::string csec_c_expression(const char* tokens, int start, int rawEnd) {
    const int end = csec_expression_ast_trim_end(tokens, start, rawEnd);
    std::string output;
    for (int cursor = start; cursor < end && csec_token_kind_at(tokens, cursor) != 'E'; ++cursor) {
        const char* text = csec_token_text_at(tokens, cursor);
        if (csec_native_token_is(tokens, cursor, 'K', "and")) output += "&&";
        else if (csec_native_token_is(tokens, cursor, 'K', "or")) output += "||";
        else if (csec_native_token_is(tokens, cursor, 'K', "xor")) output += "^";
        else output += text;
        if (cursor + 1 < end) output += " ";
    }
    return output;
}

static const char* csec_c_type(const std::string& type) {
    if (type == "Boolean" || type == "Int") return "int";
    if (type == "Char") return "char";
    if (type == "Long") return "long long";
    if (type == "Float") return "float";
    if (type == "Double") return "double";
    if (type == "String" || type == "Regex") return "const char*";
    if (type.rfind("Array", 0) == 0) return "void*";
    if (type == "Unit") return "void";
    return "void*";
}

char* csec_c_type_name(const char* typeName) {
    return csec_copy_literal(csec_c_type(typeName ? typeName : ""));
}

char* csec_empty_string(void) {
    return csec_copy_literal("");
}

char* csec_llvm_main_body_fallback(void) {
    return csec_copy_literal("  ret i32 0\n");
}

char* csec_llvm_main_body(void) {
    return csec_copy_literal(
        "  %argc = call i32 @csec_command_line_arg_count()\n"
        "  %provided = icmp sge i32 %argc, 4\n"
        "  br i1 %provided, label %compile, label %missing\n"
        "compile:\n"
        "  %input = call ptr @csec_command_line_arg(i32 1)\n"
        "  %output = call ptr @csec_command_line_arg(i32 2)\n"
        "  %mode = call ptr @csec_command_line_arg(i32 3)\n"
        "  %status = call i32 @compileFile(ptr %input, ptr %output, ptr %mode)\n"
        "  ret i32 %status\n"
        "missing:\n"
        "  ret i32 1\n");
}

char* csec_llvm_body_fallback(int kind) {
    switch (kind) {
        case 1: return csec_copy_literal("  ret i1 false\n");
        case 2: return csec_copy_literal("  ret i8 0\n");
        case 3: return csec_copy_literal("  ret double 0.0\n");
        case 4: return csec_copy_literal("  ret i64 0\n");
        case 5: return csec_copy_literal("  ret ptr null\n");
        default: return csec_copy_literal("  ret i32 0\n");
    }
}

static std::string csec_c_local_type(const char* tokens, int start, int end, int initializer) {
    for (int cursor = start; cursor < end; ++cursor) {
        if (csec_native_token_is(tokens, cursor, 'O', ":")) {
            std::string type;
            for (int pos = cursor + 1; pos < end && !csec_native_token_is(tokens, pos, 'O', "=") && !csec_native_token_is(tokens, pos, 'O', ";"); ++pos) type += csec_token_text_at(tokens, pos);
            if (!type.empty()) return type;
        }
    }
    if (initializer >= start) {
        const char kind = csec_token_kind_at(tokens, initializer + 1);
        if (kind == 'N') return "Int";
        if (kind == 'F') return "Double";
        if (kind == 'S') return "String";
        if (kind == 'C') return "Char";
        if (kind == 'B') return "Boolean";
    }
    return "Int";
}

static std::string csec_generate_c_body_impl(const char* tokens, int bodyStart, int bodyEnd, const std::string& indent) {
    std::string output;
    int cursor = csec_expression_ast_skip_trivia(tokens, bodyStart);
    while (cursor >= 0 && cursor < bodyEnd && csec_token_kind_at(tokens, cursor) != 'E') {
        const int next = csec_advance_statement(tokens, cursor, bodyEnd);
        if (next <= cursor) break;
        const char* kind = csec_token_text_at(tokens, cursor);
        if (csec_native_token_is(tokens, cursor, 'K', "return")) {
            output += indent + "return " + csec_c_expression(tokens, cursor + 1, next) + ";\n";
        } else if (csec_native_token_is(tokens, cursor, 'K', "val") || csec_native_token_is(tokens, cursor, 'K', "var")) {
            const int init = csec_find_top_level_operator(tokens, cursor, next, 1);
            output += indent + csec_c_type(csec_c_local_type(tokens, cursor, next, init)) + " " + csec_token_text_at(tokens, cursor + 1);
            output += init >= cursor ? " = " + csec_c_expression(tokens, init + 1, next) + ";\n" : " = 0;\n";
        } else if (std::strcmp(kind, "if") == 0 || std::strcmp(kind, "while") == 0) {
            const int open = csec_find_statement_paren_start(tokens, cursor, next);
            const int close = csec_find_statement_paren_end(tokens, cursor, next);
            const int brace = csec_find_statement_block_start(tokens, cursor, next);
            const int braceEnd = csec_find_closing_token(tokens, brace, next, "{", "}");
            if (open >= cursor && close > open && brace > close && braceEnd > brace) {
                output += indent + kind + " (" + csec_c_expression(tokens, open + 1, close) + ") {\n";
                output += csec_generate_c_body_impl(tokens, brace + 1, braceEnd, indent + "    ") + indent + "}\n";
            }
        } else if (std::strcmp(kind, "for") == 0) {
            const int open = csec_find_statement_paren_start(tokens, cursor, next);
            const int close = csec_find_statement_paren_end(tokens, cursor, next);
            const int brace = csec_find_statement_block_start(tokens, cursor, next);
            const int braceEnd = csec_find_statement_block_end(tokens, cursor, next);
            const int arrow = csec_find_token_text_in_range(tokens, open + 1, close, "<-");
            const int range = csec_find_top_level_operator(tokens, arrow + 1, close, 5);
            if (open >= cursor && arrow > open && range > arrow && braceEnd > brace) {
                const char* name = csec_token_text_at(tokens, open + 1);
                const char* op = csec_token_text_at(tokens, range);
                output += indent + "for (int " + std::string(name) + " = " + csec_c_expression(tokens, arrow + 1, range) + "; " + name +
                    (std::strcmp(op, "to") == 0 || std::strcmp(op, "..") == 0 ? " <= " : " < ") + csec_c_expression(tokens, range + 1, close) + "; " + name + "++) {\n";
                output += csec_generate_c_body_impl(tokens, brace + 1, braceEnd, indent + "    ") + indent + "}\n";
            }
        } else if (std::strcmp(kind, "map") == 0 || std::strcmp(kind, "pmap") == 0 || std::strcmp(kind, "reduce") == 0 || std::strcmp(kind, "preduce") == 0 || std::strcmp(kind, "filter") == 0) {
            const int brace = csec_find_statement_block_start(tokens, cursor, next);
            const int braceEnd = csec_find_statement_block_end(tokens, cursor, next);
            output += indent + "/* " + std::string(kind) + " */\n";
            if (braceEnd > brace) output += csec_generate_c_body_impl(tokens, brace + 1, braceEnd, indent);
        } else {
            output += indent + csec_c_expression(tokens, cursor, next) + ";\n";
        }
        cursor = csec_expression_ast_skip_trivia(tokens, next);
    }
    return output;
}

static std::vector<std::pair<std::string, std::string>> csec_function_params(const char* tokens, int declStart) {
    std::vector<std::pair<std::string, std::string>> params;
    int paramEnd = csec_function_param_end(tokens, declStart);
    if (paramEnd < 0) return params;
    int paramStart = -1;
    for (int cursor = declStart; cursor < paramEnd; ++cursor) {
        if (csec_native_token_is(tokens, cursor, 'O', "(")) {
            paramStart = cursor;
            break;
        }
    }
    if (paramStart < 0) return params;
    int cursor = paramStart + 1;
    while (cursor < paramEnd) {
        if (csec_token_kind_at(tokens, cursor) == 'I') {
            std::string name = csec_token_text_at(tokens, cursor);
            std::string typeName = "String";
            if (csec_native_token_is(tokens, cursor + 1, 'O', ":")) {
                typeName = csec_token_text_at(tokens, cursor + 2);
                if (csec_native_token_is(tokens, cursor + 2, 'O', "(")) {
                    const int typeClose = csec_find_closing_token(tokens, cursor + 2, paramEnd, "(", ")");
                    if (typeClose >= cursor + 2) {
                        cursor = typeClose + 1;
                        if (csec_native_token_is(tokens, cursor, 'O', "=>")) ++cursor;
                        if (cursor < paramEnd) ++cursor;
                    }
                }
            }
            params.emplace_back(std::move(name), std::move(typeName));
        }
        while (cursor < paramEnd && !csec_native_token_is(tokens, cursor, 'O', ",")) ++cursor;
        ++cursor;
    }
    return params;
}

static int csec_find_visible_local(const char* tokens, int limit, const char* name) {
    const int boundedLimit = limit < 0 ? 0 : limit;
    int begin = 0;
    int end = boundedLimit;
    int bodyStart = -1;
    int bodyEnd = -1;
    if (findFunctionAroundLimit(tokens, boundedLimit, nullptr, &bodyStart, &bodyEnd)) {
        begin = bodyStart;
        end = boundedLimit < bodyEnd ? boundedLimit : bodyEnd;
    }
    int visible = -1;
    for (int cursor = begin; cursor < end && csec_token_kind_at(tokens, cursor) != 'E'; ++cursor) {
        const bool local = csec_native_token_is(tokens, cursor, 'K', "val") ||
            csec_native_token_is(tokens, cursor, 'K', "var");
        if (local && csec_token_kind_at(tokens, cursor + 1) == 'I' &&
            std::strcmp(csec_token_text_at(tokens, cursor + 1), name ? name : "") == 0) {
            visible = cursor;
        }
    }
    return visible;
}

extern "C" {

char* csec_generate_expression_ast(const char* tokens, int start, int end) {
    return csec_owned_string(csec_generate_expression_ast_impl(tokens, start, end));
}

char* csec_generate_statement_ast(const char* tokens, int start, int end) {
    return csec_owned_string(csec_generate_statement_ast_impl(tokens, start, end));
}

char* csec_generate_body_ast(const char* tokens, int bodyStart, int bodyEnd) {
    return csec_owned_string(csec_generate_body_ast_impl(tokens, bodyStart, bodyEnd));
}

char* csec_generate_c_body(const char* tokens, int bodyStart, int bodyEnd, const char* indent) {
    return csec_owned_string(csec_generate_c_body_impl(tokens, bodyStart, bodyEnd, indent ? indent : ""));
}

char* csec_generate_c_expression(const char* tokens, int start, int end) {
    return csec_owned_string(csec_c_expression(tokens, start, end));
}

static int csec_i32_expression_end(const char* tokens, int start, int end) {
    while (end > start && csec_native_token_is(tokens, end - 1, 'O', ";")) --end;
    return end;
}

static int csec_i32_operator_precedence(const char* text) {
    if (std::strcmp(text, "or") == 0 || std::strcmp(text, "||") == 0) return 1;
    if (std::strcmp(text, "xor") == 0) return 2;
    if (std::strcmp(text, "and") == 0 || std::strcmp(text, "&&") == 0) return 3;
    if (std::strcmp(text, "|") == 0) return 4;
    if (std::strcmp(text, "^") == 0) return 5;
    if (std::strcmp(text, "&") == 0) return 6;
    if (std::strcmp(text, "==") == 0 || std::strcmp(text, "!=") == 0) return 7;
    if (std::strcmp(text, "<") == 0 || std::strcmp(text, "<=") == 0 ||
        std::strcmp(text, ">") == 0 || std::strcmp(text, ">=") == 0) return 8;
    if (std::strcmp(text, "<<") == 0 || std::strcmp(text, ">>") == 0) return 9;
    if (std::strcmp(text, "+") == 0 || std::strcmp(text, "-") == 0) return 10;
    if (std::strcmp(text, "*") == 0 || std::strcmp(text, "/") == 0 || std::strcmp(text, "%") == 0) return 11;
    return 0;
}

static int csec_i32_top_level_operator(const char* tokens, int start, int end) {
    int paren = 0;
    int bracket = 0;
    int brace = 0;
    int selected = -1;
    int bestPrecedence = 100;
    for (int cursor = start; cursor < end; ++cursor) {
        const char* text = csec_token_text_at(tokens, cursor);
        if (std::strcmp(text, "(") == 0) { ++paren; continue; }
        if (std::strcmp(text, ")") == 0) { --paren; continue; }
        if (std::strcmp(text, "[") == 0) { ++bracket; continue; }
        if (std::strcmp(text, "]") == 0) { --bracket; continue; }
        if (std::strcmp(text, "{") == 0) { ++brace; continue; }
        if (std::strcmp(text, "}") == 0) { --brace; continue; }
        if (paren == 0 && bracket == 0 && brace == 0) {
            const int precedence = csec_i32_operator_precedence(text);
            const bool unarySign = (std::strcmp(text, "+") == 0 || std::strcmp(text, "-") == 0) &&
                (cursor == start || (csec_token_kind_at(tokens, cursor - 1) == 'O' &&
                    !csec_native_token_is(tokens, cursor - 1, 'O', ")") &&
                    !csec_native_token_is(tokens, cursor - 1, 'O', "]") &&
                    !csec_native_token_is(tokens, cursor - 1, 'O', "}")));
            if (!unarySign && precedence > 0 && precedence <= bestPrecedence) {
                selected = cursor;
                bestPrecedence = precedence;
            }
        }
    }
    return selected;
}

static std::string csec_i32_literal(const char* text) {
    if (!text) return "0";
    if (text[0] == '0' && (text[1] == 'b' || text[1] == 'B')) {
        unsigned int value = 0;
        for (const char* cursor = text + 2; *cursor == '0' || *cursor == '1'; ++cursor) {
            value = (value << 1) | static_cast<unsigned int>(*cursor - '0');
        }
        return std::to_string(static_cast<int>(value));
    }
    char* end = nullptr;
    const long long value = std::strtoll(text, &end, 0);
    return end && *end == '\0' ? std::to_string(static_cast<int>(value)) : "0";
}

static std::string csec_emit_i32_expression(const char* tokens, int start, int end, const std::string& resultName);
static std::string csec_emit_i1_expression(const char* tokens, int start, int end, const std::string& resultName);
static std::string csec_emit_ptr_expression(const char* tokens, int start, int end, const std::string& resultName);
static bool csec_expression_is_boolean(const char* tokens, int start, int end);

static std::vector<std::pair<std::string, std::string>> csec_class_constructor_params(const char* tokens, int classStart) {
    std::vector<std::pair<std::string, std::string>> params;
    const int bodyStart = csec_find_decl_body_start(tokens, classStart);
    const int open = bodyStart >= 0 ? csec_find_token_text_in_range(tokens, classStart, bodyStart, "(") : -1;
    const int close = open >= 0 ? csec_find_closing_token(tokens, open, bodyStart, "(", ")") : -1;
    if (close <= open) return params;
    for (int cursor = open + 1; cursor < close;) {
        if (csec_token_kind_at(tokens, cursor) != 'I') { ++cursor; continue; }
        const std::string name = csec_token_text_at(tokens, cursor++);
        if (!csec_native_token_is(tokens, cursor, 'O', ":") || cursor + 1 >= close) continue;
        ++cursor;
        const std::string type = csec_token_text_at(tokens, cursor++);
        params.emplace_back(name, type);
        while (cursor < close && !csec_native_token_is(tokens, cursor, 'O', ",")) ++cursor;
        if (cursor < close) ++cursor;
    }
    return params;
}

extern "C++" {
static std::vector<std::pair<std::string, std::pair<int, int>>> csec_class_i32_fields(const char* tokens, int classStart) {
    std::vector<std::pair<std::string, std::pair<int, int>>> fields;
    const int bodyStart = csec_find_decl_body_start(tokens, classStart);
    const int bodyEnd = csec_find_decl_body_end(tokens, bodyStart);
    int depth = 0;
    for (int cursor = bodyStart; cursor >= 0 && cursor < bodyEnd; ++cursor) {
        if (csec_native_token_is(tokens, cursor, 'O', "{")) { ++depth; continue; }
        if (csec_native_token_is(tokens, cursor, 'O', "}")) { --depth; continue; }
        if (depth != 0 || (!csec_native_token_is(tokens, cursor, 'K', "val") && !csec_native_token_is(tokens, cursor, 'K', "var"))) continue;
        if (csec_token_kind_at(tokens, cursor + 1) != 'I') continue;
        const int statementEnd = csec_advance_statement(tokens, cursor, bodyEnd);
        const int initializer = statementEnd > cursor ? csec_find_top_level_operator(tokens, cursor, statementEnd, 1) : -1;
        const int colon = statementEnd > cursor ? csec_find_token_text_in_range(tokens, cursor + 2, initializer >= 0 ? initializer : statementEnd, ":") : -1;
        if (colon < 0 || !csec_native_token_is(tokens, colon + 1, 'I', "Int")) continue;
        if (initializer < cursor || initializer + 1 >= statementEnd) continue;
        fields.emplace_back(std::string(csec_token_text_at(tokens, cursor + 1)) + ".addr." + std::to_string(cursor),
            std::make_pair(initializer + 1, statementEnd));
    }
    return fields;
}

static std::vector<std::pair<std::string, std::pair<int, int>>> csec_class_i1_fields(const char* tokens, int classStart) {
    std::vector<std::pair<std::string, std::pair<int, int>>> fields;
    const int bodyStart = csec_find_decl_body_start(tokens, classStart);
    const int bodyEnd = csec_find_decl_body_end(tokens, bodyStart);
    int depth = 0;
    for (int cursor = bodyStart; cursor >= 0 && cursor < bodyEnd; ++cursor) {
        if (csec_native_token_is(tokens, cursor, 'O', "{")) { ++depth; continue; }
        if (csec_native_token_is(tokens, cursor, 'O', "}")) { --depth; continue; }
        if (depth != 0 || (!csec_native_token_is(tokens, cursor, 'K', "val") && !csec_native_token_is(tokens, cursor, 'K', "var"))) continue;
        if (csec_token_kind_at(tokens, cursor + 1) != 'I') continue;
        const int statementEnd = csec_advance_statement(tokens, cursor, bodyEnd);
        const int initializer = statementEnd > cursor ? csec_find_top_level_operator(tokens, cursor, statementEnd, 1) : -1;
        const int colon = statementEnd > cursor ? csec_find_token_text_in_range(tokens, cursor + 2, initializer >= 0 ? initializer : statementEnd, ":") : -1;
        if (colon < 0 || !csec_native_token_is(tokens, colon + 1, 'I', "Boolean")) continue;
        if (initializer < cursor || initializer + 1 >= statementEnd) continue;
        fields.emplace_back(std::string(csec_token_text_at(tokens, cursor + 1)) + ".addr." + std::to_string(cursor),
            std::make_pair(initializer + 1, statementEnd));
    }
    return fields;
}
}

static int csec_find_class_declaration(const char* tokens, const char* className) {
    if (!className) return -1;
    for (int cursor = 0; csec_token_kind_at(tokens, cursor) != 'E'; ++cursor) {
        if (csec_native_token_is(tokens, cursor, 'K', "class") &&
            csec_native_token_is(tokens, cursor + 1, 'I', className)) return cursor;
    }
    return -1;
}

static std::string csec_class_parent_name(const char* tokens, int classStart);

static int csec_class_inherited_field_count(const char* tokens, int classStart) {
    const std::string parent = csec_class_parent_name(tokens, classStart);
    const int parentStart = parent.empty() ? -1 : csec_find_class_declaration(tokens, parent.c_str());
    if (parentStart < 0) return 0;
    return csec_class_inherited_field_count(tokens, parentStart) +
        static_cast<int>(csec_class_i32_fields(tokens, parentStart).size()) +
        static_cast<int>(csec_class_i1_fields(tokens, parentStart).size());
}

static std::string csec_class_inherited_field_layout(const char* tokens, int classStart) {
    const std::string parent = csec_class_parent_name(tokens, classStart);
    const int parentStart = parent.empty() ? -1 : csec_find_class_declaration(tokens, parent.c_str());
    if (parentStart < 0) return "";
    std::string layout = csec_class_inherited_field_layout(tokens, parentStart);
    for (size_t index = 0; index < csec_class_i32_fields(tokens, parentStart).size(); ++index) {
        if (!layout.empty()) layout += ", ";
        layout += "i32";
    }
    for (size_t index = 0; index < csec_class_i1_fields(tokens, parentStart).size(); ++index) {
        if (!layout.empty()) layout += ", ";
        layout += "i1";
    }
    return layout;
}

static bool csec_class_uses_pointer_receiver(const char* tokens, int classStart) {
    if (csec_class_inherited_field_count(tokens, classStart) > 0 ||
        !csec_class_i32_fields(tokens, classStart).empty() || !csec_class_i1_fields(tokens, classStart).empty()) return true;
    for (const auto& parameter : csec_class_constructor_params(tokens, classStart)) {
        if (parameter.second == "Boolean") return true;
    }
    return false;
}

static std::string csec_class_i32_layout(const char* tokens, int classStart) {
    std::string layout;
    for (const auto& parameter : csec_class_constructor_params(tokens, classStart)) {
        const char* type = csec_llvm_type_for_name(parameter.second);
        if (std::strcmp(type, "i32") != 0 && std::strcmp(type, "i1") != 0) continue;
        if (!layout.empty()) layout += ", ";
        layout += type;
    }
    const std::string inherited = csec_class_inherited_field_layout(tokens, classStart);
    if (!inherited.empty()) {
        if (!layout.empty()) layout += ", ";
        layout += inherited;
    }
    for (size_t index = 0; index < csec_class_i32_fields(tokens, classStart).size(); ++index) {
        if (!layout.empty()) layout += ", ";
        layout += "i32";
    }
    for (size_t index = 0; index < csec_class_i1_fields(tokens, classStart).size(); ++index) {
        if (!layout.empty()) layout += ", ";
        layout += "i1";
    }
    return layout;
}

static int csec_enclosing_class_declaration(const char* tokens, int ordinal) {
    for (int cursor = 0; csec_token_kind_at(tokens, cursor) != 'E'; ++cursor) {
        if (!csec_native_token_is(tokens, cursor, 'K', "class")) continue;
        const int bodyStart = csec_find_decl_body_start(tokens, cursor);
        const int bodyEnd = csec_find_decl_body_end(tokens, bodyStart);
        if (bodyStart >= 0 && ordinal >= bodyStart && ordinal < bodyEnd) return cursor;
    }
    return -1;
}

static bool csec_is_boolean_class_constructor_param(const char* tokens, int ordinal, const char* name) {
    const int classStart = csec_enclosing_class_declaration(tokens, ordinal);
    if (classStart < 0 || !name) return false;
    for (const auto& parameter : csec_class_constructor_params(tokens, classStart)) {
        if (parameter.first == name) return parameter.second == "Boolean";
    }
    for (const auto& field : csec_class_i1_fields(tokens, classStart)) {
        const size_t suffix = field.first.find(".addr.");
        if (suffix != std::string::npos && field.first.substr(0, suffix) == name) return true;
    }
    return false;
}

static std::string csec_class_parent_name(const char* tokens, int classStart) {
    const int bodyStart = csec_find_decl_body_start(tokens, classStart);
    for (int cursor = classStart + 1; bodyStart >= 0 && cursor < bodyStart; ++cursor) {
        if (csec_native_token_is(tokens, cursor, 'K', "extends") && csec_token_kind_at(tokens, cursor + 1) == 'I') {
            return csec_token_text_at(tokens, cursor + 1);
        }
    }
    return "";
}

static std::string csec_emit_class_field_initializers(const char* tokens, int classStart,
    const std::string& className, const std::string& object, const std::string& variableName, int& fieldIndex) {
    std::string output;
    const std::string parent = csec_class_parent_name(tokens, classStart);
    const int parentStart = parent.empty() ? -1 : csec_find_class_declaration(tokens, parent.c_str());
    if (parentStart >= 0) output += csec_emit_class_field_initializers(tokens, parentStart, className, object, variableName, fieldIndex);
    for (const auto& field : csec_class_i32_fields(tokens, classStart)) {
        const std::string value = "%" + variableName + ".init." + std::to_string(fieldIndex);
        const std::string slot = "%" + variableName + ".field." + std::to_string(fieldIndex);
        output += csec_emit_i32_expression(tokens, field.second.first, field.second.second, value);
        output += "  " + slot + " = getelementptr inbounds %class." + className + ", ptr %" + object + ", i32 0, i32 " + std::to_string(fieldIndex++) + "\n";
        output += "  store i32 " + value + ", ptr " + slot + "\n";
    }
    for (const auto& field : csec_class_i1_fields(tokens, classStart)) {
        const std::string value = "%" + variableName + ".init." + std::to_string(fieldIndex);
        const std::string slot = "%" + variableName + ".field." + std::to_string(fieldIndex);
        output += csec_emit_i1_expression(tokens, field.second.first, field.second.second, value);
        output += "  " + slot + " = getelementptr inbounds %class." + className + ", ptr %" + object + ", i32 0, i32 " + std::to_string(fieldIndex++) + "\n";
        output += "  store i1 " + value + ", ptr " + slot + "\n";
    }
    return output;
}

static std::string csec_class_method_definition(const char* tokens, int classStart, int methodStart) {
    const std::string className = csec_top_level_decl_name(tokens, classStart);
    const std::string methodName = csec_top_level_decl_name(tokens, methodStart);
    char* raw = csec_generate_llvm_function_definition(tokens, methodStart);
    if (!raw) return "";
    std::string definition(raw);
    const std::string original = "@" + methodName + "(";
    const std::string replacement = "@" + className + "_" + methodName + "(";
    size_t position = 0;
    while ((position = definition.find(original, position)) != std::string::npos) {
        definition.replace(position, original.size(), replacement);
        position += replacement.size();
    }

    const auto fields = csec_class_constructor_params(tokens, classStart);
    const auto declaredFields = csec_class_i32_fields(tokens, classStart);
    const auto declaredBooleanFields = csec_class_i1_fields(tokens, classStart);
    if (fields.empty() && declaredFields.empty() && !csec_class_uses_pointer_receiver(tokens, classStart)) return definition;
    const size_t open = definition.find(replacement);
    const size_t paramsStart = open == std::string::npos ? std::string::npos : open + replacement.size();
    const size_t paramsEnd = paramsStart == std::string::npos ? std::string::npos : definition.find(") {\nentry:\n", paramsStart);
    if (paramsEnd == std::string::npos) return definition;
    const bool pointerReceiver = csec_class_uses_pointer_receiver(tokens, classStart);
    std::string receiverParams;
    std::string receiverAllocas;
    int fieldIndex = 0;
    if (pointerReceiver) {
        receiverParams = "ptr %arg.this";
        for (const auto& field : fields) {
            const char* fieldType = csec_llvm_type_for_name(field.second);
            if (std::strcmp(fieldType, "i32") != 0 && std::strcmp(fieldType, "i1") != 0) continue;
            receiverAllocas += "  %" + field.first + " = getelementptr inbounds %class." + className + ", ptr %arg.this, i32 0, i32 " + std::to_string(fieldIndex++) + "\n";
        }
        fieldIndex += csec_class_inherited_field_count(tokens, classStart);
        for (const auto& field : declaredFields) {
            receiverAllocas += "  %" + field.first + " = getelementptr inbounds %class." + className + ", ptr %arg.this, i32 0, i32 " + std::to_string(fieldIndex++) + "\n";
            const size_t suffix = field.first.find(".addr.");
            if (suffix != std::string::npos) {
                receiverAllocas += "  %" + field.first.substr(0, suffix) + " = getelementptr inbounds %class." + className + ", ptr %arg.this, i32 0, i32 " + std::to_string(fieldIndex - 1) + "\n";
            }
        }
        for (const auto& field : declaredBooleanFields) {
            receiverAllocas += "  %" + field.first + " = getelementptr inbounds %class." + className + ", ptr %arg.this, i32 0, i32 " + std::to_string(fieldIndex++) + "\n";
            const size_t suffix = field.first.find(".addr.");
            if (suffix != std::string::npos) {
                receiverAllocas += "  %" + field.first.substr(0, suffix) + " = getelementptr inbounds %class." + className + ", ptr %arg.this, i32 0, i32 " + std::to_string(fieldIndex - 1) + "\n";
            }
        }
    } else for (const auto& field : fields) {
        if (std::strcmp(csec_llvm_type_for_name(field.second.c_str()), "i32") != 0) return definition;
        if (!receiverParams.empty()) receiverParams += ", ";
        receiverParams += "i32 %arg.this." + field.first;
        receiverAllocas += "  %" + field.first + " = alloca i32\n";
        receiverAllocas += "  store i32 %arg.this." + field.first + ", ptr %" + field.first + "\n";
    }
    if (paramsEnd > paramsStart) receiverParams += ", ";
    definition.insert(paramsStart, receiverParams);
    const size_t entry = definition.find("entry:\n");
    if (entry != std::string::npos) {
        for (const auto& field : declaredFields) {
            if (pointerReceiver) continue;
            const std::string value = "%this." + field.first;
            receiverAllocas += "  %" + field.first + " = alloca i32\n";
            receiverAllocas += csec_emit_i32_expression(tokens, field.second.first, field.second.second, value);
            receiverAllocas += "  store i32 " + value + ", ptr %" + field.first + "\n";
        }
        definition.insert(entry + 7, receiverAllocas);
    }
    return definition;
}

static std::string csec_object_method_definition(const char* tokens, int objectStart, int methodStart) {
    const std::string objectName = csec_top_level_decl_name(tokens, objectStart);
    const std::string methodName = csec_top_level_decl_name(tokens, methodStart);
    char* raw = csec_generate_llvm_function_definition(tokens, methodStart);
    if (!raw) return "";
    std::string definition(raw);
    const std::string original = "@" + methodName + "(";
    const std::string replacement = "@" + objectName + "_" + methodName + "(";
    size_t position = 0;
    while ((position = definition.find(original, position)) != std::string::npos) {
        definition.replace(position, original.size(), replacement);
        position += replacement.size();
    }
    const size_t entry = definition.find("entry:\n");
    if (entry == std::string::npos) return definition;
    std::string initializers;
    for (const auto& field : csec_class_i32_fields(tokens, objectStart)) {
        const std::string value = "%object." + field.first;
        initializers += "  %" + field.first + " = alloca i32\n";
        initializers += csec_emit_i32_expression(tokens, field.second.first, field.second.second, value);
        initializers += "  store i32 " + value + ", ptr %" + field.first + "\n";
    }
    definition.insert(entry + 7, initializers);
    return definition;
}

static bool csec_lambda_declaration(const char* tokens, int declaration, int declarationEnd, int* bodyStart = nullptr, int* bodyEnd = nullptr) {
    const int initializer = csec_find_top_level_operator(tokens, declaration, declarationEnd, 1);
    const int start = initializer + 1;
    if (initializer < declaration || !csec_native_token_is(tokens, start, 'O', "[")) return false;
    const int arrow = csec_find_lambda_arrow(tokens, start, declarationEnd);
    const int open = arrow >= 0 ? csec_find_token_text_in_range(tokens, arrow + 1, declarationEnd, "{") : -1;
    const int close = open >= 0 ? csec_find_closing_token(tokens, open, declarationEnd, "{", "}") : -1;
    if (arrow < 0 || open < 0 || close < open) return false;
    if (bodyStart) *bodyStart = open + 1;
    if (bodyEnd) *bodyEnd = close;
    return true;
}

static std::string csec_lambda_function_name(int declaration) {
    return "csec_lambda_" + std::to_string(declaration);
}

extern "C++" {
static std::vector<std::string> csec_lambda_capture_names(const char* tokens, int declaration, int declarationEnd) {
    std::vector<std::string> captures;
    const int initializer = csec_find_top_level_operator(tokens, declaration, declarationEnd, 1);
    const int open = initializer + 1;
    const int close = open >= 0 ? csec_find_closing_token(tokens, open, declarationEnd, "[", "]") : -1;
    if (close <= open + 1) return captures;
    bool captureAll = false;
    for (int cursor = open + 1; cursor < close; ++cursor) {
        if (csec_native_token_is(tokens, cursor, 'O', "=") || csec_native_token_is(tokens, cursor, 'O', "&")) captureAll = true;
        if (csec_token_kind_at(tokens, cursor) == 'I') captures.emplace_back(csec_token_text_at(tokens, cursor));
    }
    if (!captureAll) return captures;

    const int arrow = csec_find_lambda_arrow(tokens, open, declarationEnd);
    const int paramOpen = arrow >= 0 ? csec_find_closing_token(tokens, open, declarationEnd, "[", "]") + 1 : -1;
    const int paramClose = paramOpen >= 0 ? csec_find_closing_token(tokens, paramOpen, declarationEnd, "(", ")") : -1;
    const int bodyOpen = arrow >= 0 ? csec_find_token_text_in_range(tokens, arrow + 1, declarationEnd, "{") : -1;
    const int bodyClose = bodyOpen >= 0 ? csec_find_closing_token(tokens, bodyOpen, declarationEnd, "{", "}") : -1;
    if (paramClose < paramOpen || bodyClose < bodyOpen) return captures;
    std::vector<std::string> parameters;
    for (int cursor = paramOpen + 1; cursor < paramClose; ++cursor) {
        if (csec_token_kind_at(tokens, cursor) == 'I') parameters.emplace_back(csec_token_text_at(tokens, cursor));
    }
    for (int cursor = bodyOpen + 1; cursor < bodyClose; ++cursor) {
        if (csec_token_kind_at(tokens, cursor) != 'I') continue;
        const std::string name = csec_token_text_at(tokens, cursor);
        if (std::find(parameters.begin(), parameters.end(), name) != parameters.end() ||
            std::find(captures.begin(), captures.end(), name) != captures.end()) continue;
        if (csec_find_visible_local(tokens, declaration, name.c_str()) >= 0) captures.push_back(name);
    }
    return captures;
}
}

static bool csec_lambda_captures_by_reference(const char* tokens, int declaration, int declarationEnd) {
    const int initializer = csec_find_top_level_operator(tokens, declaration, declarationEnd, 1);
    const int open = initializer + 1;
    const int close = open >= 0 ? csec_find_closing_token(tokens, open, declarationEnd, "[", "]") : -1;
    for (int cursor = open + 1; close > open && cursor < close; ++cursor) {
        if (csec_native_token_is(tokens, cursor, 'O', "&")) return true;
    }
    return false;
}

static std::string csec_lambda_closure_type_name(int declaration) {
    return "%csec.lambda.closure." + std::to_string(declaration);
}

static std::string csec_lambda_environment_type_name(int declaration) {
    return "%csec.lambda.environment." + std::to_string(declaration);
}

static std::string csec_lambda_type_definitions(const char* tokens) {
    std::string output;
    for (int cursor = 0; csec_token_kind_at(tokens, cursor) != 'E'; ++cursor) {
        if (!csec_native_token_is(tokens, cursor, 'K', "val") && !csec_native_token_is(tokens, cursor, 'K', "var")) continue;
        const int end = csec_advance_statement(tokens, cursor, 1000000000);
        if (!csec_lambda_declaration(tokens, cursor, end)) continue;
        output += csec_lambda_closure_type_name(cursor) + " = type { ptr, ptr }\n";
        const auto captures = csec_lambda_capture_names(tokens, cursor, end);
        if (!captures.empty()) {
            output += csec_lambda_environment_type_name(cursor) + " = type { ";
            for (size_t index = 0; index < captures.size(); ++index) {
                if (index != 0) output += ", ";
                output += csec_lambda_captures_by_reference(tokens, cursor, end) ? "ptr" : "i32";
            }
            output += " }\n";
        }
    }
    return output.empty() ? output : output + "\n";
}

static std::string csec_lambda_definition(const char* tokens, int declaration, int declarationEnd) {
    int bodyStart = -1, bodyEnd = -1;
    if (!csec_lambda_declaration(tokens, declaration, declarationEnd, &bodyStart, &bodyEnd)) return "";
    const int initializer = csec_find_top_level_operator(tokens, declaration, declarationEnd, 1);
    const int captureClose = csec_find_closing_token(tokens, initializer + 1, declarationEnd, "[", "]");
    const int paramOpen = captureClose >= 0 ? captureClose + 1 : -1;
    const int paramClose = paramOpen >= 0 ? csec_find_closing_token(tokens, paramOpen, declarationEnd, "(", ")") : -1;
    if (paramClose < paramOpen) return "";
    std::string parameters = "ptr %arg.env";
    std::string allocas;
    const bool byReference = csec_lambda_captures_by_reference(tokens, declaration, declarationEnd);
    int captureIndex = 0;
    for (const std::string& capture : csec_lambda_capture_names(tokens, declaration, declarationEnd)) {
        const int sourceDeclaration = csec_find_visible_local(tokens, declaration, capture.c_str());
        const std::string storage = sourceDeclaration >= 0
            ? capture + ".addr." + std::to_string(sourceDeclaration)
            : capture;
        const std::string environmentField = "%capture.env." + std::to_string(captureIndex++);
        allocas += "  " + environmentField + " = getelementptr inbounds " + csec_lambda_environment_type_name(declaration) +
            ", ptr %arg.env, i32 0, i32 " + std::to_string(captureIndex - 1) + "\n";
        if (byReference) {
            allocas += "  %" + storage + " = load ptr, ptr " + environmentField + "\n";
        } else {
            allocas += "  %" + storage + " = alloca i32\n";
            allocas += "  %capture.value." + std::to_string(captureIndex - 1) + " = load i32, ptr " + environmentField + "\n";
            allocas += "  store i32 %capture.value." + std::to_string(captureIndex - 1) + ", ptr %" + storage + "\n";
        }
    }
    for (int cursor = paramOpen + 1; cursor < paramClose;) {
        if (csec_token_kind_at(tokens, cursor) != 'I') { ++cursor; continue; }
        const std::string name = csec_token_text_at(tokens, cursor++);
        parameters += ", ";
        parameters += "i32 %arg." + name;
        allocas += "  %" + name + " = alloca i32\n  store i32 %arg." + name + ", ptr %" + name + "\n";
        while (cursor < paramClose && !csec_native_token_is(tokens, cursor, 'O', ",")) ++cursor;
        if (cursor < paramClose) ++cursor;
    }
    int returnStart = -1;
    int returnEnd = -1;
    for (int cursor = bodyStart; cursor < bodyEnd;) {
        const int next = csec_advance_statement(tokens, cursor, bodyEnd);
        if (csec_native_token_is(tokens, cursor, 'K', "return")) {
            returnStart = cursor + 1;
            returnEnd = next;
            break;
        }
        if (next <= cursor) break;
        cursor = next;
    }
    const bool returnsBoolean = returnStart >= 0 && csec_expression_is_boolean(tokens, returnStart, returnEnd);
    std::string definition = "define " + std::string(returnsBoolean ? "i1" : "i32") + " @" +
        csec_lambda_function_name(declaration) + "(" + parameters + ") {\nentry:\n" + allocas;
    if (returnsBoolean) {
        definition += csec_emit_i1_expression(tokens, returnStart, returnEnd, "%ret");
        definition += "  ret i1 %ret\n";
    } else {
        char* body = csec_generate_llvm_flat_body_i32(tokens, bodyStart, bodyEnd);
        if (body) definition += body;
        if (definition.find("ret i32") == std::string::npos) definition += "  ret i32 0\n";
    }
    definition += "}\n\n";
    return definition;
}

static std::string csec_lambda_definitions(const char* tokens) {
    std::string output;
    for (int cursor = 0; csec_token_kind_at(tokens, cursor) != 'E'; ++cursor) {
        if (!csec_native_token_is(tokens, cursor, 'K', "val") && !csec_native_token_is(tokens, cursor, 'K', "var")) continue;
        const int end = csec_advance_statement(tokens, cursor, 1000000000);
        if (end <= cursor) continue;
        output += csec_lambda_definition(tokens, cursor, end);
    }
    return output;
}

static int csec_enclosing_function_declaration(const char* tokens, int ordinal) {
    for (int cursor = 0; csec_token_kind_at(tokens, cursor) != 'E'; ++cursor) {
        if (!csec_native_token_is(tokens, cursor, 'K', "def")) continue;
        const int bodyStart = csec_find_decl_body_start(tokens, cursor);
        const int bodyEnd = csec_find_decl_body_end(tokens, bodyStart);
        if (bodyStart >= 0 && ordinal >= bodyStart && ordinal < bodyEnd) return cursor;
    }
    return -1;
}

static bool csec_is_function_parameter(const char* tokens, int ordinal, const char* name) {
    const int function = csec_enclosing_function_declaration(tokens, ordinal);
    if (function < 0 || !name) return false;
    for (const auto& parameter : csec_function_params(tokens, function)) {
        if (parameter.first == name) return parameter.second == "(";
    }
    return false;
}

static bool csec_is_i32_array_parameter(const char* tokens, int ordinal, const char* name) {
    const int function = csec_enclosing_function_declaration(tokens, ordinal);
    if (function < 0 || !name) return false;
    for (const auto& parameter : csec_function_params(tokens, function)) {
        if (parameter.first == name) return parameter.second == "Vector" || parameter.second == "Array";
    }
    return false;
}

static bool csec_is_boolean_parameter(const char* tokens, int ordinal, const char* name) {
    const int function = csec_enclosing_function_declaration(tokens, ordinal);
    if (function < 0 || !name) return false;
    for (const auto& parameter : csec_function_params(tokens, function)) {
        if (parameter.first == name) return parameter.second == "Boolean";
    }
    return false;
}

static bool csec_is_boolean_local(const char* tokens, int ordinal, const char* name) {
    const int declaration = csec_find_visible_local(tokens, ordinal, name);
    if (declaration < 0) return false;
    const int end = csec_advance_statement(tokens, declaration, 1000000000);
    const int initializer = csec_find_top_level_operator(tokens, declaration, end, 1);
    return csec_c_local_type(tokens, declaration, end, initializer) == "Boolean";
}

static bool csec_is_string_parameter(const char* tokens, int ordinal, const char* name) {
    const int function = csec_enclosing_function_declaration(tokens, ordinal);
    if (function < 0 || !name) return false;
    for (const auto& parameter : csec_function_params(tokens, function)) {
        if (parameter.first == name) return parameter.second == "String";
    }
    return false;
}

static bool csec_is_string_local(const char* tokens, int ordinal, const char* name) {
    const int declaration = csec_find_visible_local(tokens, ordinal, name);
    if (declaration < 0) return false;
    const int end = csec_advance_statement(tokens, declaration, 1000000000);
    const int initializer = csec_find_top_level_operator(tokens, declaration, end, 1);
    return csec_c_local_type(tokens, declaration, end, initializer) == "String";
}

static bool csec_is_string_expression(const char* tokens, int start, int end) {
    end = csec_i32_expression_end(tokens, start, end);
    if (end == start + 1) {
        if (csec_token_kind_at(tokens, start) == 'S') return true;
        return csec_token_kind_at(tokens, start) == 'I' &&
            (csec_is_string_local(tokens, start, csec_token_text_at(tokens, start)) ||
             csec_is_string_parameter(tokens, start, csec_token_text_at(tokens, start)));
    }
    const int operation = csec_i32_top_level_operator(tokens, start, end);
    return operation >= start && std::strcmp(csec_token_text_at(tokens, operation), "+") == 0 &&
        csec_is_string_expression(tokens, start, operation) &&
        csec_is_string_expression(tokens, operation + 1, end);
}

static bool csec_function_parameter_returns_boolean(const char* tokens, int ordinal, const char* name) {
    const int function = csec_enclosing_function_declaration(tokens, ordinal);
    const int paramEnd = function >= 0 ? csec_function_param_end(tokens, function) : -1;
    if (paramEnd < 0 || !name) return false;
    for (int cursor = function; cursor < paramEnd; ++cursor) {
        if (csec_token_kind_at(tokens, cursor) != 'I' || std::strcmp(csec_token_text_at(tokens, cursor), name) != 0 ||
            !csec_native_token_is(tokens, cursor + 1, 'O', ":") ||
            !csec_native_token_is(tokens, cursor + 2, 'O', "(")) continue;
        const int close = csec_find_closing_token(tokens, cursor + 2, paramEnd, "(", ")");
        return close >= 0 && csec_native_token_is(tokens, close + 1, 'O', "=>") &&
            std::strcmp(csec_token_text_at(tokens, close + 2), "Boolean") == 0;
    }
    return false;
}

static int csec_top_level_function_declaration(const char* tokens, const char* name) {
    for (int cursor = 0; csec_token_kind_at(tokens, cursor) != 'E';) {
        const int next = csec_advance_top_level_decl(tokens, cursor);
        if (next <= cursor) break;
        if (std::strcmp(csec_top_level_decl_kind(tokens, cursor), "function") == 0 &&
            std::strcmp(csec_top_level_decl_name(tokens, cursor), name ? name : "") == 0) return cursor;
        cursor = next;
    }
    return -1;
}

static bool csec_expression_is_boolean(const char* tokens, int start, int end) {
    end = csec_i32_expression_end(tokens, start, end);
    if (end <= start) return false;
    if (csec_native_token_is(tokens, start, 'O', "(") &&
        csec_find_closing_token(tokens, start, end, "(", ")") == end - 1) {
        return csec_expression_is_boolean(tokens, start + 1, end - 1);
    }
    if (csec_native_token_is(tokens, start, 'O', "!")) return true;
    if (csec_token_kind_at(tokens, start) == 'B') return true;
    for (int cursor = start; cursor < end; ++cursor) {
        const char* text = csec_token_text_at(tokens, cursor);
        if (std::strcmp(text, "==") == 0 || std::strcmp(text, "!=") == 0 ||
            std::strcmp(text, "<") == 0 || std::strcmp(text, "<=") == 0 ||
            std::strcmp(text, ">") == 0 || std::strcmp(text, ">=") == 0 ||
            std::strcmp(text, "&&") == 0 || std::strcmp(text, "||") == 0 ||
            std::strcmp(text, "and") == 0 || std::strcmp(text, "or") == 0) return true;
    }
    if (csec_token_kind_at(tokens, start) == 'I' && start + 1 < end && csec_native_token_is(tokens, start + 1, 'O', "(")) {
        if (csec_function_parameter_returns_boolean(tokens, start, csec_token_text_at(tokens, start))) return true;
        const int function = csec_top_level_function_declaration(tokens, csec_token_text_at(tokens, start));
        return function >= 0 && std::strcmp(csec_function_return_type_at(tokens, function), "Boolean") == 0;
    }
    return false;
}

static int csec_find_class_method_declaration(const char* tokens, int classStart, const char* methodName) {
    const int bodyStart = csec_find_decl_body_start(tokens, classStart);
    const int bodyEnd = csec_find_decl_body_end(tokens, bodyStart);
    for (int cursor = bodyStart; cursor >= 0 && cursor < bodyEnd; ++cursor) {
        if (csec_native_token_is(tokens, cursor, 'K', "def") &&
            std::strcmp(csec_top_level_decl_name(tokens, cursor), methodName ? methodName : "") == 0) return cursor;
    }
    return -1;
}

static bool csec_emit_i32_instance_call(const char* tokens, int start, int end, const std::string& resultName, std::string& output) {
    if (csec_token_kind_at(tokens, start) != 'I' || start + 3 >= end ||
        !csec_native_token_is(tokens, start + 1, 'O', ".") || csec_token_kind_at(tokens, start + 2) != 'I' ||
        !csec_native_token_is(tokens, start + 3, 'O', "(")) return false;
    const int callClose = csec_find_closing_token(tokens, start + 3, end, "(", ")");
    if (callClose != end - 1) return false;
    const int declaration = csec_find_visible_local(tokens, start, csec_token_text_at(tokens, start));
    const int declarationEnd = declaration >= 0 ? csec_advance_statement(tokens, declaration, 1000000000) : -1;
    const int initializer = declaration >= 0 ? csec_find_top_level_operator(tokens, declaration, declarationEnd, 1) : -1;
    const int instanceStart = initializer + 1;
    if (initializer < declaration || !csec_native_token_is(tokens, instanceStart, 'K', "new") ||
        csec_token_kind_at(tokens, instanceStart + 1) != 'I' || !csec_native_token_is(tokens, instanceStart + 2, 'O', "(")) return false;
    const int constructorClose = csec_find_closing_token(tokens, instanceStart + 2, declarationEnd, "(", ")");
    if (constructorClose < instanceStart + 2) return false;

    std::string arguments;
    int argumentIndex = 0;
    auto appendArguments = [&](int first, int close) {
        for (int cursor = first, itemStart = first; cursor <= close; ++cursor) {
            if (cursor == close || csec_native_token_is(tokens, cursor, 'O', ",")) {
                if (cursor > itemStart) {
                    const std::string value = resultName + ".arg" + std::to_string(argumentIndex++);
                    output += csec_emit_i32_expression(tokens, itemStart, cursor, value);
                    if (!arguments.empty()) arguments += ", ";
                    arguments += "i32 " + value;
                }
                itemStart = cursor + 1;
            }
        }
    };
    const char* className = csec_token_text_at(tokens, instanceStart + 1);
    const int classStart = csec_find_class_declaration(tokens, className);
    if (classStart >= 0 && csec_class_uses_pointer_receiver(tokens, classStart)) {
        const std::string receiver = resultName + ".this";
        const char* storage = csec_lookup_visible_storage_name(tokens, start, csec_token_text_at(tokens, start));
        output += "  " + receiver + " = load ptr, ptr %" + std::string(storage) + "\n";
        arguments = "ptr " + receiver;
    } else appendArguments(instanceStart + 3, constructorClose);
    appendArguments(start + 4, callClose);
    const int methodStart = classStart >= 0 ? csec_find_class_method_declaration(tokens, classStart, csec_token_text_at(tokens, start + 2)) : -1;
    if (methodStart >= 0 && std::strcmp(csec_function_return_type_at(tokens, methodStart), "Boolean") == 0) {
        const std::string booleanResult = resultName + ".i1";
        output += "  " + booleanResult + " = call i1 @" + std::string(className) +
            "_" + csec_token_text_at(tokens, start + 2) + "(" + arguments + ")\n";
        output += "  " + resultName + " = zext i1 " + booleanResult + " to i32\n";
    } else output += "  " + resultName + " = call i32 @" + std::string(className) +
        "_" + csec_token_text_at(tokens, start + 2) + "(" + arguments + ")\n";
    return true;
}

static std::string csec_emit_i32_block_expression(const char* tokens, int start, int end, const std::string& resultName) {
    std::string output;
    int cursor = csec_expression_ast_skip_trivia(tokens, start + 1);
    const int close = end - 1;
    while (cursor >= 0 && cursor < close && csec_token_kind_at(tokens, cursor) != 'E') {
        const int next = csec_advance_statement(tokens, cursor, close);
        if (next <= cursor) break;
        const bool declaration = csec_native_token_is(tokens, cursor, 'K', "val") ||
            csec_native_token_is(tokens, cursor, 'K', "var");
        if (declaration && csec_token_kind_at(tokens, cursor + 1) == 'I') {
            const std::string name = csec_token_text_at(tokens, cursor + 1);
            const std::string storage = name + ".addr." + std::to_string(cursor);
            const int initializer = csec_find_token_text_in_range(tokens, cursor + 2, next, "=");
            output += "  %" + storage + " = alloca i32\n";
            if (initializer >= 0 && initializer + 1 < next) {
                const std::string value = "%" + name + ".init." + std::to_string(cursor);
                output += csec_emit_i32_expression(tokens, initializer + 1, next, value);
                output += "  store i32 " + value + ", ptr %" + storage + "\n";
            } else {
                output += "  store i32 0, ptr %" + storage + "\n";
            }
        } else if (next >= close) {
            output += csec_emit_i32_expression(tokens, cursor, next, resultName);
            return output;
        }
        cursor = csec_expression_ast_skip_trivia(tokens, next);
    }
    return output + "  " + resultName + " = add i32 0, 0\n";
}

static std::string csec_emit_i32_match_expression(const char* tokens, int start, int end, int matchToken, const std::string& resultName) {
    struct MatchCase { int patternStart; int expressionStart; int expressionEnd; bool fallback; };
    const int openBrace = csec_find_token_text_in_range(tokens, matchToken + 1, end, "{");
    const int closeBrace = openBrace >= 0 ? csec_find_closing_token(tokens, openBrace, end, "{", "}") : -1;
    if (openBrace < 0 || closeBrace != end - 1) return "  " + resultName + " = add i32 0, 0\n";

    std::vector<MatchCase> cases;
    for (int cursor = openBrace + 1; cursor < closeBrace;) {
        if (!csec_native_token_is(tokens, cursor, 'K', "case")) { ++cursor; continue; }
        const int arrow = csec_find_token_text_in_range(tokens, cursor + 1, closeBrace, "=>");
        if (arrow < 0) break;
        int nextCase = closeBrace;
        for (int probe = arrow + 1; probe < closeBrace; ++probe) {
            if (csec_native_token_is(tokens, probe, 'K', "case")) { nextCase = probe; break; }
        }
        cases.push_back({cursor + 1, arrow + 1, nextCase, csec_native_token_is(tokens, cursor + 1, 'I', "_")});
        cursor = nextCase;
    }
    if (cases.empty()) return "  " + resultName + " = add i32 0, 0\n";

    std::string output;
    const std::string subject = resultName + ".match.subject";
    output += csec_emit_i32_expression(tokens, start, matchToken, subject);
    const MatchCase* fallback = nullptr;
    for (const MatchCase& item : cases) if (item.fallback) { fallback = &item; break; }
    std::string value = resultName + ".match.default";
    if (fallback) output += csec_emit_i32_expression(tokens, fallback->expressionStart, fallback->expressionEnd, value);
    else output += "  " + value + " = add i32 0, 0\n";
    for (int index = static_cast<int>(cases.size()) - 1; index >= 0; --index) {
        const MatchCase& item = cases[static_cast<size_t>(index)];
        if (item.fallback) continue;
        const std::string pattern = resultName + ".match.pattern." + std::to_string(index);
        const std::string branchValue = resultName + ".match.value." + std::to_string(index);
        const std::string comparison = resultName + ".match.comparison." + std::to_string(index);
        const std::string selected = resultName + ".match.selected." + std::to_string(index);
        output += csec_emit_i32_expression(tokens, item.patternStart, item.expressionStart - 1, pattern);
        output += csec_emit_i32_expression(tokens, item.expressionStart, item.expressionEnd, branchValue);
        output += "  " + comparison + " = icmp eq i32 " + subject + ", " + pattern + "\n";
        output += "  " + selected + " = select i1 " + comparison + ", i32 " + branchValue + ", i32 " + value + "\n";
        value = selected;
    }
    return output + "  " + resultName + " = add i32 0, " + value + "\n";
}

static bool csec_i32_static_index(const char* tokens, int start, int end, int* value) {
    if (!value || end != start + 1 || csec_token_kind_at(tokens, start) != 'N') return false;
    *value = static_cast<int>(std::strtoll(csec_token_text_at(tokens, start), nullptr, 0));
    return *value >= 0;
}

static bool csec_literal_array_item(const char* tokens, int open, int close, int wanted, int* itemStart, int* itemEnd) {
    int item = 0;
    int start = open + 1;
    int paren = 0;
    int bracket = 0;
    int brace = 0;
    for (int cursor = start; cursor <= close; ++cursor) {
        const char* text = cursor < close ? csec_token_text_at(tokens, cursor) : ",";
        if (cursor < close && std::strcmp(text, "(") == 0) ++paren;
        else if (cursor < close && std::strcmp(text, ")") == 0) --paren;
        else if (cursor < close && std::strcmp(text, "[") == 0) ++bracket;
        else if (cursor < close && std::strcmp(text, "]") == 0) --bracket;
        else if (cursor < close && std::strcmp(text, "{") == 0) ++brace;
        else if (cursor < close && std::strcmp(text, "}") == 0) --brace;
        if ((cursor == close || (std::strcmp(text, ",") == 0 && paren == 0 && bracket == 0 && brace == 0)) && cursor > start) {
            if (item == wanted) {
                *itemStart = start;
                *itemEnd = cursor;
                return true;
            }
            ++item;
            start = cursor + 1;
        }
    }
    return false;
}

static std::string csec_emit_i32_literal_array_index(const char* tokens, int start, int end, const std::string& resultName) {
    if (csec_token_kind_at(tokens, start) != 'I' || !csec_native_token_is(tokens, start + 1, 'O', "[")) return "";
    const int declaration = csec_find_visible_local(tokens, start, csec_token_text_at(tokens, start));
    const int declarationEnd = declaration >= 0 ? csec_advance_statement(tokens, declaration, csec_token_kind_at(tokens, declaration) == 'E' ? declaration : 1000000000) : -1;
    const int initializer = declaration >= 0 ? csec_find_token_text_in_range(tokens, declaration + 2, declarationEnd, "=") : -1;
    if (initializer < 0 || !csec_native_token_is(tokens, initializer + 1, 'O', "[")) return "";
    int itemStart = initializer + 1;
    int itemEnd = csec_find_closing_token(tokens, itemStart, declarationEnd, "[", "]");
    int cursor = start + 1;
    while (cursor < end && csec_native_token_is(tokens, cursor, 'O', "[")) {
        const int close = csec_find_closing_token(tokens, cursor, end, "[", "]");
        int index = 0;
        if (close < 0 || !csec_i32_static_index(tokens, cursor + 1, close, &index) ||
            !csec_literal_array_item(tokens, itemStart, itemEnd, index, &itemStart, &itemEnd)) return "";
        cursor = close + 1;
        if (cursor < end) {
            if (!csec_native_token_is(tokens, itemStart, 'O', "[")) return "";
            itemEnd = csec_find_closing_token(tokens, itemStart, itemEnd, "[", "]");
        }
    }
    if (cursor != end || itemStart >= itemEnd) return "";
    return csec_emit_i32_expression(tokens, itemStart, itemEnd, resultName);
}

static bool csec_is_i32_array_initializer(const char* tokens, int initializer, int end) {
    return initializer >= 0 && initializer + 1 < end &&
        (csec_native_token_is(tokens, initializer + 1, 'O', "[") ||
         (csec_native_token_is(tokens, initializer + 1, 'K', "new") &&
          csec_native_token_is(tokens, initializer + 2, 'I', "Int") &&
          csec_native_token_is(tokens, initializer + 3, 'O', "[")));
}

static bool csec_visible_i32_array(const char* tokens, int limit, const char* name) {
    const int declaration = csec_find_visible_local(tokens, limit, name);
    if (declaration < 0) return csec_is_i32_array_parameter(tokens, limit, name);
    const int declarationEnd = csec_advance_statement(tokens, declaration, 1000000000);
    const int initializer = csec_find_token_text_in_range(tokens, declaration + 2, declarationEnd, "=");
    return csec_is_i32_array_initializer(tokens, initializer, declarationEnd);
}

static std::string csec_emit_i32_array_index(const char* tokens, int start, int end, const std::string& resultName) {
    if (csec_token_kind_at(tokens, start) != 'I' || !csec_native_token_is(tokens, start + 1, 'O', "[") ||
        !csec_visible_i32_array(tokens, start, csec_token_text_at(tokens, start))) return "";
    const int close = csec_find_closing_token(tokens, start + 1, end, "[", "]");
    if (close < 0 || close + 1 != end) return "";
    const std::string name = csec_token_text_at(tokens, start);
    const std::string storage = csec_lookup_visible_storage_name(tokens, start, name.c_str());
    const std::string index = resultName + ".index";
    const std::string data = resultName + ".data";
    const std::string element = resultName + ".element";
    return csec_emit_i32_expression(tokens, start + 2, close, index) +
        "  " + data + " = load ptr, ptr %" + storage + "\n" +
        "  " + element + " = getelementptr inbounds i32, ptr " + data + ", i32 " + index + "\n" +
        "  " + resultName + " = load i32, ptr " + element + "\n";
}

static std::string csec_emit_i32_array_local(const char* tokens, int declaration, int end) {
    const std::string name = csec_token_text_at(tokens, declaration + 1);
    const std::string storage = name + ".addr." + std::to_string(declaration);
    const int initializer = csec_find_top_level_operator(tokens, declaration, end, 1);
    const int valueStart = initializer + 1;
    const bool allocated = csec_native_token_is(tokens, valueStart, 'K', "new");
    const int open = allocated ? valueStart + 2 : valueStart;
    const int close = csec_find_closing_token(tokens, open, end, "[", "]");
    if (initializer < declaration || close < open) return "";

    std::string output = "  %" + storage + " = alloca ptr\n";
    const std::string countBase = "%" + name + ".count." + std::to_string(declaration);
    std::string count = countBase;
    if (allocated) output += "  " + count + " = add i32 0, 1\n";
    int itemStart = open + 1;
    int itemIndex = 0;
    for (int cursor = itemStart; cursor <= close; ++cursor) {
        if (cursor == close || csec_native_token_is(tokens, cursor, 'O', ",")) {
            if (cursor > itemStart) {
                const std::string value = "%" + name + ".size." + std::to_string(declaration) + "." + std::to_string(itemIndex++);
                if (allocated) {
                    output += csec_emit_i32_expression(tokens, itemStart, cursor, value);
                    const std::string nextCount = countBase + "." + std::to_string(itemIndex);
                    output += "  " + nextCount + " = mul i32 " + count + ", " + value + "\n";
                    count = nextCount;
                }
            }
            itemStart = cursor + 1;
        }
    }
    if (!allocated) {
        int countItems = 0;
        for (int cursor = open + 1; cursor < close; ++cursor) if (csec_native_token_is(tokens, cursor, 'O', ",")) ++countItems;
        if (close > open + 1) ++countItems;
        output += "  " + count + " = add i32 0, " + std::to_string(countItems) + "\n";
    }
    const std::string data = "%" + name + ".data." + std::to_string(declaration);
    output += "  " + data + " = alloca i32, i32 " + count + "\n";
    output += "  store ptr " + data + ", ptr %" + storage + "\n";
    if (!allocated) {
        itemStart = open + 1;
        itemIndex = 0;
        for (int cursor = itemStart; cursor <= close; ++cursor) {
            if (cursor == close || csec_native_token_is(tokens, cursor, 'O', ",")) {
                if (cursor > itemStart) {
                    const std::string value = "%" + name + ".item." + std::to_string(declaration) + "." + std::to_string(itemIndex);
                    const std::string element = "%" + name + ".element." + std::to_string(declaration) + "." + std::to_string(itemIndex++);
                    output += csec_emit_i32_expression(tokens, itemStart, cursor, value);
                    output += "  " + element + " = getelementptr inbounds i32, ptr " + data + ", i32 " + std::to_string(itemIndex - 1) + "\n";
                    output += "  store i32 " + value + ", ptr " + element + "\n";
                }
                itemStart = cursor + 1;
            }
        }
    }
    return output;
}

static std::string csec_emit_ptr_expression(const char* tokens, int start, int end, const std::string& resultName) {
    end = csec_i32_expression_end(tokens, start, end);
    const int operation = csec_i32_top_level_operator(tokens, start, end);
    if (operation >= start && csec_native_token_is(tokens, operation, 'O', "+") &&
        csec_is_string_expression(tokens, start, operation) && csec_is_string_expression(tokens, operation + 1, end)) {
        const std::string left = resultName + ".left";
        const std::string right = resultName + ".right";
        return csec_emit_ptr_expression(tokens, start, operation, left) +
            csec_emit_ptr_expression(tokens, operation + 1, end, right) +
            "  " + resultName + " = call ptr @csec_string_concat(ptr " + left + ", ptr " + right + ")\n";
    }
    if (end == start + 1 && csec_token_kind_at(tokens, start) == 'S') {
        return "  " + resultName + " = getelementptr inbounds [" +
            std::to_string(csec_llvm_string_literal_byte_length(csec_token_text_at(tokens, start))) +
            " x i8], ptr @.str." + std::to_string(start) + ", i32 0, i32 0\n";
    }
    if (end == start + 1 && csec_token_kind_at(tokens, start) == 'I' &&
        (csec_is_string_local(tokens, start, csec_token_text_at(tokens, start)) ||
         csec_is_string_parameter(tokens, start, csec_token_text_at(tokens, start)))) {
        const char* storage = csec_lookup_visible_storage_name(tokens, start, csec_token_text_at(tokens, start));
        return "  " + resultName + " = load ptr, ptr %" + std::string(storage) + "\n";
    }
    if (csec_token_kind_at(tokens, start) == 'I' && start + 1 < end && csec_native_token_is(tokens, start + 1, 'O', "(")) {
        const int callee = csec_top_level_function_declaration(tokens, csec_token_text_at(tokens, start));
        const int close = csec_find_closing_token(tokens, start + 1, end, "(", ")");
        if (callee >= 0 && close == end - 1 && std::strcmp(csec_function_return_type_at(tokens, callee), "String") == 0) {
            std::string output, arguments;
            int argumentStart = start + 2, index = 0;
            for (int cursor = argumentStart; cursor <= close; ++cursor) {
                if (cursor == close || csec_native_token_is(tokens, cursor, 'O', ",")) {
                    if (cursor > argumentStart) {
                        const std::string argument = resultName + ".arg" + std::to_string(index++);
                        output += csec_emit_ptr_expression(tokens, argumentStart, cursor, argument);
                        if (!arguments.empty()) arguments += ", ";
                        arguments += "ptr " + argument;
                    }
                    argumentStart = cursor + 1;
                }
            }
            return output + "  " + resultName + " = call ptr @" + std::string(csec_token_text_at(tokens, start)) + "(" + arguments + ")\n";
        }
    }
    return "  " + resultName + " = getelementptr i8, ptr null, i32 0\n";
}

static std::string csec_emit_i32_expression(const char* tokens, int start, int end, const std::string& resultName) {
    end = csec_i32_expression_end(tokens, start, end);
    if (end <= start) return "  " + resultName + " = add i32 0, 0\n";
    if (csec_native_token_is(tokens, start, 'O', "{") &&
        csec_find_closing_token(tokens, start, end, "{", "}") == end - 1) {
        return csec_emit_i32_block_expression(tokens, start, end, resultName);
    }
    if (csec_native_token_is(tokens, start, 'O', "[")) {
        const int captureClose = csec_find_closing_token(tokens, start, end, "[", "]");
        const int parameterOpen = captureClose >= 0 ? captureClose + 1 : -1;
        const int parameterClose = parameterOpen >= 0 && csec_native_token_is(tokens, parameterOpen, 'O', "(")
            ? csec_find_closing_token(tokens, parameterOpen, end, "(", ")") : -1;
        if (parameterClose >= 0 && csec_native_token_is(tokens, parameterClose + 1, 'O', "->")) {
            return "  " + resultName + " = add i32 0, 0\n";
        }
    }
    for (int cursor = start + 1; cursor < end; ++cursor) {
        if (csec_native_token_is(tokens, cursor, 'K', "match")) {
            return csec_emit_i32_match_expression(tokens, start, end, cursor, resultName);
        }
    }
    if (csec_native_token_is(tokens, start, 'O', "(") &&
        csec_find_closing_token(tokens, start, end, "(", ")") == end - 1) {
        return csec_emit_i32_expression(tokens, start + 1, end - 1, resultName);
    }
    if (csec_native_token_is(tokens, start, 'O', "+") && start + 1 < end) {
        return csec_emit_i32_expression(tokens, start + 1, end, resultName);
    }
    if (csec_native_token_is(tokens, start, 'O', "-") && start + 1 < end) {
        const std::string valueName = resultName + ".value";
        return csec_emit_i32_expression(tokens, start + 1, end, valueName) +
            "  " + resultName + " = sub i32 0, " + valueName + "\n";
    }
    if (csec_native_token_is(tokens, start, 'O', "!") && start + 1 < end) {
        const std::string valueName = resultName + ".value";
        const std::string comparisonName = resultName + ".comparison";
        return csec_emit_i32_expression(tokens, start + 1, end, valueName) +
            "  " + comparisonName + " = icmp eq i32 " + valueName + ", 0\n" +
            "  " + resultName + " = zext i1 " + comparisonName + " to i32\n";
    }
    if (csec_native_token_is(tokens, start, 'O', "~") && start + 1 < end) {
        const std::string valueName = resultName + ".value";
        return csec_emit_i32_expression(tokens, start + 1, end, valueName) +
            "  " + resultName + " = xor i32 " + valueName + ", -1\n";
    }
    // Array postfixes are expression atoms. Split a following binary operation
    // here so the array index is lowered before the normal precedence walker.
    if (csec_token_kind_at(tokens, start) == 'I' && csec_native_token_is(tokens, start + 1, 'O', "[")) {
        const int close = csec_find_closing_token(tokens, start + 1, end, "[", "]");
        if (close >= start + 2 && close + 2 < end) {
            const char* postfixOp = csec_token_text_at(tokens, close + 1);
            const char* instruction = std::strcmp(postfixOp, "+") == 0 ? "add" :
                (std::strcmp(postfixOp, "-") == 0 ? "sub" : (std::strcmp(postfixOp, "*") == 0 ? "mul" :
                (std::strcmp(postfixOp, "/") == 0 ? "sdiv" : (std::strcmp(postfixOp, "%") == 0 ? "srem" : nullptr))));
            if (instruction) {
                const std::string leftName = resultName + ".left";
                const std::string rightName = resultName + ".right";
                return csec_emit_i32_expression(tokens, start, close + 1, leftName) +
                    csec_emit_i32_expression(tokens, close + 2, end, rightName) +
                    "  " + resultName + " = " + instruction + " i32 " + leftName + ", " + rightName + "\n";
            }
        }
    }
    const int operation = csec_i32_top_level_operator(tokens, start, end);
    if (operation >= start) {
        const std::string leftName = resultName + ".left";
        const std::string rightName = resultName + ".right";
        const char* op = csec_token_text_at(tokens, operation);
        if ((std::strcmp(op, "==") == 0 || std::strcmp(op, "!=") == 0) &&
            csec_is_string_expression(tokens, start, operation) &&
            csec_is_string_expression(tokens, operation + 1, end)) {
            const std::string equal = resultName + ".equals";
            const std::string comparison = resultName + ".comparison";
            return csec_emit_ptr_expression(tokens, start, operation, leftName) +
                csec_emit_ptr_expression(tokens, operation + 1, end, rightName) +
                "  " + equal + " = call i32 @csec_string_equals(ptr " + leftName + ", ptr " + rightName + ")\n" +
                "  " + comparison + " = icmp " + (std::strcmp(op, "==") == 0 ? "ne" : "eq") + " i32 " + equal + ", 0\n" +
                "  " + resultName + " = zext i1 " + comparison + " to i32\n";
        }
        std::string output = csec_emit_i32_expression(tokens, start, operation, leftName);
        output += csec_emit_i32_expression(tokens, operation + 1, end, rightName);
        const char* instruction = "ashr";
        if (std::strcmp(op, "+") == 0) instruction = "add";
        else if (std::strcmp(op, "-") == 0) instruction = "sub";
        else if (std::strcmp(op, "*") == 0) instruction = "mul";
        else if (std::strcmp(op, "/") == 0) instruction = "sdiv";
        else if (std::strcmp(op, "%") == 0) instruction = "srem";
        else if (std::strcmp(op, "&") == 0) instruction = "and";
        else if (std::strcmp(op, "|") == 0) instruction = "or";
        else if (std::strcmp(op, "^") == 0) instruction = "xor";
        else if (std::strcmp(op, "<<") == 0) instruction = "shl";
        else if (std::strcmp(op, "and") == 0 || std::strcmp(op, "&&") == 0) instruction = "and";
        else if (std::strcmp(op, "or") == 0 || std::strcmp(op, "||") == 0) instruction = "or";
        else if (std::strcmp(op, "xor") == 0) instruction = "xor";
        if (std::strcmp(op, "==") == 0 || std::strcmp(op, "!=") == 0 ||
            std::strcmp(op, "<") == 0 || std::strcmp(op, "<=") == 0 ||
            std::strcmp(op, ">") == 0 || std::strcmp(op, ">=") == 0) {
            const char* predicate = std::strcmp(op, "==") == 0 ? "eq" :
                (std::strcmp(op, "!=") == 0 ? "ne" : (std::strcmp(op, "<") == 0 ? "slt" :
                (std::strcmp(op, "<=") == 0 ? "sle" : (std::strcmp(op, ">") == 0 ? "sgt" : "sge"))));
            const std::string comparisonName = resultName + ".comparison";
            return output + "  " + comparisonName + " = icmp " + predicate + " i32 " + leftName + ", " + rightName + "\n" +
                "  " + resultName + " = zext i1 " + comparisonName + " to i32\n";
        }
        return output + "  " + resultName + " = " + instruction + " i32 " + leftName + ", " + rightName + "\n";
    }
    const char kind = csec_token_kind_at(tokens, start);
    if (kind == 'N') return "  " + resultName + " = add i32 0, " + csec_i32_literal(csec_token_text_at(tokens, start)) + "\n";
    if (std::strcmp(csec_token_text_at(tokens, start), "true") == 0) return "  " + resultName + " = add i32 0, 1\n";
    if (std::strcmp(csec_token_text_at(tokens, start), "false") == 0) return "  " + resultName + " = add i32 0, 0\n";
    if (csec_token_kind_at(tokens, start) == 'I' && start + 2 < end && csec_native_token_is(tokens, start + 1, 'O', ".") &&
        csec_token_kind_at(tokens, start + 2) == 'I' &&
        (std::strcmp(csec_token_text_at(tokens, start + 2), "length") == 0 ||
         std::strcmp(csec_token_text_at(tokens, start + 2), "size") == 0)) {
        const bool property = start + 3 == end;
        const bool call = start + 5 == end && csec_native_token_is(tokens, start + 3, 'O', "(") &&
            csec_native_token_is(tokens, start + 4, 'O', ")");
        if (property || call) {
            const std::string value = resultName + ".string";
            const std::string length = resultName + ".length64";
            return csec_emit_ptr_expression(tokens, start, start + 1, value) +
                "  " + length + " = call i64 @csec_string_length(ptr " + value + ")\n" +
                "  " + resultName + " = trunc i64 " + length + " to i32\n";
        }
    }
    const std::string indexedLiteral = csec_emit_i32_literal_array_index(tokens, start, end, resultName);
    if (!indexedLiteral.empty()) return indexedLiteral;
    const std::string indexedArray = csec_emit_i32_array_index(tokens, start, end, resultName);
    if (!indexedArray.empty()) return indexedArray;
    std::string instanceCall;
    if (csec_emit_i32_instance_call(tokens, start, end, resultName, instanceCall)) return instanceCall;
    if (csec_native_token_is(tokens, start, 'K', "this") && start + 3 == end &&
        csec_native_token_is(tokens, start + 1, 'O', ".") && csec_token_kind_at(tokens, start + 2) == 'I') {
        const std::string field = csec_token_text_at(tokens, start + 2);
        return "  " + resultName + " = load i32, ptr %" + field + "\n";
    }
    if (csec_native_token_is(tokens, start, 'K', "super") && start + 4 < end &&
        csec_native_token_is(tokens, start + 1, 'O', ".") && csec_token_kind_at(tokens, start + 2) == 'I' &&
        csec_native_token_is(tokens, start + 3, 'O', "(")) {
        const int close = csec_find_closing_token(tokens, start + 3, end, "(", ")");
        const int classStart = csec_enclosing_class_declaration(tokens, start);
        const std::string parent = classStart >= 0 ? csec_class_parent_name(tokens, classStart) : "";
        if (close == end - 1 && !parent.empty()) {
            const int parentStart = csec_find_class_declaration(tokens, parent.c_str());
            if (csec_class_uses_pointer_receiver(tokens, classStart) && parentStart >= 0 &&
                csec_class_uses_pointer_receiver(tokens, parentStart)) {
                return "  " + resultName + " = call i32 @" + parent + "_" +
                    csec_token_text_at(tokens, start + 2) + "(ptr %arg.this)\n";
            }
            std::string output;
            std::string arguments;
            int argumentIndex = 0;
            for (const auto& parameter : csec_class_constructor_params(tokens, classStart)) {
                if (std::strcmp(csec_llvm_type_for_name(parameter.second.c_str()), "i32") != 0) continue;
                const std::string value = resultName + ".super.arg" + std::to_string(argumentIndex++);
                output += "  " + value + " = load i32, ptr %" + parameter.first + "\n";
                if (!arguments.empty()) arguments += ", ";
                arguments += "i32 " + value;
            }
            return output + "  " + resultName + " = call i32 @" + parent + "_" +
                csec_token_text_at(tokens, start + 2) + "(" + arguments + ")\n";
        }
    }
    if (kind == 'I' && start + 3 < end && csec_native_token_is(tokens, start + 1, 'O', ".") &&
        csec_token_kind_at(tokens, start + 2) == 'I' && csec_native_token_is(tokens, start + 3, 'O', "(")) {
        const int close = csec_find_closing_token(tokens, start + 3, end, "(", ")");
        if (close == end - 1) {
            std::string output;
            std::string arguments;
            int argumentStart = start + 4;
            int argumentIndex = 0;
            for (int cursor = argumentStart; cursor <= close; ++cursor) {
                if (cursor == close || csec_native_token_is(tokens, cursor, 'O', ",")) {
                    if (cursor > argumentStart) {
                        const std::string argumentName = resultName + ".arg" + std::to_string(argumentIndex++);
                        output += csec_emit_i32_expression(tokens, argumentStart, cursor, argumentName);
                        if (!arguments.empty()) arguments += ", ";
                        arguments += "i32 " + argumentName;
                    }
                    argumentStart = cursor + 1;
                }
            }
            return output + "  " + resultName + " = call i32 @" + std::string(csec_token_text_at(tokens, start)) +
                "_" + csec_token_text_at(tokens, start + 2) + "(" + arguments + ")\n";
        }
    }
    if (kind == 'I' && start + 1 < end && csec_native_token_is(tokens, start + 1, 'O', "(") &&
        csec_is_function_parameter(tokens, start, csec_token_text_at(tokens, start))) {
        const int close = csec_find_closing_token(tokens, start + 1, end, "(", ")");
        if (close == end - 1) {
            std::string output;
            std::string arguments;
            int argumentStart = start + 2;
            int argumentIndex = 0;
            for (int cursor = argumentStart; cursor <= close; ++cursor) {
                if (cursor == close || csec_native_token_is(tokens, cursor, 'O', ",")) {
                    if (cursor > argumentStart) {
                        const std::string argumentName = resultName + ".arg" + std::to_string(argumentIndex++);
                        output += csec_emit_i32_expression(tokens, argumentStart, cursor, argumentName);
                        if (!arguments.empty()) arguments += ", ";
                        arguments += "i32 " + argumentName;
                    }
                    argumentStart = cursor + 1;
                }
            }
            const char* storage = csec_lookup_visible_storage_name(tokens, start, csec_token_text_at(tokens, start));
            const std::string closure = resultName + ".closure";
            const std::string codeField = resultName + ".code.field";
            const std::string environmentField = resultName + ".environment.field";
            const std::string functionValue = resultName + ".fn";
            const std::string environment = resultName + ".environment";
            return output + "  " + closure + " = load ptr, ptr %" + std::string(storage) + "\n" +
                "  " + codeField + " = getelementptr inbounds { ptr, ptr }, ptr " + closure + ", i32 0, i32 0\n" +
                "  " + functionValue + " = load ptr, ptr " + codeField + "\n" +
                "  " + environmentField + " = getelementptr inbounds { ptr, ptr }, ptr " + closure + ", i32 0, i32 1\n" +
                "  " + environment + " = load ptr, ptr " + environmentField + "\n" +
                "  " + resultName + " = call i32 " + functionValue + "(ptr " + environment + (arguments.empty() ? "" : ", " + arguments) + ")\n";
        }
    }
    if (kind == 'I' && start + 1 < end && csec_native_token_is(tokens, start + 1, 'O', "(")) {
        const int declaration = csec_find_visible_local(tokens, start, csec_token_text_at(tokens, start));
        const int declarationEnd = declaration >= 0 ? csec_advance_statement(tokens, declaration, 1000000000) : -1;
        if (declaration >= 0 && csec_lambda_declaration(tokens, declaration, declarationEnd)) {
            const int close = csec_find_closing_token(tokens, start + 1, end, "(", ")");
            if (close == end - 1) {
                std::string output;
                std::string arguments;
                const char* storage = csec_lookup_visible_storage_name(tokens, start, csec_token_text_at(tokens, start));
                const std::string closure = resultName + ".closure";
                const std::string codeField = resultName + ".code.field";
                const std::string environmentField = resultName + ".environment.field";
                const std::string code = resultName + ".code";
                const std::string environment = resultName + ".environment";
                const std::string closureType = csec_lambda_closure_type_name(declaration);
                output += "  " + closure + " = load ptr, ptr %" + std::string(storage) + "\n";
                output += "  " + codeField + " = getelementptr inbounds " + closureType + ", ptr " + closure + ", i32 0, i32 0\n";
                output += "  " + code + " = load ptr, ptr " + codeField + "\n";
                output += "  " + environmentField + " = getelementptr inbounds " + closureType + ", ptr " + closure + ", i32 0, i32 1\n";
                output += "  " + environment + " = load ptr, ptr " + environmentField + "\n";
                arguments = "ptr " + environment;
                int argumentStart = start + 2;
                int argumentIndex = 0;
                for (int cursor = argumentStart; cursor <= close; ++cursor) {
                    if (cursor == close || csec_native_token_is(tokens, cursor, 'O', ",")) {
                        if (cursor > argumentStart) {
                            const std::string argumentName = resultName + ".arg" + std::to_string(argumentIndex++);
                            output += csec_emit_i32_expression(tokens, argumentStart, cursor, argumentName);
                            if (!arguments.empty()) arguments += ", ";
                            arguments += "i32 " + argumentName;
                        }
                        argumentStart = cursor + 1;
                    }
                }
                return output + "  " + resultName + " = call i32 " + code + "(" + arguments + ")\n";
            }
        }
    }
    if (kind == 'I' && start + 1 < end && csec_native_token_is(tokens, start + 1, 'O', "(")) {
        const int callee = csec_top_level_function_declaration(tokens, csec_token_text_at(tokens, start));
        const auto parameters = callee >= 0 ? csec_function_params(tokens, callee) : std::vector<std::pair<std::string, std::string>>{};
        const int close = csec_find_closing_token(tokens, start + 1, end, "(", ")");
        bool hasFunctionParameter = false;
        for (const auto& parameter : parameters) if (parameter.second == "(") hasFunctionParameter = true;
        if (close == end - 1 && hasFunctionParameter) {
            std::string output;
            std::string arguments;
            int argumentStart = start + 2;
            int argumentIndex = 0;
            for (int cursor = argumentStart; cursor <= close; ++cursor) {
                if (cursor == close || csec_native_token_is(tokens, cursor, 'O', ",")) {
                    if (cursor > argumentStart) {
                        if (!arguments.empty()) arguments += ", ";
                        const bool functionArgument = argumentIndex < static_cast<int>(parameters.size()) && parameters[argumentIndex].second == "(";
                        if (functionArgument && csec_token_kind_at(tokens, argumentStart) == 'I' && argumentStart + 1 == cursor) {
                            const int lambdaDeclaration = csec_find_visible_local(tokens, argumentStart, csec_token_text_at(tokens, argumentStart));
                            const int lambdaEnd = lambdaDeclaration >= 0 ? csec_advance_statement(tokens, lambdaDeclaration, 1000000000) : -1;
                            if (lambdaDeclaration >= 0 && csec_lambda_declaration(tokens, lambdaDeclaration, lambdaEnd)) {
                                const std::string closure = resultName + ".closure.arg" + std::to_string(argumentIndex);
                                const char* storage = csec_lookup_visible_storage_name(tokens, argumentStart, csec_token_text_at(tokens, argumentStart));
                                output += "  " + closure + " = load ptr, ptr %" + std::string(storage) + "\n";
                                arguments += "ptr " + closure;
                            } else arguments += "ptr null";
                        } else {
                            const std::string value = resultName + ".arg" + std::to_string(argumentIndex);
                            output += csec_emit_i32_expression(tokens, argumentStart, cursor, value);
                            arguments += "i32 " + value;
                        }
                        ++argumentIndex;
                    }
                    argumentStart = cursor + 1;
                }
            }
            if (std::strcmp(csec_function_return_type_at(tokens, callee), "Boolean") == 0) {
                const std::string booleanResult = resultName + ".i1";
                return output + "  " + booleanResult + " = call i1 @" + std::string(csec_token_text_at(tokens, start)) + "(" + arguments + ")\n" +
                    "  " + resultName + " = zext i1 " + booleanResult + " to i32\n";
            }
            return output + "  " + resultName + " = call i32 @" + std::string(csec_token_text_at(tokens, start)) + "(" + arguments + ")\n";
        }
    }
    if (kind == 'I' && start + 1 < end && csec_native_token_is(tokens, start + 1, 'O', "(")) {
        const int close = csec_find_closing_token(tokens, start + 1, end, "(", ")");
        if (close > start + 1) {
            const int callee = csec_top_level_function_declaration(tokens, csec_token_text_at(tokens, start));
            const auto parameters = callee >= 0 ? csec_function_params(tokens, callee) : std::vector<std::pair<std::string, std::string>>{};
            std::string output;
            std::string arguments;
            int argumentStart = start + 2;
            int argumentIndex = 0;
            for (int cursor = argumentStart; cursor <= close; ++cursor) {
                if (cursor == close || csec_native_token_is(tokens, cursor, 'O', ",")) {
                    if (cursor > argumentStart) {
                        const std::string argumentName = resultName + ".arg" + std::to_string(argumentIndex);
                        const bool pointerArgument = argumentIndex < static_cast<int>(parameters.size()) &&
                            std::strcmp(csec_llvm_type_for_name(parameters[argumentIndex].second), "ptr") == 0;
                        if (!arguments.empty()) arguments += ", ";
                        if (pointerArgument && csec_token_kind_at(tokens, argumentStart) == 'I' && argumentStart + 1 == cursor &&
                            csec_visible_i32_array(tokens, argumentStart, csec_token_text_at(tokens, argumentStart))) {
                            const char* storage = csec_lookup_visible_storage_name(tokens, argumentStart, csec_token_text_at(tokens, argumentStart));
                            output += "  " + argumentName + " = load ptr, ptr %" + std::string(storage) + "\n";
                            arguments += "ptr " + argumentName;
                        } else if (pointerArgument &&
                            (csec_token_kind_at(tokens, argumentStart) == 'S' ||
                             (csec_token_kind_at(tokens, argumentStart) == 'I' && argumentStart + 1 == cursor &&
                              (csec_is_string_local(tokens, argumentStart, csec_token_text_at(tokens, argumentStart)) ||
                               csec_is_string_parameter(tokens, argumentStart, csec_token_text_at(tokens, argumentStart)))))) {
                            output += csec_emit_ptr_expression(tokens, argumentStart, cursor, argumentName);
                            arguments += "ptr " + argumentName;
                        } else {
                            const bool booleanArgument = argumentIndex < static_cast<int>(parameters.size()) && parameters[argumentIndex].second == "Boolean";
                            output += booleanArgument
                                ? csec_emit_i1_expression(tokens, argumentStart, cursor, argumentName)
                                : csec_emit_i32_expression(tokens, argumentStart, cursor, argumentName);
                            arguments += std::string(booleanArgument ? "i1 " : "i32 ") + argumentName;
                        }
                        ++argumentIndex;
                    }
                    argumentStart = cursor + 1;
                }
            }
            if (callee >= 0 && std::strcmp(csec_function_return_type_at(tokens, callee), "Boolean") == 0) {
                const std::string booleanResult = resultName + ".i1";
                output += "  " + booleanResult + " = call i1 @" + std::string(csec_token_text_at(tokens, start)) + "(" + arguments + ")\n";
                output += "  " + resultName + " = zext i1 " + booleanResult + " to i32\n";
            } else output += "  " + resultName + " = call i32 @" + std::string(csec_token_text_at(tokens, start)) + "(" + arguments + ")\n";
            return output;
        }
    }
    if (kind == 'I') {
        const char* storage = csec_lookup_visible_storage_name(tokens, start, csec_token_text_at(tokens, start));
        if (csec_is_boolean_local(tokens, start, csec_token_text_at(tokens, start)) ||
            csec_is_boolean_class_constructor_param(tokens, start, csec_token_text_at(tokens, start))) {
            const std::string booleanValue = resultName + ".i1";
            return "  " + booleanValue + " = load i1, ptr %" + std::string(storage) + "\n" +
                "  " + resultName + " = zext i1 " + booleanValue + " to i32\n";
        }
        return "  " + resultName + " = load i32, ptr %" + std::string(storage) + "\n";
    }
    return "  " + resultName + " = add i32 0, 0\n";
}

static std::string csec_emit_i1_expression(const char* tokens, int start, int end, const std::string& resultName) {
    end = csec_i32_expression_end(tokens, start, end);
    if (end <= start) return "  " + resultName + " = icmp eq i32 0, 1\n";
    if (csec_native_token_is(tokens, start, 'O', "(") &&
        csec_find_closing_token(tokens, start, end, "(", ")") == end - 1) {
        return csec_emit_i1_expression(tokens, start + 1, end - 1, resultName);
    }
    if (csec_native_token_is(tokens, start, 'O', "!") && start + 1 < end) {
        const std::string value = resultName + ".value";
        return csec_emit_i1_expression(tokens, start + 1, end, value) +
            "  " + resultName + " = xor i1 " + value + ", true\n";
    }
    if (csec_token_kind_at(tokens, start) == 'B') {
        return "  " + resultName + " = icmp eq i32 0, " +
            std::string(std::strcmp(csec_token_text_at(tokens, start), "true") == 0 ? "0\n" : "1\n");
    }
    const char kind = csec_token_kind_at(tokens, start);
    if (csec_native_token_is(tokens, start, 'K', "super") && start + 4 < end &&
        csec_native_token_is(tokens, start + 1, 'O', ".") && csec_token_kind_at(tokens, start + 2) == 'I' &&
        csec_native_token_is(tokens, start + 3, 'O', "(")) {
        const int close = csec_find_closing_token(tokens, start + 3, end, "(", ")");
        const int classStart = csec_enclosing_class_declaration(tokens, start);
        const std::string parent = classStart >= 0 ? csec_class_parent_name(tokens, classStart) : "";
        const int parentStart = parent.empty() ? -1 : csec_find_class_declaration(tokens, parent.c_str());
        if (close == end - 1 && parentStart >= 0 && csec_class_uses_pointer_receiver(tokens, parentStart)) {
            return "  " + resultName + " = call i1 @" + parent + "_" +
                csec_token_text_at(tokens, start + 2) + "(ptr %arg.this)\n";
        }
    }
    if (kind == 'I' && start + 1 < end && csec_native_token_is(tokens, start + 1, 'O', "(") &&
        csec_is_function_parameter(tokens, start, csec_token_text_at(tokens, start)) &&
        csec_function_parameter_returns_boolean(tokens, start, csec_token_text_at(tokens, start))) {
        const int close = csec_find_closing_token(tokens, start + 1, end, "(", ")");
        if (close == end - 1) {
            std::string output, arguments;
            int argumentStart = start + 2, index = 0;
            for (int cursor = argumentStart; cursor <= close; ++cursor) {
                if (cursor == close || csec_native_token_is(tokens, cursor, 'O', ",")) {
                    if (cursor > argumentStart) {
                        const std::string value = resultName + ".arg" + std::to_string(index++);
                        output += csec_emit_i32_expression(tokens, argumentStart, cursor, value);
                        if (!arguments.empty()) arguments += ", ";
                        arguments += "i32 " + value;
                    }
                    argumentStart = cursor + 1;
                }
            }
            const char* storage = csec_lookup_visible_storage_name(tokens, start, csec_token_text_at(tokens, start));
            const std::string closure = resultName + ".closure";
            const std::string codeField = resultName + ".code.field";
            const std::string environmentField = resultName + ".environment.field";
            const std::string functionValue = resultName + ".fn";
            const std::string environment = resultName + ".environment";
            return output + "  " + closure + " = load ptr, ptr %" + std::string(storage) + "\n" +
                "  " + codeField + " = getelementptr inbounds { ptr, ptr }, ptr " + closure + ", i32 0, i32 0\n" +
                "  " + functionValue + " = load ptr, ptr " + codeField + "\n" +
                "  " + environmentField + " = getelementptr inbounds { ptr, ptr }, ptr " + closure + ", i32 0, i32 1\n" +
                "  " + environment + " = load ptr, ptr " + environmentField + "\n" +
                "  " + resultName + " = call i1 " + functionValue + "(ptr " + environment + (arguments.empty() ? "" : ", " + arguments) + ")\n";
        }
    }
    if (kind == 'I' && start + 1 < end && csec_native_token_is(tokens, start + 1, 'O', "(")) {
        const int declaration = csec_find_visible_local(tokens, start, csec_token_text_at(tokens, start));
        const int declarationEnd = declaration >= 0 ? csec_advance_statement(tokens, declaration, 1000000000) : -1;
        int lambdaReturn = -1;
        if (declaration >= 0 && csec_lambda_declaration(tokens, declaration, declarationEnd)) {
            int bodyStart = -1, bodyEnd = -1;
            csec_lambda_declaration(tokens, declaration, declarationEnd, &bodyStart, &bodyEnd);
            for (int cursor = bodyStart; cursor < bodyEnd;) {
                const int next = csec_advance_statement(tokens, cursor, bodyEnd);
                if (csec_native_token_is(tokens, cursor, 'K', "return")) { lambdaReturn = cursor + 1; break; }
                if (next <= cursor) break;
                cursor = next;
            }
            if (lambdaReturn >= 0 && csec_expression_is_boolean(tokens, lambdaReturn, bodyEnd)) {
                const int close = csec_find_closing_token(tokens, start + 1, end, "(", ")");
                if (close == end - 1) {
                    std::string output, arguments;
                    const char* storage = csec_lookup_visible_storage_name(tokens, start, csec_token_text_at(tokens, start));
                    const std::string closure = resultName + ".closure";
                    const std::string codeField = resultName + ".code.field";
                    const std::string environmentField = resultName + ".environment.field";
                    const std::string code = resultName + ".code";
                    const std::string environment = resultName + ".environment";
                    const std::string closureType = csec_lambda_closure_type_name(declaration);
                    output += "  " + closure + " = load ptr, ptr %" + std::string(storage) + "\n";
                    output += "  " + codeField + " = getelementptr inbounds " + closureType + ", ptr " + closure + ", i32 0, i32 0\n";
                    output += "  " + code + " = load ptr, ptr " + codeField + "\n";
                    output += "  " + environmentField + " = getelementptr inbounds " + closureType + ", ptr " + closure + ", i32 0, i32 1\n";
                    output += "  " + environment + " = load ptr, ptr " + environmentField + "\n";
                    arguments = "ptr " + environment;
                    int argumentStart = start + 2, index = 0;
                    for (int cursor = argumentStart; cursor <= close; ++cursor) {
                        if (cursor == close || csec_native_token_is(tokens, cursor, 'O', ",")) {
                            if (cursor > argumentStart) {
                                const std::string value = resultName + ".arg" + std::to_string(index++);
                                output += csec_emit_i32_expression(tokens, argumentStart, cursor, value);
                                if (!arguments.empty()) arguments += ", ";
                                arguments += "i32 " + value;
                            }
                            argumentStart = cursor + 1;
                        }
                    }
                    return output + "  " + resultName + " = call i1 " + code + "(" + arguments + ")\n";
                }
            }
        }
        const int callee = csec_top_level_function_declaration(tokens, csec_token_text_at(tokens, start));
        if (callee >= 0 && std::strcmp(csec_function_return_type_at(tokens, callee), "Boolean") == 0) {
            const int close = csec_find_closing_token(tokens, start + 1, end, "(", ")");
            if (close == end - 1) {
                const auto parameters = csec_function_params(tokens, callee);
                std::string output, arguments;
                int argumentStart = start + 2, index = 0;
                for (int cursor = argumentStart; cursor <= close; ++cursor) {
                    if (cursor == close || csec_native_token_is(tokens, cursor, 'O', ",")) {
                        if (cursor > argumentStart) {
                            if (!arguments.empty()) arguments += ", ";
                            const bool functionArgument = index < static_cast<int>(parameters.size()) && parameters[index].second == "(";
                            if (functionArgument && csec_token_kind_at(tokens, argumentStart) == 'I' && argumentStart + 1 == cursor) {
                                const int lambdaDeclaration = csec_find_visible_local(tokens, argumentStart, csec_token_text_at(tokens, argumentStart));
                                const int lambdaEnd = lambdaDeclaration >= 0 ? csec_advance_statement(tokens, lambdaDeclaration, 1000000000) : -1;
                                if (lambdaDeclaration >= 0 && csec_lambda_declaration(tokens, lambdaDeclaration, lambdaEnd)) {
                                    const std::string closure = resultName + ".closure.arg" + std::to_string(index);
                                    const char* storage = csec_lookup_visible_storage_name(tokens, argumentStart, csec_token_text_at(tokens, argumentStart));
                                    output += "  " + closure + " = load ptr, ptr %" + std::string(storage) + "\n";
                                    arguments += "ptr " + closure;
                                } else arguments += "ptr null";
                            } else {
                                const std::string value = resultName + ".arg" + std::to_string(index);
                                const bool booleanArgument = index < static_cast<int>(parameters.size()) && parameters[index].second == "Boolean";
                                output += booleanArgument
                                    ? csec_emit_i1_expression(tokens, argumentStart, cursor, value)
                                    : csec_emit_i32_expression(tokens, argumentStart, cursor, value);
                                arguments += std::string(booleanArgument ? "i1 " : "i32 ") + value;
                            }
                            ++index;
                        }
                        argumentStart = cursor + 1;
                    }
                }
                return output + "  " + resultName + " = call i1 @" + std::string(csec_token_text_at(tokens, start)) + "(" + arguments + ")\n";
            }
        }
    }
    if (kind == 'I' && start + 1 == end &&
        (csec_is_boolean_local(tokens, start, csec_token_text_at(tokens, start)) ||
         csec_is_boolean_parameter(tokens, start, csec_token_text_at(tokens, start)) ||
         csec_is_boolean_class_constructor_param(tokens, start, csec_token_text_at(tokens, start)))) {
        const char* storage = csec_lookup_visible_storage_name(tokens, start, csec_token_text_at(tokens, start));
        return "  " + resultName + " = load i1, ptr %" + std::string(storage) + "\n";
    }
    const std::string value = resultName + ".i32";
    return csec_emit_i32_expression(tokens, start, end, value) +
        "  " + resultName + " = icmp ne i32 " + value + ", 0\n";
}

static std::string csec_generate_llvm_flat_body_i1(const char* tokens, int bodyStart, int bodyEnd) {
    std::string output;
    for (int cursor = csec_expression_ast_skip_trivia(tokens, bodyStart); cursor >= 0 && cursor < bodyEnd;) {
        const int next = csec_advance_statement(tokens, cursor, bodyEnd);
        if (next <= cursor) break;
        if (csec_native_token_is(tokens, cursor, 'K', "return") && cursor + 1 < next) {
            const std::string value = "%ret." + std::to_string(cursor);
            output += csec_emit_i1_expression(tokens, cursor + 1, next, value);
            output += "  ret i1 " + value + "\n";
            return output;
        }
        if ((csec_native_token_is(tokens, cursor, 'K', "val") || csec_native_token_is(tokens, cursor, 'K', "var")) &&
            csec_token_kind_at(tokens, cursor + 1) == 'I') {
            const std::string name = csec_token_text_at(tokens, cursor + 1);
            const std::string storage = name + ".addr." + std::to_string(cursor);
            const int initializer = csec_find_top_level_operator(tokens, cursor, next, 1);
            output += "  %" + storage + " = alloca i1\n";
            if (initializer >= cursor && initializer + 1 < next) {
                const std::string value = "%" + name + ".init." + std::to_string(cursor);
                output += csec_emit_i1_expression(tokens, initializer + 1, next, value);
                output += "  store i1 " + value + ", ptr %" + storage + "\n";
            } else output += "  store i1 false, ptr %" + storage + "\n";
        }
        if (csec_token_kind_at(tokens, cursor) == 'I' && csec_native_token_is(tokens, cursor + 1, 'O', "=")) {
            const std::string name = csec_token_text_at(tokens, cursor);
            const std::string storage = csec_lookup_visible_storage_name(tokens, cursor, name.c_str());
            const std::string value = "%" + name + ".assign." + std::to_string(cursor);
            output += csec_emit_i1_expression(tokens, cursor + 2, next, value);
            output += "  store i1 " + value + ", ptr %" + storage + "\n";
        } else if (csec_token_kind_at(tokens, cursor) == 'I' && cursor + 3 < next &&
                   csec_native_token_is(tokens, cursor + 1, 'O', ".") &&
                   csec_token_kind_at(tokens, cursor + 2) == 'I' &&
                   csec_native_token_is(tokens, cursor + 3, 'O', "(")) {
            output += csec_emit_i32_expression(tokens, cursor, next, "%discard." + std::to_string(cursor));
        }
        cursor = csec_expression_ast_skip_trivia(tokens, next);
    }
    return output;
}

char* csec_generate_llvm_flat_body_i32(const char* tokens, int bodyStart, int bodyEnd) {
    std::string output;
    int cursor = csec_expression_ast_skip_trivia(tokens, bodyStart);
    while (cursor >= 0 && cursor < bodyEnd && csec_token_kind_at(tokens, cursor) != 'E') {
        const int next = csec_advance_statement(tokens, cursor, bodyEnd);
        if (next <= cursor) break;
        const bool declaration = csec_native_token_is(tokens, cursor, 'K', "val") ||
            csec_native_token_is(tokens, cursor, 'K', "var");
        if (csec_native_token_is(tokens, cursor, 'K', "if")) {
            const int openParen = csec_find_statement_paren_start(tokens, cursor, next);
            const int closeParen = csec_find_statement_paren_end(tokens, cursor, next);
            const int thenOpen = csec_find_statement_block_start(tokens, cursor, next);
            const int thenClose = thenOpen >= 0 ? csec_find_closing_token(tokens, thenOpen, next, "{", "}") : -1;
            const bool booleanCall = openParen >= 0 && closeParen == openParen + 4 &&
                csec_token_kind_at(tokens, openParen + 1) == 'I' && csec_native_token_is(tokens, openParen + 2, 'O', "(") &&
                csec_native_token_is(tokens, openParen + 3, 'O', ")");
            if (openParen >= 0 && closeParen > openParen && thenClose > thenOpen) {
                const std::string seed = std::to_string(cursor);
                const std::string left = "%ifcond." + seed + ".left";
                if (booleanCall) {
                    output += "  %ifcond." + seed + " = call i1 @" + std::string(csec_token_text_at(tokens, openParen + 1)) + "()\n";
                } else {
                    output += csec_emit_i32_expression(tokens, openParen + 1, closeParen, left);
                    output += "  %ifcond." + seed + " = icmp ne i32 " + left + ", 0\n";
                }
                output += "  br i1 %ifcond." + seed + ", label %if.then." + seed + ", label %if.else." + seed + "\n";
                output += "if.then." + seed + ":\n";
                const int thenReturn = csec_find_token_text_in_range(tokens, thenOpen + 1, thenClose, "return");
                if (thenReturn >= 0) {
                    output += csec_emit_i32_expression(tokens, thenReturn + 1, thenClose, "%if.then.ret." + seed);
                    output += "  ret i32 %if.then.ret." + seed + "\n";
                } else output += "  br label %if.end." + seed + "\n";
                output += "if.else." + seed + ":\n";
                int elseOpen = -1;
                int elseIf = -1;
                for (int pos = thenClose + 1; pos < next; ++pos) {
                    if (csec_native_token_is(tokens, pos, 'K', "else")) {
                        if (csec_native_token_is(tokens, pos + 1, 'K', "if")) elseIf = pos + 1;
                        else elseOpen = csec_find_token_text_in_range(tokens, pos + 1, next, "{");
                        break;
                    }
                }
                if (elseIf >= 0) {
                    char* nested = csec_generate_llvm_flat_body_i32(tokens, elseIf, next);
                    if (nested) output += nested;
                    output += "if.end." + seed + ":\n  unreachable\n";
                } else {
                    const int elseClose = elseOpen >= 0 ? csec_find_closing_token(tokens, elseOpen, next, "{", "}") : -1;
                    const int elseReturn = elseClose > elseOpen ? csec_find_token_text_in_range(tokens, elseOpen + 1, elseClose, "return") : -1;
                    if (elseReturn >= 0) {
                        output += csec_emit_i32_expression(tokens, elseReturn + 1, elseClose, "%if.else.ret." + seed);
                        output += "  ret i32 %if.else.ret." + seed + "\n";
                    } else output += "  br label %if.end." + seed + "\n";
                    output += "if.end." + seed + ":\n";
                    if (thenReturn >= 0 && elseReturn >= 0) output += "  unreachable\n";
                }
            }
        } else if (csec_native_token_is(tokens, cursor, 'K', "for")) {
            const int openParen = csec_find_statement_paren_start(tokens, cursor, next);
            const int closeParen = csec_find_statement_paren_end(tokens, cursor, next);
            const int arrow = openParen >= 0 ? csec_find_token_text_in_range(tokens, openParen + 1, closeParen, "<-") : -1;
            int range = -1;
            bool inclusive = true;
            for (int pos = arrow + 1; arrow >= 0 && pos < closeParen; ++pos) {
                if (csec_native_token_is(tokens, pos, 'K', "to")) { range = pos; inclusive = true; break; }
                if (csec_native_token_is(tokens, pos, 'K', "until")) { range = pos; inclusive = false; break; }
            }
            const int loopOpen = csec_find_statement_block_start(tokens, cursor, next);
            const int loopClose = loopOpen >= 0 ? csec_find_closing_token(tokens, loopOpen, next, "{", "}") : -1;
            if (openParen >= 0 && arrow > openParen + 1 && range > arrow + 1 && loopClose > loopOpen) {
                const std::string seed = std::to_string(cursor);
                const std::string variable = csec_token_text_at(tokens, openParen + 1);
                const std::string startValue = "%forstart." + seed;
                const std::string endValue = "%forend." + seed;
                output += "  %" + variable + " = alloca i32\n";
                output += csec_emit_i32_expression(tokens, arrow + 1, range, startValue);
                output += "  store i32 " + startValue + ", ptr %" + variable + "\n";
                output += "  br label %for.cond." + seed + "\n";
                output += "for.cond." + seed + ":\n";
                output += "  %forvalue." + seed + " = load i32, ptr %" + variable + "\n";
                output += csec_emit_i32_expression(tokens, range + 1, closeParen, endValue);
                output += "  %forcond." + seed + " = icmp " + (inclusive ? "sle" : "slt") + " i32 %forvalue." + seed + ", " + endValue + "\n";
                output += "  br i1 %forcond." + seed + ", label %for.body." + seed + ", label %for.end." + seed + "\n";
                output += "for.body." + seed + ":\n";
                output += csec_generate_llvm_flat_body_i32(tokens, loopOpen + 1, loopClose);
                output += "  %fornext." + seed + " = add i32 %forvalue." + seed + ", 1\n";
                output += "  store i32 %fornext." + seed + ", ptr %" + variable + "\n";
                output += "  br label %for.cond." + seed + "\n";
                output += "for.end." + seed + ":\n";
            }
        } else if (csec_native_token_is(tokens, cursor, 'K', "while")) {
            const int openParen = csec_find_statement_paren_start(tokens, cursor, next);
            const int closeParen = csec_find_statement_paren_end(tokens, cursor, next);
            const int loopOpen = csec_find_statement_block_start(tokens, cursor, next);
            const int loopClose = loopOpen >= 0 ? csec_find_closing_token(tokens, loopOpen, next, "{", "}") : -1;
            if (openParen >= 0 && closeParen > openParen && loopClose > loopOpen) {
                const std::string seed = std::to_string(cursor);
                const std::string value = "%whilecond." + seed + ".value";
                output += "  br label %while.cond." + seed + "\n";
                output += "while.cond." + seed + ":\n";
                output += csec_emit_i32_expression(tokens, openParen + 1, closeParen, value);
                output += "  %whilecond." + seed + " = icmp ne i32 " + value + ", 0\n";
                output += "  br i1 %whilecond." + seed + ", label %while.body." + seed + ", label %while.end." + seed + "\n";
                output += "while.body." + seed + ":\n";
                output += csec_generate_llvm_flat_body_i32(tokens, loopOpen + 1, loopClose);
                output += "  br label %while.cond." + seed + "\n";
                output += "while.end." + seed + ":\n";
            }
        } else if (declaration && csec_token_kind_at(tokens, cursor + 1) == 'I') {
            const std::string name = csec_token_text_at(tokens, cursor + 1);
            const std::string storage = name + ".addr." + std::to_string(cursor);
            const int initializer = csec_find_top_level_operator(tokens, cursor, next, 1);
            if (csec_lambda_declaration(tokens, cursor, next)) {
                const std::string closure = "%" + name + ".closure." + std::to_string(cursor);
                const std::string closureType = csec_lambda_closure_type_name(cursor);
                const auto captures = csec_lambda_capture_names(tokens, cursor, next);
                const bool byReference = csec_lambda_captures_by_reference(tokens, cursor, next);
                output += "  " + closure + " = alloca " + closureType + "\n";
                output += "  %" + storage + " = alloca ptr\n";
                output += "  %" + name + ".closure.code." + std::to_string(cursor) + " = getelementptr inbounds " + closureType + ", ptr " + closure + ", i32 0, i32 0\n";
                output += "  store ptr @" + csec_lambda_function_name(cursor) + ", ptr %" + name + ".closure.code." + std::to_string(cursor) + "\n";
                output += "  %" + name + ".closure.env." + std::to_string(cursor) + " = getelementptr inbounds " + closureType + ", ptr " + closure + ", i32 0, i32 1\n";
                if (captures.empty()) {
                    output += "  store ptr null, ptr %" + name + ".closure.env." + std::to_string(cursor) + "\n";
                } else {
                    const std::string environment = "%" + name + ".environment." + std::to_string(cursor);
                    const std::string environmentType = csec_lambda_environment_type_name(cursor);
                    output += "  " + environment + " = alloca " + environmentType + "\n";
                    for (size_t index = 0; index < captures.size(); ++index) {
                        const std::string field = "%" + name + ".capture." + std::to_string(cursor) + "." + std::to_string(index);
                        const char* source = csec_lookup_visible_storage_name(tokens, cursor, captures[index].c_str());
                        output += "  " + field + " = getelementptr inbounds " + environmentType + ", ptr " + environment + ", i32 0, i32 " + std::to_string(index) + "\n";
                        if (byReference) {
                            output += "  store ptr %" + std::string(source) + ", ptr " + field + "\n";
                        } else {
                            const std::string value = "%" + name + ".capture.value." + std::to_string(cursor) + "." + std::to_string(index);
                            output += "  " + value + " = load i32, ptr %" + std::string(source) + "\n";
                            output += "  store i32 " + value + ", ptr " + field + "\n";
                        }
                    }
                    output += "  store ptr " + environment + ", ptr %" + name + ".closure.env." + std::to_string(cursor) + "\n";
                }
                output += "  store ptr " + closure + ", ptr %" + storage + "\n";
            } else if (csec_is_i32_array_initializer(tokens, initializer, next)) {
                output += csec_emit_i32_array_local(tokens, cursor, next);
            } else if (initializer >= cursor && csec_native_token_is(tokens, initializer + 1, 'K', "new") &&
                       csec_token_kind_at(tokens, initializer + 2) == 'I' && csec_native_token_is(tokens, initializer + 3, 'O', "(")) {
                const char* className = csec_token_text_at(tokens, initializer + 2);
                const int classStart = csec_find_class_declaration(tokens, className);
                const int constructorClose = csec_find_closing_token(tokens, initializer + 3, next, "(", ")");
                if (classStart >= 0 && constructorClose >= initializer + 3 && csec_class_uses_pointer_receiver(tokens, classStart)) {
                    const std::string object = name + ".object." + std::to_string(cursor);
                    output += "  %" + object + " = alloca %class." + std::string(className) + "\n";
                    output += "  %" + storage + " = alloca ptr\n";
                    output += "  store ptr %" + object + ", ptr %" + storage + "\n";
                    int fieldIndex = 0;
                    int parameterIndex = 0;
                    const auto parameters = csec_class_constructor_params(tokens, classStart);
                    int argumentStart = initializer + 4;
                    for (int position = argumentStart; position <= constructorClose; ++position) {
                        if (position == constructorClose || csec_native_token_is(tokens, position, 'O', ",")) {
                            if (position > argumentStart && parameterIndex < static_cast<int>(parameters.size()) &&
                                (std::strcmp(csec_llvm_type_for_name(parameters[parameterIndex].second), "i32") == 0 ||
                                 std::strcmp(csec_llvm_type_for_name(parameters[parameterIndex].second), "i1") == 0)) {
                                const char* fieldType = csec_llvm_type_for_name(parameters[parameterIndex].second);
                                const std::string value = "%" + name + ".ctor." + std::to_string(fieldIndex);
                                const std::string field = "%" + name + ".field." + std::to_string(fieldIndex);
                                output += std::strcmp(fieldType, "i1") == 0
                                    ? csec_emit_i1_expression(tokens, argumentStart, position, value)
                                    : csec_emit_i32_expression(tokens, argumentStart, position, value);
                                output += "  " + field + " = getelementptr inbounds %class." + std::string(className) + ", ptr %" + object + ", i32 0, i32 " + std::to_string(fieldIndex++) + "\n";
                                output += "  store " + std::string(fieldType) + " " + value + ", ptr " + field + "\n";
                            }
                            argumentStart = position + 1;
                            ++parameterIndex;
                        }
                    }
                    output += csec_emit_class_field_initializers(tokens, classStart, className, object, name, fieldIndex);
                } else {
                    output += "  %" + storage + " = alloca i32\n";
                    output += "  store i32 0, ptr %" + storage + "\n";
                }
            } else if (csec_c_local_type(tokens, cursor, next, initializer) == "String") {
                output += "  %" + storage + " = alloca ptr\n";
                if (initializer >= cursor && initializer + 1 < next) {
                    const std::string initialValue = "%" + name + ".init." + std::to_string(cursor);
                    output += csec_emit_ptr_expression(tokens, initializer + 1, next, initialValue);
                    output += "  store ptr " + initialValue + ", ptr %" + storage + "\n";
                } else output += "  store ptr null, ptr %" + storage + "\n";
            } else {
                const bool boolean = csec_c_local_type(tokens, cursor, next, initializer) == "Boolean";
                output += "  %" + storage + " = alloca " + std::string(boolean ? "i1" : "i32") + "\n";
                if (initializer >= cursor && initializer + 1 < next) {
                const std::string initialValue = "%" + name + ".init." + std::to_string(cursor);
                output += boolean
                    ? csec_emit_i1_expression(tokens, initializer + 1, next, initialValue)
                    : csec_emit_i32_expression(tokens, initializer + 1, next, initialValue);
                output += std::string("  store ") + (boolean ? "i1 " : "i32 ") + initialValue + ", ptr %" + storage + "\n";
                } else {
                    output += std::string("  store ") + (boolean ? "i1 false" : "i32 0") + ", ptr %" + storage + "\n";
                }
            }
        } else if (csec_native_token_is(tokens, cursor, 'K', "return") && cursor + 1 < next) {
            const std::string value = "%ret." + std::to_string(cursor);
            output += csec_emit_i32_expression(tokens, cursor + 1, next, value);
            output += "  ret i32 " + value + "\n";
            return csec_owned_string(output);
        } else if (csec_token_kind_at(tokens, cursor) == 'I' &&
                   csec_native_token_is(tokens, cursor + 1, 'O', "[")) {
            const int close = csec_find_closing_token(tokens, cursor + 1, next, "[", "]");
            const char* assignment = close >= 0 && close + 1 < next ? csec_token_text_at(tokens, close + 1) : "";
            const bool compound = std::strcmp(assignment, "+=") == 0 || std::strcmp(assignment, "-=") == 0 ||
                std::strcmp(assignment, "*=") == 0 || std::strcmp(assignment, "/=") == 0 || std::strcmp(assignment, "%=") == 0;
            if (close > cursor + 1 && (std::strcmp(assignment, "=") == 0 || compound) &&
                csec_visible_i32_array(tokens, cursor, csec_token_text_at(tokens, cursor))) {
                const std::string name = csec_token_text_at(tokens, cursor);
                const std::string storage = csec_lookup_visible_storage_name(tokens, cursor, name.c_str());
                const std::string seed = std::to_string(cursor);
                const std::string index = "%" + name + ".index." + seed;
                const std::string data = "%" + name + ".data." + seed;
                const std::string element = "%" + name + ".element." + seed;
                const std::string rhs = "%" + name + ".rhs." + seed;
                output += csec_emit_i32_expression(tokens, cursor + 2, close, index);
                output += "  " + data + " = load ptr, ptr %" + storage + "\n";
                output += "  " + element + " = getelementptr inbounds i32, ptr " + data + ", i32 " + index + "\n";
                output += csec_emit_i32_expression(tokens, close + 2, next, rhs);
                if (compound) {
                    const std::string old = "%" + name + ".old." + seed;
                    const std::string value = "%" + name + ".next." + seed;
                    const char* instruction = std::strcmp(assignment, "+=") == 0 ? "add" :
                        (std::strcmp(assignment, "-=") == 0 ? "sub" : (std::strcmp(assignment, "*=") == 0 ? "mul" :
                        (std::strcmp(assignment, "/=") == 0 ? "sdiv" : "srem")));
                    output += "  " + old + " = load i32, ptr " + element + "\n";
                    output += "  " + value + " = " + instruction + " i32 " + old + ", " + rhs + "\n";
                    output += "  store i32 " + value + ", ptr " + element + "\n";
                } else output += "  store i32 " + rhs + ", ptr " + element + "\n";
            }
        } else if (csec_token_kind_at(tokens, cursor) == 'I' &&
                   (csec_native_token_is(tokens, cursor + 1, 'O', "+=") ||
                    csec_native_token_is(tokens, cursor + 1, 'O', "-=") ||
                    csec_native_token_is(tokens, cursor + 1, 'O', "*=") ||
                    csec_native_token_is(tokens, cursor + 1, 'O', "/=") ||
                    csec_native_token_is(tokens, cursor + 1, 'O', "%="))) {
            const std::string name = csec_token_text_at(tokens, cursor);
            const std::string storage = csec_lookup_visible_storage_name(tokens, cursor, name.c_str());
            const std::string left = "%" + name + ".compound.left." + std::to_string(cursor);
            const std::string right = "%" + name + ".compound.right." + std::to_string(cursor);
            const std::string value = "%" + name + ".compound." + std::to_string(cursor);
            const char* operation = csec_token_text_at(tokens, cursor + 1);
            const char* instruction = std::strcmp(operation, "+=") == 0 ? "add" :
                (std::strcmp(operation, "-=") == 0 ? "sub" : (std::strcmp(operation, "*=") == 0 ? "mul" :
                (std::strcmp(operation, "/=") == 0 ? "sdiv" : "srem")));
            output += "  " + left + " = load i32, ptr %" + storage + "\n";
            output += csec_emit_i32_expression(tokens, cursor + 2, next, right);
            output += "  " + value + " = " + instruction + " i32 " + left + ", " + right + "\n";
            output += "  store i32 " + value + ", ptr %" + storage + "\n";
        } else if (csec_token_kind_at(tokens, cursor) == 'I' &&
                   csec_native_token_is(tokens, cursor + 1, 'O', "=")) {
            const std::string name = csec_token_text_at(tokens, cursor);
            const std::string storage = csec_lookup_visible_storage_name(tokens, cursor, name.c_str());
            const std::string value = "%" + name + ".assign." + std::to_string(cursor);
            const bool boolean = csec_is_boolean_local(tokens, cursor, name.c_str()) ||
                csec_is_boolean_class_constructor_param(tokens, cursor, name.c_str());
            output += boolean
                ? csec_emit_i1_expression(tokens, cursor + 2, next, value)
                : csec_emit_i32_expression(tokens, cursor + 2, next, value);
            output += std::string("  store ") + (boolean ? "i1 " : "i32 ") + value + ", ptr %" + storage + "\n";
        } else if (csec_token_kind_at(tokens, cursor) == 'I' && cursor + 3 < next &&
                   csec_native_token_is(tokens, cursor + 1, 'O', ".") &&
                   csec_token_kind_at(tokens, cursor + 2) == 'I' &&
                   csec_native_token_is(tokens, cursor + 3, 'O', "(")) {
            output += csec_emit_i32_expression(tokens, cursor, next, "%discard." + std::to_string(cursor));
        } else if (csec_token_kind_at(tokens, cursor) == 'I' && cursor + 1 < next &&
                   csec_native_token_is(tokens, cursor + 1, 'O', "(")) {
            output += csec_emit_i32_expression(tokens, cursor, next, "%discard." + std::to_string(cursor));
        }
        cursor = csec_expression_ast_skip_trivia(tokens, next);
    }
    return csec_owned_string(output);
}

char* csec_generate_llvm_string_literal_globals(const char* tokens) {
    std::string output;
    for (int cursor = 0; csec_token_kind_at(tokens, cursor) != 'E'; ++cursor) {
        if (csec_token_kind_at(tokens, cursor) != 'S') continue;
        const char* text = csec_token_text_at(tokens, cursor);
        output += "@.str." + std::to_string(cursor) + " = private unnamed_addr constant [";
        output += std::to_string(csec_llvm_string_literal_byte_length(text));
        output += " x i8] c\"";
        output += csec_llvm_string_literal_bytes(text);
        output += "\"\n";
    }
    if (!output.empty()) output += "\n";
    return csec_owned_string(output);
}

int csec_generate_llvm_module_into(const char* tokens, long long builder) {
    static constexpr const char* header =
        "; ModuleID = 'csec.selfhost'\n"
        "source_filename = \"csec.selfhost\"\n\n"
        "declare ptr @csec_append_expression_until(ptr, i32, i32)\n"
        "declare ptr @csec_generate_symbol_table(ptr)\n"
        "declare ptr @csec_ir_type_name(ptr)\n"
        "declare ptr @csec_collect_type_name(ptr, i32, i32)\n"
        "declare ptr @csec_lookup_visible_value_type(ptr, i32, ptr)\n"
        "declare ptr @csec_lookup_visible_storage_name(ptr, i32, ptr)\n"
        "declare i32 @csec_find_function_param_start(ptr, i32)\n"
        "declare i32 @csec_count_comma_separated(ptr, i32, i32)\n"
        "declare i32 @csec_count_function_params(ptr, i32)\n"
        "declare i32 @csec_expression_top_level_operator(ptr, i32, i32)\n"
        "declare i32 @csec_find_closing_token(ptr, i32, i32, ptr, ptr)\n"
        "declare i32 @csec_find_last_top_level_token(ptr, i32, i32, ptr)\n"
        "declare i32 @csec_find_statement_block_end(ptr, i32, i32)\n"
        "declare i32 @csec_find_statement_block_start(ptr, i32, i32)\n"
        "declare i32 @csec_find_statement_paren_end(ptr, i32, i32)\n"
        "declare i32 @csec_find_statement_paren_start(ptr, i32, i32)\n"
        "declare i32 @csec_find_token_text_in_range(ptr, i32, i32, ptr)\n"
        "declare i32 @csec_find_top_level_match(ptr, i32, i32)\n"
        "declare i32 @csec_find_top_level_operator(ptr, i32, i32, i32)\n"
        "declare ptr @csec_generate_body_ast(ptr, i32, i32)\n"
        "declare ptr @csec_generate_c_body(ptr, i32, i32, ptr)\n"
        "declare ptr @csec_generate_c_expression(ptr, i32, i32)\n"
        "declare ptr @csec_generate_expression_ast(ptr, i32, i32)\n"
        "declare ptr @csec_generate_statement_ast(ptr, i32, i32)\n"
        "declare ptr @csec_ir_operator_name(ptr)\n"
        "declare i32 @csec_is_keyword(ptr)\n"
        "declare i32 @csec_line_end(ptr, i32)\n"
        "declare i32 @csec_line_start(ptr, i32)\n"
        "declare i32 @csec_starts_top_level_declaration(ptr, i32)\n"
        "declare i8 @csec_string_char_at(ptr, i32)\n"
        "declare ptr @csec_string_concat(ptr, ptr)\n"
        "declare i32 @csec_string_equals(ptr, ptr)\n"
        "declare i64 @csec_string_length(ptr)\n"
        "declare i32 @csec_string_starts_with(ptr, ptr)\n"
        "declare ptr @csec_string_substring(ptr, i32, i32)\n"
        "declare i32 @csec_command_line_arg_count()\n"
        "declare ptr @csec_command_line_arg(i32)\n"
        "declare i32 @csec_to_int(ptr)\n"
        "declare ptr @csec_to_string_char(i8)\n"
        "declare ptr @csec_to_string_i64(i64)\n"
        "declare i32 @csec_token_is_top_level_operator(ptr, i32, i32)\n"
        "declare ptr @csec_top_level_decl_kind(ptr, i32)\n"
        "declare ptr @csec_top_level_decl_name(ptr, i32)\n"
        "declare i32 @csec_validate_balanced(ptr)\n"
        "declare i32 @csec_validate_top_level(ptr)\n\n";
    if (csec_string_builder_append(builder, header) != 0) return -1;
    char* stringGlobals = csec_generate_llvm_string_literal_globals(tokens);
    if (stringGlobals && csec_string_builder_append(builder, stringGlobals) != 0) return -1;
    const std::string lambdaTypeDefinitions = csec_lambda_type_definitions(tokens);
    if (!lambdaTypeDefinitions.empty() && csec_string_builder_append(builder, lambdaTypeDefinitions.c_str()) != 0) return -1;
    const std::string lambdaDefinitions = csec_lambda_definitions(tokens);
    if (!lambdaDefinitions.empty() && csec_string_builder_append(builder, lambdaDefinitions.c_str()) != 0) return -1;

    bool compilerDriver = false;
    for (int cursor = 0; csec_token_kind_at(tokens, cursor) != 'E';) {
        const int next = csec_advance_top_level_decl(tokens, cursor);
        if (next <= cursor) break;
        if (std::strcmp(csec_top_level_decl_kind(tokens, cursor), "function") == 0 &&
            std::strcmp(csec_top_level_decl_name(tokens, cursor), "compileFile") == 0) {
            compilerDriver = true;
            break;
        }
        cursor = next;
    }
    bool hasUserMain = false;
    int userMainDeclaration = -1;
    if (!compilerDriver) {
        for (int cursor = 0; csec_token_kind_at(tokens, cursor) != 'E'; ++cursor) {
            if (csec_native_token_is(tokens, cursor, 'K', "def") &&
                csec_token_kind_at(tokens, cursor + 1) == 'I' &&
                std::strcmp(csec_token_text_at(tokens, cursor + 1), "main") == 0) {
                userMainDeclaration = cursor;
                break;
            }
        }
    }
    for (int cursor = 0; csec_token_kind_at(tokens, cursor) != 'E';) {
        const int next = csec_advance_top_level_decl(tokens, cursor);
        if (next <= cursor) break;
        const char* declarationKind = csec_top_level_decl_kind(tokens, cursor);
        if (std::strcmp(declarationKind, "external-function") == 0) {
            std::string declaration = "declare ";
            declaration += csec_llvm_type_for_name(csec_function_return_type_at(tokens, cursor));
            declaration += " @";
            declaration += csec_top_level_decl_name(tokens, cursor);
            declaration += "(";
            declaration += csec_function_llvm_param_list(tokens, cursor);
            declaration += ")\n";
            if (csec_string_builder_append(builder, declaration.c_str()) != 0) return -1;
        } else if (std::strcmp(declarationKind, "object") == 0) {
            const int objectBody = csec_find_decl_body_start(tokens, cursor);
            const int objectEnd = csec_find_decl_body_end(tokens, objectBody);
            // csec_find_decl_body_start already returns the first token inside the body.
            for (int member = objectBody; objectBody >= 0 && member < objectEnd; ++member) {
                if (csec_native_token_is(tokens, member, 'K', "def")) {
                    const std::string definition = csec_object_method_definition(tokens, cursor, member);
                    if (definition.empty() || csec_string_builder_append(builder, definition.c_str()) != 0) return -1;
                }
            }
        } else if (std::strcmp(declarationKind, "class") == 0) {
            const std::string className = csec_top_level_decl_name(tokens, cursor);
            if (csec_class_uses_pointer_receiver(tokens, cursor)) {
                const std::string layout = csec_class_i32_layout(tokens, cursor);
                if (layout.empty() || csec_string_builder_append(builder, ("%class." + className + " = type { " + layout + " }\n\n").c_str()) != 0) return -1;
            }
            const int classBody = csec_find_decl_body_start(tokens, cursor);
            const int classEnd = csec_find_decl_body_end(tokens, classBody);
            // Expression-bodied methods do not always have a statement boundary before the
            // following member, so inspect every token in the class body for method starts.
            for (int member = classBody; classBody >= 0 && member < classEnd; ++member) {
                if (csec_native_token_is(tokens, member, 'K', "def")) {
                    const std::string definition = csec_class_method_definition(tokens, cursor, member);
                    if (definition.empty() || csec_string_builder_append(builder, definition.c_str()) != 0) return -1;
                }
            }
        } else if (std::strcmp(declarationKind, "function") == 0) {
            const std::string functionName = csec_top_level_decl_name(tokens, cursor);
            const char* name = functionName.c_str();
            if (std::strncmp(name, "csec_", 5) == 0) {
                cursor = next;
                continue;
            }
            if (std::strcmp(name, "main") == 0) {
                if (compilerDriver) {
                    std::string mainDefinition = "define i32 @main() {\nentry:\n";
                    mainDefinition += csec_llvm_main_body();
                    mainDefinition += "}\n\n";
                    if (csec_string_builder_append(builder, mainDefinition.c_str()) != 0) return -1;
                } else {
                    char* userMain = csec_generate_llvm_function_definition(tokens, cursor);
                    if (!userMain || csec_string_builder_append(builder, userMain) != 0) return -1;
                    hasUserMain = true;
                }
                cursor = next;
                continue;
            }
            char* definition = csec_llvm_lexer_helper_definition(name);
            if (definition && definition[0] != '\0') {
                if (csec_string_builder_append(builder, definition) != 0) return -1;
            } else {
                char* generated = csec_generate_llvm_function_definition(tokens, cursor);
                if (!generated || csec_string_builder_append(builder, generated) != 0) return -1;
            }
        }
        cursor = next;
    }
    if (!compilerDriver && !hasUserMain && userMainDeclaration >= 0) {
        char* userMain = csec_generate_llvm_function_definition(tokens, userMainDeclaration);
        if (!userMain || csec_string_builder_append(builder, userMain) != 0) return -1;
        hasUserMain = true;
    }
    if (hasUserMain) {
        static constexpr const char* entryWrapper =
            "define i32 @main() {\n"
            "entry:\n"
            "  %ret = call i32 @csec_user_main()\n"
            "  ret i32 %ret\n"
            "}\n\n";
        if (csec_string_builder_append(builder, entryWrapper) != 0) return -1;
    }
    return 0;
}

char* csec_ir_type_name(const char* typeName) {
    return csec_owned_string(csec_llvm_type_for_name(typeName ? typeName : ""));
}

char* csec_collect_type_name(const char* tokens, int start, int end) {
    std::string output;
    for (int cursor = start < 0 ? 0 : start; cursor < end && csec_token_kind_at(tokens, cursor) != 'E'; ++cursor) {
        const char* text = csec_token_text_at(tokens, cursor);
        if (std::strcmp(text, "{") == 0 || std::strcmp(text, "=") == 0 ||
            std::strcmp(text, ";") == 0 || std::strcmp(text, ",") == 0) break;
        output += text;
    }
    return csec_owned_string(output);
}

char* csec_lookup_visible_value_type(const char* tokens, int limit, const char* name) {
    const int declaration = csec_find_visible_local(tokens, limit, name);
    if (declaration < 0) return csec_owned_string("Int");
    const int end = limit < declaration ? declaration : limit;
    const int initializer = csec_find_top_level_operator(tokens, declaration, end, 1);
    return csec_owned_string(csec_c_local_type(tokens, declaration, end, initializer));
}

char* csec_lookup_visible_storage_name(const char* tokens, int limit, const char* name) {
    const int declaration = csec_find_visible_local(tokens, limit, name);
    if (declaration < 0) return csec_owned_string(name ? name : "");
    return csec_owned_string(std::string(name ? name : "") + ".addr." + std::to_string(declaration));
}

char* csec_function_llvm_param_list(const char* tokens, int declStart) {
    std::string output;
    for (const auto& param : csec_function_params(tokens, declStart)) {
        if (!output.empty()) output += ", ";
        output += csec_llvm_type_for_name(param.second);
        output += " %arg.";
        output += param.first;
    }
    return csec_owned_string(output);
}

char* csec_function_llvm_param_allocas(const char* tokens, int declStart) {
    std::string output;
    for (const auto& param : csec_function_params(tokens, declStart)) {
        const char* llvmType = csec_llvm_type_for_name(param.second);
        output += "  %" + param.first + " = alloca ";
        output += llvmType;
        output += "\n  store ";
        output += llvmType;
        output += " %arg." + param.first + ", ptr %" + param.first + "\n";
    }
    return csec_owned_string(output);
}

char* csec_generate_llvm_function_definition(const char* tokens, int declStart) {
    const std::string functionName = csec_top_level_decl_name(tokens, declStart);
    const char* name = functionName.c_str();
    char* direct = std::strcmp(name, "main") == 0 ? nullptr : csec_llvm_lexer_helper_definition(name);
    if (direct && direct[0] != '\0') return direct;

    const char* resultType = csec_llvm_type_for_name(csec_function_return_type_at(tokens, declStart));
    const char* symbolName = std::strcmp(name, "main") == 0 ? "csec_user_main" : name;
    const int bodyStart = csec_find_decl_body_start(tokens, declStart);
    const int bodyEnd = csec_find_decl_body_end(tokens, bodyStart);
    const int declEnd = csec_advance_top_level_decl(tokens, declStart);
    const int expressionStart = csec_find_top_level_operator(tokens, declStart, declEnd, 1);
    std::string output = "define ";
    output += resultType;
    output += " @";
    output += symbolName;
    output += "(";
    output += csec_function_llvm_param_list(tokens, declStart);
    output += ") {\nentry:\n";
    output += csec_function_llvm_param_allocas(tokens, declStart);

    if (std::strcmp(resultType, "i32") == 0 && expressionStart >= declStart && expressionStart + 1 < declEnd) {
        output += csec_emit_i32_expression(tokens, expressionStart + 1, declEnd, "%ret");
        output += "  ret i32 %ret\n";
    } else if (std::strcmp(resultType, "i32") == 0 && bodyStart >= 0 && bodyEnd > bodyStart) {
        const std::string body = csec_generate_llvm_flat_body_i32(tokens, bodyStart, bodyEnd);
        output += body;
        if (body.find("ret i32") == std::string::npos) output += "  ret i32 0\n";
    } else if (std::strcmp(resultType, "i1") == 0 && expressionStart >= declStart && expressionStart + 1 < declEnd) {
        output += csec_emit_i1_expression(tokens, expressionStart + 1, declEnd, "%ret");
        output += "  ret i1 %ret\n";
    } else if (std::strcmp(resultType, "i1") == 0 && bodyStart >= 0 && bodyEnd > bodyStart) {
        const std::string body = csec_generate_llvm_flat_body_i1(tokens, bodyStart, bodyEnd);
        output += body;
        if (body.find("ret i1") == std::string::npos) output += "  ret i1 false\n";
    } else if (std::strcmp(resultType, "ptr") == 0 && expressionStart >= declStart && expressionStart + 1 < declEnd) {
        output += csec_emit_ptr_expression(tokens, expressionStart + 1, declEnd, "%ret");
        output += "  ret ptr %ret\n";
    } else if (std::strcmp(resultType, "ptr") == 0 && bodyStart >= 0 && bodyEnd > bodyStart) {
        int returnValue = -1;
        int returnEnd = -1;
        for (int cursor = bodyStart; cursor < bodyEnd;) {
            const int next = csec_advance_statement(tokens, cursor, bodyEnd);
            if (csec_native_token_is(tokens, cursor, 'K', "return")) { returnValue = cursor + 1; returnEnd = next; break; }
            if (next <= cursor) break;
            cursor = next;
        }
        if (returnValue >= 0) {
            output += csec_emit_ptr_expression(tokens, returnValue, returnEnd, "%ret");
            output += "  ret ptr %ret\n";
        } else output += "  ret ptr null\n";
    } else {
        int value = -1;
        for (int cursor = bodyStart; cursor >= 0 && cursor < bodyEnd;) {
            const int next = csec_advance_statement(tokens, cursor, bodyEnd);
            if (csec_native_token_is(tokens, cursor, 'K', "return")) {
                value = cursor + 1;
                break;
            }
            if (next <= cursor) break;
            cursor = next;
        }
        const char* text = value >= 0 ? csec_token_text_at(tokens, value) : "0";
        const char kind = value >= 0 ? csec_token_kind_at(tokens, value) : 'N';
        if (std::strcmp(resultType, "void") == 0) output += "  ret void\n";
        else if (std::strcmp(resultType, "i1") == 0 && value >= 0) {
            const int returnEnd = csec_advance_statement(tokens, value - 1, bodyEnd);
            output += csec_emit_i1_expression(tokens, value, returnEnd, "%ret");
            output += "  ret i1 %ret\n";
        } else if (std::strcmp(resultType, "i1") == 0) output += "  ret i1 false\n";
        else if (std::strcmp(resultType, "i64") == 0) output += std::string("  ret i64 ") + (kind == 'N' ? text : "0") + "\n";
        else if (std::strcmp(resultType, "double") == 0) output += std::string("  ret double ") + ((kind == 'N' || kind == 'F') ? text : "0.0") + "\n";
        else if (std::strcmp(resultType, "ptr") == 0 && kind == 'S') {
            output += "  %ret = getelementptr inbounds [" + std::to_string(csec_llvm_string_literal_byte_length(text)) + " x i8], ptr @.str." + std::to_string(value) + ", i32 0, i32 0\n  ret ptr %ret\n";
        } else if (std::strcmp(resultType, "ptr") == 0) output += "  ret ptr null\n";
        else if (std::strcmp(resultType, "i8") == 0) output += "  ret i8 0\n";
        else output += "  ret i32 0\n";
    }
    output += "}\n\n";
    return csec_owned_string(output);
}

char* csec_llvm_name_with_number(const char* prefix, int number) {
    return csec_owned_string(std::string(prefix ? prefix : "") + std::to_string(number));
}

char* csec_llvm_string_literal_bytes(const char* text) {
    const std::string input = text ? text : "";
    std::string output;
    output.reserve(input.size() * 3 + 3);
    for (size_t index = 0; index < input.size(); ++index) {
        char value = input[index];
        if (value == '\\' && index + 1 < input.size()) {
            const char escaped = input[++index];
            switch (escaped) {
            case 'n': output += "\\0A"; break;
            case 'r': output += "\\0D"; break;
            case 't': output += "\\09"; break;
            case '"': output += "\\22"; break;
            case '\\': output += "\\5C"; break;
            default: output += escaped; break;
            }
        } else if (value == '"') {
            output += "\\22";
        } else if (value == '\\') {
            output += "\\5C";
        } else {
            output += value;
        }
    }
    output += "\\00";
    return csec_owned_string(output);
}

int csec_llvm_string_literal_byte_length(const char* text) {
    const std::string input = text ? text : "";
    int length = 1;
    for (size_t index = 0; index < input.size(); ++index) {
        if (input[index] == '\\' && index + 1 < input.size()) ++index;
        ++length;
    }
    return length;
}

char* csec_function_return_type_at(const char* tokens, int declStart) {
    int declEnd = csec_advance_top_level_decl(tokens, declStart);
    int paramStart = -1;
    for (int cursor = declStart; cursor < declEnd && csec_token_kind_at(tokens, cursor) != 'E'; ++cursor) {
        if (csec_native_token_is(tokens, cursor, 'O', "(")) {
            paramStart = cursor;
            break;
        }
        if (csec_native_token_is(tokens, cursor, 'O', "{") || csec_native_token_is(tokens, cursor, 'O', ";")) {
            break;
        }
    }
    if (paramStart < 0) return const_cast<char*>("Unit");

    int paramEnd = csec_native_find_closing_token(tokens, paramStart, declEnd, "(", ")");
    if (paramEnd < 0) return const_cast<char*>("Unit");
    if (!csec_native_token_is(tokens, paramEnd + 1, 'O', ":")) return const_cast<char*>("Unit");

    std::string typeName;
    for (int cursor = paramEnd + 2; cursor < declEnd && csec_token_kind_at(tokens, cursor) != 'E'; ++cursor) {
        const char* text = csec_token_text_at(tokens, cursor);
        if (std::strcmp(text, "{") == 0 || std::strcmp(text, "=") == 0 ||
            std::strcmp(text, ";") == 0 || std::strcmp(text, ",") == 0) {
            break;
        }
        typeName += text;
    }
    if (typeName.empty()) return const_cast<char*>("Unit");

    char* result = static_cast<char*>(std::malloc(typeName.size() + 1));
    if (!result) return const_cast<char*>("Unit");
    std::memcpy(result, typeName.c_str(), typeName.size() + 1);
    return result;
}

int csec_enclosing_function_decl_start(const char* tokens, int limit) {
    int declStart = -1;
    if (!findFunctionAroundLimit(tokens, limit, &declStart, nullptr, nullptr)) {
        return -1;
    }
    return declStart;
}

int csec_enclosing_function_body_start(const char* tokens, int limit) {
    int bodyStart = -1;
    if (!findFunctionAroundLimit(tokens, limit, nullptr, &bodyStart, nullptr)) {
        return -1;
    }
    return bodyStart;
}

int csec_enclosing_function_body_end(const char* tokens, int limit) {
    int bodyEnd = -1;
    if (!findFunctionAroundLimit(tokens, limit, nullptr, nullptr, &bodyEnd)) {
        return -1;
    }
    return bodyEnd;
}

char* csec_lookup_function_return_type(const char* tokens, const char* name) {
    if (!name) {
        return const_cast<char*>("unknown");
    }
    const auto& types = functionReturnTypesCached(tokens);
    auto found = types.find(name);
    if (found == types.end()) {
        return const_cast<char*>("unknown");
    }
    return const_cast<char*>(found->second.c_str());
}

long long csec_string_length(const char* value) {
    return static_cast<long long>(std::strlen(value ? value : ""));
}

int csec_string_is_empty(const char* value) {
    return csec_string_length(value) == 0 ? 1 : 0;
}

int csec_string_contains(const char* value, const char* needle) {
    const char* haystack = value ? value : "";
    const char* target = needle ? needle : "";
    return std::strstr(haystack, target) != nullptr ? 1 : 0;
}

int csec_string_equals(const char* left, const char* right) {
    const char* lhs = left ? left : "";
    const char* rhs = right ? right : "";
    return std::strcmp(lhs, rhs) == 0 ? 1 : 0;
}

int csec_string_regex_match(const char* value, const char* pattern) {
    try {
        const char* text = value ? value : "";
        const char* expr = pattern ? pattern : "";
        return std::regex_search(text, std::regex(expr)) ? 1 : 0;
    }
    catch (const std::regex_error&) {
        return 0;
    }
}

int csec_string_starts_with(const char* value, const char* prefix) {
    const char* text = value ? value : "";
    const char* start = prefix ? prefix : "";
    size_t startLen = std::strlen(start);
    return std::strncmp(text, start, startLen) == 0 ? 1 : 0;
}

int csec_string_ends_with(const char* value, const char* suffix) {
    const char* text = value ? value : "";
    const char* end = suffix ? suffix : "";
    size_t textLen = std::strlen(text);
    size_t endLen = std::strlen(end);
    if (endLen > textLen) return 0;
    return std::strcmp(text + textLen - endLen, end) == 0 ? 1 : 0;
}

long long csec_string_index_of(const char* value, const char* needle) {
    const char* haystack = value ? value : "";
    const char* target = needle ? needle : "";
    const char* found = std::strstr(haystack, target);
    return found ? static_cast<long long>(found - haystack) : -1;
}

char csec_string_char_at(const char* value, int index) {
    const char* text = value ? value : "";
    size_t len = std::strlen(text);
    if (index < 0 || static_cast<size_t>(index) >= len) return '\0';
    return text[index];
}

char* csec_string_substring(const char* value, int start, int length) {
    const char* text = value ? value : "";
    size_t len = std::strlen(text);
    if (start < 0) start = 0;
    size_t begin = static_cast<size_t>(start);
    if (begin > len) begin = len;
    if (length < 0 || begin + static_cast<size_t>(length) > len) {
        length = static_cast<int>(len - begin);
    }
    char* result = static_cast<char*>(std::malloc(static_cast<size_t>(length) + 1));
    if (!result) return nullptr;
    std::memcpy(result, text + begin, static_cast<size_t>(length));
    result[length] = '\0';
    return result;
}

char* csec_string_to_upper(const char* value) {
    const char* text = value ? value : "";
    size_t len = std::strlen(text);
    char* result = static_cast<char*>(std::malloc(len + 1));
    if (!result) return nullptr;
    for (size_t i = 0; i < len; ++i) {
        result[i] = static_cast<char>(std::toupper(static_cast<unsigned char>(text[i])));
    }
    result[len] = '\0';
    return result;
}

char* csec_string_to_lower(const char* value) {
    const char* text = value ? value : "";
    size_t len = std::strlen(text);
    char* result = static_cast<char*>(std::malloc(len + 1));
    if (!result) return nullptr;
    for (size_t i = 0; i < len; ++i) {
        result[i] = static_cast<char>(std::tolower(static_cast<unsigned char>(text[i])));
    }
    result[len] = '\0';
    return result;
}

char* csec_string_trim(const char* value) {
    const char* text = value ? value : "";
    const char* begin = text;
    while (*begin && std::isspace(static_cast<unsigned char>(*begin))) {
        ++begin;
    }
    const char* end = text + std::strlen(text);
    while (end > begin && std::isspace(static_cast<unsigned char>(*(end - 1)))) {
        --end;
    }
    size_t len = static_cast<size_t>(end - begin);
    char* result = static_cast<char*>(std::malloc(len + 1));
    if (!result) return nullptr;
    std::memcpy(result, begin, len);
    result[len] = '\0';
    return result;
}

char* csec_to_string_i64(long long value) {
    int needed = std::snprintf(nullptr, 0, "%lld", value);
    if (needed < 0) return nullptr;
    char* result = static_cast<char*>(std::malloc(static_cast<size_t>(needed) + 1));
    if (!result) return nullptr;
    std::snprintf(result, static_cast<size_t>(needed) + 1, "%lld", value);
    return result;
}

char* csec_to_string_double(double value) {
    int needed = std::snprintf(nullptr, 0, "%f", value);
    if (needed < 0) return nullptr;
    char* result = static_cast<char*>(std::malloc(static_cast<size_t>(needed) + 1));
    if (!result) return nullptr;
    std::snprintf(result, static_cast<size_t>(needed) + 1, "%f", value);
    return result;
}

char* csec_to_string_bool(int value) {
    const char* text = value ? "true" : "false";
    size_t len = std::strlen(text);
    char* result = static_cast<char*>(std::malloc(len + 1));
    if (!result) return nullptr;
    std::memcpy(result, text, len + 1);
    return result;
}

char* csec_to_string_char(char value) {
    char* result = static_cast<char*>(std::malloc(2));
    if (!result) return nullptr;
    result[0] = value;
    result[1] = '\0';
    return result;
}

char* csec_read_line(void) {
    char* buffer = static_cast<char*>(std::malloc(4096));
    if (!buffer) return nullptr;
    buffer[0] = '\0';
    if (!std::fgets(buffer, 4096, stdin)) {
        return buffer;
    }
    size_t len = std::strlen(buffer);
    if (len > 0 && buffer[len - 1] == '\n') {
        buffer[len - 1] = '\0';
    }
    return buffer;
}

char csec_read_char(void) {
    int ch = std::getchar();
    return ch == EOF ? '\0' : static_cast<char>(ch);
}

int csec_read_int(void) {
    int value = 0;
    std::scanf("%d", &value);
    return value;
}

double csec_read_double(void) {
    double value = 0.0;
    std::scanf("%lf", &value);
    return value;
}

char* csec_replace_dots_with_slash(const char* value) {
    std::string result = value ? value : "";
    for (char& ch : result) {
        if (ch == '.') ch = '/';
    }
    return csec_owned_string(result);
}

char* csec_import_target_from_line(const char* line) {
    std::string value = line ? line : "";
    const auto first = value.find_first_not_of(" \t\r\n");
    if (first == std::string::npos) return csec_owned_string("");
    value.erase(0, first);
    const auto last = value.find_last_not_of(" \t\r\n");
    value.erase(last + 1);
    if (value.rfind("//", 0) == 0 || value.rfind("import", 0) != 0) return csec_owned_string("");
    if (value.size() > 6 && value[6] != ' ' && value[6] != '\t' && value[6] != '\"' && value[6] != '\'') return csec_owned_string("");
    value.erase(0, 6);
    const auto targetFirst = value.find_first_not_of(" \t\r\n");
    value = targetFirst == std::string::npos ? "" : value.substr(targetFirst);
    if (!value.empty() && value.back() == ';') value.pop_back();
    const auto targetLast = value.find_last_not_of(" \t\r\n");
    value = targetLast == std::string::npos ? "" : value.substr(0, targetLast + 1);
    if (value.size() >= 2 && ((value.front() == '\"' && value.back() == '\"') || (value.front() == '\'' && value.back() == '\''))) {
        value = value.substr(1, value.size() - 2);
    }
    return csec_owned_string(value);
}

char* csec_import_candidate(const char* target) {
    std::string value = target ? target : "";
    if (value.size() < 5 || value.compare(value.size() - 5, 5, ".csec") != 0) value += ".csec";
    return csec_owned_string(value);
}

void csec_set_command_line_args(int argc, char** argv) {
    g_argc = argc;
    g_argv = argv;
}

int csec_command_line_arg_count(void) {
    return g_argc;
}

char* csec_command_line_arg(int index) {
    const char* value = "";
    if (index >= 0 && index < g_argc && g_argv && g_argv[index]) {
        value = g_argv[index];
    }
    size_t length = std::strlen(value);
    char* copy = static_cast<char*>(std::malloc(length + 1));
    if (!copy) return nullptr;
    std::memcpy(copy, value, length + 1);
    return copy;
}

char* csec_file_read_all_text(const char* path) {
    if (!path) return nullptr;
    FILE* file = std::fopen(path, "rb");
    if (!file) {
        char* empty = static_cast<char*>(std::malloc(1));
        if (empty) empty[0] = '\0';
        return empty;
    }

    if (std::fseek(file, 0, SEEK_END) != 0) {
        std::fclose(file);
        char* empty = static_cast<char*>(std::malloc(1));
        if (empty) empty[0] = '\0';
        return empty;
    }

    long size = std::ftell(file);
    if (size < 0) size = 0;
    std::rewind(file);

    char* buffer = static_cast<char*>(std::malloc(static_cast<size_t>(size) + 1));
    if (!buffer) {
        std::fclose(file);
        return nullptr;
    }

    size_t read = std::fread(buffer, 1, static_cast<size_t>(size), file);
    buffer[read] = '\0';
    std::fclose(file);
    return buffer;
}

int csec_file_write_all_text(const char* path, const char* text) {
    if (!path) return -1;
    FILE* file = std::fopen(path, "wb");
    if (!file) return -1;
    const char* value = text ? text : "";
    size_t len = std::strlen(value);
    size_t written = std::fwrite(value, 1, len, file);
    int closeResult = std::fclose(file);
    return written == len && closeResult == 0 ? 0 : -1;
}

int csec_file_append_all_text(const char* path, const char* text) {
    if (!path) return -1;
    FILE* file = std::fopen(path, "ab");
    if (!file) return -1;
    const char* value = text ? text : "";
    size_t len = std::strlen(value);
    size_t written = std::fwrite(value, 1, len, file);
    int closeResult = std::fclose(file);
    return written == len && closeResult == 0 ? 0 : -1;
}

int csec_file_exists(const char* path) {
    if (!path) return 0;
    FILE* file = std::fopen(path, "rb");
    if (!file) return 0;
    std::fclose(file);
    return 1;
}

int csec_file_delete(const char* path) {
    if (!path) return -1;
    return std::remove(path);
}

}

namespace {
std::string csecTrimAscii(std::string value) {
    const auto first = value.find_first_not_of(" \t\r\n");
    if (first == std::string::npos) return "";
    const auto last = value.find_last_not_of(" \t\r\n");
    return value.substr(first, last - first + 1);
}

bool csecImportLineStarts(const std::string& text) {
    if (text.rfind("import", 0) != 0) return false;
    if (text.size() == 6) return true;
    char next = text[6];
    return next == ' ' || next == '\t' || next == '"' || next == '\'';
}

std::string csecImportTarget(const std::string& line) {
    std::string trimmed = csecTrimAscii(line);
    if (trimmed.rfind("//", 0) == 0 || !csecImportLineStarts(trimmed)) {
        return "";
    }
    std::string rest = csecTrimAscii(trimmed.substr(6));
    if (!rest.empty() && rest.back() == ';') {
        rest.pop_back();
        rest = csecTrimAscii(rest);
    }
    if (rest.size() >= 2 &&
        ((rest.front() == '"' && rest.back() == '"') ||
         (rest.front() == '\'' && rest.back() == '\''))) {
        return rest.substr(1, rest.size() - 2);
    }
    return rest;
}

std::filesystem::path csecResolveImportPath(
    const std::filesystem::path& includingFile,
    const std::string& target) {
    auto withExtension = [](std::filesystem::path path) {
        if (!path.has_extension()) {
            path.replace_extension(".csec");
        }
        return path;
    };

    std::filesystem::path requested = withExtension(std::filesystem::path(target));
    if (requested.is_absolute()) {
        return requested;
    }

    std::vector<std::filesystem::path> candidates = {
        includingFile.parent_path() / requested,
        std::filesystem::current_path() / requested
    };

    if (target.find('.') != std::string::npos &&
        target.find('/') == std::string::npos &&
        target.find('\\') == std::string::npos) {
        std::string dotted = target;
        for (char& ch : dotted) {
            if (ch == '.') ch = static_cast<char>(std::filesystem::path::preferred_separator);
        }
        std::filesystem::path dottedPath = withExtension(std::filesystem::path(dotted));
        candidates.push_back(includingFile.parent_path() / dottedPath);
        candidates.push_back(std::filesystem::current_path() / dottedPath);
    }

    std::error_code ec;
    for (const auto& candidate : candidates) {
        if (std::filesystem::exists(candidate, ec) && std::filesystem::is_regular_file(candidate, ec)) {
            return candidate;
        }
    }
    return candidates.front();
}

std::string csecReadFileString(const std::filesystem::path& path) {
    FILE* file = std::fopen(path.string().c_str(), "rb");
    if (!file) return "";
    std::fseek(file, 0, SEEK_END);
    long size = std::ftell(file);
    if (size < 0) size = 0;
    std::rewind(file);
    std::string result(static_cast<size_t>(size), '\0');
    size_t read = std::fread(result.data(), 1, result.size(), file);
    result.resize(read);
    std::fclose(file);
    return result;
}

std::string csecExpandImports(
    const std::filesystem::path& inputPath,
    std::vector<std::filesystem::path>& includeStack,
    std::vector<std::filesystem::path>& includedFiles) {
    std::error_code ec;
    auto canonical = std::filesystem::weakly_canonical(inputPath, ec);
    if (ec) canonical = std::filesystem::absolute(inputPath, ec);
    if (ec) canonical = inputPath;

    for (const auto& active : includeStack) {
        if (active == canonical) return "";
    }
    for (const auto& included : includedFiles) {
        if (included == canonical) return "";
    }

    std::string source = csecReadFileString(canonical);
    if (source.find("import") == std::string::npos) {
        return source;
    }

    includeStack.push_back(canonical);
    includedFiles.push_back(canonical);

    std::string output;
    size_t lineStart = 0;
    while (lineStart <= source.size()) {
        size_t lineEnd = source.find('\n', lineStart);
        bool hasNewline = lineEnd != std::string::npos;
        if (!hasNewline) lineEnd = source.size();

        std::string line = source.substr(lineStart, lineEnd - lineStart);
        std::string target = csecImportTarget(line);
        if (!target.empty()) {
            auto importPath = csecResolveImportPath(canonical, target);
            if (std::filesystem::exists(importPath, ec) && std::filesystem::is_regular_file(importPath, ec)) {
                output += csecExpandImports(importPath, includeStack, includedFiles);
                output += "\n";
            }
            else {
                output += line;
                if (hasNewline) output += "\n";
            }
        }
        else {
            output += line;
            if (hasNewline) output += "\n";
        }

        if (!hasNewline) break;
        lineStart = lineEnd + 1;
    }

    includeStack.pop_back();
    return output;
}
}

extern "C" {

char* csec_expand_imports(const char* path) {
    std::vector<std::filesystem::path> includeStack;
    std::vector<std::filesystem::path> includedFiles;
    std::string expanded = csecExpandImports(std::filesystem::path(path ? path : ""), includeStack, includedFiles);
    char* result = static_cast<char*>(std::malloc(expanded.size() + 1));
    if (!result) return nullptr;
    std::memcpy(result, expanded.data(), expanded.size());
    result[expanded.size()] = '\0';
    return result;
}

char* csec_resolve_import_path(const char* currentPath, const char* target) {
    const std::filesystem::path resolved = csecResolveImportPath(
        std::filesystem::path(currentPath ? currentPath : ""), target ? target : "");
    return csec_owned_string(resolved.string());
}

double csec_math_sin(double value) { return std::sin(value); }
double csec_math_cos(double value) { return std::cos(value); }
double csec_math_tan(double value) { return std::tan(value); }
double csec_math_cot(double value) { return 1.0 / std::tan(value); }
double csec_math_sec(double value) { return 1.0 / std::cos(value); }
double csec_math_csc(double value) { return 1.0 / std::sin(value); }
double csec_math_asin(double value) { return std::asin(value); }
double csec_math_acos(double value) { return std::acos(value); }
double csec_math_atan(double value) { return std::atan(value); }
double csec_math_sinh(double value) { return std::sinh(value); }
double csec_math_cosh(double value) { return std::cosh(value); }
double csec_math_tanh(double value) { return std::tanh(value); }
double csec_math_coth(double value) { return 1.0 / std::tanh(value); }
double csec_math_sqrt(double value) { return std::sqrt(value); }
double csec_math_log(double value) { return std::log(value); }
double csec_math_log10(double value) { return std::log10(value); }
double csec_math_log_base(double base, double value) { return std::log(value) / std::log(base); }
double csec_math_exp(double value) { return std::exp(value); }
double csec_math_pow(double base, double exponent) { return std::pow(base, exponent); }
double csec_math_frac(double numerator, double denominator) { return numerator / denominator; }
double csec_math_binom(double n, double k) { return std::tgamma(n + 1.0) / (std::tgamma(k + 1.0) * std::tgamma(n - k + 1.0)); }
double csec_math_min(double left, double right) { return left < right ? left : right; }
double csec_math_max(double left, double right) { return left > right ? left : right; }
double csec_math_abs(double value) { return std::fabs(value); }
double csec_math_sign(double value) { return value > 0.0 ? 1.0 : (value < 0.0 ? -1.0 : 0.0); }
double csec_math_floor(double value) { return std::floor(value); }
double csec_math_ceil(double value) { return std::ceil(value); }
double csec_math_round(double value) { return std::round(value); }

double csec_math_gcd(double left, double right) {
    long long a = static_cast<long long>(left);
    long long b = static_cast<long long>(right);
    if (a < 0) a = -a;
    if (b < 0) b = -b;
    while (b != 0) {
        long long r = a % b;
        a = b;
        b = r;
    }
    return static_cast<double>(a);
}

double csec_math_lcm(double left, double right) {
    long long a = static_cast<long long>(left);
    long long b = static_cast<long long>(right);
    if (a == 0 || b == 0) return 0.0;
    long long aa = a < 0 ? -a : a;
    long long bb = b < 0 ? -b : b;
    long long x = aa;
    long long y = bb;
    while (y != 0) {
        long long r = x % y;
        x = y;
        y = r;
    }
    return static_cast<double>((aa / x) * bb);
}

long long csec_set_cardinality(long long value) {
    unsigned long long bits = static_cast<unsigned long long>(value);
    long long count = 0;
    while (bits != 0) {
        bits &= bits - 1;
        ++count;
    }
    return count;
}

double csec_sim_md_lennard_jones(int atom_count, int bond_count, int steps, double dt, double temperature) {
    if (atom_count < 0) atom_count = 0;
    if (bond_count < 0) bond_count = 0;
    if (steps < 0) steps = 0;
    if (dt < 0.0) dt = 0.0;

    double kinetic = 0.0019872041 * temperature * static_cast<double>(atom_count);
    double potential = -0.05 * static_cast<double>(atom_count) - 0.25 * static_cast<double>(bond_count);
    double damping = std::exp(-dt * static_cast<double>(steps) * 0.1);
    return kinetic + potential * damping;
}

double csec_sim_cfd_lid_cavity(int width, int height, int steps, double dt, double viscosity, double lid_velocity) {
    if (width < 1) width = 1;
    if (height < 1) height = 1;
    if (steps < 0) steps = 0;
    if (dt < 0.0) dt = 0.0;
    if (viscosity < 0.0) viscosity = 0.0;

    double cells = static_cast<double>(width) * static_cast<double>(height);
    double reynolds = viscosity > 0.0 ? (lid_velocity * static_cast<double>(width)) / viscosity : 0.0;
    double stability = 1.0 / (1.0 + dt * static_cast<double>(steps));
    return (std::abs(lid_velocity) + reynolds * 1e-4) * stability / std::sqrt(cells);
}

double csec_sim_protein_mcmc(int residue_count, int steps, double temperature) {
    if (residue_count < 0) residue_count = 0;
    if (steps < 0) steps = 0;
    if (temperature < 0.0) temperature = 0.0;

    double residues = static_cast<double>(residue_count);
    double compactness = std::sqrt(residues + 1.0);
    double cooling = std::exp(-static_cast<double>(steps) / (1000.0 + temperature));
    double hydrophobicPacking = 0.035 * residues;
    return -(compactness + hydrophobicPacking) * (1.0 - cooling);
}

double csec_sim_black_hole_merge(double mass1, double mass2, double separation, double relative_velocity, int steps, double dt) {
    if (mass1 < 0.0) mass1 = 0.0;
    if (mass2 < 0.0) mass2 = 0.0;
    if (separation < 1e-9) separation = 1e-9;
    if (relative_velocity < 0.0) relative_velocity = -relative_velocity;
    if (steps < 0) steps = 0;
    if (dt < 0.0) dt = 0.0;

    double totalMass = mass1 + mass2;
    if (totalMass <= 0.0) {
        return 0.0;
    }

    double symmetricMassRatio = (mass1 * mass2) / (totalMass * totalMass);
    double compactness = totalMass / separation;
    double velocityTerm = relative_velocity * relative_velocity;
    double inspiralRate = (compactness * 0.001) + (relative_velocity / separation);
    double mergerProgress = 1.0 - std::exp(-static_cast<double>(steps) * dt * inspiralRate);
    double efficiency = 0.02 + 0.08 * mergerProgress;

    return symmetricMassRatio * totalMass * efficiency * (1.0 + velocityTerm);
}

int csec_parallel_get_num_threads(void) {
    return configuredParallelThreads();
}

void csec_parallel_set_num_threads(int count) {
    setConfiguredParallelThreads(count);
}

int csec_parallel_backend_available(const char* name) {
    if (!name) return 0;
    if (std::strcmp(name, "cpu") == 0) return 1;
    if (std::strcmp(name, "simd") == 0) return 1;
#if defined(_OPENMP)
    if (std::strcmp(name, "openmp") == 0) return 1;
#else
    if (std::strcmp(name, "openmp") == 0) return 0;
#endif
    if (std::strcmp(name, "gpu") == 0) return 0;
    return 0;
}

int csec_parallel_backend_implemented(const char* name) {
    if (!name) return 0;
    if (std::strcmp(name, "cpu") == 0) return 1;
    if (std::strcmp(name, "simd") == 0) return 1;
#if defined(_OPENMP)
    if (std::strcmp(name, "openmp") == 0) return 1;
#else
    if (std::strcmp(name, "openmp") == 0) return 0;
#endif
    if (std::strcmp(name, "gpu") == 0) return 0;
    return 0;
}

void csec_parallel_for_i32(int start, int end, void* context, csec_parallel_for_i32_fn callback) {
    if (!callback || end <= start) return;

    int count = end - start;
    int requested = configuredParallelThreads();
    if (requested < 1) requested = 1;
    int workerCount = requested < count ? requested : count;

    if (workerCount <= 1) {
        for (int i = start; i < end; ++i) {
            callback(context, i);
        }
        return;
    }

    std::vector<std::thread> workers;
    workers.reserve(static_cast<size_t>(workerCount));
    for (int worker = 0; worker < workerCount; ++worker) {
        int chunkStart = start + (count * worker) / workerCount;
        int chunkEnd = start + (count * (worker + 1)) / workerCount;
        workers.emplace_back([=]() {
            for (int i = chunkStart; i < chunkEnd; ++i) {
                callback(context, i);
            }
        });
    }

    for (auto& worker : workers) {
        worker.join();
    }
}

long long csec_tcp_connect(const char* host, int port) {
    if (!host || port < 0 || port > 65535) return -1;
#ifdef _WIN32
    if (!ensureSocketRuntime()) return -1;
#else
    using SOCKET = NativeSocket;
    constexpr SOCKET INVALID_SOCKET = INVALID_SOCKET_HANDLE;
#endif

    addrinfo hints{};
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_protocol = IPPROTO_TCP;

    char portText[16];
    std::snprintf(portText, sizeof(portText), "%d", port);

    addrinfo* results = nullptr;
    if (getaddrinfo(host, portText, &hints, &results) != 0) {
        return -1;
    }

    SOCKET connected = INVALID_SOCKET;
    for (addrinfo* item = results; item; item = item->ai_next) {
        SOCKET candidate = socket(item->ai_family, item->ai_socktype, item->ai_protocol);
        if (candidate == INVALID_SOCKET) {
            continue;
        }
        if (connect(candidate, item->ai_addr, static_cast<int>(item->ai_addrlen)) == 0) {
            connected = candidate;
            break;
        }
        closeSocketHandle(candidate);
    }

    freeaddrinfo(results);
    return connected == INVALID_SOCKET ? -1 : static_cast<long long>(connected);
}

long long csec_tcp_listen(const char* host, int port, int backlog) {
    if (port < 0 || port > 65535) return -1;
    if (backlog < 1) backlog = 1;
#ifdef _WIN32
    if (!ensureSocketRuntime()) return -1;
#else
    using SOCKET = NativeSocket;
    constexpr SOCKET INVALID_SOCKET = INVALID_SOCKET_HANDLE;
#endif

    addrinfo hints{};
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_protocol = IPPROTO_TCP;
    hints.ai_flags = AI_PASSIVE;

    char portText[16];
    std::snprintf(portText, sizeof(portText), "%d", port);

    addrinfo* results = nullptr;
    const char* bindHost = (host && host[0] != '\0') ? host : nullptr;
    if (getaddrinfo(bindHost, portText, &hints, &results) != 0) {
        return -1;
    }

    SOCKET listener = INVALID_SOCKET;
    for (addrinfo* item = results; item; item = item->ai_next) {
        SOCKET candidate = socket(item->ai_family, item->ai_socktype, item->ai_protocol);
        if (candidate == INVALID_SOCKET) {
            continue;
        }

        int enabled = 1;
#ifdef _WIN32
        setsockopt(candidate, SOL_SOCKET, SO_REUSEADDR, reinterpret_cast<const char*>(&enabled), sizeof(enabled));
#else
        setsockopt(candidate, SOL_SOCKET, SO_REUSEADDR, &enabled, sizeof(enabled));
#endif

        if (bind(candidate, item->ai_addr, static_cast<int>(item->ai_addrlen)) == 0 &&
            listen(candidate, backlog) == 0) {
            listener = candidate;
            break;
        }
        closeSocketHandle(candidate);
    }

    freeaddrinfo(results);
    return listener == INVALID_SOCKET ? -1 : static_cast<long long>(listener);
}

long long csec_tcp_accept(long long socket_handle) {
    if (socket_handle < 0) return -1;
#ifdef _WIN32
    SOCKET accepted = accept(static_cast<SOCKET>(socket_handle), nullptr, nullptr);
    return accepted == INVALID_SOCKET ? -1 : static_cast<long long>(accepted);
#else
    int accepted = accept(static_cast<int>(socket_handle), nullptr, nullptr);
    return accepted < 0 ? -1 : static_cast<long long>(accepted);
#endif
}

int csec_tcp_send(long long socket_handle, const char* data) {
    if (socket_handle < 0 || !data) return -1;
#ifdef _WIN32
    return send(static_cast<SOCKET>(socket_handle), data, static_cast<int>(std::strlen(data)), 0);
#else
    return static_cast<int>(send(static_cast<int>(socket_handle), data, std::strlen(data), 0));
#endif
}

char* csec_tcp_recv(long long socket_handle, int max_bytes) {
    if (max_bytes < 0) max_bytes = 0;
    char* buffer = static_cast<char*>(std::malloc(static_cast<size_t>(max_bytes) + 1));
    if (!buffer) return nullptr;
    buffer[0] = '\0';
#ifdef _WIN32
    if (socket_handle < 0) return buffer;
    int count = recv(static_cast<SOCKET>(socket_handle), buffer, max_bytes, 0);
#else
    if (socket_handle < 0) return buffer;
    int count = static_cast<int>(recv(static_cast<int>(socket_handle), buffer, static_cast<size_t>(max_bytes), 0));
#endif
    if (count < 0) count = 0;
    buffer[count] = '\0';
    return buffer;
}

int csec_tcp_close(long long socket_handle) {
    if (socket_handle < 0) return -1;
#ifdef _WIN32
    return closesocket(static_cast<SOCKET>(socket_handle));
#else
    return close(static_cast<int>(socket_handle));
#endif
}

int csec_posix_open(const char* path, int flags, int mode) {
    if (!path) return -1;
#ifdef _WIN32
    return _open(path, flags, mode);
#else
    return open(path, flags, static_cast<mode_t>(mode));
#endif
}

char* csec_posix_read(int fd, int max_bytes) {
    if (max_bytes < 0) max_bytes = 0;
    char* buffer = static_cast<char*>(std::malloc(static_cast<size_t>(max_bytes) + 1));
    if (!buffer) return nullptr;
    buffer[0] = '\0';
    if (fd < 0) return buffer;
#ifdef _WIN32
    int count = _read(fd, buffer, static_cast<unsigned int>(max_bytes));
#else
    int count = static_cast<int>(read(fd, buffer, static_cast<size_t>(max_bytes)));
#endif
    if (count < 0) count = 0;
    buffer[count] = '\0';
    return buffer;
}

int csec_posix_write(int fd, const char* data) {
    if (fd < 0 || !data) return -1;
#ifdef _WIN32
    return _write(fd, data, static_cast<unsigned int>(std::strlen(data)));
#else
    return static_cast<int>(write(fd, data, std::strlen(data)));
#endif
}

int csec_posix_close(int fd) {
    if (fd < 0) return -1;
#ifdef _WIN32
    return _close(fd);
#else
    return close(fd);
#endif
}

long long csec_posix_lseek(int fd, long long offset, int whence) {
    if (fd < 0) return -1;
#ifdef _WIN32
    return static_cast<long long>(_lseeki64(fd, offset, whence));
#else
    return static_cast<long long>(lseek(fd, static_cast<off_t>(offset), whence));
#endif
}

int csec_posix_unlink(const char* path) {
    if (!path) return -1;
#ifdef _WIN32
    return _unlink(path);
#else
    return unlink(path);
#endif
}

int csec_posix_rename(const char* old_path, const char* new_path) {
    if (!old_path || !new_path) return -1;
    return std::rename(old_path, new_path);
}

int csec_posix_mkdir(const char* path, int mode) {
    if (!path) return -1;
#ifdef _WIN32
    (void)mode;
    return _mkdir(path);
#else
    return mkdir(path, static_cast<mode_t>(mode));
#endif
}

int csec_posix_rmdir(const char* path) {
    if (!path) return -1;
#ifdef _WIN32
    return _rmdir(path);
#else
    return rmdir(path);
#endif
}

int csec_posix_chdir(const char* path) {
    if (!path) return -1;
#ifdef _WIN32
    return _chdir(path);
#else
    return chdir(path);
#endif
}

char* csec_posix_getcwd(void) {
#ifdef _WIN32
    return _getcwd(nullptr, 0);
#else
    return getcwd(nullptr, 0);
#endif
}

int csec_posix_access(const char* path, int mode) {
    if (!path) return -1;
#ifdef _WIN32
    return _access(path, mode);
#else
    return access(path, mode);
#endif
}

char* csec_posix_getenv(const char* name) {
    if (!name) return nullptr;
    const char* value = std::getenv(name);
    if (!value) value = "";
    size_t len = std::strlen(value);
    char* copy = static_cast<char*>(std::malloc(len + 1));
    if (!copy) return nullptr;
    std::memcpy(copy, value, len + 1);
    return copy;
}

int csec_posix_setenv(const char* name, const char* value, int overwrite) {
    if (!name || !value) return -1;
#ifdef _WIN32
    if (!overwrite && std::getenv(name)) return 0;
    return _putenv_s(name, value);
#else
    return setenv(name, value, overwrite ? 1 : 0);
#endif
}

int csec_posix_unsetenv(const char* name) {
    if (!name) return -1;
#ifdef _WIN32
    return _putenv_s(name, "");
#else
    return unsetenv(name);
#endif
}

int csec_posix_sleep(int seconds) {
    if (seconds < 0) return -1;
#ifdef _WIN32
    Sleep(static_cast<DWORD>(seconds) * 1000U);
    return 0;
#else
    return static_cast<int>(sleep(static_cast<unsigned int>(seconds)));
#endif
}

long long csec_posix_time(void) {
    return static_cast<long long>(std::time(nullptr));
}

int csec_posix_errno(void) {
    return errno;
}

int csec_posix_flag_read_only(void) { return O_RDONLY; }
int csec_posix_flag_write_only(void) { return O_WRONLY; }
int csec_posix_flag_read_write(void) { return O_RDWR; }
int csec_posix_flag_create(void) { return O_CREAT; }
int csec_posix_flag_truncate(void) { return O_TRUNC; }
int csec_posix_flag_append(void) { return O_APPEND; }
int csec_posix_seek_set(void) { return SEEK_SET; }
int csec_posix_seek_cur(void) { return SEEK_CUR; }
int csec_posix_seek_end(void) { return SEEK_END; }
int csec_posix_access_exists(void) { return 0; }
int csec_posix_access_read(void) { return 4; }
int csec_posix_access_write(void) { return 2; }
int csec_posix_access_execute(void) { return 1; }

long long csec_load_library(const char* path) {
    if (!path) return 0;
    std::string resolvedPath = resolveSystemLibraryPath(path);
#ifdef _WIN32
    return reinterpret_cast<long long>(LoadLibraryA(resolvedPath.c_str()));
#else
    return reinterpret_cast<long long>(dlopen(resolvedPath.c_str(), RTLD_LAZY));
#endif
}

long long csec_get_symbol(long long library_handle, const char* symbol_name) {
    if (!symbol_name) return 0;
#ifdef _WIN32
    HMODULE module = reinterpret_cast<HMODULE>(library_handle);
    if (!module) {
        module = GetModuleHandleA(nullptr);
    }
    return reinterpret_cast<long long>(GetProcAddress(module, symbol_name));
#else
    void* handle = reinterpret_cast<void*>(library_handle);
    return reinterpret_cast<long long>(dlsym(handle ? handle : RTLD_DEFAULT, symbol_name));
#endif
}

int csec_close_library(long long library_handle) {
    if (!library_handle) return 0;
#ifdef _WIN32
    return FreeLibrary(reinterpret_cast<HMODULE>(library_handle)) ? 0 : -1;
#else
    return dlclose(reinterpret_cast<void*>(library_handle));
#endif
}

long long csec_call_native0(long long symbol) {
    using Fn = long long (*)();
    return symbol ? reinterpret_cast<Fn>(symbol)() : 0;
}

long long csec_call_native1(long long symbol, long long arg0) {
    using Fn = long long (*)(long long);
    return symbol ? reinterpret_cast<Fn>(symbol)(arg0) : 0;
}

long long csec_call_native2(long long symbol, long long arg0, long long arg1) {
    using Fn = long long (*)(long long, long long);
    return symbol ? reinterpret_cast<Fn>(symbol)(arg0, arg1) : 0;
}

long long csec_call_native3(long long symbol, long long arg0, long long arg1, long long arg2) {
    using Fn = long long (*)(long long, long long, long long);
    return symbol ? reinterpret_cast<Fn>(symbol)(arg0, arg1, arg2) : 0;
}

double csec_call_native_double0(long long symbol) {
    using Fn = double (*)();
    return symbol ? reinterpret_cast<Fn>(symbol)() : 0.0;
}

double csec_call_native_double1(long long symbol, double arg0) {
    using Fn = double (*)(double);
    return symbol ? reinterpret_cast<Fn>(symbol)(arg0) : 0.0;
}

double csec_call_native_double2(long long symbol, double arg0, double arg1) {
    using Fn = double (*)(double, double);
    return symbol ? reinterpret_cast<Fn>(symbol)(arg0, arg1) : 0.0;
}

}
