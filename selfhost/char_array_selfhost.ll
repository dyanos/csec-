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

define i8 @identity(i8 %arg.value) {
entry:
  %value = alloca i8
  store i8 %arg.value, ptr %value
  %ret.i32 = load i32, ptr %value
  %ret = trunc i32 %ret.i32 to i8
  ret i8 %ret
}

define i8 @second(ptr %arg.values) {
entry:
  %values = alloca ptr
  store ptr %arg.values, ptr %values
  %ret.index = add i32 0, 1
  %ret.data = load ptr, ptr %values
  %ret.element = getelementptr inbounds i8, ptr %ret.data, i32 %ret.index
  %ret = load i8, ptr %ret.element
  ret i8 %ret
}

define i32 @csec_user_main() {
entry:
  %values.addr.39 = alloca ptr
  %values.count.39 = add i32 0, 1
  %values.size.39.0 = add i32 0, 2
  %values.count.39.1 = mul i32 %values.count.39, %values.size.39.0
  %values.data.39 = alloca i8, i32 %values.count.39.1
  store ptr %values.data.39, ptr %values.addr.39
  %values.index.48 = add i32 0, 0
  %values.data.48 = load ptr, ptr %values.addr.39
  %values.element.48 = getelementptr inbounds i8, ptr %values.data.48, i32 %values.index.48
  %values.rhs.48.arg0 = add i8 0, 65
  %values.rhs.48 = call i8 @identity(i8 %values.rhs.48.arg0)
  store i8 %values.rhs.48, ptr %values.element.48
  %values.index.58 = add i32 0, 1
  %values.data.58 = load ptr, ptr %values.addr.39
  %values.element.58 = getelementptr inbounds i8, ptr %values.data.58, i32 %values.index.58
  %values.rhs.58 = add i8 0, 90
  store i8 %values.rhs.58, ptr %values.element.58
  %selected.addr.65 = alloca i8
  %selected.init.65.arg0 = load ptr, ptr %values.addr.39
  %selected.init.65 = call i8 @second(ptr %selected.init.65.arg0)
  store i8 %selected.init.65, ptr %selected.addr.65
  %ifcond.73.i32.left.char = load i8, ptr %selected.addr.65
  %ifcond.73.i32.left = zext i8 %ifcond.73.i32.left.char to i32
  %ifcond.73.i32.right.char = add i8 0, 90
  %ifcond.73.i32.right = zext i8 %ifcond.73.i32.right.char to i32
  %ifcond.73.i32.comparison = icmp eq i32 %ifcond.73.i32.left, %ifcond.73.i32.right
  %ifcond.73.i32 = zext i1 %ifcond.73.i32.comparison to i32
  %ifcond.73 = icmp ne i32 %ifcond.73.i32, 0
  br i1 %ifcond.73, label %if.then.73, label %if.else.73
if.then.73:
  %if.then.ret.73 = add i32 0, 0
  ret i32 %if.then.ret.73
if.else.73:
  br label %if.end.73
if.end.73:
  %ret.84 = add i32 0, 1
  ret i32 %ret.84
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

