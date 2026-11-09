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
  %arr.addr.7 = alloca ptr
  %arr.count.7 = add i32 0, 1
  %arr.size.7.0 = add i32 0, 3
  %arr.count.7.1 = mul i32 %arr.count.7, %arr.size.7.0
  %arr.data.7 = alloca i32, i32 %arr.count.7.1
  store ptr %arr.data.7, ptr %arr.addr.7
  %arr.index.16 = add i32 0, 0
  %arr.data.16 = load ptr, ptr %arr.addr.7
  %arr.element.16 = getelementptr inbounds i32, ptr %arr.data.16, i32 %arr.index.16
  %arr.rhs.16 = add i32 0, 20
  store i32 %arr.rhs.16, ptr %arr.element.16
  %arr.index.23 = add i32 0, 1
  %arr.data.23 = load ptr, ptr %arr.addr.7
  %arr.element.23 = getelementptr inbounds i32, ptr %arr.data.23, i32 %arr.index.23
  %arr.rhs.23 = add i32 0, 22
  store i32 %arr.rhs.23, ptr %arr.element.23
  %arr.index.30 = add i32 0, 2
  %arr.data.30 = load ptr, ptr %arr.addr.7
  %arr.element.30 = getelementptr inbounds i32, ptr %arr.data.30, i32 %arr.index.30
  %arr.rhs.30 = add i32 0, 0
  store i32 %arr.rhs.30, ptr %arr.element.30
  %v.addr.37 = alloca i32
  %v.init.37.left.index = add i32 0, 0
  %v.init.37.left.data = load ptr, ptr %arr.addr.7
  %v.init.37.left.element = getelementptr inbounds i32, ptr %v.init.37.left.data, i32 %v.init.37.left.index
  %v.init.37.left = load i32, ptr %v.init.37.left.element
  %v.init.37.right.index = add i32 0, 1
  %v.init.37.right.data = load ptr, ptr %arr.addr.7
  %v.init.37.right.element = getelementptr inbounds i32, ptr %v.init.37.right.data, i32 %v.init.37.right.index
  %v.init.37.right = load i32, ptr %v.init.37.right.element
  %v.init.37 = add i32 %v.init.37.left, %v.init.37.right
  store i32 %v.init.37, ptr %v.addr.37
  ; free() no-op (self-host stack allocation)
  %ret.55 = load i32, ptr %v.addr.37
  ret i32 %ret.55
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

