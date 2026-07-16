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

int csec_digit_value(char ch) {
    return ch >= '0' && ch <= '9' ? ch - '0' : 0;
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

char* csec_llvm_lexer_helper_definition(const char* name) {
    const char* definition = "";
    if (name && std::strcmp(name, "tokenIs") == 0) {
        definition = "define i1 @tokenIs(ptr %arg.tokens, i32 %arg.ordinal, i8 %arg.kind, ptr %arg.text) {\nentry:\n  %token.is = call i32 @csec_token_is(ptr %arg.tokens, i32 %arg.ordinal, i8 %arg.kind, ptr %arg.text)\n  %token.is.bool = icmp ne i32 %token.is, 0\n  ret i1 %token.is.bool\n}\n\n";
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
    return reinterpret_cast<long long>(builder);
}

int csec_string_builder_append(long long handle, const char* text) {
    auto* builder = reinterpret_cast<StringBuilder*>(handle);
    if (!builder) return -1;

    const char* value = text ? text : "";
    size_t valueLen = std::strlen(value);
    if (builder->file) {
        if (std::fwrite(value, 1, valueLen, builder->file) != valueLen) return -1;
        return std::fflush(builder->file) == 0 ? 0 : -1;
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
        std::free(const_cast<char*>(tokens));
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
            }
            params.emplace_back(std::move(name), std::move(typeName));
        }
        while (cursor < paramEnd && !csec_native_token_is(tokens, cursor, 'O', ",")) ++cursor;
        ++cursor;
    }
    return params;
}

extern "C" {

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
