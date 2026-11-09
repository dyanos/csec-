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

@.str.12 = private unnamed_addr constant [7 x i8] c" AbCd \00"

define i32 @csec_user_main() {
entry:
  %trimmed.addr.7 = alloca ptr
  %trimmed.init.7.string = getelementptr inbounds [7 x i8], ptr @.str.12, i32 0, i32 0
  %trimmed.init.7 = call ptr @csec_string_trim(ptr %trimmed.init.7.string)
  store ptr %trimmed.init.7, ptr %trimmed.addr.7
  %upper.addr.18 = alloca ptr
  %upper.init.18.string = load ptr, ptr %trimmed.addr.7
  %upper.init.18 = call ptr @csec_string_to_upper(ptr %upper.init.18.string)
  store ptr %upper.init.18, ptr %upper.addr.18
  %lower.addr.29 = alloca ptr
  %lower.init.29.string = load ptr, ptr %upper.addr.18
  %lower.init.29 = call ptr @csec_string_to_lower(ptr %lower.init.29.string)
  store ptr %lower.init.29, ptr %lower.addr.29
  %slice.addr.40 = alloca ptr
  %slice.init.40.string = load ptr, ptr %lower.addr.29
  %slice.init.40.offset = add i32 0, 1
  %slice.init.40.length = add i32 0, 2
  %slice.init.40 = call ptr @csec_string_substring(ptr %slice.init.40.string, i32 %slice.init.40.offset, i32 %slice.init.40.length)
  store ptr %slice.init.40, ptr %slice.addr.40
  %copy.addr.54 = alloca ptr
  %copy.init.54.string = load ptr, ptr %slice.addr.40
  %copy.init.54 = getelementptr i8, ptr %copy.init.54.string, i32 0
  store ptr %copy.init.54, ptr %copy.addr.54
  %ret.65.left.left.string = load ptr, ptr %trimmed.addr.7
  %ret.65.left.left.length64 = call i64 @csec_string_length(ptr %ret.65.left.left.string)
  %ret.65.left.left = trunc i64 %ret.65.left.left.length64 to i32
  %ret.65.left.right.string = load ptr, ptr %upper.addr.18
  %ret.65.left.right.length64 = call i64 @csec_string_length(ptr %ret.65.left.right.string)
  %ret.65.left.right = trunc i64 %ret.65.left.right.length64 to i32
  %ret.65.left = add i32 %ret.65.left.left, %ret.65.left.right
  %ret.65.right.string = load ptr, ptr %copy.addr.54
  %ret.65.right.length64 = call i64 @csec_string_length(ptr %ret.65.right.string)
  %ret.65.right = trunc i64 %ret.65.right.length64 to i32
  %ret.65 = add i32 %ret.65.left, %ret.65.right
  ret i32 %ret.65
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

