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

define i32 @doubleAll(ptr %arg.xs) {
entry:
  %xs = alloca ptr
  store ptr %arg.xs, ptr %xs
  %ret.25 = add i32 0, 0
  ret i32 %ret.25
}

define i32 @sumAll(ptr %arg.xs) {
entry:
  %xs = alloca ptr
  store ptr %arg.xs, ptr %xs
  %ret.56 = add i32 0, 0
  ret i32 %ret.56
}

define i32 @keepPositive(ptr %arg.xs) {
entry:
  %xs = alloca ptr
  store ptr %arg.xs, ptr %xs
  %ret.85 = add i32 0, 0
  ret i32 %ret.85
}

define i32 @csec_user_main() {
entry:
  %data.addr.96 = alloca ptr
  %data.count.96 = add i32 0, 5
  %data.data.96 = alloca i32, i32 %data.count.96
  store ptr %data.data.96, ptr %data.addr.96
  %data.item.96.0 = add i32 0, 1
  %data.element.96.0 = getelementptr inbounds i32, ptr %data.data.96, i32 0
  store i32 %data.item.96.0, ptr %data.element.96.0
  %data.item.96.1 = add i32 0, 2
  %data.element.96.1 = getelementptr inbounds i32, ptr %data.data.96, i32 1
  store i32 %data.item.96.1, ptr %data.element.96.1
  %data.item.96.2 = add i32 0, 3
  %data.element.96.2 = getelementptr inbounds i32, ptr %data.data.96, i32 2
  store i32 %data.item.96.2, ptr %data.element.96.2
  %data.item.96.3 = add i32 0, 4
  %data.element.96.3 = getelementptr inbounds i32, ptr %data.data.96, i32 3
  store i32 %data.item.96.3, ptr %data.element.96.3
  %data.item.96.4 = add i32 0, 5
  %data.element.96.4 = getelementptr inbounds i32, ptr %data.data.96, i32 4
  store i32 %data.item.96.4, ptr %data.element.96.4
  %discard.111.arg0 = load ptr, ptr %data.addr.96
  %discard.111 = call i32 @doubleAll(ptr %discard.111.arg0)
  %discard.116.arg0 = load ptr, ptr %data.addr.96
  %discard.116 = call i32 @sumAll(ptr %discard.116.arg0)
  %discard.121.arg0 = load ptr, ptr %data.addr.96
  %discard.121 = call i32 @keepPositive(ptr %discard.121.arg0)
  %ret.126 = add i32 0, 0
  ret i32 %ret.126
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

