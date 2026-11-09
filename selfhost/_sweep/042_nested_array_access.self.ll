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
  %xs.addr.7 = alloca ptr
  %xs.count.7 = add i32 0, 5
  %xs.data.7 = alloca i32, i32 %xs.count.7
  store ptr %xs.data.7, ptr %xs.addr.7
  %xs.item.7.0 = add i32 0, 10
  %xs.element.7.0 = getelementptr inbounds i32, ptr %xs.data.7, i32 0
  store i32 %xs.item.7.0, ptr %xs.element.7.0
  %xs.item.7.1 = add i32 0, 20
  %xs.element.7.1 = getelementptr inbounds i32, ptr %xs.data.7, i32 1
  store i32 %xs.item.7.1, ptr %xs.element.7.1
  %xs.item.7.2 = add i32 0, 30
  %xs.element.7.2 = getelementptr inbounds i32, ptr %xs.data.7, i32 2
  store i32 %xs.item.7.2, ptr %xs.element.7.2
  %xs.item.7.3 = add i32 0, 40
  %xs.element.7.3 = getelementptr inbounds i32, ptr %xs.data.7, i32 3
  store i32 %xs.item.7.3, ptr %xs.element.7.3
  %xs.item.7.4 = add i32 0, 50
  %xs.element.7.4 = getelementptr inbounds i32, ptr %xs.data.7, i32 4
  store i32 %xs.item.7.4, ptr %xs.element.7.4
  %ys.addr.22 = alloca ptr
  %ys.count.22 = add i32 0, 4
  %ys.data.22 = alloca i32, i32 %ys.count.22
  store ptr %ys.data.22, ptr %ys.addr.22
  %ys.item.22.0 = add i32 0, 0
  %ys.element.22.0 = getelementptr inbounds i32, ptr %ys.data.22, i32 0
  store i32 %ys.item.22.0, ptr %ys.element.22.0
  %ys.item.22.1 = add i32 0, 0
  %ys.element.22.1 = getelementptr inbounds i32, ptr %ys.data.22, i32 1
  store i32 %ys.item.22.1, ptr %ys.element.22.1
  %zs.addr.39 = alloca ptr
  %zs.count.39 = add i32 0, 1
  %zs.data.39 = alloca i32, i32 %zs.count.39
  store ptr %zs.data.39, ptr %zs.addr.39
  %zs.item.39.0 = add i32 0, 0
  %zs.element.39.0 = getelementptr inbounds i32, ptr %zs.data.39, i32 0
  store i32 %zs.item.39.0, ptr %zs.element.39.0
  %empty.addr.50 = alloca ptr
  %empty.count.50 = add i32 0, 1
  %empty.size.50.0 = add i32 0, 0
  %empty.count.50.1 = mul i32 %empty.count.50, %empty.size.50.0
  %empty.data.50 = alloca i32, i32 %empty.count.50.1
  store ptr %empty.data.50, ptr %empty.addr.50
  %single.addr.59 = alloca ptr
  %single.count.59 = add i32 0, 1
  %single.data.59 = alloca i32, i32 %single.count.59
  store ptr %single.data.59, ptr %single.addr.59
  %single.item.59.0 = add i32 0, 42
  %single.element.59.0 = getelementptr inbounds i32, ptr %single.data.59, i32 0
  store i32 %single.item.59.0, ptr %single.element.59.0
  %ret.66 = add i32 0, 0
  ret i32 %ret.66
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

