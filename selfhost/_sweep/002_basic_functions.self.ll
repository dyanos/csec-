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

define i32 @add(i32 %arg.a, i32 %arg.b) {
entry:
  %a = alloca i32
  store i32 %arg.a, ptr %a
  %b = alloca i32
  store i32 %arg.b, ptr %b
  %ret.left = load i32, ptr %a
  %ret.right = load i32, ptr %b
  %ret = add i32 %ret.left, %ret.right
  ret i32 %ret
}

define i32 @sub(i32 %arg.a, i32 %arg.b) {
entry:
  %a = alloca i32
  store i32 %arg.a, ptr %a
  %b = alloca i32
  store i32 %arg.b, ptr %b
  %ret.left = load i32, ptr %a
  %ret.right = load i32, ptr %b
  %ret = sub i32 %ret.left, %ret.right
  ret i32 %ret
}

define i32 @mul(i32 %arg.a, i32 %arg.b) {
entry:
  %a = alloca i32
  store i32 %arg.a, ptr %a
  %b = alloca i32
  store i32 %arg.b, ptr %b
  %ret.left = load i32, ptr %a
  %ret.right = load i32, ptr %b
  %ret = mul i32 %ret.left, %ret.right
  ret i32 %ret
}

define i32 @csec_user_main() {
entry:
  %result.addr.58 = alloca i32
  %result.init.58.arg0 = add i32 0, 4
  %result.init.58.arg1 = add i32 0, 5
  %result.init.58 = call i32 @add(i32 %result.init.58.arg0, i32 %result.init.58.arg1)
  store i32 %result.init.58, ptr %result.addr.58
  %result.assign.70.left = load i32, ptr %result.addr.58
  %result.assign.70.right.arg0 = add i32 0, 10
  %result.assign.70.right.arg1 = add i32 0, 3
  %result.assign.70.right = call i32 @sub(i32 %result.assign.70.right.arg0, i32 %result.assign.70.right.arg1)
  %result.assign.70 = add i32 %result.assign.70.left, %result.assign.70.right
  store i32 %result.assign.70, ptr %result.addr.58
  %result.assign.81.left = load i32, ptr %result.addr.58
  %result.assign.81.right.arg0 = add i32 0, 2
  %result.assign.81.right.arg1 = add i32 0, 3
  %result.assign.81.right = call i32 @mul(i32 %result.assign.81.right.arg0, i32 %result.assign.81.right.arg1)
  %result.assign.81 = add i32 %result.assign.81.left, %result.assign.81.right
  store i32 %result.assign.81, ptr %result.addr.58
  %ret.92 = load i32, ptr %result.addr.58
  ret i32 %ret.92
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

