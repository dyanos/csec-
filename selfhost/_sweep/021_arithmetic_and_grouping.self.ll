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
  %value.addr.7 = alloca i32
  %value.init.7.left.left = add i32 0, 1
  %value.init.7.left.right = add i32 0, 2
  %value.init.7.left = add i32 %value.init.7.left.left, %value.init.7.left.right
  %value.init.7.right.left = add i32 0, 3
  %value.init.7.right.right = add i32 0, 4
  %value.init.7.right = add i32 %value.init.7.right.left, %value.init.7.right.right
  %value.init.7 = mul i32 %value.init.7.left, %value.init.7.right
  store i32 %value.init.7, ptr %value.addr.7
  %value.assign.24.left = load i32, ptr %value.addr.7
  %value.assign.24.right = add i32 0, 7
  %value.assign.24 = sdiv i32 %value.assign.24.left, %value.assign.24.right
  store i32 %value.assign.24, ptr %value.addr.7
  %value.assign.30.left = load i32, ptr %value.addr.7
  %value.assign.30.right = add i32 0, 5
  %value.assign.30 = srem i32 %value.assign.30.left, %value.assign.30.right
  store i32 %value.assign.30, ptr %value.addr.7
  %value.assign.36.left = load i32, ptr %value.addr.7
  %value.assign.36.right.value = add i32 0, 1
  %value.assign.36.right = sub i32 0, %value.assign.36.right.value
  %value.assign.36 = add i32 %value.assign.36.left, %value.assign.36.right
  store i32 %value.assign.36, ptr %value.addr.7
  %ret.43 = load i32, ptr %value.addr.7
  ret i32 %ret.43
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

