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
CSEC_NATIVE_API void csec_release_concat_strings(void);
CSEC_NATIVE_API int csec_lex_quoted(const char* source, int index);
CSEC_NATIVE_API int csec_lex_number(const char* source, int index);
CSEC_NATIVE_API int csec_lex_identifier(const char* source, int index);
CSEC_NATIVE_API int csec_operator_length(const char* source, int index);
CSEC_NATIVE_API int csec_digit_value(char ch);
CSEC_NATIVE_API int csec_is_keyword(const char* text);
CSEC_NATIVE_API int csec_to_int(const char* text);
CSEC_NATIVE_API int csec_line_start(const char* text, int ordinal);
CSEC_NATIVE_API int csec_line_end(const char* text, int start);
CSEC_NATIVE_API int csec_validate_balanced(const char* tokens);
CSEC_NATIVE_API int csec_starts_top_level_declaration(const char* tokens, int ordinal);
CSEC_NATIVE_API int csec_validate_top_level(const char* tokens);
CSEC_NATIVE_API char* csec_top_level_decl_kind(const char* tokens, int ordinal);
CSEC_NATIVE_API char* csec_top_level_decl_name(const char* tokens, int ordinal);
CSEC_NATIVE_API int csec_count_function_params(const char* tokens, int declStart);
CSEC_NATIVE_API int csec_token_is_top_level_operator(const char* tokens, int ordinal, int group);
CSEC_NATIVE_API int csec_find_top_level_operator(const char* tokens, int start, int end, int group);
CSEC_NATIVE_API int csec_find_top_level_match(const char* tokens, int start, int end);
CSEC_NATIVE_API int csec_find_lambda_arrow(const char* tokens, int start, int end);
CSEC_NATIVE_API char* csec_generate_symbol_table(const char* tokens);
CSEC_NATIVE_API char* csec_append_expression_until(const char* tokens, int start, int end);
CSEC_NATIVE_API char* csec_generate_expression_ast(const char* tokens, int start, int end);
CSEC_NATIVE_API char* csec_generate_statement_ast(const char* tokens, int start, int end);
CSEC_NATIVE_API char* csec_generate_body_ast(const char* tokens, int bodyStart, int bodyEnd);
CSEC_NATIVE_API char* csec_generate_c_body(const char* tokens, int bodyStart, int bodyEnd, const char* indent);
CSEC_NATIVE_API char* csec_generate_c_expression(const char* tokens, int start, int end);
CSEC_NATIVE_API char* csec_ir_operator_name(const char* text);
CSEC_NATIVE_API char* csec_ir_type_name(const char* typeName);
CSEC_NATIVE_API int csec_expression_top_level_operator(const char* tokens, int start, int end);
CSEC_NATIVE_API char* csec_llvm_lexer_helper_definition(const char* name);
CSEC_NATIVE_API char* csec_statement_kind(const char* tokens, int ordinal);
CSEC_NATIVE_API char* csec_expression_leaf_kind(const char* tokens, int start, int end);
CSEC_NATIVE_API char* csec_declared_value_type(const char* tokens, int declStart, int declEnd);
CSEC_NATIVE_API char* csec_infer_expression_type(const char* tokens, int start, int end);
CSEC_NATIVE_API char* csec_declared_local_type(const char* tokens, int start, int end);
CSEC_NATIVE_API char* csec_class_member_kind(const char* tokens, int ordinal);
CSEC_NATIVE_API char* csec_class_member_name(const char* tokens, int ordinal);
CSEC_NATIVE_API int csec_parse_return_integer_in_range(const char* tokens, int start, int end);
CSEC_NATIVE_API char* csec_c_type_name(const char* typeName);
CSEC_NATIVE_API char* csec_empty_string(void);
CSEC_NATIVE_API char* csec_generate_llvm_flat_body_i32(const char* tokens, int bodyStart, int bodyEnd);
CSEC_NATIVE_API char* csec_generate_llvm_string_literal_globals(const char* tokens);
CSEC_NATIVE_API char* csec_generate_llvm_function_definition(const char* tokens, int declStart);
CSEC_NATIVE_API int csec_generate_llvm_module_into(const char* tokens, long long builder);
CSEC_NATIVE_API char* csec_llvm_main_body_fallback(void);
CSEC_NATIVE_API char* csec_llvm_main_body(void);
CSEC_NATIVE_API char* csec_llvm_body_fallback(int kind);
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
CSEC_NATIVE_API int csec_find_token_text_in_range(const char* tokens, int start, int end, const char* text);
CSEC_NATIVE_API int csec_find_closing_token(const char* tokens, int openOrdinal, int end, const char* openText, const char* closeText);
CSEC_NATIVE_API int csec_find_statement_paren_start(const char* tokens, int start, int end);
CSEC_NATIVE_API int csec_find_statement_paren_end(const char* tokens, int start, int end);
CSEC_NATIVE_API int csec_find_statement_block_start(const char* tokens, int start, int end);
CSEC_NATIVE_API int csec_find_statement_block_end(const char* tokens, int start, int end);
CSEC_NATIVE_API int csec_count_comma_separated(const char* tokens, int start, int end);
CSEC_NATIVE_API int csec_find_last_top_level_token(const char* tokens, int start, int end, const char* text);
CSEC_NATIVE_API int csec_function_param_end(const char* tokens, int declStart);
CSEC_NATIVE_API int csec_find_function_param_start(const char* tokens, int declStart);
CSEC_NATIVE_API char* csec_function_llvm_param_list(const char* tokens, int declStart);
CSEC_NATIVE_API char* csec_function_llvm_param_allocas(const char* tokens, int declStart);
CSEC_NATIVE_API char* csec_llvm_name_with_number(const char* prefix, int number);
CSEC_NATIVE_API char* csec_llvm_string_literal_bytes(const char* text);
CSEC_NATIVE_API int csec_llvm_string_literal_byte_length(const char* text);
CSEC_NATIVE_API char* csec_function_return_type_at(const char* tokens, int declStart);
CSEC_NATIVE_API int csec_instance_call_returns_string(const char* tokens, int receiverOrdinal, int methodClose);
CSEC_NATIVE_API char* csec_collect_type_name(const char* tokens, int start, int end);
CSEC_NATIVE_API int csec_enclosing_function_decl_start(const char* tokens, int limit);
CSEC_NATIVE_API int csec_enclosing_function_body_start(const char* tokens, int limit);
CSEC_NATIVE_API int csec_enclosing_function_body_end(const char* tokens, int limit);
CSEC_NATIVE_API char* csec_lookup_function_return_type(const char* tokens, const char* name);
CSEC_NATIVE_API char* csec_lookup_visible_value_type(const char* tokens, int limit, const char* name);
CSEC_NATIVE_API char* csec_lookup_visible_storage_name(const char* tokens, int limit, const char* name);
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

// Arbitrary-precision integers backing the Nat (Gaussian integer) type. Handles
// are opaque, heap-allocated, caller-owned (leaked), like the string helpers.
CSEC_NATIVE_API void* csec_bigint_from_i64(long long value);
CSEC_NATIVE_API void* csec_bigint_from_decimal(const char* text);
CSEC_NATIVE_API void* csec_bigint_add(void* a, void* b);
CSEC_NATIVE_API void* csec_bigint_sub(void* a, void* b);
CSEC_NATIVE_API void* csec_bigint_mul(void* a, void* b);
CSEC_NATIVE_API int   csec_bigint_cmp(void* a, void* b);
CSEC_NATIVE_API char* csec_bigint_to_string(void* a);

// Tensor operations callable from the self-host compiler (csec++ inlines these instead).
CSEC_NATIVE_API void*  csec_tensor_new(long long count, double fill);
CSEC_NATIVE_API double csec_tensor_get(void* t, long long i);
CSEC_NATIVE_API void   csec_tensor_set(void* t, long long i, double v);
CSEC_NATIVE_API void*  csec_tensor_new2(long long rows, long long cols, double fill);
CSEC_NATIVE_API double csec_tensor_get2(void* t, long long i, long long j);
CSEC_NATIVE_API void   csec_tensor_set2(void* t, long long i, long long j, double v);
CSEC_NATIVE_API void*  csec_tensor_add(void* a, void* b);
CSEC_NATIVE_API void*  csec_tensor_sub(void* a, void* b);
CSEC_NATIVE_API void*  csec_tensor_mul(void* a, void* b);
CSEC_NATIVE_API void*  csec_tensor_scale(void* t, double s);
CSEC_NATIVE_API void*  csec_tensor_div_scalar(void* t, double s);
CSEC_NATIVE_API double csec_tensor_inner(void* a, void* b);
CSEC_NATIVE_API char* csec_to_string_bool(int value);
CSEC_NATIVE_API char* csec_to_string_char(char value);
CSEC_NATIVE_API char* csec_replace_dots_with_slash(const char* value);
CSEC_NATIVE_API char* csec_import_target_from_line(const char* line);
CSEC_NATIVE_API char* csec_import_candidate(const char* target);
CSEC_NATIVE_API char* csec_resolve_import_path(const char* currentPath, const char* target);

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
