#pragma once

#if defined(_WIN32)
#if defined(CSEC_NATIVE_RUNTIME_BUILD)
#define CSEC_NATIVE_API __declspec(dllexport)
#else
#define CSEC_NATIVE_API __declspec(dllimport)
#endif
#else
#define CSEC_NATIVE_API __attribute__((visibility("default")))
#endif

#ifdef __cplusplus
extern "C" {
#endif

CSEC_NATIVE_API void csec_print_string(const char* value);
CSEC_NATIVE_API void csec_print_i64(long long value);
CSEC_NATIVE_API void csec_print_double(double value);
CSEC_NATIVE_API void csec_print_bool(int value);
CSEC_NATIVE_API void csec_print_char(char value);
CSEC_NATIVE_API void csec_print_newline(void);

CSEC_NATIVE_API char* csec_read_line(void);
CSEC_NATIVE_API char csec_read_char(void);
CSEC_NATIVE_API int csec_read_int(void);
CSEC_NATIVE_API double csec_read_double(void);

CSEC_NATIVE_API double csec_math_sin(double value);
CSEC_NATIVE_API double csec_math_cos(double value);
CSEC_NATIVE_API double csec_math_tan(double value);
CSEC_NATIVE_API double csec_math_cot(double value);
CSEC_NATIVE_API double csec_math_sec(double value);
CSEC_NATIVE_API double csec_math_csc(double value);
CSEC_NATIVE_API double csec_math_asin(double value);
CSEC_NATIVE_API double csec_math_acos(double value);
CSEC_NATIVE_API double csec_math_atan(double value);
CSEC_NATIVE_API double csec_math_sinh(double value);
CSEC_NATIVE_API double csec_math_cosh(double value);
CSEC_NATIVE_API double csec_math_tanh(double value);
CSEC_NATIVE_API double csec_math_coth(double value);
CSEC_NATIVE_API double csec_math_sqrt(double value);
CSEC_NATIVE_API double csec_math_log(double value);
CSEC_NATIVE_API double csec_math_log10(double value);
CSEC_NATIVE_API double csec_math_log_base(double base, double value);
CSEC_NATIVE_API double csec_math_exp(double value);
CSEC_NATIVE_API double csec_math_pow(double base, double exponent);
CSEC_NATIVE_API double csec_math_frac(double numerator, double denominator);
CSEC_NATIVE_API double csec_math_binom(double n, double k);
CSEC_NATIVE_API double csec_math_min(double left, double right);
CSEC_NATIVE_API double csec_math_max(double left, double right);
CSEC_NATIVE_API double csec_math_gcd(double left, double right);

CSEC_NATIVE_API long long csec_tcp_connect(const char* host, int port);
CSEC_NATIVE_API int csec_tcp_send(long long socket_handle, const char* data);
CSEC_NATIVE_API char* csec_tcp_recv(long long socket_handle, int max_bytes);
CSEC_NATIVE_API int csec_tcp_close(long long socket_handle);

#ifdef __cplusplus
}
#endif
