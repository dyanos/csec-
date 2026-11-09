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

@.str.10 = private unnamed_addr constant [6 x i8] c"hello\00"
@.str.15 = private unnamed_addr constant [12 x i8] c"hello world\00"
@.str.20 = private unnamed_addr constant [12 x i8] c"line1\0Aline2\00"
@.str.25 = private unnamed_addr constant [10 x i8] c"col1\09col2\00"
@.str.30 = private unnamed_addr constant [14 x i8] c"she said \22hi\22\00"
@.str.35 = private unnamed_addr constant [13 x i8] c"path\5Cto\5Cfile\00"
@.str.40 = private unnamed_addr constant [1 x i8] c"\00"

define i32 @csec_user_main() {
entry:
  %simple.addr.7 = alloca ptr
  %simple.init.7 = getelementptr inbounds [6 x i8], ptr @.str.10, i32 0, i32 0
  store ptr %simple.init.7, ptr %simple.addr.7
  %withSpace.addr.12 = alloca ptr
  %withSpace.init.12 = getelementptr inbounds [12 x i8], ptr @.str.15, i32 0, i32 0
  store ptr %withSpace.init.12, ptr %withSpace.addr.12
  %withEscape.addr.17 = alloca ptr
  %withEscape.init.17 = getelementptr inbounds [12 x i8], ptr @.str.20, i32 0, i32 0
  store ptr %withEscape.init.17, ptr %withEscape.addr.17
  %withTab.addr.22 = alloca ptr
  %withTab.init.22 = getelementptr inbounds [10 x i8], ptr @.str.25, i32 0, i32 0
  store ptr %withTab.init.22, ptr %withTab.addr.22
  %withQuote.addr.27 = alloca ptr
  %withQuote.init.27 = getelementptr inbounds [14 x i8], ptr @.str.30, i32 0, i32 0
  store ptr %withQuote.init.27, ptr %withQuote.addr.27
  %withBackslash.addr.32 = alloca ptr
  %withBackslash.init.32 = getelementptr inbounds [13 x i8], ptr @.str.35, i32 0, i32 0
  store ptr %withBackslash.init.32, ptr %withBackslash.addr.32
  %empty.addr.37 = alloca ptr
  %empty.init.37 = getelementptr inbounds [1 x i8], ptr @.str.40, i32 0, i32 0
  store ptr %empty.init.37, ptr %empty.addr.37
  %ret.42 = add i32 0, 0
  ret i32 %ret.42
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

