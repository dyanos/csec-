// ============================================================================
//  tensor_runtime.inc  --  tensor operations callable from the self-host compiler
//
//  csec++ lowers tensor arithmetic as inline IR (TensorRuntime.h). The self-host
//  compiler emits IR by string-building and cannot practically inline those
//  loops, so it calls these runtime helpers instead. The struct layout matches
//  csec++'s  %csec.tensor { i64 rank, i64* dims, i64 count, double* data }  so a
//  handle is interchangeable. Handles are heap objects, caller-owned (leaked),
//  like the string and bigint helpers.
// ============================================================================

namespace {
struct CsecTensor {
    long long rank;
    long long* dims;
    long long count;
    double* data;
};

CsecTensor* csecTensorAlloc(long long rank, long long count) {
    auto* t = static_cast<CsecTensor*>(std::malloc(sizeof(CsecTensor)));
    if (!t) return nullptr;
    t->rank = rank;
    t->count = count;
    t->dims = static_cast<long long*>(std::malloc(sizeof(long long) * static_cast<size_t>(rank > 0 ? rank : 1)));
    t->data = static_cast<double*>(std::malloc(sizeof(double) * static_cast<size_t>(count > 0 ? count : 1)));
    return t;
}

CsecTensor* csecTensorLike(const CsecTensor* src) {
    CsecTensor* r = csecTensorAlloc(src->rank, src->count);
    for (long long i = 0; i < src->rank; ++i) r->dims[i] = src->dims[i];
    return r;
}
}  // namespace

extern "C" {

// Create a flat tensor of `count` elements, every element initialised to `fill`. For a rank-1 vector
// `count` is the length; a higher-rank tensor is stored flat with `count` = product of its dimensions.
void* csec_tensor_new(long long count, double fill) {
    if (count < 0) count = 0;
    CsecTensor* t = csecTensorAlloc(1, count);
    t->dims[0] = count;
    for (long long i = 0; i < count; ++i) t->data[i] = fill;
    return t;
}

double csec_tensor_get(void* tp, long long i) {
    auto* t = static_cast<CsecTensor*>(tp);
    if (!t || i < 0 || i >= t->count) return 0.0;
    return t->data[i];
}

// Rank-2 (matrix) tensor: `rows x cols`, stored flat row-major.
void* csec_tensor_new2(long long rows, long long cols, double fill) {
    if (rows < 0) rows = 0;
    if (cols < 0) cols = 0;
    long long count = rows * cols;
    CsecTensor* t = csecTensorAlloc(2, count);
    if (t->rank >= 2) { t->dims[0] = rows; t->dims[1] = cols; }
    for (long long i = 0; i < count; ++i) t->data[i] = fill;
    return t;
}

double csec_tensor_get2(void* tp, long long i, long long j) {
    auto* t = static_cast<CsecTensor*>(tp);
    if (!t) return 0.0;
    long long cols = t->rank >= 2 ? t->dims[1] : 1;
    long long idx = i * cols + j;
    if (idx < 0 || idx >= t->count) return 0.0;
    return t->data[idx];
}

void csec_tensor_set2(void* tp, long long i, long long j, double v) {
    auto* t = static_cast<CsecTensor*>(tp);
    if (!t) return;
    long long cols = t->rank >= 2 ? t->dims[1] : 1;
    long long idx = i * cols + j;
    if (idx < 0 || idx >= t->count) return;
    t->data[idx] = v;
}

void csec_tensor_set(void* tp, long long i, double v) {
    auto* t = static_cast<CsecTensor*>(tp);
    if (!t || i < 0 || i >= t->count) return;
    t->data[i] = v;
}

void* csec_tensor_add(void* ap, void* bp) {
    auto* a = static_cast<CsecTensor*>(ap);
    auto* b = static_cast<CsecTensor*>(bp);
    CsecTensor* r = csecTensorLike(a);
    for (long long i = 0; i < a->count; ++i) r->data[i] = a->data[i] + (i < b->count ? b->data[i] : 0.0);
    return r;
}

void* csec_tensor_sub(void* ap, void* bp) {
    auto* a = static_cast<CsecTensor*>(ap);
    auto* b = static_cast<CsecTensor*>(bp);
    CsecTensor* r = csecTensorLike(a);
    for (long long i = 0; i < a->count; ++i) r->data[i] = a->data[i] - (i < b->count ? b->data[i] : 0.0);
    return r;
}

// Element-wise (Hadamard) product of two equal-shaped tensors.
void* csec_tensor_mul(void* ap, void* bp) {
    auto* a = static_cast<CsecTensor*>(ap);
    auto* b = static_cast<CsecTensor*>(bp);
    CsecTensor* r = csecTensorLike(a);
    for (long long i = 0; i < a->count; ++i) r->data[i] = a->data[i] * (i < b->count ? b->data[i] : 0.0);
    return r;
}

void* csec_tensor_scale(void* tp, double s) {
    auto* t = static_cast<CsecTensor*>(tp);
    CsecTensor* r = csecTensorLike(t);
    for (long long i = 0; i < t->count; ++i) r->data[i] = t->data[i] * s;
    return r;
}

void* csec_tensor_div_scalar(void* tp, double s) {
    auto* t = static_cast<CsecTensor*>(tp);
    CsecTensor* r = csecTensorLike(t);
    for (long long i = 0; i < t->count; ++i) r->data[i] = t->data[i] / s;
    return r;
}

// Dot product (sum of element-wise products) of two equal-length tensors.
double csec_tensor_inner(void* ap, void* bp) {
    auto* a = static_cast<CsecTensor*>(ap);
    auto* b = static_cast<CsecTensor*>(bp);
    double sum = 0.0;
    long long n = a->count < b->count ? a->count : b->count;
    for (long long i = 0; i < n; ++i) sum += a->data[i] * b->data[i];
    return sum;
}

}  // extern "C"
