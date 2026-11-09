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

define ptr @build(i32 %arg.size) {
entry:
  %size = alloca i32
  store i32 %arg.size, ptr %size
  %values.addr.13 = alloca ptr
  %values.count.13 = add i32 0, 1
  %values.size.13.0 = load i32, ptr %size
  %values.count.13.1 = mul i32 %values.count.13, %values.size.13.0
  %values.data.13 = alloca i32, i32 %values.count.13.1
  store ptr %values.data.13, ptr %values.addr.13
  %values.index.22 = add i32 0, 0
  %values.data.22 = load ptr, ptr %values.addr.13
  %values.element.22 = getelementptr inbounds i32, ptr %values.data.22, i32 %values.index.22
  %values.rhs.22 = add i32 0, 40
  store i32 %values.rhs.22, ptr %values.element.22
  %values.index.29 = add i32 0, 1
  %values.data.29 = load ptr, ptr %values.addr.13
  %values.element.29 = getelementptr inbounds i32, ptr %values.data.29, i32 %values.index.29
  %values.rhs.29 = add i32 0, 42
  store i32 %values.rhs.29, ptr %values.element.29
  %ret.36 = load ptr, ptr %values.addr.13
  ret ptr %ret.36
}

define i32 @csec_user_main() {
entry:
  %made.addr.47 = alloca ptr
  %made.init.47.arg0 = add i32 0, 3
  %made.init.47 = call ptr @build(i32 %made.init.47.arg0)
  store ptr %made.init.47, ptr %made.addr.47
  %ifcond.60.i32.left.index = add i32 0, 1
  %ifcond.60.i32.left.data = load ptr, ptr %made.addr.47
  %ifcond.60.i32.left.element = getelementptr inbounds i32, ptr %ifcond.60.i32.left.data, i32 %ifcond.60.i32.left.index
  %ifcond.60.i32.left = load i32, ptr %ifcond.60.i32.left.element
  %ifcond.60.i32.right = add i32 0, 42
  %ifcond.60.i32.comparison = icmp eq i32 %ifcond.60.i32.left, %ifcond.60.i32.right
  %ifcond.60.i32 = zext i1 %ifcond.60.i32.comparison to i32
  %ifcond.60 = icmp ne i32 %ifcond.60.i32, 0
  br i1 %ifcond.60, label %if.then.60, label %if.else.60
if.then.60:
  %ret.70 = add i32 0, 0
  ret i32 %ret.70
if.else.60:
  br label %if.end.60
if.end.60:
  %ret.74 = add i32 0, 1
  ret i32 %ret.74
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

