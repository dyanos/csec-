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

@.str.10 = private unnamed_addr constant [7 x i8] c"score=\00"
@.str.19 = private unnamed_addr constant [6 x i8] c", ok=\00"
@.str.23 = private unnamed_addr constant [9 x i8] c", value=\00"
@.str.27 = private unnamed_addr constant [8 x i8] c", mark=\00"

define i32 @csec_user_main() {
entry:
  %label.addr.7 = alloca ptr
  %label.init.7 = getelementptr inbounds [7 x i8], ptr @.str.10, i32 0, i32 0
  store ptr %label.init.7, ptr %label.addr.7
  %message.addr.12 = alloca i32
  %message.init.12.left.left.left.left.left.left.left = load i32, ptr %label.addr.7
  %message.init.12.left.left.left.left.left.left.right = add i32 0, 4
  %message.init.12.left.left.left.left.left.left = add i32 %message.init.12.left.left.left.left.left.left.left, %message.init.12.left.left.left.left.left.left.right
  %message.init.12.left.left.left.left.left.right = add i32 0, 0
  %message.init.12.left.left.left.left.left = add i32 %message.init.12.left.left.left.left.left.left, %message.init.12.left.left.left.left.left.right
  %message.init.12.left.left.left.left.right = add i32 0, 1
  %message.init.12.left.left.left.left = add i32 %message.init.12.left.left.left.left.left, %message.init.12.left.left.left.left.right
  %message.init.12.left.left.left.right = add i32 0, 0
  %message.init.12.left.left.left = add i32 %message.init.12.left.left.left.left, %message.init.12.left.left.left.right
  %message.init.12.left.left.right = add i32 0, 0
  %message.init.12.left.left = add i32 %message.init.12.left.left.left, %message.init.12.left.left.right
  %message.init.12.left.right = add i32 0, 0
  %message.init.12.left = add i32 %message.init.12.left.left, %message.init.12.left.right
  %message.init.12.right = add i32 0, 0
  %message.init.12 = add i32 %message.init.12.left, %message.init.12.right
  store i32 %message.init.12, ptr %message.addr.12
  %println.31.value = load i32, ptr %message.addr.12
  %println.31.wide = sext i32 %println.31.value to i64
  call void @csec_print_i64(i64 %println.31.wide)
  call void @csec_print_newline()
  %ret.36 = add i32 0, 0
  ret i32 %ret.36
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

