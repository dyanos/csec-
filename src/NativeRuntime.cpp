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

std::unordered_map<const char*, std::vector<int>>& tokenLineCache() {
    static std::unordered_map<const char*, std::vector<int>> cache;
    return cache;
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
        char* empty = static_cast<char*>(std::malloc(1));
        if (empty) empty[0] = '\0';
        return empty;
    }

    const auto& starts = tokenLineStarts(value);
    if (static_cast<size_t>(ordinal) >= starts.size()) {
        char* empty = static_cast<char*>(std::malloc(1));
        if (empty) empty[0] = '\0';
        return empty;
    }

    int start = starts[static_cast<size_t>(ordinal)];
    int textStart = start + 2;
    int end = textStart;
    while (value[end] != '\0' && value[end] != '\n') {
        ++end;
    }
    if (textStart > end) textStart = end;

    size_t length = static_cast<size_t>(end - textStart);
    char* result = static_cast<char*>(std::malloc(length + 1));
    if (!result) return nullptr;
    std::memcpy(result, value + textStart, length);
    result[length] = '\0';
    return result;
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
