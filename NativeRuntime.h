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

CSEC_NATIVE_API double csec_sim_md_lennard_jones(int atom_count, int bond_count, int steps, double dt, double temperature);
CSEC_NATIVE_API double csec_sim_cfd_lid_cavity(int width, int height, int steps, double dt, double viscosity, double lid_velocity);
CSEC_NATIVE_API double csec_sim_protein_mcmc(int residue_count, int steps, double temperature);

CSEC_NATIVE_API int csec_parallel_get_num_threads(void);
CSEC_NATIVE_API void csec_parallel_set_num_threads(int count);
CSEC_NATIVE_API int csec_parallel_backend_available(const char* name);
CSEC_NATIVE_API int csec_parallel_backend_implemented(const char* name);
typedef void (*csec_parallel_for_i32_fn)(void* context, int index);
CSEC_NATIVE_API void csec_parallel_for_i32(int start, int end, void* context, csec_parallel_for_i32_fn callback);

CSEC_NATIVE_API long long csec_tcp_connect(const char* host, int port);
CSEC_NATIVE_API int csec_tcp_send(long long socket_handle, const char* data);
CSEC_NATIVE_API char* csec_tcp_recv(long long socket_handle, int max_bytes);
CSEC_NATIVE_API int csec_tcp_close(long long socket_handle);

CSEC_NATIVE_API int csec_posix_open(const char* path, int flags, int mode);
CSEC_NATIVE_API char* csec_posix_read(int fd, int max_bytes);
CSEC_NATIVE_API int csec_posix_write(int fd, const char* data);
CSEC_NATIVE_API int csec_posix_close(int fd);
CSEC_NATIVE_API long long csec_posix_lseek(int fd, long long offset, int whence);
CSEC_NATIVE_API int csec_posix_unlink(const char* path);
CSEC_NATIVE_API int csec_posix_rename(const char* old_path, const char* new_path);
CSEC_NATIVE_API int csec_posix_mkdir(const char* path, int mode);
CSEC_NATIVE_API int csec_posix_rmdir(const char* path);
CSEC_NATIVE_API int csec_posix_chdir(const char* path);
CSEC_NATIVE_API char* csec_posix_getcwd(void);
CSEC_NATIVE_API int csec_posix_access(const char* path, int mode);
CSEC_NATIVE_API char* csec_posix_getenv(const char* name);
CSEC_NATIVE_API int csec_posix_setenv(const char* name, const char* value, int overwrite);
CSEC_NATIVE_API int csec_posix_unsetenv(const char* name);
CSEC_NATIVE_API int csec_posix_sleep(int seconds);
CSEC_NATIVE_API long long csec_posix_time(void);
CSEC_NATIVE_API int csec_posix_errno(void);

CSEC_NATIVE_API int csec_posix_flag_read_only(void);
CSEC_NATIVE_API int csec_posix_flag_write_only(void);
CSEC_NATIVE_API int csec_posix_flag_read_write(void);
CSEC_NATIVE_API int csec_posix_flag_create(void);
CSEC_NATIVE_API int csec_posix_flag_truncate(void);
CSEC_NATIVE_API int csec_posix_flag_append(void);
CSEC_NATIVE_API int csec_posix_seek_set(void);
CSEC_NATIVE_API int csec_posix_seek_cur(void);
CSEC_NATIVE_API int csec_posix_seek_end(void);
CSEC_NATIVE_API int csec_posix_access_exists(void);
CSEC_NATIVE_API int csec_posix_access_read(void);
CSEC_NATIVE_API int csec_posix_access_write(void);
CSEC_NATIVE_API int csec_posix_access_execute(void);

#ifdef __cplusplus
}
#endif
