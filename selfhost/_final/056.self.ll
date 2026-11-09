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
  %xs.item.7.0 = add i32 0, 1
  %xs.element.7.0 = getelementptr inbounds i32, ptr %xs.data.7, i32 0
  store i32 %xs.item.7.0, ptr %xs.element.7.0
  %xs.item.7.1 = add i32 0, 2
  %xs.element.7.1 = getelementptr inbounds i32, ptr %xs.data.7, i32 1
  store i32 %xs.item.7.1, ptr %xs.element.7.1
  %xs.item.7.2 = add i32 0, 3
  %xs.element.7.2 = getelementptr inbounds i32, ptr %xs.data.7, i32 2
  store i32 %xs.item.7.2, ptr %xs.element.7.2
  %xs.item.7.3 = add i32 0, 4
  %xs.element.7.3 = getelementptr inbounds i32, ptr %xs.data.7, i32 3
  store i32 %xs.item.7.3, ptr %xs.element.7.3
  %xs.item.7.4 = add i32 0, 5
  %xs.element.7.4 = getelementptr inbounds i32, ptr %xs.data.7, i32 4
  store i32 %xs.item.7.4, ptr %xs.element.7.4
  %weights.addr.22 = alloca ptr
  %weights.count.22 = add i32 0, 5
  %weights.data.22 = alloca i32, i32 %weights.count.22
  store ptr %weights.data.22, ptr %weights.addr.22
  %weights.item.22.0 = add i32 0, 2
  %weights.element.22.0 = getelementptr inbounds i32, ptr %weights.data.22, i32 0
  store i32 %weights.item.22.0, ptr %weights.element.22.0
  %weights.item.22.1 = add i32 0, 4
  %weights.element.22.1 = getelementptr inbounds i32, ptr %weights.data.22, i32 1
  store i32 %weights.item.22.1, ptr %weights.element.22.1
  %weights.item.22.2 = add i32 0, 6
  %weights.element.22.2 = getelementptr inbounds i32, ptr %weights.data.22, i32 2
  store i32 %weights.item.22.2, ptr %weights.element.22.2
  %weights.item.22.3 = add i32 0, 8
  %weights.element.22.3 = getelementptr inbounds i32, ptr %weights.data.22, i32 3
  store i32 %weights.item.22.3, ptr %weights.element.22.3
  %weights.item.22.4 = add i32 0, 10
  %weights.element.22.4 = getelementptr inbounds i32, ptr %weights.data.22, i32 4
  store i32 %weights.item.22.4, ptr %weights.element.22.4
  %sum.addr.37 = alloca i32
  %sum.init.37 = add i32 0, 0
  store i32 %sum.init.37, ptr %sum.addr.37
  %weighted.addr.59 = alloca i32
  %weighted.init.59 = add i32 0, 0
  store i32 %weighted.init.59, ptr %weighted.addr.59
  %squares.addr.83 = alloca i32
  %squares.init.83 = add i32 0, 0
  store i32 %squares.init.83, ptr %squares.addr.83
  %sumSquares.addr.99 = alloca i32
  %sumSquares.init.99 = add i32 0, 0
  store i32 %sumSquares.init.99, ptr %sumSquares.addr.99
  %filtered.addr.121 = alloca i32
  %filtered.init.121 = add i32 0, 0
  store i32 %filtered.init.121, ptr %filtered.addr.121
  %count.addr.137 = alloca i32
  %count.init.137 = add i32 0, 0
  store i32 %count.init.137, ptr %count.addr.137
  %ret.159.left.left.left = load i32, ptr %sum.addr.37
  %ret.159.left.left.right = load i32, ptr %weighted.addr.59
  %ret.159.left.left = add i32 %ret.159.left.left.left, %ret.159.left.left.right
  %ret.159.left.right = load i32, ptr %sumSquares.addr.99
  %ret.159.left = add i32 %ret.159.left.left, %ret.159.left.right
  %ret.159.right = load i32, ptr %count.addr.137
  %ret.159 = add i32 %ret.159.left, %ret.159.right
  ret i32 %ret.159
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

