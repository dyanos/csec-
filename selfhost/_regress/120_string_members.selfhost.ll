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

@.str.10 = private unnamed_addr constant [15 x i8] c"  Hello CSEC  \00"
@.str.66 = private unnamed_addr constant [4 x i8] c"CSE\00"
@.str.76 = private unnamed_addr constant [3 x i8] c"He\00"
@.str.86 = private unnamed_addr constant [4 x i8] c"SEC\00"
@.str.96 = private unnamed_addr constant [2 x i8] c"C\00"

define i32 @csec_user_main() {
entry:
  %text.addr.7 = alloca ptr
  %text.init.7 = getelementptr inbounds [15 x i8], ptr @.str.10, i32 0, i32 0
  store ptr %text.init.7, ptr %text.addr.7
  %trimmed.addr.12 = alloca ptr
  %trimmed.init.12.string = load ptr, ptr %text.addr.7
  %trimmed.init.12 = call ptr @csec_string_trim(ptr %trimmed.init.12.string)
  store ptr %trimmed.init.12, ptr %trimmed.addr.12
  %println.21.value.string = load ptr, ptr %text.addr.7
  %println.21.value.length64 = call i64 @csec_string_length(ptr %println.21.value.string)
  %println.21.value = trunc i64 %println.21.value.length64 to i32
  %println.21.wide = sext i32 %println.21.value to i64
  call void @csec_print_i64(i64 %println.21.wide)
  call void @csec_print_newline()
  %println.28.value.string = load ptr, ptr %text.addr.7
  %println.28.value.length64 = call i64 @csec_string_length(ptr %println.28.value.string)
  %println.28.value = trunc i64 %println.28.value.length64 to i32
  %println.28.wide = sext i32 %println.28.value to i64
  call void @csec_print_i64(i64 %println.28.wide)
  call void @csec_print_newline()
  %println.37.string = load ptr, ptr %trimmed.addr.12
  call void @csec_print_string(ptr %println.37.string)
  call void @csec_print_newline()
  %println.42.value.string = load ptr, ptr %trimmed.addr.12
  %println.42.value.length64 = call i64 @csec_string_length(ptr %println.42.value.string)
  %println.42.value = trunc i64 %println.42.value.length64 to i32
  %println.42.wide = sext i32 %println.42.value to i64
  call void @csec_print_i64(i64 %println.42.wide)
  call void @csec_print_newline()
  %println.51.value.string = load ptr, ptr %trimmed.addr.12
  %println.51.value = call i32 @csec_string_is_empty(ptr %println.51.value.string)
  %println.51.wide = sext i32 %println.51.value to i64
  call void @csec_print_i64(i64 %println.51.wide)
  call void @csec_print_newline()
  %println.60.value.string = load ptr, ptr %trimmed.addr.12
  %println.60.value.needle = getelementptr inbounds [4 x i8], ptr @.str.66, i32 0, i32 0
  %println.60.value = call i32 @csec_string_contains(ptr %println.60.value.string, ptr %println.60.value.needle)
  %println.60.wide = sext i32 %println.60.value to i64
  call void @csec_print_i64(i64 %println.60.wide)
  call void @csec_print_newline()
  %println.70.value.string = load ptr, ptr %trimmed.addr.12
  %println.70.value.needle = getelementptr inbounds [3 x i8], ptr @.str.76, i32 0, i32 0
  %println.70.value = call i32 @csec_string_starts_with(ptr %println.70.value.string, ptr %println.70.value.needle)
  %println.70.wide = sext i32 %println.70.value to i64
  call void @csec_print_i64(i64 %println.70.wide)
  call void @csec_print_newline()
  %println.80.value.string = load ptr, ptr %trimmed.addr.12
  %println.80.value.needle = getelementptr inbounds [4 x i8], ptr @.str.86, i32 0, i32 0
  %println.80.value = call i32 @csec_string_ends_with(ptr %println.80.value.string, ptr %println.80.value.needle)
  %println.80.wide = sext i32 %println.80.value to i64
  call void @csec_print_i64(i64 %println.80.wide)
  call void @csec_print_newline()
  %println.90.value.string = load ptr, ptr %trimmed.addr.12
  %println.90.value.needle = getelementptr inbounds [2 x i8], ptr @.str.96, i32 0, i32 0
  %println.90.value.index64 = call i64 @csec_string_index_of(ptr %println.90.value.string, ptr %println.90.value.needle)
  %println.90.value = trunc i64 %println.90.value.index64 to i32
  %println.90.wide = sext i32 %println.90.value to i64
  call void @csec_print_i64(i64 %println.90.wide)
  call void @csec_print_newline()
  %println.100.string.string = load ptr, ptr %trimmed.addr.12
  %println.100.string.offset = add i32 0, 6
  %println.100.string.length = add i32 0, 4
  %println.100.string = call ptr @csec_string_substring(ptr %println.100.string.string, i32 %println.100.string.offset, i32 %println.100.string.length)
  call void @csec_print_string(ptr %println.100.string)
  call void @csec_print_newline()
  %println.112.value.string = load ptr, ptr %trimmed.addr.12
  %println.112.value.index = add i32 0, 0
  %println.112.value.char = call i8 @csec_string_char_at(ptr %println.112.value.string, i32 %println.112.value.index)
  %println.112.value = zext i8 %println.112.value.char to i32
  %println.112.wide = sext i32 %println.112.value to i64
  call void @csec_print_i64(i64 %println.112.wide)
  call void @csec_print_newline()
  %println.122.string.string = load ptr, ptr %trimmed.addr.12
  %println.122.string = call ptr @csec_string_to_upper(ptr %println.122.string.string)
  call void @csec_print_string(ptr %println.122.string)
  call void @csec_print_newline()
  %println.131.string.string = load ptr, ptr %trimmed.addr.12
  %println.131.string = call ptr @csec_string_to_lower(ptr %println.131.string.string)
  call void @csec_print_string(ptr %println.131.string)
  call void @csec_print_newline()
  %println.140.string.string = load ptr, ptr %trimmed.addr.12
  %println.140.string = getelementptr i8, ptr %println.140.string.string, i32 0
  call void @csec_print_string(ptr %println.140.string)
  call void @csec_print_newline()
  %ret.149 = add i32 0, 0
  ret i32 %ret.149
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

