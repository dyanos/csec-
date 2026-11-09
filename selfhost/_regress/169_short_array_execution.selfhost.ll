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

define i16 @second(ptr %arg.values) {
entry:
  %values = alloca ptr
  store ptr %arg.values, ptr %values
  %ret.31.index = add i32 0, 1
  %ret.31.data = load ptr, ptr %values
  %ret.31.element = getelementptr inbounds i16, ptr %ret.31.data, i32 %ret.31.index
  %ret.31 = load i16, ptr %ret.31.element
  ret i16 %ret.31
}

define i32 @csec_user_main() {
entry:
  %values.addr.45 = alloca ptr
  %values.count.45 = add i32 0, 1
  %values.size.45.0 = add i32 0, 2
  %values.count.45.1 = mul i32 %values.count.45, %values.size.45.0
  %values.data.45 = alloca i16, i32 %values.count.45.1
  store ptr %values.data.45, ptr %values.addr.45
  %values.index.54 = add i32 0, 0
  %values.data.54 = load ptr, ptr %values.addr.45
  %values.element.54 = getelementptr inbounds i16, ptr %values.data.54, i32 %values.index.54
  %values.rhs.54.i32 = add i32 0, 1024
  %values.rhs.54 = trunc i32 %values.rhs.54.i32 to i16
  store i16 %values.rhs.54, ptr %values.element.54
  %values.index.61 = add i32 0, 1
  %values.data.61 = load ptr, ptr %values.addr.45
  %values.element.61 = getelementptr inbounds i16, ptr %values.data.61, i32 %values.index.61
  %values.rhs.61.i32 = add i32 0, 2048
  %values.rhs.61 = trunc i32 %values.rhs.61.i32 to i16
  store i16 %values.rhs.61, ptr %values.element.61
  %forwarded.addr.68 = alloca ptr
  %forwarded.init.68.arg0 = load ptr, ptr %values.addr.45
  %forwarded.init.68 = call ptr @identity(ptr %forwarded.init.68.arg0)
  store ptr %forwarded.init.68, ptr %forwarded.addr.68
  %selected.addr.81 = alloca i16
  %selected.init.81.arg0 = load ptr, ptr %forwarded.addr.68
  %selected.init.81 = call i16 @second(ptr %selected.init.81.arg0)
  store i16 %selected.init.81, ptr %selected.addr.81
  %ifcond.91.left = load i16, ptr %selected.addr.81
  %ifcond.91.right.i32 = add i32 0, 2048
  %ifcond.91.right = trunc i32 %ifcond.91.right.i32 to i16
  %ifcond.91 = icmp eq i16 %ifcond.91.left, %ifcond.91.right
  br i1 %ifcond.91, label %if.then.91, label %if.else.91
if.then.91:
  %ret.98 = add i32 0, 0
  ret i32 %ret.98
if.else.91:
  br label %if.end.91
if.end.91:
  %ret.102 = add i32 0, 1
  ret i32 %ret.102
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

