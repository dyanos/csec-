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

define i32 @MathConstants_getPi() {
entry:
  %pi.addr.3 = alloca i32
  %object.pi.addr.3 = add i32 0, 3
  store i32 %object.pi.addr.3, ptr %pi.addr.3
  %e.addr.10 = alloca i32
  %object.e.addr.10 = add i32 0, 2
  store i32 %object.e.addr.10, ptr %e.addr.10
  %phi.addr.17 = alloca i32
  %object.phi.addr.17 = add i32 0, 1
  store i32 %object.phi.addr.17, ptr %phi.addr.17
  %ret = load i32, ptr %pi.addr.3
  ret i32 %ret
}

define i32 @MathConstants_getE() {
entry:
  %pi.addr.3 = alloca i32
  %object.pi.addr.3 = add i32 0, 3
  store i32 %object.pi.addr.3, ptr %pi.addr.3
  %e.addr.10 = alloca i32
  %object.e.addr.10 = add i32 0, 2
  store i32 %object.e.addr.10, ptr %e.addr.10
  %phi.addr.17 = alloca i32
  %object.phi.addr.17 = add i32 0, 1
  store i32 %object.phi.addr.17, ptr %phi.addr.17
  %ret = load i32, ptr %e.addr.10
  ret i32 %ret
}

define i32 @MathConstants_sum() {
entry:
  %pi.addr.3 = alloca i32
  %object.pi.addr.3 = add i32 0, 3
  store i32 %object.pi.addr.3, ptr %pi.addr.3
  %e.addr.10 = alloca i32
  %object.e.addr.10 = add i32 0, 2
  store i32 %object.e.addr.10, ptr %e.addr.10
  %phi.addr.17 = alloca i32
  %object.phi.addr.17 = add i32 0, 1
  store i32 %object.phi.addr.17, ptr %phi.addr.17
  %ret.left.left = load i32, ptr %pi.addr.3
  %ret.left.right = load i32, ptr %e.addr.10
  %ret.left = add i32 %ret.left.left, %ret.left.right
  %ret.right = load i32, ptr %phi.addr.17
  %ret = add i32 %ret.left, %ret.right
  ret i32 %ret
}

define i32 @Counter_increment() {
entry:
  %count.addr.56 = alloca i32
  %object.count.addr.56 = add i32 0, 0
  store i32 %object.count.addr.56, ptr %count.addr.56
  %count.assign.70.left = load i32, ptr %count.addr.56
  %count.assign.70.right = add i32 0, 1
  %count.assign.70 = add i32 %count.assign.70.left, %count.assign.70.right
  store i32 %count.assign.70, ptr %count.addr.56
  %ret.76 = load i32, ptr %count.addr.56
  ret i32 %ret.76
}

define i32 @Counter_reset() {
entry:
  %count.addr.56 = alloca i32
  %object.count.addr.56 = add i32 0, 0
  store i32 %object.count.addr.56, ptr %count.addr.56
  %count.assign.87 = add i32 0, 0
  store i32 %count.assign.87, ptr %count.addr.56
  %ret.91 = load i32, ptr %count.addr.56
  ret i32 %ret.91
}

define i32 @csec_user_main() {
entry:
  %ret = call i32 @MathConstants_sum()
  ret i32 %ret
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

