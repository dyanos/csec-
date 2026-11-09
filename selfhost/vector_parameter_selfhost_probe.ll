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
declare i32 @csec_string_equals(ptr, ptr)
declare i64 @csec_string_length(ptr)
declare i32 @csec_string_starts_with(ptr, ptr)
declare ptr @csec_string_substring(ptr, i32, i32)
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

define i32 @pairSum(ptr %arg.values) {
entry:
  %values = alloca ptr
  store ptr %arg.values, ptr %values
  %ret.13.left.index = add i32 0, 0
  %ret.13.left.data = load ptr, ptr %values
  %ret.13.left.element = getelementptr inbounds i32, ptr %ret.13.left.data, i32 %ret.13.left.index
  %ret.13.left = load i32, ptr %ret.13.left.element
  %ret.13.right.index = add i32 0, 1
  %ret.13.right.data = load ptr, ptr %values
  %ret.13.right.element = getelementptr inbounds i32, ptr %ret.13.right.data, i32 %ret.13.right.index
  %ret.13.right = load i32, ptr %ret.13.right.element
  %ret.13 = add i32 %ret.13.left, %ret.13.right
  ret i32 %ret.13
}

define i32 @csec_user_main() {
entry:
  %values.addr.32 = alloca ptr
  %values.count.32 = add i32 0, 3
  %values.data.32 = alloca i32, i32 %values.count.32
  store ptr %values.data.32, ptr %values.addr.32
  %values.item.32.0 = add i32 0, 19
  %values.element.32.0 = getelementptr inbounds i32, ptr %values.data.32, i32 0
  store i32 %values.item.32.0, ptr %values.element.32.0
  %values.item.32.1 = add i32 0, 23
  %values.element.32.1 = getelementptr inbounds i32, ptr %values.data.32, i32 1
  store i32 %values.item.32.1, ptr %values.element.32.1
  %values.item.32.2 = add i32 0, 99
  %values.element.32.2 = getelementptr inbounds i32, ptr %values.data.32, i32 2
  store i32 %values.item.32.2, ptr %values.element.32.2
  %ret.43.arg0 = load ptr, ptr %values.addr.32
  %ret.43 = call i32 @pairSum(ptr %ret.43.arg0)
  ret i32 %ret.43
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

