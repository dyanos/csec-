// Polars-style expressions and lazy queries for std.dataframe.
//
// Expressions (`col("a") > 5`, `col("x").sum().alias("total")`, `when(...).then(...).otherwise(...)`)
// are immutable trees addressed by handles. They are evaluated column-at-a-time against a frame:
//   - in a row context (select, with_columns, filter, sort keys) a column expression yields one value
//     per row, while aggregations and literals yield a scalar that broadcasts;
//   - in a group context (group_by(...).agg(...), and `.over(keys)` windows) every aggregation is
//     computed per group.
// A LazyFrame is an immutable query plan. collect() optimizes it -- predicate pushdown (filters move
// below sorts, with_columns, group keys, joins, and into the scan, where Parquet row-group statistics
// skip whole row groups), projection pushdown (scans read only the columns the query uses, and unused
// with_columns expressions are dropped), and limit pushdown (a head() over a scan stops reading row
// groups early) -- and then runs it with the eager operations. explain() shows the optimized plan.

#include <optional>
#include <set>
#include <stdexcept>
#include <string_view>

#ifdef _WIN32
#include <windows.h>
#endif

namespace csec_df {

// ---- Expression trees --------------------------------------------------------------------------

enum class EK { Col, Lit, Binary, Unary, Agg, Alias, Cast, FillNull, Str, When, Over, Len, Round };

struct Expr;
using ExprPtr = std::shared_ptr<Expr>;

struct Expr {
    EK kind = EK::Lit;
    std::string op;  // Col: name; Alias: name; Binary/Unary/Agg/Str: operator or function; Cast: type
    Column literal;  // Lit: one cell
    std::vector<ExprPtr> args;
    std::vector<std::string> keys;  // Over: partition columns
    std::string text;               // Str: first argument
    std::string text2;              // Str: second argument (replace)
    long long n = 0;                // Round: decimals
};

struct ExprList {
    std::vector<ExprPtr> items;
};

csec_threads::HandleTable<Expr>& exprTable() { return csec_threads::leakedTable<Expr>(); }
csec_threads::HandleTable<ExprList>& exprLists() { return csec_threads::leakedTable<ExprList>(); }

struct EvalError : std::runtime_error {
    using std::runtime_error::runtime_error;
};

ExprPtr exprOf(long long handle) {
    auto e = exprTable().get(handle);
    if (!e) throw EvalError("unknown expression handle");
    return e;
}

long long storeExpr(Expr&& e) { return exprTable().add(std::make_shared<Expr>(std::move(e))); }

ExprPtr makeExpr(EK kind, std::string op, std::vector<ExprPtr> args = {}) {
    auto e = std::make_shared<Expr>();
    e->kind = kind;
    e->op = std::move(op);
    e->args = std::move(args);
    return e;
}

const char* dtypeName(ColType type) {
    switch (type) {
    case ColType::Long: return "i64";
    case ColType::Double: return "f64";
    case ColType::Bool: return "bool";
    default: return "str";
    }
}

bool parseDtype(const std::string& name, ColType& type) {
    std::string t;
    for (char c : name) t.push_back(static_cast<char>(std::tolower(static_cast<unsigned char>(c))));
    if (t == "i64" || t == "int64" || t == "long" || t == "i32" || t == "int32" || t == "int") type = ColType::Long;
    else if (t == "f64" || t == "float64" || t == "double" || t == "f32" || t == "float32" || t == "float") type = ColType::Double;
    else if (t == "str" || t == "string" || t == "utf8") type = ColType::String;
    else if (t == "bool" || t == "boolean") type = ColType::Bool;
    else return false;
    return true;
}

std::string quote(const std::string& text) {
    std::string out = "\"";
    for (char c : text) {
        if (c == '"' || c == '\\') out.push_back('\\');
        out.push_back(c);
    }
    return out + "\"";
}

std::string formatFloat(double value) {
    std::string text = formatDouble(value);
    if (std::isfinite(value) && text.find_first_of(".eEn") == std::string::npos) text += ".0";
    return text;
}

std::string exprToString(const Expr& e) {
    auto arg = [&](size_t i) { return i < e.args.size() && e.args[i] ? exprToString(*e.args[i]) : std::string("?"); };
    switch (e.kind) {
    case EK::Col: return e.op == "*" ? "all()" : "col(" + quote(e.op) + ")";
    case EK::Lit:
        if (e.literal.isNull(0)) return "null";
        if (e.literal.type == ColType::String) return quote(e.literal.strings[0]);
        if (e.literal.type == ColType::Double) return formatFloat(e.literal.doubles[0]);
        return cellText(e.literal, 0, "null");
    case EK::Binary: return "(" + arg(0) + " " + e.op + " " + arg(1) + ")";
    case EK::Unary: return e.op == "neg" ? "-(" + arg(0) + ")" : arg(0) + "." + e.op + "()";
    case EK::Agg: return arg(0) + "." + e.op + "()";
    case EK::Alias: return arg(0) + ".alias(" + quote(e.op) + ")";
    case EK::Cast: return arg(0) + ".cast(" + e.op + ")";
    case EK::FillNull: return arg(0) + ".fill_null(" + arg(1) + ")";
    case EK::Round: return arg(0) + ".round(" + std::to_string(e.n) + ")";
    case EK::Str: {
        std::string s = arg(0) + ".str." + e.op + "(";
        if (e.op == "replace" || e.op == "replace_all") s += quote(e.text) + ", " + quote(e.text2);
        else if (e.op != "len_chars" && e.op != "len_bytes" && e.op != "to_uppercase" && e.op != "to_lowercase" &&
                 e.op != "strip_chars") s += quote(e.text);
        return s + ")";
    }
    case EK::When: return "when(" + arg(0) + ").then(" + arg(1) + ").otherwise(" + arg(2) + ")";
    case EK::Over: {
        std::string s = arg(0) + ".over([";
        for (size_t k = 0; k < e.keys.size(); ++k) s += (k ? ", " : "") + std::string("col(") + quote(e.keys[k]) + ")";
        return s + "])";
    }
    case EK::Len: return "len()";
    }
    return "?";
}

// Name of the column an expression produces (Polars rules: the leftmost input column, or the alias).
std::string outputName(const Expr& e) {
    switch (e.kind) {
    case EK::Alias:
    case EK::Col: return e.op;
    case EK::Lit: return "literal";
    case EK::Len: return "len";
    case EK::When: return e.args.size() > 1 && e.args[1] ? outputName(*e.args[1]) : "literal";
    default: return !e.args.empty() && e.args[0] ? outputName(*e.args[0]) : "literal";
    }
}

void collectRefs(const Expr& e, std::set<std::string>& refs, bool& wildcard) {
    if (e.kind == EK::Col) {
        if (e.op == "*") wildcard = true;
        else refs.insert(e.op);
    }
    for (const auto& k : e.keys) refs.insert(k);
    for (const auto& a : e.args) {
        if (a) collectRefs(*a, refs, wildcard);
    }
}

bool containsKind(const Expr& e, EK kind) {
    if (e.kind == kind) return true;
    for (const auto& a : e.args) {
        if (a && containsKind(*a, kind)) return true;
    }
    return false;
}

bool hasAggregation(const Expr& e) {
    return containsKind(e, EK::Agg) || containsKind(e, EK::Len) || containsKind(e, EK::Over);
}

ExprPtr replaceWildcard(const ExprPtr& e, const std::string& name) {
    if (e->kind == EK::Col && e->op == "*") return makeExpr(EK::Col, name);
    bool changed = false;
    std::vector<ExprPtr> args;
    for (const auto& a : e->args) {
        args.push_back(a ? replaceWildcard(a, name) : a);
        changed = changed || args.back() != a;
    }
    if (!changed) return e;
    auto copy = std::make_shared<Expr>(*e);
    copy->args = std::move(args);
    return copy;
}

// Expand `col("*")` (all()) to one expression per column, skipping `exclude` (group keys).
std::vector<ExprPtr> expandWildcards(const std::vector<ExprPtr>& exprs, const std::vector<std::string>& columns,
                                     const std::set<std::string>& exclude = {}) {
    std::vector<ExprPtr> out;
    for (const auto& e : exprs) {
        std::set<std::string> refs;
        bool wildcard = false;
        collectRefs(*e, refs, wildcard);
        if (!wildcard) {
            out.push_back(e);
            continue;
        }
        for (const auto& name : columns) {
            if (!exclude.count(name)) out.push_back(replaceWildcard(e, name));
        }
    }
    return out;
}

std::vector<std::string> columnNames(const DataFrame& df) {
    std::vector<std::string> names;
    for (const auto& c : df.columns) names.push_back(c.name);
    return names;
}

// ---- Evaluation --------------------------------------------------------------------------------

// A column (owned, or borrowed from the frame being evaluated), or a scalar that broadcasts.
struct Val {
    std::shared_ptr<const Column> col;
    bool scalar = false;
    const Column& c() const { return *col; }
    size_t at(size_t row) const { return scalar ? 0 : row; }
};

Val borrow(const Column& c) { return Val{std::shared_ptr<const Column>(&c, [](const Column*) {}), false}; }
Val own(Column&& c, bool scalar) { return Val{std::make_shared<const Column>(std::move(c)), scalar}; }

size_t resultLength(const Val& a, const Val& b, size_t rows) { return (a.scalar && b.scalar) ? 1 : rows; }

bool isCmp(const std::string& op) { return op == "==" || op == "!=" || op == "<" || op == "<=" || op == ">" || op == ">="; }

Val evalBinary(const std::string& op, const Val& a, const Val& b, size_t rows) {
    const Column& x = a.c();
    const Column& y = b.c();
    const size_t n = resultLength(a, b, rows);
    const bool scalar = a.scalar && b.scalar;
    if (op == "and" || op == "or") {
        auto boolish = [](const Column& c) { return c.type == ColType::Bool || (c.size() == 1 && c.isNull(0)); };
        if (!boolish(x) || !boolish(y)) throw EvalError("'" + op + "' needs boolean operands");
        Column out("", ColType::Bool);
        out.reserve(n);
        for (size_t r = 0; r < n; ++r) {
            const size_t i = a.at(r), j = b.at(r);
            const bool xn = x.isNull(i), yn = y.isNull(j);
            const bool xv = !xn && x.longs[i] != 0, yv = !yn && y.longs[j] != 0;
            // Kleene logic: false and null = false, true or null = true.
            if (op == "and") {
                if ((!xn && !xv) || (!yn && !yv)) out.pushBool(false);
                else if (xn || yn) out.pushNull();
                else out.pushBool(true);
            } else {
                if (xv || yv) out.pushBool(true);
                else if (xn || yn) out.pushNull();
                else out.pushBool(false);
            }
        }
        return own(std::move(out), scalar);
    }
    const bool xNullLit = x.size() == 1 && x.isNull(0) && a.scalar;
    const bool yNullLit = y.size() == 1 && y.isNull(0) && b.scalar;
    if (isCmp(op)) {
        const bool strings = x.type == ColType::String || y.type == ColType::String;
        if (strings && !(x.type == y.type || xNullLit || yNullLit)) {
            throw EvalError(std::string("cannot compare ") + dtypeName(x.type) + " with " + dtypeName(y.type));
        }
        const auto cmp = parseCmp(op.c_str());
        const bool longs = x.usesLongs() && y.usesLongs();
        Column out("", ColType::Bool);
        out.reserve(n);
        for (size_t r = 0; r < n; ++r) {
            const size_t i = a.at(r), j = b.at(r);
            if (x.isNull(i) || y.isNull(j)) {
                out.pushNull();
            } else if (strings) {
                out.pushBool(compareOrdered(x.strings[i], y.strings[j], cmp));
            } else if (longs) {
                out.pushBool(compareOrdered(x.longs[i], y.longs[j], cmp));
            } else {
                out.pushBool(compareOrdered(x.number(i), y.number(j), cmp));
            }
        }
        return own(std::move(out), scalar);
    }
    if (op == "+" && (x.type == ColType::String || y.type == ColType::String)) {
        if (!((x.type == ColType::String || xNullLit) && (y.type == ColType::String || yNullLit))) {
            throw EvalError(std::string("cannot add ") + dtypeName(x.type) + " and " + dtypeName(y.type));
        }
        Column out("", ColType::String);
        out.reserve(n);
        for (size_t r = 0; r < n; ++r) {
            const size_t i = a.at(r), j = b.at(r);
            if (x.isNull(i) || y.isNull(j)) out.pushNull();
            else out.pushString(x.strings[i] + y.strings[j]);
        }
        return own(std::move(out), scalar);
    }
    if (op != "+" && op != "-" && op != "*" && op != "/" && op != "%") throw EvalError("unknown operator '" + op + "'");
    if ((!x.numeric() && !xNullLit) || (!y.numeric() && !yNullLit)) {
        throw EvalError(std::string("arithmetic '") + op + "' on " + dtypeName(x.type) + " and " + dtypeName(y.type));
    }
    const bool integral = op != "/" && (x.usesLongs() || xNullLit) && (y.usesLongs() || yNullLit);
    Column out("", integral ? ColType::Long : ColType::Double);
    out.reserve(n);
    for (size_t r = 0; r < n; ++r) {
        const size_t i = a.at(r), j = b.at(r);
        if (x.isNull(i) || y.isNull(j)) {
            out.pushNull();
        } else if (integral) {
            const long long p = x.longs[i], q = y.longs[j];
            if (op == "%") {
                if (q == 0) out.pushNull();
                else out.pushLong(((p % q) + q) % q);  // Python/Polars modulo takes the divisor's sign
            } else {
                out.pushLong(op == "+" ? p + q : op == "-" ? p - q : p * q);
            }
        } else {
            const double p = x.number(i), q = y.number(j);
            if (op == "%") out.pushDouble(q == 0.0 ? std::numeric_limits<double>::quiet_NaN() : p - std::floor(p / q) * q);
            else out.pushDouble(op == "+" ? p + q : op == "-" ? p - q : op == "*" ? p * q : p / q);
        }
    }
    return own(std::move(out), scalar);
}

Val evalUnary(const std::string& op, const Val& a) {
    const Column& x = a.c();
    const size_t n = x.size();
    if (op == "is_null" || op == "is_not_null") {
        Column out("", ColType::Bool);
        out.reserve(n);
        for (size_t r = 0; r < n; ++r) out.pushBool(x.isNull(r) == (op == "is_null"));
        return own(std::move(out), a.scalar);
    }
    if (op == "not") {
        if (x.type != ColType::Bool) throw EvalError("not() needs a boolean expression");
        Column out("", ColType::Bool);
        for (size_t r = 0; r < n; ++r) {
            if (x.isNull(r)) out.pushNull();
            else out.pushBool(x.longs[r] == 0);
        }
        return own(std::move(out), a.scalar);
    }
    if (!x.numeric()) throw EvalError(op + "() needs a numeric expression, not " + dtypeName(x.type));
    const bool keepsLong = x.usesLongs() && (op == "neg" || op == "abs" || op == "floor" || op == "ceil");
    Column out("", keepsLong ? ColType::Long : ColType::Double);
    out.reserve(n);
    for (size_t r = 0; r < n; ++r) {
        if (x.isNull(r)) {
            out.pushNull();
            continue;
        }
        if (keepsLong) {
            const long long v = x.longs[r];
            out.pushLong(op == "neg" ? -v : op == "abs" ? (v < 0 ? -v : v) : v);
            continue;
        }
        const double v = x.number(r);
        double result;
        if (op == "neg") result = -v;
        else if (op == "abs") result = std::fabs(v);
        else if (op == "sqrt") result = std::sqrt(v);
        else if (op == "exp") result = std::exp(v);
        else if (op == "log") result = std::log(v);
        else if (op == "floor") result = std::floor(v);
        else if (op == "ceil") result = std::ceil(v);
        else throw EvalError("unknown function " + op + "()");
        out.pushDouble(result);
    }
    return own(std::move(out), a.scalar);
}

Val evalCast(const Val& a, ColType to) {
    const Column& x = a.c();
    Column out("", to);
    out.reserve(x.size());
    for (size_t r = 0; r < x.size(); ++r) {
        if (x.isNull(r)) {
            out.pushNull();
            continue;
        }
        switch (to) {
        case ColType::Long:
            if (x.usesLongs()) out.pushLong(x.longs[r]);
            else if (x.type == ColType::Double) {
                if (std::isfinite(x.doubles[r])) out.pushLong(static_cast<long long>(x.doubles[r]));
                else out.pushNull();
            } else {
                long long v;
                if (parseLongStrict(trim(x.strings[r]), v)) out.pushLong(v);
                else out.pushNull();
            }
            break;
        case ColType::Double:
            if (x.numeric()) out.pushDouble(x.number(r));
            else {
                double v;
                if (parseDoubleStrict(trim(x.strings[r]), v)) out.pushDouble(v);
                else out.pushNull();
            }
            break;
        case ColType::Bool:
            if (x.numeric()) out.pushBool(x.number(r) != 0.0);
            else {
                bool v;
                if (parseBoolStrict(trim(x.strings[r]), v)) out.pushBool(v);
                else out.pushNull();
            }
            break;
        case ColType::String:
            out.pushString(x.type == ColType::Double ? formatFloat(x.doubles[r]) : cellText(x, r, ""));
            break;
        }
    }
    return own(std::move(out), a.scalar);
}

// Common type of two value columns for fill_null / when-then-otherwise.
ColType unifyTypes(const Column& a, const Column& b, bool aNullLit, bool bNullLit) {
    if (aNullLit) return b.type;
    if (bNullLit || a.type == b.type) return a.type;
    if (a.numeric() && b.numeric()) return (a.usesLongs() && b.usesLongs()) ? ColType::Long : ColType::Double;
    throw EvalError(std::string("cannot combine ") + dtypeName(a.type) + " and " + dtypeName(b.type));
}

void pushConverted(Column& out, const Column& src, size_t row) {
    if (src.isNull(row)) {
        out.pushNull();
    } else if (out.type == src.type || (out.usesLongs() && src.usesLongs())) {
        if (out.usesLongs()) out.pushLong(src.longs[row]);
        else if (out.type == ColType::Double) out.pushDouble(src.doubles[row]);
        else out.pushString(src.strings[row]);
    } else if (out.type == ColType::Double) {
        out.pushDouble(src.number(row));
    } else {
        out.pushString(cellText(src, row, ""));
    }
}

bool isNullLiteral(const Val& v) { return v.scalar && v.c().size() == 1 && v.c().isNull(0); }

Val evalChoose(const Val& cond, const Val& yes, const Val& no, size_t rows) {
    const Column& c = cond.c();
    if (c.type != ColType::Bool && !isNullLiteral(cond)) throw EvalError("when() needs a boolean condition");
    const ColType type = unifyTypes(yes.c(), no.c(), isNullLiteral(yes), isNullLiteral(no));
    const bool scalar = cond.scalar && yes.scalar && no.scalar;
    const size_t n = scalar ? 1 : rows;
    Column out("", type);
    out.reserve(n);
    for (size_t r = 0; r < n; ++r) {
        const size_t i = cond.at(r);
        const bool take = !c.isNull(i) && c.longs[i] != 0;
        if (take) pushConverted(out, yes.c(), yes.at(r));
        else pushConverted(out, no.c(), no.at(r));
    }
    return own(std::move(out), scalar);
}

Val evalFillNull(const Val& a, const Val& b, size_t rows) {
    const ColType type = unifyTypes(a.c(), b.c(), isNullLiteral(a), isNullLiteral(b));
    const bool scalar = a.scalar && b.scalar;
    const size_t n = scalar ? 1 : rows;
    Column out("", type);
    out.reserve(n);
    for (size_t r = 0; r < n; ++r) {
        if (!a.c().isNull(a.at(r))) pushConverted(out, a.c(), a.at(r));
        else pushConverted(out, b.c(), b.at(r));
    }
    return own(std::move(out), scalar);
}

size_t utf8Length(const std::string& s) {
    size_t n = 0;
    for (unsigned char c : s) n += (c & 0xC0) != 0x80 ? 1 : 0;
    return n;
}

Val evalStr(const Expr& e, const Val& a) {
    const Column& x = a.c();
    if (x.type != ColType::String && !isNullLiteral(a)) throw EvalError(".str." + e.op + "() needs a string expression");
    const std::string& op = e.op;
    const bool boolean = op == "contains" || op == "starts_with" || op == "ends_with";
    const bool length = op == "len_chars" || op == "len_bytes";
    Column out("", boolean ? ColType::Bool : length ? ColType::Long : ColType::String);
    out.reserve(x.size());
    for (size_t r = 0; r < x.size(); ++r) {
        if (x.isNull(r)) {
            out.pushNull();
            continue;
        }
        const std::string& s = x.strings[r];
        if (op == "contains") out.pushBool(s.find(e.text) != std::string::npos);
        else if (op == "starts_with") out.pushBool(s.compare(0, e.text.size(), e.text) == 0);
        else if (op == "ends_with") out.pushBool(s.size() >= e.text.size() && s.compare(s.size() - e.text.size(), e.text.size(), e.text) == 0);
        else if (op == "len_chars") out.pushLong(static_cast<long long>(utf8Length(s)));
        else if (op == "len_bytes") out.pushLong(static_cast<long long>(s.size()));
        else if (op == "to_uppercase" || op == "to_lowercase") {
            std::string t = s;
            for (char& c : t) c = static_cast<char>(op == "to_uppercase" ? std::toupper(static_cast<unsigned char>(c)) : std::tolower(static_cast<unsigned char>(c)));
            out.pushString(std::move(t));
        } else if (op == "strip_chars") out.pushString(trim(s));
        else if (op == "replace" || op == "replace_all") {
            std::string t = s;
            if (!e.text.empty()) {
                size_t pos = 0;
                while ((pos = t.find(e.text, pos)) != std::string::npos) {
                    t.replace(pos, e.text.size(), e.text2);
                    pos += e.text2.size();
                    if (op == "replace") break;
                }
            }
            out.pushString(std::move(t));
        } else {
            throw EvalError("unknown string function ." + op + "()");
        }
    }
    return own(std::move(out), a.scalar);
}

Val evalRound(const Val& a, long long decimals) {
    const Column& x = a.c();
    if (!x.numeric()) throw EvalError("round() needs a numeric expression");
    if (x.usesLongs()) return a;
    Column out("", ColType::Double);
    const double scale = std::pow(10.0, static_cast<double>(decimals));
    for (size_t r = 0; r < x.size(); ++r) {
        if (x.isNull(r)) out.pushNull();
        else out.pushDouble(std::round(x.doubles[r] * scale) / scale);
    }
    return own(std::move(out), a.scalar);
}

Val materialize(const Val& v, size_t rows) {
    if (!v.scalar) return v;
    Column out("", v.c().type);
    out.reserve(rows);
    for (size_t r = 0; r < rows; ++r) out.appendFrom(v.c(), 0);
    return own(std::move(out), false);
}

using Groups = std::vector<std::vector<size_t>>;

Val evalRow(const Expr& e, const DataFrame& df);

// Group rows by the values of `keys` (first-appearance order); `groupOf[row]` is the group index.
Groups groupRows(const std::vector<Val>& keys, size_t rows, std::vector<size_t>* groupOf = nullptr) {
    Groups groups;
    // Fast paths for one integer or string key: hash the value itself, not a serialized key.
    if (keys.size() == 1 && !keys[0].scalar && keys[0].c().type != ColType::Double) {
        const Column& k = keys[0].c();
        if (groupOf) groupOf->assign(rows, 0);
        size_t nullGroup = SIZE_MAX;
        auto place = [&](size_t g, size_t r) {
            groups[g].push_back(r);
            if (groupOf) (*groupOf)[r] = g;
        };
        if (k.usesLongs()) {
            std::unordered_map<long long, size_t> index;
            index.reserve(1024);
            for (size_t r = 0; r < rows; ++r) {
                size_t g;
                if (k.isNull(r)) {
                    if (nullGroup == SIZE_MAX) {
                        nullGroup = groups.size();
                        groups.emplace_back();
                    }
                    g = nullGroup;
                } else {
                    auto it = index.find(k.longs[r]);
                    if (it == index.end()) {
                        it = index.emplace(k.longs[r], groups.size()).first;
                        groups.emplace_back();
                    }
                    g = it->second;
                }
                place(g, r);
            }
        } else {
            std::unordered_map<std::string_view, size_t> index;
            index.reserve(1024);
            for (size_t r = 0; r < rows; ++r) {
                size_t g;
                if (k.isNull(r)) {
                    if (nullGroup == SIZE_MAX) {
                        nullGroup = groups.size();
                        groups.emplace_back();
                    }
                    g = nullGroup;
                } else {
                    const std::string_view key(k.strings[r]);
                    auto it = index.find(key);
                    if (it == index.end()) {
                        it = index.emplace(key, groups.size()).first;
                        groups.emplace_back();
                    }
                    g = it->second;
                }
                place(g, r);
            }
        }
        return groups;
    }
    std::unordered_map<std::string, size_t> index;
    if (groupOf) groupOf->assign(rows, 0);
    std::string key;
    for (size_t r = 0; r < rows; ++r) {
        key.clear();
        for (const auto& k : keys) appendKey(key, k.c(), k.at(r), false);
        auto it = index.find(key);
        if (it == index.end()) {
            it = index.emplace(key, groups.size()).first;
            groups.emplace_back();
        }
        groups[it->second].push_back(r);
        if (groupOf) (*groupOf)[r] = it->second;
    }
    return groups;
}

// Evaluate `e` once per group; the result has one cell per group.
Val evalGroup(const Expr& e, const DataFrame& df, const Groups& groups) {
    const size_t rows = df.rows();
    const size_t n = groups.size();
    switch (e.kind) {
    case EK::Lit: return own(Column(e.literal), true);
    case EK::Len: {
        Column out("", ColType::Long);
        for (const auto& g : groups) out.pushLong(static_cast<long long>(g.size()));
        return own(std::move(out), false);
    }
    case EK::Col:
        throw EvalError("column '" + e.op + "' must be aggregated inside agg(), e.g. col(\"" + e.op + "\").first()");
    case EK::Agg: {
        if (hasAggregation(*e.args[0])) throw EvalError("nested aggregation in " + exprToString(e));
        const Val inner = materialize(evalRow(*e.args[0], df), rows);
        const Agg agg = parseAgg(e.op);
        if (agg == Agg::Invalid) throw EvalError("unknown aggregation " + e.op + "()");
        if (!inner.c().numeric() && (agg == Agg::Sum || agg == Agg::Mean || agg == Agg::Std || agg == Agg::Var || agg == Agg::Median)) {
            throw EvalError("cannot take the " + e.op + " of a str column");
        }
        Column out("", aggType(agg, &inner.c()));
        if (agg == Agg::First || agg == Agg::Last) {
            // Polars: the first/last value of the group, even when it is null.
            for (const auto& g : groups) {
                if (g.empty()) out.pushNull();
                else out.appendFrom(inner.c(), agg == Agg::First ? g.front() : g.back());
            }
            return own(std::move(out), false);
        }
        if (agg == Agg::NUnique) {
            // Polars counts null as one more distinct value.
            for (const auto& g : groups) {
                std::unordered_set<std::string> seen;
                std::string key;
                for (size_t r : g) {
                    key.clear();
                    appendKey(key, inner.c(), r, false);
                    seen.insert(key);
                }
                out.pushLong(static_cast<long long>(seen.size()));
            }
            return own(std::move(out), false);
        }
        for (const auto& g : groups) aggregate(agg, &inner.c(), g, out);
        return own(std::move(out), false);
    }
    case EK::Alias: return evalGroup(*e.args[0], df, groups);
    case EK::Binary: return evalBinary(e.op, evalGroup(*e.args[0], df, groups), evalGroup(*e.args[1], df, groups), n);
    case EK::Unary: return evalUnary(e.op, evalGroup(*e.args[0], df, groups));
    case EK::Cast: {
        ColType t;
        parseDtype(e.op, t);
        return evalCast(evalGroup(*e.args[0], df, groups), t);
    }
    case EK::FillNull: return evalFillNull(evalGroup(*e.args[0], df, groups), evalGroup(*e.args[1], df, groups), n);
    case EK::Str: return evalStr(e, evalGroup(*e.args[0], df, groups));
    case EK::Round: return evalRound(evalGroup(*e.args[0], df, groups), e.n);
    case EK::When:
        return evalChoose(evalGroup(*e.args[0], df, groups), evalGroup(*e.args[1], df, groups), evalGroup(*e.args[2], df, groups), n);
    case EK::Over: throw EvalError("over() cannot be used inside agg()");
    }
    throw EvalError("cannot evaluate " + exprToString(e));
}

Val evalRow(const Expr& e, const DataFrame& df) {
    const size_t rows = df.rows();
    switch (e.kind) {
    case EK::Col: {
        const int index = df.find(e.op);
        if (index < 0) throw EvalError("column '" + e.op + "' not found");
        return borrow(df.columns[index]);
    }
    case EK::Lit: return own(Column(e.literal), true);
    case EK::Len: {
        Column out("", ColType::Long);
        out.pushLong(static_cast<long long>(rows));
        return own(std::move(out), true);
    }
    case EK::Agg: {
        Groups all(1);
        all[0].reserve(rows);
        for (size_t r = 0; r < rows; ++r) all[0].push_back(r);
        Val v = evalGroup(e, df, all);
        v.scalar = true;
        return v;
    }
    case EK::Alias: return evalRow(*e.args[0], df);
    case EK::Binary: return evalBinary(e.op, evalRow(*e.args[0], df), evalRow(*e.args[1], df), rows);
    case EK::Unary: return evalUnary(e.op, evalRow(*e.args[0], df));
    case EK::Cast: {
        ColType t;
        if (!parseDtype(e.op, t)) throw EvalError("unknown dtype '" + e.op + "'");
        return evalCast(evalRow(*e.args[0], df), t);
    }
    case EK::FillNull: return evalFillNull(evalRow(*e.args[0], df), evalRow(*e.args[1], df), rows);
    case EK::Str: return evalStr(e, evalRow(*e.args[0], df));
    case EK::Round: return evalRound(evalRow(*e.args[0], df), e.n);
    case EK::When: return evalChoose(evalRow(*e.args[0], df), evalRow(*e.args[1], df), evalRow(*e.args[2], df), rows);
    case EK::Over: {
        std::vector<Val> keys;
        for (const auto& k : e.keys) {
            const int index = df.find(k);
            if (index < 0) throw EvalError("over(): column '" + k + "' not found");
            keys.push_back(borrow(df.columns[index]));
        }
        std::vector<size_t> groupOf;
        const Groups groups = groupRows(keys, rows, &groupOf);
        const Val perGroup = evalGroup(*e.args[0], df, groups);
        Column out("", perGroup.c().type);
        out.reserve(rows);
        for (size_t r = 0; r < rows; ++r) out.appendFrom(perGroup.c(), perGroup.at(groupOf[r]));
        return own(std::move(out), false);
    }
    }
    throw EvalError("cannot evaluate " + exprToString(e));
}

Column namedColumn(const Val& v, const std::string& name, size_t rows) {
    Val full = materialize(v, rows);
    Column c = full.c();
    c.name = name;
    return c;
}

// ---- Eager frame operations on expressions ------------------------------------------------------

void checkUnique(const std::vector<std::string>& names) {
    std::set<std::string> seen;
    for (const auto& n : names) {
        if (!seen.insert(n).second) throw EvalError("duplicate output column '" + n + "'; use alias() to rename one");
    }
}

DataFrame selectExprs(const DataFrame& df, const std::vector<ExprPtr>& exprs) {
    const auto expanded = expandWildcards(exprs, columnNames(df));
    std::vector<Val> values;
    std::vector<std::string> names;
    bool allScalar = true;
    for (const auto& e : expanded) {
        values.push_back(evalRow(*e, df));
        names.push_back(outputName(*e));
        allScalar = allScalar && values.back().scalar;
    }
    checkUnique(names);
    const size_t rows = allScalar ? (values.empty() ? 0 : 1) : df.rows();
    DataFrame out;
    for (size_t k = 0; k < values.size(); ++k) out.columns.push_back(namedColumn(values[k], names[k], rows));
    return out;
}

DataFrame withColumnsExprs(const DataFrame& df, const std::vector<ExprPtr>& exprs) {
    const auto expanded = expandWildcards(exprs, columnNames(df));
    std::vector<Val> values;
    std::vector<std::string> names;
    for (const auto& e : expanded) {
        values.push_back(evalRow(*e, df));
        names.push_back(outputName(*e));
    }
    checkUnique(names);
    const size_t rows = df.rows();
    DataFrame out = df;
    for (size_t k = 0; k < values.size(); ++k) {
        Column c = namedColumn(values[k], names[k], rows);
        const int existing = out.find(names[k]);
        if (existing >= 0) out.columns[existing] = std::move(c);
        else out.columns.push_back(std::move(c));
    }
    return out;
}

std::vector<size_t> maskRows(const Val& mask, size_t rows) {
    const Column& m = mask.c();
    if (m.type != ColType::Bool && !isNullLiteral(mask)) throw EvalError("filter() needs a boolean expression");
    std::vector<size_t> picked;
    for (size_t r = 0; r < rows; ++r) {
        const size_t i = mask.at(r);
        if (!m.isNull(i) && m.longs[i] != 0) picked.push_back(r);
    }
    return picked;
}

DataFrame filterExpr(const DataFrame& df, const Expr& predicate) {
    return take(df, maskRows(evalRow(predicate, df), df.rows()));
}

DataFrame groupByAgg(const DataFrame& df, const std::vector<ExprPtr>& keyExprs, const std::vector<ExprPtr>& aggExprs) {
    const auto keysExpanded = expandWildcards(keyExprs, columnNames(df));
    std::vector<Val> keys;
    std::vector<std::string> keyNames;
    for (const auto& k : keysExpanded) {
        if (hasAggregation(*k)) throw EvalError("group_by key " + exprToString(*k) + " cannot aggregate");
        keys.push_back(materialize(evalRow(*k, df), df.rows()));
        keyNames.push_back(outputName(*k));
    }
    const Groups groups = groupRows(keys, df.rows());
    const auto aggs = expandWildcards(aggExprs, columnNames(df), std::set<std::string>(keyNames.begin(), keyNames.end()));
    DataFrame out;
    std::vector<std::string> names = keyNames;
    for (size_t k = 0; k < keys.size(); ++k) {
        Column c = keys[k].c().emptyLike();
        c.name = keyNames[k];
        for (const auto& g : groups) c.appendFrom(keys[k].c(), g.front());
        out.columns.push_back(std::move(c));
    }
    for (const auto& a : aggs) {
        const Val v = evalGroup(*a, df, groups);
        names.push_back(outputName(*a));
        out.columns.push_back(namedColumn(v, names.back(), groups.size()));
    }
    checkUnique(names);
    return out;
}

DataFrame sortExprs(const DataFrame& df, const std::vector<ExprPtr>& keyExprs, unsigned long long descendingMask, bool nullsLast) {
    const size_t rows = df.rows();
    const auto expanded = expandWildcards(keyExprs, columnNames(df));
    std::vector<Val> keys;
    for (const auto& k : expanded) keys.push_back(materialize(evalRow(*k, df), rows));
    if (keys.empty()) throw EvalError("sort() needs at least one key");
    std::vector<size_t> order(rows);
    for (size_t r = 0; r < rows; ++r) order[r] = r;
    std::stable_sort(order.begin(), order.end(), [&](size_t a, size_t b) {
        for (size_t k = 0; k < keys.size(); ++k) {
            const Column& c = keys[k].c();
            const bool descending = k < 64 && ((descendingMask >> k) & 1);
            const bool na = c.isNull(a), nb = c.isNull(b);
            if (na || nb) {
                if (na == nb) continue;
                return nullsLast ? nb : na;
            }
            const int cmp = compareCells(c, a, b);
            if (cmp != 0) return descending ? cmp > 0 : cmp < 0;
        }
        return false;
    });
    return take(df, order);
}

// Distinct rows (by `subset`, or all columns), keeping the first occurrence and the row order.
DataFrame uniqueRows(const DataFrame& df, const std::vector<std::string>& subset) {
    std::vector<const Column*> keys;
    if (subset.empty()) {
        for (const auto& c : df.columns) keys.push_back(&c);
    } else {
        for (const auto& name : subset) {
            const int index = df.find(name);
            if (index < 0) throw EvalError("column '" + name + "' not found");
            keys.push_back(&df.columns[index]);
        }
    }
    std::unordered_set<std::string> seen;
    std::vector<size_t> picked;
    std::string key;
    const size_t rows = df.rows();
    for (size_t r = 0; r < rows; ++r) {
        key.clear();
        for (const Column* c : keys) appendKey(key, *c, r, false);
        if (seen.insert(key).second) picked.push_back(r);
    }
    return take(df, picked);
}

DataFrame sliceRows(const DataFrame& df, long long offset, long long length) {
    const long long rows = static_cast<long long>(df.rows());
    if (offset < 0) offset = std::max(0LL, rows + offset);
    offset = std::min(offset, rows);
    const long long end = length < 0 ? rows : std::min(rows, offset + length);
    std::vector<size_t> picked;
    for (long long r = offset; r < end; ++r) picked.push_back(static_cast<size_t>(r));
    return take(df, picked);
}

DataFrame withRowIndex(const DataFrame& df, const std::string& name, long long offset) {
    if (df.find(name) >= 0) throw EvalError("column '" + name + "' already exists");
    DataFrame out;
    Column index(name, ColType::Long);
    const size_t rows = df.rows();
    for (size_t r = 0; r < rows; ++r) index.pushLong(offset + static_cast<long long>(r));
    out.columns.push_back(std::move(index));
    for (const auto& c : df.columns) out.columns.push_back(c);
    return out;
}

DataFrame renameColumns(const DataFrame& df, const std::vector<std::pair<std::string, std::string>>& renames) {
    DataFrame out = df;
    for (const auto& r : renames) {
        const int index = out.find(r.first);
        if (index < 0) throw EvalError("column '" + r.first + "' not found");
        out.columns[index].name = r.second;
    }
    std::vector<std::string> names = columnNames(out);
    checkUnique(names);
    return out;
}

DataFrame dropColumns(const DataFrame& df, const std::vector<std::string>& names) {
    DataFrame out;
    for (const auto& c : df.columns) {
        if (std::find(names.begin(), names.end(), c.name) == names.end()) out.columns.push_back(c);
    }
    return out;
}

DataFrame projectColumns(const DataFrame& df, const std::vector<std::string>& names) {
    DataFrame out;
    for (const auto& name : names) {
        const int index = df.find(name);
        if (index < 0) throw EvalError("column '" + name + "' not found");
        out.columns.push_back(df.columns[index]);
    }
    return out;
}

// Join keys "a" / "a,b" / "a=x,b=y" -> (left, right) column names.
std::vector<std::pair<std::string, std::string>> parseJoinKeys(const std::string& on) {
    std::vector<std::pair<std::string, std::string>> keys;
    for (const auto& item : splitList(on.c_str())) {
        const auto eq = item.find('=');
        if (eq == std::string::npos) keys.emplace_back(item, item);
        else keys.emplace_back(trim(item.substr(0, eq)), trim(item.substr(eq + 1)));
    }
    return keys;
}

// Inner / left / full / semi / anti / cross join. Right-hand key columns are dropped (except in a
// full join, where they are kept with the suffix); other clashing right-hand names get `suffix`.
DataFrame joinFrames(const DataFrame& left, const DataFrame& right, const std::string& on, const std::string& how,
                     const std::string& suffix) {
    if (how != "inner" && how != "left" && how != "full" && how != "semi" && how != "anti" && how != "cross") {
        throw EvalError("unknown join '" + how + "' (inner, left, full, semi, anti, cross)");
    }
    const size_t leftRows = left.rows(), rightRows = right.rows();
    std::vector<long long> li, ri;  // matched row pairs (-1: no row on that side)
    std::vector<int> lk, rk;
    if (how == "cross") {
        for (size_t a = 0; a < leftRows; ++a) {
            for (size_t b = 0; b < rightRows; ++b) {
                li.push_back(static_cast<long long>(a));
                ri.push_back(static_cast<long long>(b));
            }
        }
    } else {
        const auto keys = parseJoinKeys(on);
        if (keys.empty()) throw EvalError("join() needs key columns");
        std::vector<bool> asDouble;
        for (const auto& k : keys) {
            const int a = left.find(k.first), b = right.find(k.second);
            if (a < 0) throw EvalError("join key '" + k.first + "' not found in the left frame");
            if (b < 0) throw EvalError("join key '" + k.second + "' not found in the right frame");
            const Column& x = left.columns[a];
            const Column& y = right.columns[b];
            if (x.numeric() != y.numeric()) {
                throw EvalError(std::string("join keys '") + k.first + "' (" + dtypeName(x.type) + ") and '" + k.second + "' (" +
                                dtypeName(y.type) + ") have different types");
            }
            lk.push_back(a);
            rk.push_back(b);
            asDouble.push_back(x.numeric() && !(x.usesLongs() && y.usesLongs()));
        }
        auto keyOf = [&](const DataFrame& df, const std::vector<int>& cols, size_t row, std::string& key) {
            key.clear();
            for (size_t k = 0; k < cols.size(); ++k) {
                const Column& c = df.columns[cols[k]];
                if (c.isNull(row)) return false;  // null keys never match
                appendKey(key, c, row, asDouble[k]);
            }
            return true;
        };
        std::unordered_map<std::string, std::vector<size_t>> index;
        std::string key;
        for (size_t b = 0; b < rightRows; ++b) {
            if (keyOf(right, rk, b, key)) index[key].push_back(b);
        }
        std::vector<bool> rightUsed(rightRows, false);
        for (size_t a = 0; a < leftRows; ++a) {
            const std::vector<size_t>* matches = nullptr;
            if (keyOf(left, lk, a, key)) {
                auto it = index.find(key);
                if (it != index.end()) matches = &it->second;
            }
            if (how == "semi" || how == "anti") {
                if ((matches != nullptr) == (how == "semi")) {
                    li.push_back(static_cast<long long>(a));
                    ri.push_back(-1);
                }
                continue;
            }
            if (matches) {
                for (size_t b : *matches) {
                    li.push_back(static_cast<long long>(a));
                    ri.push_back(static_cast<long long>(b));
                    rightUsed[b] = true;
                }
            } else if (how == "left" || how == "full") {
                li.push_back(static_cast<long long>(a));
                ri.push_back(-1);
            }
        }
        if (how == "full") {
            for (size_t b = 0; b < rightRows; ++b) {
                if (!rightUsed[b]) {
                    li.push_back(-1);
                    ri.push_back(static_cast<long long>(b));
                }
            }
        }
    }
    auto gather = [](const Column& source, const std::vector<long long>& rows) {
        Column c = source.emptyLike();
        c.reserve(rows.size());
        for (long long r : rows) {
            if (r < 0) c.pushNull();
            else c.appendFrom(source, static_cast<size_t>(r));
        }
        return c;
    };
    DataFrame out;
    for (const auto& c : left.columns) out.columns.push_back(gather(c, li));
    if (how == "semi" || how == "anti") return out;
    for (size_t k = 0; k < right.columns.size(); ++k) {
        const bool isKey = std::find(rk.begin(), rk.end(), static_cast<int>(k)) != rk.end();
        if (isKey && how != "full") continue;
        Column c = gather(right.columns[k], ri);
        if (out.find(c.name) >= 0) c.name += suffix;
        out.columns.push_back(std::move(c));
    }
    checkUnique(columnNames(out));
    return out;
}

DataFrame nullCounts(const DataFrame& df) {
    DataFrame out;
    for (const auto& c : df.columns) {
        Column n(c.name, ColType::Long);
        long long count = 0;
        for (unsigned char v : c.valid) count += v ? 0 : 1;
        n.pushLong(count);
        out.columns.push_back(std::move(n));
    }
    return out;
}

// Summary statistics per column, like Polars' DataFrame.describe().
DataFrame describeFrame(const DataFrame& df) {
    static const char* stats[] = {"count", "null_count", "mean", "std", "min", "25%", "50%", "75%", "max"};
    DataFrame out;
    Column label("statistic", ColType::String);
    for (const char* s : stats) label.pushString(s);
    out.columns.push_back(std::move(label));
    for (const auto& c : df.columns) {
        std::vector<size_t> present;
        for (size_t r = 0; r < c.size(); ++r) {
            if (!c.isNull(r)) present.push_back(r);
        }
        const long long nulls = static_cast<long long>(c.size() - present.size());
        if (c.numeric()) {
            Column col(c.name, ColType::Double);
            std::vector<double> values;
            for (size_t r : present) values.push_back(c.number(r));
            std::sort(values.begin(), values.end());
            auto quantile = [&](double q) {
                // Nearest-rank on the sorted values (Polars' default "nearest" interpolation).
                const size_t idx = static_cast<size_t>(std::llround(q * static_cast<double>(values.size() - 1)));
                return values[idx];
            };
            col.pushDouble(static_cast<double>(values.size()));
            col.pushDouble(static_cast<double>(nulls));
            Column cell("", ColType::Double);
            aggregate(Agg::Mean, &c, present, cell);
            aggregate(Agg::Std, &c, present, cell);
            for (size_t k = 0; k < 2; ++k) {
                if (cell.isNull(k)) col.pushNull();
                else col.pushDouble(cell.doubles[k]);
            }
            if (values.empty()) {
                for (int k = 0; k < 5; ++k) col.pushNull();
            } else {
                col.pushDouble(values.front());
                col.pushDouble(quantile(0.25));
                col.pushDouble(quantile(0.5));
                col.pushDouble(quantile(0.75));
                col.pushDouble(values.back());
            }
            out.columns.push_back(std::move(col));
        } else {
            Column col(c.name, ColType::String);
            col.pushString(std::to_string(present.size()));
            col.pushString(std::to_string(nulls));
            col.pushNull();
            col.pushNull();
            size_t lo = 0, hi = 0;
            for (size_t k = 0; k < present.size(); ++k) {
                if (c.strings[present[k]] < c.strings[present[lo]]) lo = k;
                if (c.strings[present[k]] > c.strings[present[hi]]) hi = k;
            }
            if (present.empty()) col.pushNull();
            else col.pushString(c.strings[present[lo]]);
            col.pushNull();
            col.pushNull();
            col.pushNull();
            if (present.empty()) col.pushNull();
            else col.pushString(c.strings[present[hi]]);
            out.columns.push_back(std::move(col));
        }
    }
    return out;
}

// ---- Polars-style display ------------------------------------------------------------------------

int tableFormat = 0;  // 0 auto, 1 UTF-8 box drawing, 2 ASCII

bool useUtf8Tables() {
    if (tableFormat != 0) return tableFormat == 1;
    if (const char* env = std::getenv("CSEC_TABLE_FORMAT")) {
        if (std::strcmp(env, "ascii") == 0) return false;
        if (std::strcmp(env, "utf8") == 0) return true;
    }
#ifdef _WIN32
    // A console that is not in UTF-8 mode would show box drawing as mojibake.
    return GetConsoleOutputCP() == CP_UTF8;
#else
    return true;
#endif
}

// Floats in tables show up to 6 significant digits, like Polars (CSV and getters keep full precision).
std::string displayFloat(double value) {
    if (!std::isfinite(value)) return formatFloat(value);
    char buffer[40];
    std::snprintf(buffer, sizeof buffer, "%.6g", value);
    std::string text = buffer;
    if (text.find_first_of(".en") == std::string::npos) text += ".0";
    return text;
}

std::string displayCell(const Column& c, size_t row) {
    if (c.isNull(row)) return "null";
    if (c.type == ColType::String) return quote(c.strings[row]);
    if (c.type == ColType::Double) return displayFloat(c.doubles[row]);
    return cellText(c, row, "null");
}

std::string formatTable(const DataFrame& df, long long maxRows) {
    const bool utf8 = useUtf8Tables();
    const size_t rows = df.rows();
    const size_t cols = df.columns.size();
    const size_t limit = maxRows < 0 ? rows : static_cast<size_t>(maxRows);
    std::vector<size_t> shown;
    bool elided = false;
    if (rows <= limit) {
        for (size_t r = 0; r < rows; ++r) shown.push_back(r);
    } else {
        const size_t head = (limit + 1) / 2;
        for (size_t r = 0; r < head; ++r) shown.push_back(r);
        for (size_t r = rows - (limit - head); r < rows; ++r) shown.push_back(r);
        elided = true;
    }
    const std::string ellipsis = utf8 ? "\xE2\x80\xA6" : "...";
    std::vector<std::vector<std::string>> body(shown.size(), std::vector<std::string>(cols));
    std::vector<size_t> width(cols, 0);
    for (size_t c = 0; c < cols; ++c) {
        const Column& column = df.columns[c];
        width[c] = std::max({utf8Length(column.name), size_t(3), utf8Length(dtypeName(column.type))});
        for (size_t k = 0; k < shown.size(); ++k) {
            body[k][c] = displayCell(column, shown[k]);
            width[c] = std::max(width[c], utf8Length(body[k][c]));
        }
        if (elided) width[c] = std::max(width[c], utf8Length(ellipsis));
    }
    const std::string V = utf8 ? "\xE2\x94\x82" : "|";
    const std::string S = utf8 ? "\xE2\x94\x86" : "|";
    auto repeat = [](const std::string& s, size_t n) {
        std::string out;
        for (size_t k = 0; k < n; ++k) out += s;
        return out;
    };
    auto rule = [&](const std::string& left, const std::string& fill, const std::string& mid, const std::string& right) {
        std::string line = left;
        for (size_t c = 0; c < cols; ++c) line += repeat(fill, width[c] + 2) + (c + 1 < cols ? mid : right);
        return line + "\n";
    };
    auto row = [&](const std::vector<std::string>& cells) {
        std::string line = V;
        for (size_t c = 0; c < cols; ++c) {
            line += " " + cells[c] + std::string(width[c] - utf8Length(cells[c]), ' ') + " " + (c + 1 < cols ? S : V);
        }
        return line + "\n";
    };
    std::string out = "shape: (" + std::to_string(rows) + ", " + std::to_string(cols) + ")\n";
    if (cols == 0) return out;
    if (utf8) out += rule("\xE2\x94\x8C", "\xE2\x94\x80", "\xE2\x94\xAC", "\xE2\x94\x90");
    else out += rule("+", "-", "+", "+");
    std::vector<std::string> names, dashes, types;
    for (const auto& c : df.columns) {
        names.push_back(c.name);
        dashes.push_back("---");
        types.push_back(dtypeName(c.type));
    }
    out += row(names) + row(dashes) + row(types);
    if (utf8) out += rule("\xE2\x95\x9E", "\xE2\x95\x90", "\xE2\x95\xAA", "\xE2\x95\xA1");
    else out += rule("+", "=", "+", "+");
    const size_t head = elided ? (limit + 1) / 2 : shown.size();
    for (size_t k = 0; k < shown.size(); ++k) {
        if (elided && k == head) out += row(std::vector<std::string>(cols, ellipsis));
        out += row(body[k]);
    }
    if (elided && shown.size() == head) out += row(std::vector<std::string>(cols, ellipsis));
    if (utf8) out += rule("\xE2\x94\x94", "\xE2\x94\x80", "\xE2\x94\xB4", "\xE2\x94\x98");
    else out += rule("+", "-", "+", "+");
    out.pop_back();
    return out;
}

std::string schemaString(const DataFrame& df) {
    std::string out = "Schema([";
    for (size_t c = 0; c < df.columns.size(); ++c) {
        out += (c ? ", " : "") + std::string("(") + quote(df.columns[c].name) + ", " + dtypeName(df.columns[c].type) + ")";
    }
    return out + "])";
}

// ---- Lazy query plans ----------------------------------------------------------------------------

enum class PK { ScanParquet, ScanCsv, Frame, Select, WithColumns, Filter, GroupBy, Sort, Join, Slice, Unique, Rename, Drop, RowIndex };

struct Plan;
using PlanPtr = std::shared_ptr<Plan>;

struct Plan {
    PK kind = PK::Frame;
    PlanPtr input;
    PlanPtr other;  // join right side
    std::string path;
    std::shared_ptr<DataFrame> frame;
    std::vector<ExprPtr> exprs;  // select / with_columns / agg / sort keys
    std::vector<ExprPtr> keys;   // group_by keys
    ExprPtr predicate;           // filter, or a scan's pushed-down predicate
    std::string on, how, suffix, name;
    std::vector<std::string> names;  // unique subset, drop list
    std::vector<std::pair<std::string, std::string>> renames;
    long long offset = 0;
    long long length = -1;
    unsigned long long descending = 0;
    bool nullsLast = false;
    // Set by the optimizer on scans.
    std::optional<std::vector<std::string>> projection;  // columns to read (nullopt: all)
    std::optional<std::vector<std::string>> output;      // columns to return after the predicate
    long long limit = -1;
};

csec_threads::HandleTable<Plan>& plans() { return csec_threads::leakedTable<Plan>(); }

PlanPtr planOf(long long handle) {
    auto p = plans().get(handle);
    if (!p) throw EvalError("unknown LazyFrame handle");
    return p;
}

long long storePlan(Plan&& p) { return plans().add(std::make_shared<Plan>(std::move(p))); }

PlanPtr derive(const PlanPtr& input, PK kind) {
    auto p = std::make_shared<Plan>();
    p->kind = kind;
    p->input = input;
    return p;
}

std::vector<std::string> csvHeader(const std::string& path) {
    std::ifstream in(path, std::ios::binary);
    if (!in) throw EvalError("cannot read " + path);
    std::string line;
    std::getline(in, line);
    const auto records = parseCsv(line);
    std::vector<std::string> names;
    if (!records.empty()) {
        for (const auto& f : records[0]) names.push_back(trim(f));
    }
    return names;
}

std::vector<std::string> exprOutputNames(const std::vector<ExprPtr>& exprs, const std::vector<std::string>& input,
                                         const std::set<std::string>& exclude = {}) {
    std::vector<std::string> names;
    for (const auto& e : expandWildcards(exprs, input, exclude)) names.push_back(outputName(*e));
    return names;
}

// Output column names of a plan (without running it).
std::vector<std::string> schemaOf(const Plan& p) {
    switch (p.kind) {
    case PK::ScanParquet: {
        if (p.output) return *p.output;
        std::vector<std::string> names;
        std::string error;
        if (!parquetColumnNames(p.path, names, error)) throw EvalError(error);
        return names;
    }
    case PK::ScanCsv: return p.output ? *p.output : csvHeader(p.path);
    case PK::Frame: return p.output ? *p.output : columnNames(*p.frame);
    case PK::Select: return exprOutputNames(p.exprs, schemaOf(*p.input));
    case PK::WithColumns: {
        auto names = schemaOf(*p.input);
        for (const auto& n : exprOutputNames(p.exprs, names)) {
            if (std::find(names.begin(), names.end(), n) == names.end()) names.push_back(n);
        }
        return names;
    }
    case PK::GroupBy: {
        const auto input = schemaOf(*p.input);
        auto names = exprOutputNames(p.keys, input);
        const auto aggs = exprOutputNames(p.exprs, input, std::set<std::string>(names.begin(), names.end()));
        names.insert(names.end(), aggs.begin(), aggs.end());
        return names;
    }
    case PK::Join: {
        auto names = schemaOf(*p.input);
        if (p.how == "semi" || p.how == "anti") return names;
        std::set<std::string> rightKeys;
        if (p.how != "cross" && p.how != "full") {
            for (const auto& k : parseJoinKeys(p.on)) rightKeys.insert(k.second);
        }
        for (auto n : schemaOf(*p.other)) {
            if (rightKeys.count(n)) continue;
            if (std::find(names.begin(), names.end(), n) != names.end()) n += p.suffix;
            names.push_back(n);
        }
        return names;
    }
    case PK::Rename: {
        auto names = schemaOf(*p.input);
        for (auto& n : names) {
            for (const auto& r : p.renames) {
                if (n == r.first) {
                    n = r.second;
                    break;
                }
            }
        }
        return names;
    }
    case PK::Drop: {
        std::vector<std::string> names;
        for (const auto& n : schemaOf(*p.input)) {
            if (std::find(p.names.begin(), p.names.end(), n) == p.names.end()) names.push_back(n);
        }
        return names;
    }
    case PK::RowIndex: {
        auto names = schemaOf(*p.input);
        names.insert(names.begin(), p.name);
        return names;
    }
    default: return schemaOf(*p.input);  // Filter, Sort, Slice, Unique
    }
}

ExprPtr andAll(const std::vector<ExprPtr>& predicates) {
    ExprPtr result;
    for (const auto& p : predicates) result = result ? makeExpr(EK::Binary, "and", {result, p}) : p;
    return result;
}

void splitConjuncts(const ExprPtr& e, std::vector<ExprPtr>& out) {
    if (e->kind == EK::Binary && e->op == "and") {
        splitConjuncts(e->args[0], out);
        splitConjuncts(e->args[1], out);
    } else {
        out.push_back(e);
    }
}

std::set<std::string> refsOf(const Expr& e, bool& wildcard) {
    std::set<std::string> refs;
    collectRefs(e, refs, wildcard);
    return refs;
}

bool refsWithin(const Expr& e, const std::set<std::string>& allowed) {
    bool wildcard = false;
    const auto refs = refsOf(e, wildcard);
    if (wildcard || hasAggregation(e)) return false;
    for (const auto& r : refs) {
        if (!allowed.count(r)) return false;
    }
    return true;
}

bool refsDisjoint(const Expr& e, const std::set<std::string>& names) {
    bool wildcard = false;
    const auto refs = refsOf(e, wildcard);
    if (wildcard || hasAggregation(e)) return false;
    for (const auto& r : refs) {
        if (names.count(r)) return false;
    }
    return true;
}

PlanPtr clonePlan(const PlanPtr& p) {
    if (!p) return p;
    auto copy = std::make_shared<Plan>(*p);
    copy->input = clonePlan(p->input);
    copy->other = clonePlan(p->other);
    return copy;
}

PlanPtr wrapFilter(const PlanPtr& p, const std::vector<ExprPtr>& predicates) {
    if (predicates.empty()) return p;
    auto f = derive(p, PK::Filter);
    f->predicate = andAll(predicates);
    return f;
}

// Move filters as close to the data as they can go.
PlanPtr pushPredicates(const PlanPtr& p, std::vector<ExprPtr> pending) {
    switch (p->kind) {
    case PK::Filter: {
        splitConjuncts(p->predicate, pending);
        return pushPredicates(p->input, pending);
    }
    case PK::ScanParquet:
    case PK::ScanCsv: {
        if (!pending.empty()) {
            std::vector<ExprPtr> all;
            if (p->predicate) splitConjuncts(p->predicate, all);
            all.insert(all.end(), pending.begin(), pending.end());
            p->predicate = andAll(all);
        }
        return p;
    }
    case PK::Frame: return wrapFilter(p, pending);
    case PK::Sort:
    case PK::Drop:
        p->input = pushPredicates(p->input, pending);
        return p;
    case PK::WithColumns: {
        std::set<std::string> produced;
        for (const auto& n : exprOutputNames(p->exprs, schemaOf(*p->input))) produced.insert(n);
        std::vector<ExprPtr> down, stay;
        for (const auto& e : pending) (refsDisjoint(*e, produced) ? down : stay).push_back(e);
        p->input = pushPredicates(p->input, down);
        return wrapFilter(p, stay);
    }
    case PK::Select: {
        // Columns passed through unchanged (plain col("x") without alias).
        std::set<std::string> passthrough;
        for (const auto& e : p->exprs) {
            if (e->kind == EK::Col && e->op != "*") passthrough.insert(e->op);
        }
        std::vector<ExprPtr> down, stay;
        for (const auto& e : pending) (refsWithin(*e, passthrough) ? down : stay).push_back(e);
        p->input = pushPredicates(p->input, down);
        return wrapFilter(p, stay);
    }
    case PK::GroupBy: {
        std::set<std::string> plainKeys;
        for (const auto& k : p->keys) {
            if (k->kind == EK::Col && k->op != "*") plainKeys.insert(k->op);
        }
        std::vector<ExprPtr> down, stay;
        for (const auto& e : pending) (refsWithin(*e, plainKeys) ? down : stay).push_back(e);
        p->input = pushPredicates(p->input, down);
        return wrapFilter(p, stay);
    }
    case PK::Join: {
        const auto leftNames = schemaOf(*p->input);
        const auto rightNames = schemaOf(*p->other);
        const std::set<std::string> leftSet(leftNames.begin(), leftNames.end());
        std::set<std::string> rightPlain;  // right columns that keep their name in the output
        if (p->how == "inner") {
            std::set<std::string> rightKeys;
            for (const auto& k : parseJoinKeys(p->on)) rightKeys.insert(k.second);
            for (const auto& n : rightNames) {
                if (!leftSet.count(n) && !rightKeys.count(n)) rightPlain.insert(n);
            }
        }
        std::vector<ExprPtr> left, right, stay;
        const bool leftOk = p->how == "inner" || p->how == "left" || p->how == "semi" || p->how == "anti";
        for (const auto& e : pending) {
            if (leftOk && refsWithin(*e, leftSet)) left.push_back(e);
            else if (!rightPlain.empty() && refsWithin(*e, rightPlain)) right.push_back(e);
            else stay.push_back(e);
        }
        p->input = pushPredicates(p->input, left);
        p->other = pushPredicates(p->other, right);
        return wrapFilter(p, stay);
    }
    default: {
        // Slice, Unique, Rename, RowIndex: filters do not commute with them.
        p->input = pushPredicates(p->input, {});
        if (p->other) p->other = pushPredicates(p->other, {});
        return wrapFilter(p, pending);
    }
    }
}

using Needed = std::optional<std::set<std::string>>;  // nullopt: every column

void addRefs(Needed& needed, const std::vector<ExprPtr>& exprs) {
    if (!needed) return;
    for (const auto& e : exprs) {
        bool wildcard = false;
        const auto refs = refsOf(*e, wildcard);
        if (wildcard) {
            needed.reset();
            return;
        }
        needed->insert(refs.begin(), refs.end());
    }
}

// Read only the columns the query needs; drop with_columns expressions nobody uses.
PlanPtr pushProjection(const PlanPtr& p, Needed needed) {
    switch (p->kind) {
    case PK::ScanParquet:
    case PK::ScanCsv:
    case PK::Frame: {
        const auto all = schemaOf(*p);
        if (needed) {
            std::vector<std::string> out;
            for (const auto& n : all) {
                if (needed->count(n)) out.push_back(n);
            }
            std::vector<std::string> read = out;
            if (p->predicate) {
                bool wildcard = false;
                for (const auto& r : refsOf(*p->predicate, wildcard)) {
                    if (std::find(read.begin(), read.end(), r) == read.end() && std::find(all.begin(), all.end(), r) != all.end()) {
                        read.push_back(r);
                    }
                }
            }
            // Keep the file's column order for what is read.
            std::vector<std::string> ordered;
            for (const auto& n : all) {
                if (std::find(read.begin(), read.end(), n) != read.end()) ordered.push_back(n);
            }
            p->projection = ordered;
            p->output = out;
        }
        return p;
    }
    case PK::Select: {
        Needed inputNeeded = std::set<std::string>();
        addRefs(inputNeeded, p->exprs);
        p->input = pushProjection(p->input, inputNeeded);
        return p;
    }
    case PK::WithColumns: {
        if (needed) {
            // Drop expressions whose output nobody reads.
            std::vector<ExprPtr> kept;
            for (const auto& e : p->exprs) {
                bool wildcard = false;
                refsOf(*e, wildcard);
                if (wildcard || needed->count(outputName(*e))) kept.push_back(e);
            }
            if (kept.empty()) return pushProjection(p->input, needed);
            p->exprs = kept;
            Needed inputNeeded = std::set<std::string>();
            for (const auto& n : *needed) {
                bool produced = false;
                for (const auto& e : p->exprs) produced = produced || outputName(*e) == n;
                if (!produced) inputNeeded->insert(n);
            }
            addRefs(inputNeeded, p->exprs);
            p->input = pushProjection(p->input, inputNeeded);
        } else {
            p->input = pushProjection(p->input, needed);
        }
        return p;
    }
    case PK::Filter: {
        addRefs(needed, {p->predicate});
        p->input = pushProjection(p->input, needed);
        return p;
    }
    case PK::GroupBy: {
        Needed inputNeeded = std::set<std::string>();
        addRefs(inputNeeded, p->keys);
        addRefs(inputNeeded, p->exprs);
        p->input = pushProjection(p->input, inputNeeded);
        return p;
    }
    case PK::Sort: {
        addRefs(needed, p->exprs);
        p->input = pushProjection(p->input, needed);
        return p;
    }
    case PK::Slice:
        p->input = pushProjection(p->input, needed);
        return p;
    case PK::Unique: {
        if (p->names.empty()) needed.reset();
        else if (needed) needed->insert(p->names.begin(), p->names.end());
        p->input = pushProjection(p->input, needed);
        return p;
    }
    case PK::Rename: {
        if (needed) {
            Needed back = std::set<std::string>();
            for (const auto& n : *needed) {
                std::string original = n;
                for (const auto& r : p->renames) {
                    if (r.second == n) original = r.first;
                }
                back->insert(original);
            }
            needed = back;
        }
        p->input = pushProjection(p->input, needed);
        return p;
    }
    case PK::Drop:
    case PK::RowIndex:
        if (needed) needed->erase(p->name);
        p->input = pushProjection(p->input, needed);
        return p;
    case PK::Join: {
        if (!needed) {
            p->input = pushProjection(p->input, needed);
            p->other = pushProjection(p->other, needed);
            return p;
        }
        const auto leftNames = schemaOf(*p->input);
        const auto rightNames = schemaOf(*p->other);
        const auto keys = parseJoinKeys(p->on);
        Needed left = std::set<std::string>(), right = std::set<std::string>();
        for (const auto& k : keys) {
            left->insert(k.first);
            right->insert(k.second);
        }
        const std::set<std::string> leftSet(leftNames.begin(), leftNames.end());
        for (const auto& n : leftNames) {
            if (needed->count(n)) left->insert(n);
        }
        for (const auto& n : rightNames) {
            const std::string shown = leftSet.count(n) ? n + p->suffix : n;
            if (needed->count(shown) || needed->count(n)) right->insert(n);
        }
        p->input = pushProjection(p->input, left);
        p->other = pushProjection(p->other, right);
        return p;
    }
    }
    return p;
}

// head(n) over a scan (possibly through row-wise steps) stops reading row groups early.
void pushLimit(const PlanPtr& p) {
    if (p->kind == PK::Slice && p->offset >= 0 && p->length >= 0) {
        PlanPtr q = p->input;
        while (q && (q->kind == PK::Rename || q->kind == PK::Drop ||
                     ((q->kind == PK::Select || q->kind == PK::WithColumns) &&
                      std::none_of(q->exprs.begin(), q->exprs.end(), [](const ExprPtr& e) { return hasAggregation(*e); })))) {
            q = q->input;
        }
        if (q && (q->kind == PK::ScanParquet || q->kind == PK::ScanCsv) && !q->predicate) {
            q->limit = p->offset + p->length;
        }
    }
    if (p->input) pushLimit(p->input);
    if (p->other) pushLimit(p->other);
}

PlanPtr optimize(const PlanPtr& p) {
    PlanPtr q = clonePlan(p);
    q = pushPredicates(q, {});
    q = pushProjection(q, std::nullopt);
    pushLimit(q);
    return q;
}

// Row groups a scan predicate cannot match, judged by their min/max statistics.
RowGroupFilter statisticsFilter(const ExprPtr& predicate) {
    if (!predicate) return RowGroupFilter();
    std::vector<ExprPtr> conjuncts;
    splitConjuncts(predicate, conjuncts);
    struct Bound {
        std::string column;
        std::string op;  // col op value
        double value;
    };
    std::vector<Bound> bounds;
    auto flip = [](const std::string& op) {
        if (op == "<") return std::string(">");
        if (op == "<=") return std::string(">=");
        if (op == ">") return std::string("<");
        if (op == ">=") return std::string("<=");
        return op;
    };
    for (const auto& c : conjuncts) {
        if (c->kind != EK::Binary || !isCmp(c->op) || c->op == "!=") continue;
        const Expr& a = *c->args[0];
        const Expr& b = *c->args[1];
        auto numericLit = [](const Expr& e, double& v) {
            if (e.kind != EK::Lit || e.literal.isNull(0) || !e.literal.numeric()) return false;
            v = e.literal.number(0);
            return true;
        };
        double v;
        if (a.kind == EK::Col && numericLit(b, v)) bounds.push_back({a.op, c->op, v});
        else if (b.kind == EK::Col && numericLit(a, v)) bounds.push_back({b.op, flip(c->op), v});
    }
    if (bounds.empty()) return RowGroupFilter();
    return [bounds](const std::vector<Leaf>& leaves, const TValue& group) {
        const TValue* chunks = group.field(1);
        if (!chunks) return true;
        for (const auto& bound : bounds) {
            for (size_t k = 0; k < leaves.size() && k < chunks->list.size(); ++k) {
                if (leaves[k].name != bound.column) continue;
                ChunkStats s;
                if (!chunkStats(leaves[k], chunks->list[k], s)) continue;
                const double v = bound.value;
                bool possible = true;
                if (bound.op == "==") possible = s.min <= v && v <= s.max;
                else if (bound.op == "<") possible = s.min < v;
                else if (bound.op == "<=") possible = s.min <= v;
                else if (bound.op == ">") possible = s.max > v;
                else if (bound.op == ">=") possible = s.max >= v;
                if (!possible) return false;
            }
        }
        return true;
    };
}

DataFrame finishScan(DataFrame df, const Plan& p) {
    if (p.predicate) df = filterExpr(df, *p.predicate);
    if (p.output) df = projectColumns(df, *p.output);
    if (p.limit >= 0) df = sliceRows(df, 0, p.limit);
    return df;
}

DataFrame execute(const Plan& p) {
    switch (p.kind) {
    case PK::ScanParquet: {
        DataFrame df;
        std::string error;
        const auto* columns = p.projection ? &*p.projection : nullptr;
        if (!readParquetInto(p.path, columns, statisticsFilter(p.predicate), p.limit, df, error)) throw EvalError(error);
        return finishScan(std::move(df), p);
    }
    case PK::ScanCsv: {
        std::string text;
        if (!readFile(p.path, text)) throw EvalError("cannot read " + p.path);
        const long long handle = frameFromCsv(text);
        if (!handle) throw EvalError(lastError);
        DataFrame df = *frames().take(handle);
        if (p.projection) df = projectColumns(df, *p.projection);
        return finishScan(std::move(df), p);
    }
    case PK::Frame: {
        DataFrame df = p.projection ? projectColumns(*p.frame, *p.projection) : *p.frame;
        return finishScan(std::move(df), p);
    }
    case PK::Select: return selectExprs(execute(*p.input), p.exprs);
    case PK::WithColumns: return withColumnsExprs(execute(*p.input), p.exprs);
    case PK::Filter: return filterExpr(execute(*p.input), *p.predicate);
    case PK::GroupBy: return groupByAgg(execute(*p.input), p.keys, p.exprs);
    case PK::Sort: return sortExprs(execute(*p.input), p.exprs, p.descending, p.nullsLast);
    case PK::Join: return joinFrames(execute(*p.input), execute(*p.other), p.on, p.how, p.suffix);
    case PK::Slice: return sliceRows(execute(*p.input), p.offset, p.length);
    case PK::Unique: return uniqueRows(execute(*p.input), p.names);
    case PK::Rename: return renameColumns(execute(*p.input), p.renames);
    case PK::Drop: return dropColumns(execute(*p.input), p.names);
    case PK::RowIndex: return withRowIndex(execute(*p.input), p.name, p.offset);
    }
    throw EvalError("cannot execute plan");
}

std::string exprListString(const std::vector<ExprPtr>& exprs) {
    std::string s = "[";
    for (size_t k = 0; k < exprs.size(); ++k) s += (k ? ", " : "") + exprToString(*exprs[k]);
    return s + "]";
}

void explainPlan(const Plan& p, int depth, std::string& out) {
    const std::string pad(static_cast<size_t>(depth) * 2, ' ');
    auto line = [&](const std::string& text) { out += pad + text + "\n"; };
    switch (p.kind) {
    case PK::ScanParquet:
    case PK::ScanCsv:
    case PK::Frame: {
        if (p.kind == PK::Frame) line("DF " + std::to_string(p.frame->columns.size()) + " columns, " + std::to_string(p.frame->rows()) + " rows");
        else line(std::string(p.kind == PK::ScanParquet ? "Parquet" : "Csv") + " SCAN [" + p.path + "]");
        if (p.output) {
            size_t total = 0;
            try {
                if (p.kind == PK::ScanParquet) {
                    std::vector<std::string> names;
                    std::string error;
                    if (parquetColumnNames(p.path, names, error)) total = names.size();
                } else if (p.kind == PK::ScanCsv) {
                    total = csvHeader(p.path).size();
                } else {
                    total = p.frame->columns.size();
                }
            } catch (const std::exception&) {
            }
            std::string cols;
            for (size_t k = 0; k < p.output->size(); ++k) cols += (k ? ", " : "") + (*p.output)[k];
            line("  PROJECT " + std::to_string(p.output->size()) + "/" + std::to_string(total) + " COLUMNS: " + cols);
        } else {
            line("  PROJECT */all COLUMNS");
        }
        if (p.predicate) line("  SELECTION: " + exprToString(*p.predicate));
        if (p.limit >= 0) line("  LIMIT: " + std::to_string(p.limit));
        return;
    }
    case PK::Select: line("SELECT " + exprListString(p.exprs) + " FROM"); break;
    case PK::WithColumns: line("WITH_COLUMNS " + exprListString(p.exprs)); break;
    case PK::Filter: line("FILTER " + exprToString(*p.predicate) + " FROM"); break;
    case PK::GroupBy: line("AGGREGATE " + exprListString(p.exprs) + " BY " + exprListString(p.keys) + " FROM"); break;
    case PK::Sort: {
        std::string desc;
        for (size_t k = 0; k < p.exprs.size(); ++k) desc += std::string(k ? ", " : "") + ((p.descending >> k) & 1 ? "true" : "false");
        line("SORT BY " + exprListString(p.exprs) + " descending=[" + desc + "]" + (p.nullsLast ? " nulls_last" : ""));
        break;
    }
    case PK::Join:
        line(p.how == "cross" ? "CROSS JOIN:" : (p.how == "inner" ? "INNER" : p.how == "left" ? "LEFT" : p.how == "full" ? "FULL" :
                                                 p.how == "semi" ? "SEMI" : "ANTI") + std::string(" JOIN ON ") + p.on + ":");
        line("LEFT PLAN:");
        explainPlan(*p.input, depth + 1, out);
        line("RIGHT PLAN:");
        explainPlan(*p.other, depth + 1, out);
        line("END JOIN");
        return;
    case PK::Slice: line("SLICE offset=" + std::to_string(p.offset) + " len=" + std::to_string(p.length)); break;
    case PK::Unique: {
        std::string subset;
        for (size_t k = 0; k < p.names.size(); ++k) subset += (k ? ", " : "") + p.names[k];
        line("UNIQUE" + (subset.empty() ? std::string() : " BY [" + subset + "]"));
        break;
    }
    case PK::Rename: {
        std::string r;
        for (size_t k = 0; k < p.renames.size(); ++k) r += (k ? ", " : "") + p.renames[k].first + " -> " + p.renames[k].second;
        line("RENAME " + r);
        break;
    }
    case PK::Drop: {
        std::string d;
        for (size_t k = 0; k < p.names.size(); ++k) d += (k ? ", " : "") + p.names[k];
        line("DROP " + d);
        break;
    }
    case PK::RowIndex: line("ROW_INDEX " + p.name); break;
    }
    explainPlan(*p.input, depth + 1, out);
}

// Run `body` and turn evaluation errors into a 0 handle plus dfLastError().
template <typename Body>
long long guarded(Body body) {
    try {
        lastError.clear();
        return body();
    } catch (const std::exception& e) {
        return fail(e.what());
    }
}

std::vector<ExprPtr> listOf(long long handle) {
    if (handle == 0) return {};
    auto l = exprLists().get(handle);
    if (!l) throw EvalError("unknown expression list handle");
    return l->items;
}

std::vector<std::pair<std::string, std::string>> parseRenames(const char* spec) {
    std::vector<std::pair<std::string, std::string>> renames;
    for (const auto& item : splitList(spec)) {
        const auto eq = item.find('=');
        if (eq == std::string::npos) throw EvalError("rename needs 'old=new' pairs, got '" + item + "'");
        renames.emplace_back(trim(item.substr(0, eq)), trim(item.substr(eq + 1)));
    }
    return renames;
}

} // namespace csec_df

// ---- C API: expressions ------------------------------------------------------------------------

extern "C" {

long long csec_expr_col(const char* name) {
    return csec_df::guarded([&] {
        const std::string n = name ? name : "";
        const auto names = csec_df::splitList(name);
        if (names.size() <= 1) return csec_df::storeExpr(std::move(*csec_df::makeExpr(csec_df::EK::Col, csec_df::trim(n))));
        throw csec_df::EvalError("col() takes one column name (use select(\"a,b\") for several)");
        return 0LL;
    });
}

static long long csecExprLit(csec_df::Column&& c) {
    csec_df::Expr e;
    e.kind = csec_df::EK::Lit;
    e.literal = std::move(c);
    return csec_df::storeExpr(std::move(e));
}

long long csec_expr_lit_long(long long v) {
    csec_df::Column c("literal", csec_df::ColType::Long);
    c.pushLong(v);
    return csecExprLit(std::move(c));
}

long long csec_expr_lit_double(double v) {
    csec_df::Column c("literal", csec_df::ColType::Double);
    c.pushDouble(v);
    return csecExprLit(std::move(c));
}

long long csec_expr_lit_string(const char* v) {
    csec_df::Column c("literal", csec_df::ColType::String);
    c.pushString(v ? v : "");
    return csecExprLit(std::move(c));
}

long long csec_expr_lit_bool(int v) {
    csec_df::Column c("literal", csec_df::ColType::Bool);
    c.pushBool(v != 0);
    return csecExprLit(std::move(c));
}

long long csec_expr_lit_null(void) {
    csec_df::Column c("literal", csec_df::ColType::Long);
    c.pushNull();
    return csecExprLit(std::move(c));
}

long long csec_expr_len(void) {
    return csec_df::storeExpr(std::move(*csec_df::makeExpr(csec_df::EK::Len, "")));
}

long long csec_expr_binary(long long a, const char* op, long long b) {
    return csec_df::guarded([&] {
        const std::string o = op ? op : "";
        static const std::set<std::string> ops = {"+", "-", "*", "/", "%", "==", "!=", "<", "<=", ">", ">=", "and", "or"};
        if (!ops.count(o)) throw csec_df::EvalError("unknown operator '" + o + "'");
        return csec_df::storeExpr(std::move(*csec_df::makeExpr(csec_df::EK::Binary, o, {csec_df::exprOf(a), csec_df::exprOf(b)})));
    });
}

long long csec_expr_unary(long long a, const char* op) {
    return csec_df::guarded([&] {
        const std::string o = op ? op : "";
        static const std::set<std::string> ops = {"not", "neg", "is_null", "is_not_null", "abs", "sqrt", "exp", "log", "floor", "ceil"};
        if (!ops.count(o)) throw csec_df::EvalError("unknown function " + o + "()");
        return csec_df::storeExpr(std::move(*csec_df::makeExpr(csec_df::EK::Unary, o, {csec_df::exprOf(a)})));
    });
}

long long csec_expr_agg(long long a, const char* fn) {
    return csec_df::guarded([&] {
        const std::string f = fn ? fn : "";
        if (csec_df::parseAgg(f) == csec_df::Agg::Invalid) throw csec_df::EvalError("unknown aggregation " + f + "()");
        return csec_df::storeExpr(std::move(*csec_df::makeExpr(csec_df::EK::Agg, f, {csec_df::exprOf(a)})));
    });
}

long long csec_expr_alias(long long a, const char* name) {
    return csec_df::guarded([&] {
        return csec_df::storeExpr(std::move(*csec_df::makeExpr(csec_df::EK::Alias, name ? name : "", {csec_df::exprOf(a)})));
    });
}

long long csec_expr_cast(long long a, const char* dtype) {
    return csec_df::guarded([&] {
        csec_df::ColType t;
        const std::string d = dtype ? dtype : "";
        if (!csec_df::parseDtype(d, t)) throw csec_df::EvalError("unknown dtype '" + d + "' (i64, f64, str, bool)");
        return csec_df::storeExpr(std::move(*csec_df::makeExpr(csec_df::EK::Cast, csec_df::dtypeName(t), {csec_df::exprOf(a)})));
    });
}

long long csec_expr_fill_null(long long a, long long value) {
    return csec_df::guarded([&] {
        return csec_df::storeExpr(std::move(*csec_df::makeExpr(csec_df::EK::FillNull, "", {csec_df::exprOf(a), csec_df::exprOf(value)})));
    });
}

long long csec_expr_round(long long a, long long decimals) {
    return csec_df::guarded([&] {
        auto e = csec_df::makeExpr(csec_df::EK::Round, "", {csec_df::exprOf(a)});
        e->n = decimals;
        return csec_df::storeExpr(std::move(*e));
    });
}

long long csec_expr_str(long long a, const char* fn, const char* arg, const char* arg2) {
    return csec_df::guarded([&] {
        const std::string f = fn ? fn : "";
        static const std::set<std::string> fns = {"contains", "starts_with", "ends_with", "len_chars", "len_bytes", "to_uppercase",
                                                  "to_lowercase", "strip_chars", "replace", "replace_all"};
        if (!fns.count(f)) throw csec_df::EvalError("unknown string function ." + f + "()");
        auto e = csec_df::makeExpr(csec_df::EK::Str, f, {csec_df::exprOf(a)});
        e->text = arg ? arg : "";
        e->text2 = arg2 ? arg2 : "";
        return csec_df::storeExpr(std::move(*e));
    });
}

long long csec_expr_when(long long condition, long long then, long long otherwise) {
    return csec_df::guarded([&] {
        return csec_df::storeExpr(std::move(*csec_df::makeExpr(
            csec_df::EK::When, "", {csec_df::exprOf(condition), csec_df::exprOf(then), csec_df::exprOf(otherwise)})));
    });
}

long long csec_expr_over(long long a, const char* keys) {
    return csec_df::guarded([&] {
        auto e = csec_df::makeExpr(csec_df::EK::Over, "", {csec_df::exprOf(a)});
        e->keys = csec_df::splitList(keys);
        if (e->keys.empty()) throw csec_df::EvalError("over() needs partition columns");
        return csec_df::storeExpr(std::move(*e));
    });
}

char* csec_expr_to_string(long long a) {
    auto e = csec_df::exprTable().get(a);
    return csec_microthread::ownedText(e ? csec_df::exprToString(*e) : std::string("<invalid expression>"));
}

void csec_expr_free(long long a) {
    csec_df::exprTable().take(a);
}

long long csec_exprlist_new(void) {
    return csec_df::exprLists().add(std::make_shared<csec_df::ExprList>());
}

// Append `expr` to `list`; returns the list (so calls can be chained).
long long csec_exprlist_push(long long list, long long expr) {
    auto l = csec_df::exprLists().get(list);
    auto e = csec_df::exprTable().get(expr);
    if (!l || !e) return csec_df::fail("unknown expression or expression list");
    l->items.push_back(e);
    return list;
}

void csec_exprlist_free(long long list) {
    csec_df::exprLists().take(list);
}

// A list of col() expressions for "a,b,c" (a "-" prefix sets that key's bit in *descending).
long long csec_exprlist_cols(const char* names) {
    return csec_df::guarded([&] {
        auto list = std::make_shared<csec_df::ExprList>();
        for (auto name : csec_df::splitList(names)) {
            if (!name.empty() && (name[0] == '-' || name[0] == '+')) name = csec_df::trim(name.substr(1));
            list->items.push_back(csec_df::makeExpr(csec_df::EK::Col, name));
        }
        if (list->items.empty()) throw csec_df::EvalError("no column names given");
        return csec_df::exprLists().add(list);
    });
}

// Bit k set when the k-th name of "a,-b" has a '-' prefix.
long long csec_exprlist_descending_mask(const char* names) {
    long long mask = 0;
    int k = 0;
    for (const auto& name : csec_df::splitList(names)) {
        if (!name.empty() && name[0] == '-' && k < 63) mask |= 1LL << k;
        ++k;
    }
    return mask;
}

// Polars raises on errors; std.dataframe's class API prints the error and exits unless raising is
// turned off (then failed operations return an empty, invalid frame and dfLastError() explains).
static bool csecDfRaise = true;

void csec_df_set_raise(int raise) {
    csecDfRaise = raise != 0;
}

long long csec_df_check(long long handle) {
    if (handle == 0 && csecDfRaise) {
        std::fflush(stdout);
        std::fprintf(stderr, "DataFrame error: %s\n", csec_df::lastError.empty() ? "unknown error" : csec_df::lastError.c_str());
        std::fflush(stderr);
        std::exit(1);
    }
    return handle;
}

// ---- C API: eager frame operations on expressions ----

static long long csecDfApply(long long frame, const std::function<csec_df::DataFrame(const csec_df::DataFrame&)>& op) {
    return csec_df::guarded([&] {
        auto df = csec_df::frameOf(frame);
        if (!df) throw csec_df::EvalError("unknown data frame handle");
        return csec_df::store(op(*df));
    });
}

long long csec_df_select_exprs(long long frame, long long list) {
    return csecDfApply(frame, [&](const csec_df::DataFrame& df) { return csec_df::selectExprs(df, csec_df::listOf(list)); });
}

long long csec_df_with_columns(long long frame, long long list) {
    return csecDfApply(frame, [&](const csec_df::DataFrame& df) { return csec_df::withColumnsExprs(df, csec_df::listOf(list)); });
}

long long csec_df_filter_expr(long long frame, long long predicate) {
    return csecDfApply(frame, [&](const csec_df::DataFrame& df) { return csec_df::filterExpr(df, *csec_df::exprOf(predicate)); });
}

long long csec_df_group_by_agg(long long frame, long long keys, long long aggs) {
    return csecDfApply(frame, [&](const csec_df::DataFrame& df) {
        return csec_df::groupByAgg(df, csec_df::listOf(keys), csec_df::listOf(aggs));
    });
}

long long csec_df_sort_by(long long frame, long long keys, long long descendingMask, int nullsLast) {
    return csecDfApply(frame, [&](const csec_df::DataFrame& df) {
        return csec_df::sortExprs(df, csec_df::listOf(keys), static_cast<unsigned long long>(descendingMask), nullsLast != 0);
    });
}

long long csec_df_unique(long long frame, const char* subset) {
    return csecDfApply(frame, [&](const csec_df::DataFrame& df) { return csec_df::uniqueRows(df, csec_df::splitList(subset)); });
}

long long csec_df_with_row_index(long long frame, const char* name, long long offset) {
    return csecDfApply(frame, [&](const csec_df::DataFrame& df) { return csec_df::withRowIndex(df, name ? name : "index", offset); });
}

long long csec_df_rename_many(long long frame, const char* spec) {
    return csecDfApply(frame, [&](const csec_df::DataFrame& df) { return csec_df::renameColumns(df, csec_df::parseRenames(spec)); });
}

long long csec_df_join_frames(long long left, long long right, const char* on, const char* how, const char* suffix) {
    return csec_df::guarded([&] {
        auto l = csec_df::frameOf(left);
        auto r = csec_df::frameOf(right);
        if (!l || !r) throw csec_df::EvalError("unknown data frame handle");
        return csec_df::store(csec_df::joinFrames(*l, *r, on ? on : "", how && *how ? how : "inner", suffix && *suffix ? suffix : "_right"));
    });
}

long long csec_df_describe(long long frame) {
    return csecDfApply(frame, [&](const csec_df::DataFrame& df) { return csec_df::describeFrame(df); });
}

// DataFrame.sum() / mean() / min() / max() / std() / var() / median(): one row, one aggregate per
// column. Like Polars, a string column gives null for the numeric aggregations.
long long csec_df_reduce(long long frame, const char* fn) {
    return csecDfApply(frame, [&](const csec_df::DataFrame& df) {
        const std::string f = fn ? fn : "";
        const csec_df::Agg agg = csec_df::parseAgg(f);
        if (agg == csec_df::Agg::Invalid) throw csec_df::EvalError("unknown aggregation " + f + "()");
        const bool numericOnly = agg != csec_df::Agg::Min && agg != csec_df::Agg::Max && agg != csec_df::Agg::Count &&
                                 agg != csec_df::Agg::NullCount && agg != csec_df::Agg::First && agg != csec_df::Agg::Last &&
                                 agg != csec_df::Agg::NUnique;
        csec_df::DataFrame out;
        for (const auto& c : df.columns) {
            std::vector<size_t> rows(c.size());
            for (size_t r = 0; r < rows.size(); ++r) rows[r] = r;
            if (numericOnly && !c.numeric()) {
                csec_df::Column cell(c.name, c.type);
                cell.pushNull();
                out.columns.push_back(std::move(cell));
                continue;
            }
            csec_df::Column cell(c.name, csec_df::aggType(agg, &c));
            csec_df::aggregate(agg, &c, rows, cell);
            out.columns.push_back(std::move(cell));
        }
        return out;
    });
}

long long csec_df_null_counts(long long frame) {
    return csecDfApply(frame, [&](const csec_df::DataFrame& df) { return csec_df::nullCounts(df); });
}

char* csec_df_format(long long frame, long long maxRows) {
    auto df = csec_df::frames().get(frame);
    return csec_microthread::ownedText(df ? csec_df::formatTable(*df, maxRows) : std::string("<invalid DataFrame>"));
}

char* csec_df_schema(long long frame) {
    auto df = csec_df::frames().get(frame);
    return csec_microthread::ownedText(df ? csec_df::schemaString(*df) : std::string());
}

char* csec_df_dtype(long long frame, const char* name) {
    auto df = csec_df::frames().get(frame);
    const int index = df && name ? df->find(name) : -1;
    return csec_microthread::ownedText(index >= 0 ? csec_df::dtypeName(df->columns[index].type) : "");
}

// "utf8", "ascii", or "auto" (UTF-8 box drawing unless a Windows console is not in UTF-8 mode).
void csec_df_set_table_format(const char* format) {
    const std::string f = format ? format : "";
    csec_df::tableFormat = f == "utf8" ? 1 : f == "ascii" ? 2 : 0;
}

char* csec_df_last_scan_info(void) {
    const auto& s = csec_df::lastScan;
    return csec_microthread::ownedText("row_groups=" + std::to_string(s.rowGroupsRead) + "/" + std::to_string(s.rowGroupsTotal) +
                                       " columns=" + std::to_string(s.columnsRead) + "/" + std::to_string(s.columnsTotal));
}

// ---- C API: lazy frames ----

long long csec_lazy_scan_parquet(const char* path) {
    csec_df::Plan p;
    p.kind = csec_df::PK::ScanParquet;
    p.path = path ? path : "";
    return csec_df::storePlan(std::move(p));
}

long long csec_lazy_scan_csv(const char* path) {
    csec_df::Plan p;
    p.kind = csec_df::PK::ScanCsv;
    p.path = path ? path : "";
    return csec_df::storePlan(std::move(p));
}

long long csec_lazy_from_frame(long long frame) {
    return csec_df::guarded([&] {
        auto df = csec_df::frameOf(frame);
        if (!df) throw csec_df::EvalError("unknown data frame handle");
        csec_df::Plan p;
        p.kind = csec_df::PK::Frame;
        p.frame = std::make_shared<csec_df::DataFrame>(*df);
        return csec_df::storePlan(std::move(p));
    });
}

static long long csecLazyDerive(long long lazy, csec_df::PK kind, const std::function<void(csec_df::Plan&)>& fill) {
    return csec_df::guarded([&] {
        auto p = csec_df::derive(csec_df::planOf(lazy), kind);
        fill(*p);
        return csec_df::plans().add(p);
    });
}

long long csec_lazy_select(long long lazy, long long list) {
    return csecLazyDerive(lazy, csec_df::PK::Select, [&](csec_df::Plan& p) { p.exprs = csec_df::listOf(list); });
}

long long csec_lazy_with_columns(long long lazy, long long list) {
    return csecLazyDerive(lazy, csec_df::PK::WithColumns, [&](csec_df::Plan& p) { p.exprs = csec_df::listOf(list); });
}

long long csec_lazy_filter(long long lazy, long long predicate) {
    return csecLazyDerive(lazy, csec_df::PK::Filter, [&](csec_df::Plan& p) { p.predicate = csec_df::exprOf(predicate); });
}

long long csec_lazy_group_by_agg(long long lazy, long long keys, long long aggs) {
    return csecLazyDerive(lazy, csec_df::PK::GroupBy, [&](csec_df::Plan& p) {
        p.keys = csec_df::listOf(keys);
        p.exprs = csec_df::listOf(aggs);
    });
}

long long csec_lazy_sort_by(long long lazy, long long keys, long long descendingMask, int nullsLast) {
    return csecLazyDerive(lazy, csec_df::PK::Sort, [&](csec_df::Plan& p) {
        p.exprs = csec_df::listOf(keys);
        p.descending = static_cast<unsigned long long>(descendingMask);
        p.nullsLast = nullsLast != 0;
    });
}

long long csec_lazy_join(long long lazy, long long other, const char* on, const char* how, const char* suffix) {
    return csecLazyDerive(lazy, csec_df::PK::Join, [&](csec_df::Plan& p) {
        p.other = csec_df::planOf(other);
        p.on = on ? on : "";
        p.how = how && *how ? how : "inner";
        p.suffix = suffix && *suffix ? suffix : "_right";
    });
}

long long csec_lazy_slice(long long lazy, long long offset, long long length) {
    return csecLazyDerive(lazy, csec_df::PK::Slice, [&](csec_df::Plan& p) {
        p.offset = offset;
        p.length = length;
    });
}

long long csec_lazy_unique(long long lazy, const char* subset) {
    return csecLazyDerive(lazy, csec_df::PK::Unique, [&](csec_df::Plan& p) { p.names = csec_df::splitList(subset); });
}

long long csec_lazy_rename(long long lazy, const char* spec) {
    return csecLazyDerive(lazy, csec_df::PK::Rename, [&](csec_df::Plan& p) { p.renames = csec_df::parseRenames(spec); });
}

long long csec_lazy_drop(long long lazy, const char* columns) {
    return csecLazyDerive(lazy, csec_df::PK::Drop, [&](csec_df::Plan& p) { p.names = csec_df::splitList(columns); });
}

long long csec_lazy_with_row_index(long long lazy, const char* name, long long offset) {
    return csecLazyDerive(lazy, csec_df::PK::RowIndex, [&](csec_df::Plan& p) {
        p.name = name && *name ? name : "index";
        p.offset = offset;
    });
}

long long csec_lazy_collect(long long lazy) {
    return csec_df::guarded([&] {
        const auto optimized = csec_df::optimize(csec_df::planOf(lazy));
        return csec_df::store(csec_df::execute(*optimized));
    });
}

// The query plan as text; `optimized` != 0 shows it after pushdown.
char* csec_lazy_explain(long long lazy, int optimized) {
    std::string out;
    try {
        auto plan = csec_df::planOf(lazy);
        if (optimized) plan = csec_df::optimize(plan);
        csec_df::explainPlan(*plan, 0, out);
        if (!out.empty()) out.pop_back();
    } catch (const std::exception& e) {
        out = std::string("error: ") + e.what();
    }
    return csec_microthread::ownedText(out);
}

char* csec_lazy_schema(long long lazy) {
    std::string out;
    try {
        const auto names = csec_df::schemaOf(*csec_df::optimize(csec_df::planOf(lazy)));
        for (size_t k = 0; k < names.size(); ++k) out += (k ? "," : "") + names[k];
    } catch (const std::exception& e) {
        csec_df::fail(e.what());
    }
    return csec_microthread::ownedText(out);
}

void csec_lazy_free(long long lazy) {
    csec_df::plans().take(lazy);
}

} // extern "C"

// Restores the <windows.h> min/max macros suspended in parquet_codec.inc.
#pragma pop_macro("max")
#pragma pop_macro("min")
