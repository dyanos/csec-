// JSON documents (std.json).
//
// A document is a tree of JSON values behind a Long handle. Values are addressed by a path string:
//
//     ""                         the root
//     "choices[0].message.role"  object members and array elements
//     "items[-1]"                negative indices count from the end
//     "a[\"key.with.dots\"]"     quoted member names
//     "messages[]"               (set only) append a new element to an array
//
// Setters create the objects and arrays a path needs (a null or missing value becomes an object for
// a member step and an array for an index step). csec_json_get returns a handle that shares the
// subtree with its document, so changes through either are visible in both. Numbers keep their source
// text, so 64-bit integers round-trip exactly. Strings returned to the caller are new allocations.

#include <cerrno>
#include <memory>
#include <mutex>
#include <string>
#include <utility>
#include <vector>

namespace csec_json {

struct Value;
using ValuePtr = std::shared_ptr<Value>;

struct Value {
    enum Kind { Null, Bool, Number, String, Array, Object };
    Kind kind = Null;
    bool flag = false;
    std::string text;  // number source text, or the string's (UTF-8) value
    std::vector<ValuePtr> items;
    std::vector<std::pair<std::string, ValuePtr>> members;

    ValuePtr member(const std::string& key) const {
        for (const auto& entry : members) {
            if (entry.first == key) return entry.second;
        }
        return nullptr;
    }
};

ValuePtr deepCopy(const ValuePtr& value) {
    auto copy = std::make_shared<Value>();
    copy->kind = value->kind;
    copy->flag = value->flag;
    copy->text = value->text;
    for (const auto& item : value->items) copy->items.push_back(deepCopy(item));
    for (const auto& entry : value->members) copy->members.emplace_back(entry.first, deepCopy(entry.second));
    return copy;
}

csec_threads::HandleTable<Value>& documents() {
    static auto* table = new csec_threads::HandleTable<Value>();
    return *table;
}

std::mutex& errorMutex() {
    static std::mutex mutex;
    return mutex;
}
std::string& lastError() {
    static std::string error;
    return error;
}
void setError(const std::string& message) {
    std::lock_guard<std::mutex> lock(errorMutex());
    lastError() = message;
}

// ---- Parsing ----

class Parser {
public:
    Parser(const char* text, size_t size) : p_(text), begin_(text), end_(text + size) {}

    ValuePtr parseDocument() {
        skipSpace();
        ValuePtr value = parseValue(0);
        if (!value) return nullptr;
        skipSpace();
        if (p_ != end_) return fail("unexpected text after the JSON value");
        return value;
    }

    std::string error;

private:
    const char* p_;
    const char* begin_;
    const char* end_;

    ValuePtr fail(const std::string& message) {
        if (error.empty()) error = message + " at offset " + std::to_string(p_ - begin_);
        return nullptr;
    }

    void skipSpace() {
        while (p_ < end_ && (*p_ == ' ' || *p_ == '\t' || *p_ == '\n' || *p_ == '\r')) ++p_;
    }

    bool literal(const char* word) {
        const size_t n = std::strlen(word);
        if (static_cast<size_t>(end_ - p_) < n || std::memcmp(p_, word, n) != 0) return false;
        p_ += n;
        return true;
    }

    ValuePtr parseValue(int depth) {
        if (depth > 512) return fail("JSON nested too deeply");
        if (p_ >= end_) return fail("unexpected end of JSON");
        auto value = std::make_shared<Value>();
        const char c = *p_;
        if (c == '{') {
            value->kind = Value::Object;
            ++p_;
            skipSpace();
            if (p_ < end_ && *p_ == '}') {
                ++p_;
                return value;
            }
            for (;;) {
                skipSpace();
                if (p_ >= end_ || *p_ != '"') return fail("expected a member name");
                std::string key;
                if (!parseString(key)) return nullptr;
                skipSpace();
                if (p_ >= end_ || *p_ != ':') return fail("expected ':'");
                ++p_;
                skipSpace();
                ValuePtr item = parseValue(depth + 1);
                if (!item) return nullptr;
                bool replaced = false;
                for (auto& entry : value->members) {
                    if (entry.first == key) {
                        entry.second = item;  // a repeated name keeps its last value
                        replaced = true;
                        break;
                    }
                }
                if (!replaced) value->members.emplace_back(std::move(key), item);
                skipSpace();
                if (p_ < end_ && *p_ == ',') {
                    ++p_;
                    continue;
                }
                if (p_ < end_ && *p_ == '}') {
                    ++p_;
                    return value;
                }
                return fail("expected ',' or '}'");
            }
        }
        if (c == '[') {
            value->kind = Value::Array;
            ++p_;
            skipSpace();
            if (p_ < end_ && *p_ == ']') {
                ++p_;
                return value;
            }
            for (;;) {
                skipSpace();
                ValuePtr item = parseValue(depth + 1);
                if (!item) return nullptr;
                value->items.push_back(item);
                skipSpace();
                if (p_ < end_ && *p_ == ',') {
                    ++p_;
                    continue;
                }
                if (p_ < end_ && *p_ == ']') {
                    ++p_;
                    return value;
                }
                return fail("expected ',' or ']'");
            }
        }
        if (c == '"') {
            value->kind = Value::String;
            if (!parseString(value->text)) return nullptr;
            return value;
        }
        if (literal("true")) {
            value->kind = Value::Bool;
            value->flag = true;
            return value;
        }
        if (literal("false")) {
            value->kind = Value::Bool;
            return value;
        }
        if (literal("null")) return value;
        if (c == '-' || (c >= '0' && c <= '9')) {
            const char* start = p_;
            if (*p_ == '-') ++p_;
            if (p_ >= end_ || !(*p_ >= '0' && *p_ <= '9')) return fail("invalid number");
            if (*p_ == '0') {
                ++p_;
            } else {
                while (p_ < end_ && *p_ >= '0' && *p_ <= '9') ++p_;
            }
            if (p_ < end_ && *p_ == '.') {
                ++p_;
                if (p_ >= end_ || !(*p_ >= '0' && *p_ <= '9')) return fail("invalid number");
                while (p_ < end_ && *p_ >= '0' && *p_ <= '9') ++p_;
            }
            if (p_ < end_ && (*p_ == 'e' || *p_ == 'E')) {
                ++p_;
                if (p_ < end_ && (*p_ == '+' || *p_ == '-')) ++p_;
                if (p_ >= end_ || !(*p_ >= '0' && *p_ <= '9')) return fail("invalid number");
                while (p_ < end_ && *p_ >= '0' && *p_ <= '9') ++p_;
            }
            value->kind = Value::Number;
            value->text.assign(start, p_);
            return value;
        }
        return fail("unexpected character");
    }

    static void appendUtf8(std::string& out, unsigned code) {
        if (code < 0x80) {
            out += static_cast<char>(code);
        } else if (code < 0x800) {
            out += static_cast<char>(0xC0 | (code >> 6));
            out += static_cast<char>(0x80 | (code & 0x3F));
        } else if (code < 0x10000) {
            out += static_cast<char>(0xE0 | (code >> 12));
            out += static_cast<char>(0x80 | ((code >> 6) & 0x3F));
            out += static_cast<char>(0x80 | (code & 0x3F));
        } else {
            out += static_cast<char>(0xF0 | (code >> 18));
            out += static_cast<char>(0x80 | ((code >> 12) & 0x3F));
            out += static_cast<char>(0x80 | ((code >> 6) & 0x3F));
            out += static_cast<char>(0x80 | (code & 0x3F));
        }
    }

    bool hex4(unsigned& code) {
        if (end_ - p_ < 4) return false;
        code = 0;
        for (int i = 0; i < 4; ++i) {
            const char h = p_[i];
            code <<= 4;
            if (h >= '0' && h <= '9') code |= static_cast<unsigned>(h - '0');
            else if (h >= 'a' && h <= 'f') code |= static_cast<unsigned>(h - 'a' + 10);
            else if (h >= 'A' && h <= 'F') code |= static_cast<unsigned>(h - 'A' + 10);
            else return false;
        }
        p_ += 4;
        return true;
    }

    bool parseString(std::string& out) {
        ++p_;  // opening quote
        for (;;) {
            if (p_ >= end_) {
                fail("unterminated string");
                return false;
            }
            const char c = *p_++;
            if (c == '"') return true;
            if (static_cast<unsigned char>(c) < 0x20) {
                --p_;
                fail("control character in string");
                return false;
            }
            if (c != '\\') {
                out += c;
                continue;
            }
            if (p_ >= end_) {
                fail("unterminated string");
                return false;
            }
            const char e = *p_++;
            switch (e) {
            case '"': out += '"'; break;
            case '\\': out += '\\'; break;
            case '/': out += '/'; break;
            case 'b': out += '\b'; break;
            case 'f': out += '\f'; break;
            case 'n': out += '\n'; break;
            case 'r': out += '\r'; break;
            case 't': out += '\t'; break;
            case 'u': {
                unsigned code = 0;
                if (!hex4(code)) {
                    fail("invalid \\u escape");
                    return false;
                }
                if (code >= 0xD800 && code <= 0xDBFF && end_ - p_ >= 6 && p_[0] == '\\' && p_[1] == 'u') {
                    const char* save = p_;
                    p_ += 2;
                    unsigned low = 0;
                    if (hex4(low) && low >= 0xDC00 && low <= 0xDFFF) {
                        code = 0x10000 + ((code - 0xD800) << 10) + (low - 0xDC00);
                    } else {
                        p_ = save;
                        code = 0xFFFD;
                    }
                } else if (code >= 0xD800 && code <= 0xDFFF) {
                    code = 0xFFFD;  // lone surrogate
                }
                appendUtf8(out, code);
                break;
            }
            default:
                --p_;
                fail("invalid escape");
                return false;
            }
        }
    }
};

ValuePtr parse(const char* text, size_t size, std::string& error) {
    Parser parser(text, size);
    ValuePtr value = parser.parseDocument();
    if (!value) error = parser.error;
    return value;
}

// ---- Writing ----

void quote(std::string& out, const std::string& text) {
    static const char* hex = "0123456789abcdef";
    out += '"';
    for (unsigned char c : text) {
        switch (c) {
        case '"': out += "\\\""; break;
        case '\\': out += "\\\\"; break;
        case '\n': out += "\\n"; break;
        case '\r': out += "\\r"; break;
        case '\t': out += "\\t"; break;
        case '\b': out += "\\b"; break;
        case '\f': out += "\\f"; break;
        default:
            if (c < 0x20) {
                out += "\\u00";
                out += hex[c >> 4];
                out += hex[c & 15];
            } else {
                out += static_cast<char>(c);
            }
        }
    }
    out += '"';
}

void newline(std::string& out, int indent, int level) {
    if (indent <= 0) return;
    out += '\n';
    out.append(static_cast<size_t>(indent) * static_cast<size_t>(level), ' ');
}

void write(std::string& out, const Value& value, int indent, int level) {
    switch (value.kind) {
    case Value::Null: out += "null"; break;
    case Value::Bool: out += value.flag ? "true" : "false"; break;
    case Value::Number: out += value.text; break;
    case Value::String: quote(out, value.text); break;
    case Value::Array:
        if (value.items.empty()) {
            out += "[]";
            break;
        }
        out += '[';
        for (size_t i = 0; i < value.items.size(); ++i) {
            if (i) out += ',';
            newline(out, indent, level + 1);
            write(out, *value.items[i], indent, level + 1);
        }
        newline(out, indent, level);
        out += ']';
        break;
    case Value::Object:
        if (value.members.empty()) {
            out += "{}";
            break;
        }
        out += '{';
        for (size_t i = 0; i < value.members.size(); ++i) {
            if (i) out += ',';
            newline(out, indent, level + 1);
            quote(out, value.members[i].first);
            out += indent > 0 ? ": " : ":";
            write(out, *value.members[i].second, indent, level + 1);
        }
        newline(out, indent, level);
        out += '}';
        break;
    }
}

std::string toText(const Value& value, int indent) {
    std::string out;
    write(out, value, indent, 0);
    return out;
}

std::string numberText(double number) {
    if (!(number == number) || number > 1.7976931348623157e308 || number < -1.7976931348623157e308) return "null";
    char buffer[40];
    for (int precision = 15; precision <= 17; ++precision) {
        std::snprintf(buffer, sizeof(buffer), "%.*g", precision, number);
        if (std::strtod(buffer, nullptr) == number) break;
    }
    return buffer;
}

// ---- Paths ----

struct Step {
    enum Kind { Member, Index, Append } kind = Member;
    std::string key;
    long long index = 0;
};

bool parsePath(const char* path, std::vector<Step>& steps, std::string& error) {
    const char* p = path ? path : "";
    while (*p) {
        if (*p == '.') {
            ++p;
            continue;
        }
        Step step;
        if (*p == '[') {
            ++p;
            if (*p == ']') {
                step.kind = Step::Append;
                ++p;
            } else if (*p == '"' || *p == '\'') {
                const char q = *p++;
                while (*p && *p != q) {
                    if (*p == '\\' && p[1]) ++p;
                    step.key += *p++;
                }
                if (*p != q || p[1] != ']') {
                    error = std::string("bad quoted name in path '") + path + "'";
                    return false;
                }
                p += 2;
            } else {
                char* stop = nullptr;
                step.kind = Step::Index;
                step.index = std::strtoll(p, &stop, 10);
                if (stop == p || *stop != ']') {
                    error = std::string("bad index in path '") + path + "'";
                    return false;
                }
                p = stop + 1;
            }
        } else {
            while (*p && *p != '.' && *p != '[') step.key += *p++;
        }
        steps.push_back(std::move(step));
    }
    return true;
}

ValuePtr lookup(const ValuePtr& root, const char* path) {
    std::vector<Step> steps;
    std::string error;
    if (!root || !parsePath(path, steps, error)) return nullptr;
    ValuePtr node = root;
    for (const Step& step : steps) {
        if (step.kind == Step::Member) {
            if (node->kind != Value::Object) return nullptr;
            node = node->member(step.key);
        } else if (step.kind == Step::Index) {
            if (node->kind != Value::Array) return nullptr;
            long long index = step.index;
            const long long size = static_cast<long long>(node->items.size());
            if (index < 0) index += size;
            if (index < 0 || index >= size) return nullptr;
            node = node->items[static_cast<size_t>(index)];
        } else {
            return nullptr;
        }
        if (!node) return nullptr;
    }
    return node;
}

// The node at `path`, created (as null) if missing; nullptr when the path runs into a scalar.
ValuePtr locate(const ValuePtr& root, const char* path, std::string& error) {
    std::vector<Step> steps;
    if (!root || !parsePath(path, steps, error)) return nullptr;
    ValuePtr node = root;
    for (const Step& step : steps) {
        if (step.kind == Step::Member) {
            if (node->kind == Value::Null) node->kind = Value::Object;
            if (node->kind != Value::Object) {
                error = std::string("'") + step.key + "' in path '" + path + "' is not inside an object";
                return nullptr;
            }
            ValuePtr next = node->member(step.key);
            if (!next) {
                next = std::make_shared<Value>();
                node->members.emplace_back(step.key, next);
            }
            node = next;
        } else {
            if (node->kind == Value::Null) node->kind = Value::Array;
            if (node->kind != Value::Array) {
                error = std::string("index in path '") + path + "' is not inside an array";
                return nullptr;
            }
            const long long size = static_cast<long long>(node->items.size());
            long long index = step.kind == Step::Append ? size : step.index;
            if (index < 0) index += size;
            if (index == size) {
                node->items.push_back(std::make_shared<Value>());
            } else if (index < 0 || index > size) {
                error = std::string("index out of range in path '") + path + "'";
                return nullptr;
            }
            node = node->items[static_cast<size_t>(index)];
        }
    }
    return node;
}

int assign(long long handle, const char* path, const Value& value) {
    auto root = documents().get(handle);
    if (!root) {
        setError("invalid JSON handle");
        return 0;
    }
    std::string error;
    ValuePtr node = locate(root, path, error);
    if (!node) {
        setError(error);
        return 0;
    }
    node->kind = value.kind;
    node->flag = value.flag;
    node->text = value.text;
    node->items = value.items;
    node->members = value.members;
    return 1;
}

const char* kindName(Value::Kind kind) {
    switch (kind) {
    case Value::Null: return "null";
    case Value::Bool: return "bool";
    case Value::Number: return "number";
    case Value::String: return "string";
    case Value::Array: return "array";
    case Value::Object: return "object";
    }
    return "null";
}

ValuePtr at(long long handle, const char* path) {
    auto root = documents().get(handle);
    return root ? lookup(root, path) : nullptr;
}

char* owned(const std::string& text) {
    return csec_microthread::ownedText(text);
}

} // namespace csec_json

extern "C" {

long long csec_json_parse(const char* text) {
    std::string error;
    const char* source = text ? text : "";
    auto value = csec_json::parse(source, std::strlen(source), error);
    if (!value) {
        csec_json::setError(error);
        return 0;
    }
    return csec_json::documents().add(value);
}

char* csec_json_last_error(void) {
    std::lock_guard<std::mutex> lock(csec_json::errorMutex());
    return csec_json::owned(csec_json::lastError());
}

long long csec_json_new_object(void) {
    auto value = std::make_shared<csec_json::Value>();
    value->kind = csec_json::Value::Object;
    return csec_json::documents().add(value);
}

long long csec_json_new_array(void) {
    auto value = std::make_shared<csec_json::Value>();
    value->kind = csec_json::Value::Array;
    return csec_json::documents().add(value);
}

long long csec_json_get(long long handle, const char* path) {
    auto node = csec_json::at(handle, path);
    return node ? csec_json::documents().add(node) : 0;
}

long long csec_json_copy(long long handle, const char* path) {
    auto node = csec_json::at(handle, path);
    return node ? csec_json::documents().add(csec_json::deepCopy(node)) : 0;
}

void csec_json_free(long long handle) {
    csec_json::documents().take(handle);
}

int csec_json_has(long long handle, const char* path) {
    return csec_json::at(handle, path) ? 1 : 0;
}

char* csec_json_type(long long handle, const char* path) {
    auto node = csec_json::at(handle, path);
    return csec_json::owned(node ? csec_json::kindName(node->kind) : "missing");
}

char* csec_json_get_string(long long handle, const char* path) {
    using csec_json::Value;
    auto node = csec_json::at(handle, path);
    if (!node || node->kind == Value::Null) return csec_json::owned("");
    if (node->kind == Value::String || node->kind == Value::Number) return csec_json::owned(node->text);
    if (node->kind == Value::Bool) return csec_json::owned(node->flag ? "true" : "false");
    return csec_json::owned(csec_json::toText(*node, 0));
}

long long csec_json_get_long(long long handle, const char* path, long long fallback) {
    using csec_json::Value;
    auto node = csec_json::at(handle, path);
    if (!node) return fallback;
    if (node->kind == Value::Bool) return node->flag ? 1 : 0;
    if (node->kind != Value::Number && node->kind != Value::String) return fallback;
    const char* text = node->text.c_str();
    char* stop = nullptr;
    errno = 0;
    const long long whole = std::strtoll(text, &stop, 10);
    if (stop != text && *stop == '\0' && errno == 0) return whole;
    const double number = std::strtod(text, &stop);
    if (stop == text || *stop != '\0' || !(number == number)) return fallback;
    if (number >= 9.2233720368547758e18) return 9223372036854775807LL;
    if (number <= -9.2233720368547758e18) return (-9223372036854775807LL - 1);
    return static_cast<long long>(number);
}

double csec_json_get_double(long long handle, const char* path, double fallback) {
    using csec_json::Value;
    auto node = csec_json::at(handle, path);
    if (!node) return fallback;
    if (node->kind == Value::Bool) return node->flag ? 1.0 : 0.0;
    if (node->kind != Value::Number && node->kind != Value::String) return fallback;
    char* stop = nullptr;
    const double number = std::strtod(node->text.c_str(), &stop);
    return stop == node->text.c_str() || *stop != '\0' ? fallback : number;
}

int csec_json_get_bool(long long handle, const char* path, int fallback) {
    using csec_json::Value;
    auto node = csec_json::at(handle, path);
    if (!node) return fallback;
    if (node->kind == Value::Bool) return node->flag ? 1 : 0;
    if (node->kind == Value::Number) return std::strtod(node->text.c_str(), nullptr) != 0.0 ? 1 : 0;
    if (node->kind == Value::String) {
        if (node->text == "true") return 1;
        if (node->text == "false") return 0;
    }
    return fallback;
}

long long csec_json_length(long long handle, const char* path) {
    using csec_json::Value;
    auto node = csec_json::at(handle, path);
    if (!node) return 0;
    if (node->kind == Value::Array) return static_cast<long long>(node->items.size());
    if (node->kind == Value::Object) return static_cast<long long>(node->members.size());
    if (node->kind == Value::String) return static_cast<long long>(node->text.size());
    return 0;
}

char* csec_json_key(long long handle, const char* path, long long index) {
    auto node = csec_json::at(handle, path);
    if (!node || node->kind != csec_json::Value::Object || index < 0 ||
        index >= static_cast<long long>(node->members.size())) {
        return csec_json::owned("");
    }
    return csec_json::owned(node->members[static_cast<size_t>(index)].first);
}

int csec_json_set_string(long long handle, const char* path, const char* value) {
    csec_json::Value v;
    v.kind = csec_json::Value::String;
    v.text = value ? value : "";
    return csec_json::assign(handle, path, v);
}

int csec_json_set_long(long long handle, const char* path, long long value) {
    csec_json::Value v;
    v.kind = csec_json::Value::Number;
    v.text = std::to_string(value);
    return csec_json::assign(handle, path, v);
}

int csec_json_set_double(long long handle, const char* path, double value) {
    csec_json::Value v;
    v.text = csec_json::numberText(value);
    v.kind = v.text == "null" ? csec_json::Value::Null : csec_json::Value::Number;
    if (v.kind == csec_json::Value::Null) v.text.clear();
    return csec_json::assign(handle, path, v);
}

int csec_json_set_bool(long long handle, const char* path, int value) {
    csec_json::Value v;
    v.kind = csec_json::Value::Bool;
    v.flag = value != 0;
    return csec_json::assign(handle, path, v);
}

int csec_json_set_null(long long handle, const char* path) {
    return csec_json::assign(handle, path, csec_json::Value());
}

int csec_json_set_empty_object(long long handle, const char* path) {
    csec_json::Value v;
    v.kind = csec_json::Value::Object;
    return csec_json::assign(handle, path, v);
}

int csec_json_set_empty_array(long long handle, const char* path) {
    csec_json::Value v;
    v.kind = csec_json::Value::Array;
    return csec_json::assign(handle, path, v);
}

// Parse `json` and store the value at `path`.
int csec_json_set_json(long long handle, const char* path, const char* json) {
    std::string error;
    const char* source = json ? json : "";
    auto value = csec_json::parse(source, std::strlen(source), error);
    if (!value) {
        csec_json::setError(error);
        return 0;
    }
    return csec_json::assign(handle, path, *value);
}

// Store a deep copy of another document (or subtree handle) at `path`.
int csec_json_set_value(long long handle, const char* path, long long other) {
    auto source = csec_json::documents().get(other);
    if (!source) {
        csec_json::setError("invalid JSON handle");
        return 0;
    }
    return csec_json::assign(handle, path, *csec_json::deepCopy(source));
}

int csec_json_remove(long long handle, const char* path) {
    auto root = csec_json::documents().get(handle);
    std::vector<csec_json::Step> steps;
    std::string error;
    if (!root || !csec_json::parsePath(path, steps, error) || steps.empty()) return 0;
    const csec_json::Step last = steps.back();
    steps.pop_back();
    std::string parentPath;
    for (const auto& step : steps) {
        if (step.kind == csec_json::Step::Member) {
            parentPath += "[\"" + step.key + "\"]";
        } else if (step.kind == csec_json::Step::Index) {
            parentPath += "[" + std::to_string(step.index) + "]";
        } else {
            return 0;
        }
    }
    auto parent = csec_json::lookup(root, parentPath.c_str());
    if (!parent) return 0;
    if (last.kind == csec_json::Step::Member && parent->kind == csec_json::Value::Object) {
        for (auto it = parent->members.begin(); it != parent->members.end(); ++it) {
            if (it->first == last.key) {
                parent->members.erase(it);
                return 1;
            }
        }
        return 0;
    }
    if (last.kind == csec_json::Step::Index && parent->kind == csec_json::Value::Array) {
        long long index = last.index;
        const long long size = static_cast<long long>(parent->items.size());
        if (index < 0) index += size;
        if (index < 0 || index >= size) return 0;
        parent->items.erase(parent->items.begin() + index);
        return 1;
    }
    return 0;
}

// The value at `path` as JSON text; indent > 0 pretty-prints with that many spaces per level.
char* csec_json_stringify(long long handle, const char* path, int indent) {
    auto node = csec_json::at(handle, path);
    return csec_json::owned(node ? csec_json::toText(*node, indent) : "");
}

// `text` as a JSON string literal, quotes included.
char* csec_json_quote(const char* text) {
    std::string out;
    csec_json::quote(out, text ? text : "");
    return csec_json::owned(out);
}

} // extern "C"
