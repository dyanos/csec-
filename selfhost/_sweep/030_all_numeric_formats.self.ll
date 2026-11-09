; ModuleID = 'csec.selfhost'
source_filename = "csec.selfhost"

declare ptr @csec_append_expression_until(ptr, i32, i32)
declare ptr @csec_generate_symbol_table(ptr)
declare ptr @csec_ir_type_name(ptr)
declare ptr @csec_collect_type_name(ptr, i32, i32)
declare ptr @csec_lookup_visible_value_type(ptr, i32, ptr)
declare ptr @csec_lookup_visible_storage_name(ptr, i32, ptr)
declare i32 @csec_find_function_param_start(ptr, i32)
declare i32 @csec_count_comma_separated(ptr, i32, i32)
declare i32 @csec_count_function_params(ptr, i32)
declare i32 @csec_expression_top_level_operator(ptr, i32, i32)
declare i32 @csec_find_closing_token(ptr, i32, i32, ptr, ptr)
declare i32 @csec_find_last_top_level_token(ptr, i32, i32, ptr)
declare i32 @csec_find_statement_block_end(ptr, i32, i32)
declare i32 @csec_find_statement_block_start(ptr, i32, i32)
declare i32 @csec_find_statement_paren_end(ptr, i32, i32)
declare i32 @csec_find_statement_paren_start(ptr, i32, i32)
declare i32 @csec_find_token_text_in_range(ptr, i32, i32, ptr)
declare i32 @csec_find_top_level_match(ptr, i32, i32)
declare i32 @csec_find_top_level_operator(ptr, i32, i32, i32)
declare ptr @csec_generate_body_ast(ptr, i32, i32)
declare ptr @csec_generate_c_body(ptr, i32, i32, ptr)
declare ptr @csec_generate_c_expression(ptr, i32, i32)
declare ptr @csec_generate_expression_ast(ptr, i32, i32)
declare ptr @csec_generate_statement_ast(ptr, i32, i32)
declare ptr @csec_ir_operator_name(ptr)
declare i32 @csec_is_keyword(ptr)
declare i32 @csec_line_end(ptr, i32)
declare i32 @csec_line_start(ptr, i32)
declare i32 @csec_starts_top_level_declaration(ptr, i32)
declare i8 @csec_string_char_at(ptr, i32)
declare ptr @csec_string_concat(ptr, ptr)
declare i32 @csec_string_contains(ptr, ptr)
declare i32 @csec_string_ends_with(ptr, ptr)
declare i32 @csec_string_equals(ptr, ptr)
declare i64 @csec_string_index_of(ptr, ptr)
declare i32 @csec_string_is_empty(ptr)
declare i64 @csec_string_length(ptr)
declare i32 @csec_string_starts_with(ptr, ptr)
declare ptr @csec_string_substring(ptr, i32, i32)
declare ptr @csec_string_to_lower(ptr)
declare ptr @csec_string_to_upper(ptr)
declare ptr @csec_string_trim(ptr)
declare void @csec_print_i64(i64)
declare void @csec_print_newline()
declare void @csec_print_string(ptr)
declare i32 @csec_command_line_arg_count()
declare ptr @csec_command_line_arg(i32)
declare i32 @csec_to_int(ptr)
declare ptr @csec_to_string_char(i8)
declare ptr @csec_to_string_i64(i64)
declare i32 @csec_token_is_top_level_operator(ptr, i32, i32)
declare ptr @csec_top_level_decl_kind(ptr, i32)
declare ptr @csec_top_level_decl_name(ptr, i32)
declare i32 @csec_validate_balanced(ptr)
declare i32 @csec_validate_top_level(ptr)

define i32 @csec_user_main() {
entry:
  %d1.addr.7 = alloca i32
  %d1.init.7 = add i32 0, 0
  store i32 %d1.init.7, ptr %d1.addr.7
  %d2.addr.12 = alloca i32
  %d2.init.12 = add i32 0, 1
  store i32 %d2.init.12, ptr %d2.addr.12
  %d3.addr.17 = alloca i32
  %d3.init.17 = add i32 0, 42
  store i32 %d3.init.17, ptr %d3.addr.17
  %d4.addr.22 = alloca i32
  %d4.init.22 = add i32 0, 999999
  store i32 %d4.init.22, ptr %d4.addr.22
  %h1.addr.27 = alloca i32
  %h1.init.27 = add i32 0, 0
  store i32 %h1.init.27, ptr %h1.addr.27
  %h2.addr.32 = alloca i32
  %h2.init.32 = add i32 0, 255
  store i32 %h2.init.32, ptr %h2.addr.32
  %h3.addr.37 = alloca i32
  %h3.init.37 = add i32 0, 6699
  store i32 %h3.init.37, ptr %h3.addr.37
  %h4.addr.42 = alloca i32
  %h4.init.42 = add i32 0, 43981
  store i32 %h4.init.42, ptr %h4.addr.42
  %b1.addr.47 = alloca i32
  %b1.init.47 = add i32 0, 0
  store i32 %b1.init.47, ptr %b1.addr.47
  %b2.addr.52 = alloca i32
  %b2.init.52 = add i32 0, 1
  store i32 %b2.init.52, ptr %b2.addr.52
  %b3.addr.57 = alloca i32
  %b3.init.57 = add i32 0, 42
  store i32 %b3.init.57, ptr %b3.addr.57
  %b4.addr.62 = alloca i32
  %b4.init.62 = add i32 0, 255
  store i32 %b4.init.62, ptr %b4.addr.62
  %o1.addr.67 = alloca i32
  %o1.init.67 = add i32 0, 0
  store i32 %o1.init.67, ptr %o1.addr.67
  %o2.addr.72 = alloca i32
  %o2.init.72 = add i32 0, 0
  store i32 %o2.init.72, ptr %o2.addr.72
  %o3.addr.77 = alloca i32
  %o3.init.77 = add i32 0, 0
  store i32 %o3.init.77, ptr %o3.addr.77
  %o4.addr.82 = alloca i32
  %o4.init.82 = add i32 0, 0
  store i32 %o4.init.82, ptr %o4.addr.82
  %f1.addr.87 = alloca double
  %f1.init.87 = fadd double 0.000000e+00, 0x0000000000000000
  store double %f1.init.87, ptr %f1.addr.87
  %f2.addr.92 = alloca double
  %f2.init.92 = fadd double 0.000000e+00, 0x40091EB851EB851F
  store double %f2.init.92, ptr %f2.addr.92
  %f3.addr.97 = alloca double
  %f3.init.97 = fadd double 0.000000e+00, 0x3F50624DD2F1A9FC
  store double %f3.init.97, ptr %f3.addr.97
  %e1.addr.102 = alloca double
  %e1.init.102 = fadd double 0.000000e+00, 0x408F400000000000
  store double %e1.init.102, ptr %e1.addr.102
  %e2.addr.107 = alloca double
  %e2.init.107 = fadd double 0.000000e+00, 0x42174876E8000000
  store double %e2.init.107, ptr %e2.addr.107
  %e3.addr.112 = alloca double
  %e3.init.112.left = fadd double 0.000000e+00, 0x3FF0000000000000
  %e3.init.112.right = fadd double 0.000000e+00, 0x4008000000000000
  %e3.init.112 = fsub double %e3.init.112.left, %e3.init.112.right
  store double %e3.init.112, ptr %e3.addr.112
  %e4.addr.119 = alloca double
  %e4.init.119.left = fadd double 0.000000e+00, 0x402399999999999A
  %e4.init.119.right = fadd double 0.000000e+00, 0x4000000000000000
  %e4.init.119 = fadd double %e4.init.119.left, %e4.init.119.right
  store double %e4.init.119, ptr %e4.addr.119
  %ret.126 = load i32, ptr %d3.addr.17
  ret i32 %ret.126
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

