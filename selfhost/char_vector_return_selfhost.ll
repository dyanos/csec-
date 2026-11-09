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

define ptr @identity(ptr %arg.values) {
entry:
  %values = alloca ptr
  store ptr %arg.values, ptr %values
  %ret = load ptr, ptr %values
  ret ptr %ret
}

define i32 @csec_user_main() {
entry:
  %values.addr.25 = alloca ptr
  %values.count.25 = add i32 0, 1
  %values.size.25.0 = add i32 0, 2
  %values.count.25.1 = mul i32 %values.count.25, %values.size.25.0
  %values.data.25 = alloca i8, i32 %values.count.25.1
  store ptr %values.data.25, ptr %values.addr.25
  %values.index.34 = add i32 0, 0
  %values.data.34 = load ptr, ptr %values.addr.25
  %values.element.34 = getelementptr inbounds i8, ptr %values.data.34, i32 %values.index.34
  %values.rhs.34 = add i8 0, 67
  store i8 %values.rhs.34, ptr %values.element.34
  %values.index.41 = add i32 0, 1
  %values.data.41 = load ptr, ptr %values.addr.25
  %values.element.41 = getelementptr inbounds i8, ptr %values.data.41, i32 %values.index.41
  %values.rhs.41 = add i8 0, 68
  store i8 %values.rhs.41, ptr %values.element.41
  %forwarded.addr.48 = alloca ptr
  %forwarded.init.48.arg0 = load ptr, ptr %values.addr.25
  %forwarded.init.48 = call ptr @identity(ptr %forwarded.init.48.arg0)
  store ptr %forwarded.init.48, ptr %forwarded.addr.48
  %ifcond.61.i32.left.char.index = add i32 0, 1
  %ifcond.61.i32.left.char.data = load ptr, ptr %forwarded.addr.48
  %ifcond.61.i32.left.char.element = getelementptr inbounds i8, ptr %ifcond.61.i32.left.char.data, i32 %ifcond.61.i32.left.char.index
  %ifcond.61.i32.left.char = load i8, ptr %ifcond.61.i32.left.char.element
  %ifcond.61.i32.left = zext i8 %ifcond.61.i32.left.char to i32
  %ifcond.61.i32.right.char = add i8 0, 68
  %ifcond.61.i32.right = zext i8 %ifcond.61.i32.right.char to i32
  %ifcond.61.i32.comparison = icmp eq i32 %ifcond.61.i32.left, %ifcond.61.i32.right
  %ifcond.61.i32 = zext i1 %ifcond.61.i32.comparison to i32
  %ifcond.61 = icmp ne i32 %ifcond.61.i32, 0
  br i1 %ifcond.61, label %if.then.61, label %if.else.61
if.then.61:
  %if.then.ret.61 = add i32 0, 0
  ret i32 %if.then.ret.61
if.else.61:
  br label %if.end.61
if.end.61:
  %ret.75 = add i32 0, 1
  ret i32 %ret.75
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

