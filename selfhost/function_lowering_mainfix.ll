; ModuleID = 'csec.selfhost'
source_filename = "csec.selfhost"

declare i64 @csec_string_length(ptr)
declare i8 @csec_string_char_at(ptr, i32)

declare i32 @csec_lex_quoted(ptr, i32)
declare i32 @csec_lex_number(ptr, i32)
declare i32 @csec_lex_identifier(ptr, i32)
declare i32 @csec_lex_line_comment(ptr, i32)
declare i32 @csec_lex_block_comment(ptr, i32)
declare i32 @csec_digit_value(i8)
declare i32 @csec_is_keyword(ptr)
declare i32 @csec_to_int(ptr)
declare i32 @csec_line_start(ptr, i32)
declare i32 @csec_line_end(ptr, i32)
declare i32 @csec_validate_balanced(ptr)
declare i32 @csec_starts_top_level_declaration(ptr, i32)
declare i32 @csec_validate_top_level(ptr)
declare ptr @csec_top_level_decl_kind(ptr, i32)
declare ptr @csec_top_level_decl_name(ptr, i32)
declare i32 @csec_count_function_params(ptr, i32)
declare i32 @csec_token_is_top_level_operator(ptr, i32, i32)
declare i32 @csec_find_top_level_operator(ptr, i32, i32, i32)
declare i32 @csec_find_top_level_match(ptr, i32, i32)
declare i32 @csec_find_lambda_arrow(ptr, i32, i32)
declare ptr @csec_generate_symbol_table(ptr)
declare ptr @csec_append_expression_until(ptr, i32, i32)
declare ptr @csec_generate_expression_ast(ptr, i32, i32)
declare ptr @csec_generate_statement_ast(ptr, i32, i32)
declare ptr @csec_generate_body_ast(ptr, i32, i32)
declare i32 @csec_find_function_param_start(ptr, i32)
declare ptr @csec_generate_c_body(ptr, i32, i32, ptr)
declare ptr @csec_generate_c_expression(ptr, i32, i32)
declare ptr @csec_ir_operator_name(ptr)
declare ptr @csec_ir_type_name(ptr)
declare i32 @csec_expression_top_level_operator(ptr, i32, i32)
declare i32 @csec_find_token_text_in_range(ptr, i32, i32, ptr)
declare i32 @csec_find_closing_token(ptr, i32, i32, ptr, ptr)
declare i32 @csec_find_statement_paren_start(ptr, i32, i32)
declare i32 @csec_find_statement_paren_end(ptr, i32, i32)
declare i32 @csec_find_statement_block_start(ptr, i32, i32)
declare i32 @csec_find_statement_block_end(ptr, i32, i32)
declare i32 @csec_count_comma_separated(ptr, i32, i32)
declare i32 @csec_find_last_top_level_token(ptr, i32, i32, ptr)
declare ptr @csec_llvm_lexer_helper_definition(ptr)
declare i64 @csec_string_builder_new()
declare i64 @csec_string_builder_new_file(ptr)
declare i32 @csec_string_builder_append(i64, ptr)
declare ptr @csec_string_builder_finish(i64)
declare i32 @csec_string_builder_write_to_file(i64, ptr)
declare void @csec_set_command_line_args(i32, ptr)
declare i32 @csec_command_line_arg_count()
declare ptr @csec_command_line_arg(i32)
declare ptr @csec_file_read_all_text(ptr)
declare i32 @csec_file_write_all_text(ptr, ptr)
declare void @csec_print_string(ptr)
declare void @csec_print_newline()
declare ptr @csec_string_concat(ptr, ptr)
declare i32 @csec_string_equals(ptr, ptr)
declare i32 @csec_string_starts_with(ptr, ptr)
declare ptr @csec_string_substring(ptr, i32, i32)
declare ptr @csec_to_string_i64(i64)
declare ptr @csec_to_string_char(i8)
declare ptr @csec_token_append_owned(ptr, i8, ptr)
declare i64 @csec_token_builder_new()
declare i32 @csec_token_builder_append(i64, i8, ptr)
declare ptr @csec_token_builder_finish(i64)
declare ptr @csec_tokenize_source(ptr)
declare i8 @csec_token_kind_at(ptr, i32)
declare ptr @csec_token_text_at(ptr, i32)
declare i32 @csec_token_is(ptr, i32, i8, ptr)
declare i32 @csec_advance_statement(ptr, i32, i32)
declare i32 @csec_advance_top_level_decl(ptr, i32)
declare i32 @csec_find_decl_body_start(ptr, i32)
declare i32 @csec_find_decl_body_end(ptr, i32)
declare i32 @csec_function_param_end(ptr, i32)
declare ptr @csec_function_llvm_param_list(ptr, i32)
declare ptr @csec_function_llvm_param_allocas(ptr, i32)
declare ptr @csec_llvm_name_with_number(ptr, i32)
declare ptr @csec_llvm_string_literal_bytes(ptr)
declare i32 @csec_llvm_string_literal_byte_length(ptr)
declare ptr @csec_function_return_type_at(ptr, i32)
declare ptr @csec_collect_type_name(ptr, i32, i32)
declare i32 @csec_enclosing_function_decl_start(ptr, i32)
declare i32 @csec_enclosing_function_body_start(ptr, i32)
declare i32 @csec_enclosing_function_body_end(ptr, i32)
declare ptr @csec_lookup_function_return_type(ptr, ptr)
declare ptr @csec_lookup_visible_value_type(ptr, i32, ptr)
declare ptr @csec_lookup_visible_storage_name(ptr, i32, ptr)
declare ptr @csec_expand_imports(ptr)

@.str.37 = private unnamed_addr constant [6 x i8] c"hello\00"

define i32 @answer() {
entry:
  %value.addr.7 = alloca i32
  %value.init.7 = add i32 0, 42
  store i32 %value.init.7, ptr %value.addr.7
  %value.ret = load i32, ptr %value.addr.7
  ret i32 %value.ret
}

define i1 @enabled() {
entry:
  %ret.25 = icmp eq i1 true, true
  ret i1 %ret.25
}

define ptr @greeting() {
entry:
  %ret.36 = getelementptr inbounds [6 x i8], ptr @.str.37, i32 0, i32 0
  ret ptr %ret.36
}

define i32 @main(i32 %argc, ptr %argv) {
entry:
  call void @csec_set_command_line_args(i32 %argc, ptr %argv)
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}
define i32 @csec_user_main() {
entry:
  %ret.47 = call i32 @answer()
  ret i32 %ret.47
}

