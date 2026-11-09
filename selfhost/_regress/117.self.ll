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

@.str.34 = private unnamed_addr constant [2 x i8] c"!\00"
@.str.69 = private unnamed_addr constant [3 x i8] c"ok\00"

define i32 @Formatter_show_Int(i32 %arg.value) {
entry:
  %value = alloca i32
  store i32 %arg.value, ptr %value
  %ret.15.left = load i32, ptr %value
  %ret.15.right = add i32 0, 1
  %ret.15 = add i32 %ret.15.left, %ret.15.right
  ret i32 %ret.15
}

define ptr @Formatter_show_String(ptr %arg.value) {
entry:
  %value = alloca ptr
  store ptr %arg.value, ptr %value
  %ret.31.left = load ptr, ptr %value
  %ret.31.right = getelementptr inbounds [2 x i8], ptr @.str.34, i32 0, i32 0
  %ret.31 = call ptr @csec_string_concat(ptr %ret.31.left, ptr %ret.31.right)
  ret ptr %ret.31
}

define i32 @csec_user_main() {
entry:
  %formatter.addr.45 = alloca i32
  store i32 0, ptr %formatter.addr.45
  %println.53.value.arg0 = add i32 0, 4
  %println.53.value = call i32 @Formatter_show_Int(i32 %println.53.value.arg0)
  %println.53.wide = sext i32 %println.53.value to i64
  call void @csec_print_i64(i64 %println.53.wide)
  call void @csec_print_newline()
  %println.63.string.arg0 = getelementptr inbounds [3 x i8], ptr @.str.69, i32 0, i32 0
  %println.63.string = call ptr @Formatter_show_String(ptr %println.63.string.arg0)
  call void @csec_print_string(ptr %println.63.string)
  call void @csec_print_newline()
  %ret.73 = add i32 0, 0
  ret i32 %ret.73
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

