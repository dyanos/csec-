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

CSEC_NATIVE_API char* csec_string_concat(const char* left, const char* right);
CSEC_NATIVE_API int csec_lex_quoted(const char* source, int index);
CSEC_NATIVE_API int csec_lex_number(const char* source, int index);
CSEC_NATIVE_API int csec_lex_identifier(const char* source, int index);
CSEC_NATIVE_API int csec_digit_value(char ch);
CSEC_NATIVE_API char* csec_llvm_lexer_helper_definition(const char* name);
CSEC_NATIVE_API int csec_lex_line_comment(const char* source, int index);
CSEC_NATIVE_API int csec_lex_block_comment(const char* source, int index);
CSEC_NATIVE_API long long csec_string_builder_new(void);
CSEC_NATIVE_API long long csec_string_builder_new_file(const char* path);
CSEC_NATIVE_API int csec_string_builder_append(long long handle, const char* text);
CSEC_NATIVE_API char* csec_string_builder_finish(long long handle);
CSEC_NATIVE_API int csec_string_builder_write_to_file(long long handle, const char* path);
CSEC_NATIVE_API char* csec_token_append_owned(const char* tokens, char kind, const char* text);
CSEC_NATIVE_API long long csec_token_builder_new(void);
CSEC_NATIVE_API int csec_token_builder_append(long long handle, char kind, const char* text);
CSEC_NATIVE_API char* csec_token_builder_finish(long long handle);
CSEC_NATIVE_API char* csec_tokenize_source(const char* sourceText);
CSEC_NATIVE_API char csec_token_kind_at(const char* tokens, int ordinal);
CSEC_NATIVE_API char* csec_token_text_at(const char* tokens, int ordinal);
CSEC_NATIVE_API int csec_token_is(const char* tokens, int ordinal, char kind, const char* text);
CSEC_NATIVE_API int csec_advance_statement(const char* tokens, int ordinal, int bodyEnd);
CSEC_NATIVE_API int csec_advance_top_level_decl(const char* tokens, int ordinal);
CSEC_NATIVE_API int csec_find_decl_body_start(const char* tokens, int ordinal);
CSEC_NATIVE_API int csec_find_decl_body_end(const char* tokens, int bodyStart);
CSEC_NATIVE_API int csec_function_param_end(const char* tokens, int declStart);
CSEC_NATIVE_API char* csec_function_llvm_param_list(const char* tokens, int declStart);
CSEC_NATIVE_API char* csec_function_llvm_param_allocas(const char* tokens, int declStart);
CSEC_NATIVE_API char* csec_llvm_name_with_number(const char* prefix, int number);
CSEC_NATIVE_API char* csec_llvm_string_literal_bytes(const char* text);
CSEC_NATIVE_API char* csec_function_return_type_at(const char* tokens, int declStart);
CSEC_NATIVE_API int csec_enclosing_function_decl_start(const char* tokens, int limit);
CSEC_NATIVE_API int csec_enclosing_function_body_start(const char* tokens, int limit);
CSEC_NATIVE_API int csec_enclosing_function_body_end(const char* tokens, int limit);
CSEC_NATIVE_API char* csec_lookup_function_return_type(const char* tokens, const char* name);
CSEC_NATIVE_API long long csec_string_length(const char* value);
CSEC_NATIVE_API int csec_string_is_empty(const char* value);
CSEC_NATIVE_API int csec_string_contains(const char* value, const char* needle);
CSEC_NATIVE_API int csec_string_equals(const char* left, const char* right);
CSEC_NATIVE_API int csec_string_regex_match(const char* value, const char* pattern);
CSEC_NATIVE_API int csec_string_starts_with(const char* value, const char* prefix);
CSEC_NATIVE_API int csec_string_ends_with(const char* value, const char* suffix);
CSEC_NATIVE_API long long csec_string_index_of(const char* value, const char* needle);
CSEC_NATIVE_API char csec_string_char_at(const char* value, int index);
CSEC_NATIVE_API char* csec_string_substring(const char* value, int start, int length);
CSEC_NATIVE_API char* csec_string_to_upper(const char* value);
CSEC_NATIVE_API char* csec_string_to_lower(const char* value);
CSEC_NATIVE_API char* csec_string_trim(const char* value);
CSEC_NATIVE_API char* csec_to_string_i64(long long value);
CSEC_NATIVE_API char* csec_to_string_double(double value);
CSEC_NATIVE_API char* csec_to_string_bool(int value);
CSEC_NATIVE_API char* csec_to_string_char(char value);

CSEC_NATIVE_API char* csec_read_line(void);
CSEC_NATIVE_API char csec_read_char(void);
CSEC_NATIVE_API int csec_read_int(void);
CSEC_NATIVE_API double csec_read_double(void);
CSEC_NATIVE_API void csec_set_command_line_args(int argc, char** argv);
CSEC_NATIVE_API int csec_command_line_arg_count(void);
CSEC_NATIVE_API char* csec_command_line_arg(int index);

CSEC_NATIVE_API char* csec_file_read_all_text(const char* path);
CSEC_NATIVE_API int csec_file_write_all_text(const char* path, const char* text);
CSEC_NATIVE_API int csec_file_append_all_text(const char* path, const char* text);
CSEC_NATIVE_API int csec_file_exists(const char* path);
CSEC_NATIVE_API int csec_file_delete(const char* path);
CSEC_NATIVE_API char* csec_expand_imports(const char* path);

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
CSEC_NATIVE_API double csec_math_abs(double value);
CSEC_NATIVE_API double csec_math_sign(double value);
CSEC_NATIVE_API double csec_math_floor(double value);
CSEC_NATIVE_API double csec_math_ceil(double value);
CSEC_NATIVE_API double csec_math_round(double value);
CSEC_NATIVE_API double csec_math_lcm(double left, double right);
CSEC_NATIVE_API long long csec_set_cardinality(long long value);

CSEC_NATIVE_API double csec_sim_md_lennard_jones(int atom_count, int bond_count, int steps, double dt, double temperature);
CSEC_NATIVE_API double csec_sim_cfd_lid_cavity(int width, int height, int steps, double dt, double viscosity, double lid_velocity);
CSEC_NATIVE_API double csec_sim_protein_mcmc(int residue_count, int steps, double temperature);
CSEC_NATIVE_API double csec_sim_black_hole_merge(double mass1, double mass2, double separation, double relative_velocity, int steps, double dt);

CSEC_NATIVE_API int csec_parallel_get_num_threads(void);
CSEC_NATIVE_API void csec_parallel_set_num_threads(int count);
CSEC_NATIVE_API int csec_parallel_backend_available(const char* name);
CSEC_NATIVE_API int csec_parallel_backend_implemented(const char* name);
typedef void (*csec_parallel_for_i32_fn)(void* context, int index);
CSEC_NATIVE_API void csec_parallel_for_i32(int start, int end, void* context, csec_parallel_for_i32_fn callback);

CSEC_NATIVE_API long long csec_tcp_connect(const char* host, int port);
CSEC_NATIVE_API long long csec_tcp_listen(const char* host, int port, int backlog);
CSEC_NATIVE_API long long csec_tcp_accept(long long socket_handle);
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

CSEC_NATIVE_API long long csec_load_library(const char* path);
CSEC_NATIVE_API long long csec_get_symbol(long long library_handle, const char* symbol_name);
CSEC_NATIVE_API int csec_close_library(long long library_handle);
CSEC_NATIVE_API long long csec_call_native0(long long symbol);
CSEC_NATIVE_API long long csec_call_native1(long long symbol, long long arg0);
CSEC_NATIVE_API long long csec_call_native2(long long symbol, long long arg0, long long arg1);
CSEC_NATIVE_API long long csec_call_native3(long long symbol, long long arg0, long long arg1, long long arg2);
CSEC_NATIVE_API double csec_call_native_double0(long long symbol);
CSEC_NATIVE_API double csec_call_native_double1(long long symbol, double arg0);
CSEC_NATIVE_API double csec_call_native_double2(long long symbol, double arg0, double arg1);
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
