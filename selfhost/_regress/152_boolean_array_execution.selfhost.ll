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

define i1 @allEnabled() {
entry:
  %flags.addr.7 = alloca ptr
  %flags.count.7 = add i32 0, 3
  %flags.data.7 = alloca i1, i32 %flags.count.7
  store ptr %flags.data.7, ptr %flags.addr.7
  %flags.item.7.0 = icmp eq i32 0, 0
  %flags.element.7.0 = getelementptr inbounds i1, ptr %flags.data.7, i32 0
  store i1 %flags.item.7.0, ptr %flags.element.7.0
  %flags.item.7.1 = icmp eq i32 0, 1
  %flags.element.7.1 = getelementptr inbounds i1, ptr %flags.data.7, i32 1
  store i1 %flags.item.7.1, ptr %flags.element.7.1
  %flags.item.7.2 = icmp eq i32 0, 0
  %flags.element.7.2 = getelementptr inbounds i1, ptr %flags.data.7, i32 2
  store i1 %flags.item.7.2, ptr %flags.element.7.2
  %dynamic.addr.18 = alloca ptr
  %dynamic.count.18 = add i32 0, 1
  %dynamic.size.18.0 = add i32 0, 2
  %dynamic.count.18.1 = mul i32 %dynamic.count.18, %dynamic.size.18.0
  %dynamic.data.18 = alloca i1, i32 %dynamic.count.18.1
  store ptr %dynamic.data.18, ptr %dynamic.addr.18
  %flags.index.27 = add i32 0, 1
  %flags.data.27 = load ptr, ptr %flags.addr.7
  %flags.element.27 = getelementptr inbounds i1, ptr %flags.data.27, i32 %flags.index.27
  %flags.rhs.27 = icmp eq i32 0, 0
  store i1 %flags.rhs.27, ptr %flags.element.27
  %dynamic.index.34 = add i32 0, 0
  %dynamic.data.34 = load ptr, ptr %dynamic.addr.18
  %dynamic.element.34 = getelementptr inbounds i1, ptr %dynamic.data.34, i32 %dynamic.index.34
  %dynamic.rhs.34 = icmp eq i32 0, 0
  store i1 %dynamic.rhs.34, ptr %dynamic.element.34
  %dynamic.index.41 = add i32 0, 1
  %dynamic.data.41 = load ptr, ptr %dynamic.addr.18
  %dynamic.element.41 = getelementptr inbounds i1, ptr %dynamic.data.41, i32 %dynamic.index.41
  %dynamic.rhs.41 = icmp eq i32 0, 0
  store i1 %dynamic.rhs.41, ptr %dynamic.element.41
  %ret.48.left.left.left.left.index = add i32 0, 0
  %ret.48.left.left.left.left.data = load ptr, ptr %flags.addr.7
  %ret.48.left.left.left.left.element = getelementptr inbounds i1, ptr %ret.48.left.left.left.left.data, i32 %ret.48.left.left.left.left.index
  %ret.48.left.left.left.left = load i1, ptr %ret.48.left.left.left.left.element
  %ret.48.left.left.left.right.index = add i32 0, 1
  %ret.48.left.left.left.right.data = load ptr, ptr %flags.addr.7
  %ret.48.left.left.left.right.element = getelementptr inbounds i1, ptr %ret.48.left.left.left.right.data, i32 %ret.48.left.left.left.right.index
  %ret.48.left.left.left.right = load i1, ptr %ret.48.left.left.left.right.element
  %ret.48.left.left.left = and i1 %ret.48.left.left.left.left, %ret.48.left.left.left.right
  %ret.48.left.left.right.index = add i32 0, 2
  %ret.48.left.left.right.data = load ptr, ptr %flags.addr.7
  %ret.48.left.left.right.element = getelementptr inbounds i1, ptr %ret.48.left.left.right.data, i32 %ret.48.left.left.right.index
  %ret.48.left.left.right = load i1, ptr %ret.48.left.left.right.element
  %ret.48.left.left = and i1 %ret.48.left.left.left, %ret.48.left.left.right
  %ret.48.left.right.index = add i32 0, 0
  %ret.48.left.right.data = load ptr, ptr %dynamic.addr.18
  %ret.48.left.right.element = getelementptr inbounds i1, ptr %ret.48.left.right.data, i32 %ret.48.left.right.index
  %ret.48.left.right = load i1, ptr %ret.48.left.right.element
  %ret.48.left = and i1 %ret.48.left.left, %ret.48.left.right
  %ret.48.right.index = add i32 0, 1
  %ret.48.right.data = load ptr, ptr %dynamic.addr.18
  %ret.48.right.element = getelementptr inbounds i1, ptr %ret.48.right.data, i32 %ret.48.right.index
  %ret.48.right = load i1, ptr %ret.48.right.element
  %ret.48 = and i1 %ret.48.left, %ret.48.right
  ret i1 %ret.48
}

define i32 @csec_user_main() {
entry:
  %ifcond.82 = call i1 @allEnabled()
  br i1 %ifcond.82, label %if.then.82, label %if.else.82
if.then.82:
  %ret.89 = add i32 0, 0
  ret i32 %ret.89
if.else.82:
  br label %if.end.82
if.end.82:
  %ret.93 = add i32 0, 1
  ret i32 %ret.93
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

