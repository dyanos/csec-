// ============================================================================
//  bigint_runtime.inc  --  arbitrary-precision integers for the Nat type
//
//  A Nat (Gaussian integer) stores two of these as its real and imaginary
//  components, so a natural number has no 64-bit ceiling: its magnitude grows
//  with the value.  Representation is sign-magnitude, little-endian, base 1e9
//  (each limb holds 0..999999999, which keeps a full limb*limb product inside
//  a uint64_t and makes decimal formatting a plain per-limb print).
//
//  Handles are heap objects returned as void* and are caller-owned / leaked,
//  matching the char* string helpers elsewhere in the runtime.
// ============================================================================

namespace {

constexpr std::uint32_t CSEC_BIGINT_BASE = 1000000000u;  // 1e9

struct CsecBigInt {
    int sign = 0;                       // -1, 0, +1  (0 => the value is zero)
    std::vector<std::uint32_t> mag;     // base-1e9 limbs, little-endian, no trailing zeros
};

void csecBigIntTrim(std::vector<std::uint32_t>& m) {
    while (!m.empty() && m.back() == 0) m.pop_back();
}

CsecBigInt* csecBigIntAlloc(int sign, std::vector<std::uint32_t> mag) {
    csecBigIntTrim(mag);
    auto* r = new CsecBigInt();
    r->mag = std::move(mag);
    r->sign = r->mag.empty() ? 0 : sign;   // canonical zero has sign 0
    return r;
}

// Compare magnitudes only: -1 (a<b), 0 (a==b), +1 (a>b).
int csecMagCmp(const std::vector<std::uint32_t>& a, const std::vector<std::uint32_t>& b) {
    if (a.size() != b.size()) return a.size() < b.size() ? -1 : 1;
    for (std::size_t i = a.size(); i-- > 0;) {
        if (a[i] != b[i]) return a[i] < b[i] ? -1 : 1;
    }
    return 0;
}

std::vector<std::uint32_t> csecMagAdd(const std::vector<std::uint32_t>& a, const std::vector<std::uint32_t>& b) {
    std::vector<std::uint32_t> r;
    std::size_t n = a.size() > b.size() ? a.size() : b.size();  // std::max clashes with windows.h max macro
    r.reserve(n + 1);
    std::uint64_t carry = 0;
    for (std::size_t i = 0; i < n; ++i) {
        std::uint64_t s = carry;
        if (i < a.size()) s += a[i];
        if (i < b.size()) s += b[i];
        r.push_back(static_cast<std::uint32_t>(s % CSEC_BIGINT_BASE));
        carry = s / CSEC_BIGINT_BASE;
    }
    if (carry) r.push_back(static_cast<std::uint32_t>(carry));
    return r;
}

// Magnitude subtraction, requires |a| >= |b|.
std::vector<std::uint32_t> csecMagSub(const std::vector<std::uint32_t>& a, const std::vector<std::uint32_t>& b) {
    std::vector<std::uint32_t> r;
    r.reserve(a.size());
    std::int64_t borrow = 0;
    for (std::size_t i = 0; i < a.size(); ++i) {
        std::int64_t s = static_cast<std::int64_t>(a[i]) - borrow
            - (i < b.size() ? static_cast<std::int64_t>(b[i]) : 0);
        if (s < 0) { s += CSEC_BIGINT_BASE; borrow = 1; } else { borrow = 0; }
        r.push_back(static_cast<std::uint32_t>(s));
    }
    csecBigIntTrim(r);
    return r;
}

std::vector<std::uint32_t> csecMagMul(const std::vector<std::uint32_t>& a, const std::vector<std::uint32_t>& b) {
    if (a.empty() || b.empty()) return {};
    std::vector<std::uint64_t> acc(a.size() + b.size(), 0);
    for (std::size_t i = 0; i < a.size(); ++i) {
        std::uint64_t carry = 0;
        for (std::size_t j = 0; j < b.size(); ++j) {
            std::uint64_t cur = acc[i + j] + static_cast<std::uint64_t>(a[i]) * b[j] + carry;
            acc[i + j] = cur % CSEC_BIGINT_BASE;
            carry = cur / CSEC_BIGINT_BASE;
        }
        acc[i + b.size()] += carry;
    }
    std::vector<std::uint32_t> r(acc.size());
    for (std::size_t i = 0; i < acc.size(); ++i) r[i] = static_cast<std::uint32_t>(acc[i]);
    csecBigIntTrim(r);
    return r;
}

// Signed add of two big integers (subtraction is add-with-negated-b).
CsecBigInt* csecBigIntAddSigned(const CsecBigInt* a, const CsecBigInt* b) {
    if (a->sign == 0) return csecBigIntAlloc(b->sign, b->mag);
    if (b->sign == 0) return csecBigIntAlloc(a->sign, a->mag);
    if (a->sign == b->sign) return csecBigIntAlloc(a->sign, csecMagAdd(a->mag, b->mag));
    int c = csecMagCmp(a->mag, b->mag);
    if (c == 0) return csecBigIntAlloc(0, {});
    if (c > 0) return csecBigIntAlloc(a->sign, csecMagSub(a->mag, b->mag));
    return csecBigIntAlloc(b->sign, csecMagSub(b->mag, a->mag));
}

}  // namespace

extern "C" {

void* csec_bigint_from_i64(long long value) {
    int sign = value > 0 ? 1 : (value < 0 ? -1 : 0);
    unsigned long long u = value < 0
        ? (0ULL - static_cast<unsigned long long>(value))   // two's-complement-safe abs
        : static_cast<unsigned long long>(value);
    std::vector<std::uint32_t> mag;
    while (u) { mag.push_back(static_cast<std::uint32_t>(u % CSEC_BIGINT_BASE)); u /= CSEC_BIGINT_BASE; }
    return csecBigIntAlloc(sign, std::move(mag));
}

void* csec_bigint_add(void* a, void* b) {
    return csecBigIntAddSigned(static_cast<CsecBigInt*>(a), static_cast<CsecBigInt*>(b));
}

void* csec_bigint_sub(void* a, void* b) {
    auto* bb = static_cast<CsecBigInt*>(b);
    CsecBigInt negated;                 // -b, without allocating
    negated.sign = -bb->sign;
    negated.mag = bb->mag;
    return csecBigIntAddSigned(static_cast<CsecBigInt*>(a), &negated);
}

void* csec_bigint_mul(void* a, void* b) {
    auto* aa = static_cast<CsecBigInt*>(a);
    auto* bb = static_cast<CsecBigInt*>(b);
    if (aa->sign == 0 || bb->sign == 0) return csecBigIntAlloc(0, {});
    return csecBigIntAlloc(aa->sign * bb->sign, csecMagMul(aa->mag, bb->mag));
}

int csec_bigint_cmp(void* a, void* b) {
    auto* aa = static_cast<CsecBigInt*>(a);
    auto* bb = static_cast<CsecBigInt*>(b);
    if (aa->sign != bb->sign) return aa->sign < bb->sign ? -1 : 1;
    if (aa->sign == 0) return 0;
    int c = csecMagCmp(aa->mag, bb->mag);
    return aa->sign > 0 ? c : -c;       // for negatives, larger magnitude is smaller value
}

char* csec_bigint_to_string(void* a) {
    auto* v = static_cast<CsecBigInt*>(a);
    if (!v || v->sign == 0) {
        char* z = static_cast<char*>(std::malloc(2));
        if (!z) return nullptr;
        z[0] = '0'; z[1] = '\0';
        return z;
    }
    std::string s;
    if (v->sign < 0) s.push_back('-');
    char buf[16];
    std::snprintf(buf, sizeof(buf), "%u", v->mag.back());   // top limb: no zero padding
    s += buf;
    for (std::size_t i = v->mag.size() - 1; i-- > 0;) {
        std::snprintf(buf, sizeof(buf), "%09u", v->mag[i]); // lower limbs: 9-digit padded
        s += buf;
    }
    char* result = static_cast<char*>(std::malloc(s.size() + 1));
    if (!result) return nullptr;
    std::memcpy(result, s.c_str(), s.size() + 1);
    return result;
}

}  // extern "C"
