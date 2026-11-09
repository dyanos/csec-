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

define i1 @allEnabled(ptr %arg.values) {
entry:
  %values = alloca ptr
  store ptr %arg.values, ptr %values
  %ret.13.left.left.index = add i32 0, 0
  %ret.13.left.left.data = load ptr, ptr %values
  %ret.13.left.left.element = getelementptr inbounds i1, ptr %ret.13.left.left.data, i32 %ret.13.left.left.index
  %ret.13.left.left = load i1, ptr %ret.13.left.left.element
  %ret.13.left.right.index = add i32 0, 1
  %ret.13.left.right.data = load ptr, ptr %values
  %ret.13.left.right.element = getelementptr inbounds i1, ptr %ret.13.left.right.data, i32 %ret.13.left.right.index
  %ret.13.left.right = load i1, ptr %ret.13.left.right.element
  %ret.13.left = and i1 %ret.13.left.left, %ret.13.left.right
  %ret.13.right.index = add i32 0, 2
  %ret.13.right.data = load ptr, ptr %values
  %ret.13.right.element = getelementptr inbounds i1, ptr %ret.13.right.data, i32 %ret.13.right.index
  %ret.13.right = load i1, ptr %ret.13.right.element
  %ret.13 = and i1 %ret.13.left, %ret.13.right
  ret i1 %ret.13
}

define i32 @csec_user_main() {
entry:
  %flags.addr.37 = alloca ptr
  %flags.count.37 = add i32 0, 3
  %flags.data.37 = alloca i1, i32 %flags.count.37
  store ptr %flags.data.37, ptr %flags.addr.37
  %flags.item.37.0 = icmp eq i32 0, 0
  %flags.element.37.0 = getelementptr inbounds i1, ptr %flags.data.37, i32 0
  store i1 %flags.item.37.0, ptr %flags.element.37.0
  %flags.item.37.1 = icmp eq i32 0, 1
  %flags.element.37.1 = getelementptr inbounds i1, ptr %flags.data.37, i32 1
  store i1 %flags.item.37.1, ptr %flags.element.37.1
  %flags.item.37.2 = icmp eq i32 0, 0
  %flags.element.37.2 = getelementptr inbounds i1, ptr %flags.data.37, i32 2
  store i1 %flags.item.37.2, ptr %flags.element.37.2
  %flags.index.48 = add i32 0, 1
  %flags.data.48 = load ptr, ptr %flags.addr.37
  %flags.element.48 = getelementptr inbounds i1, ptr %flags.data.48, i32 %flags.index.48
  %flags.rhs.48 = icmp eq i32 0, 0
  store i1 %flags.rhs.48, ptr %flags.element.48
  %ifcond.55.arg0 = load ptr, ptr %flags.addr.37
  %ifcond.55 = call i1 @allEnabled(ptr %ifcond.55.arg0)
  br i1 %ifcond.55, label %if.then.55, label %if.else.55
if.then.55:
  %if.then.ret.55 = add i32 0, 0
  ret i32 %if.then.ret.55
if.else.55:
  br label %if.end.55
if.end.55:
  %ret.67 = add i32 0, 1
  ret i32 %ret.67
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

