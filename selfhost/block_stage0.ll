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
declare i32 @csec_string_equals(ptr, ptr)
declare i64 @csec_string_length(ptr)
declare i32 @csec_string_starts_with(ptr, ptr)
declare ptr @csec_string_substring(ptr, i32, i32)
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

define i32 @csec_user_main() {
entry:
  %a.addr.7 = alloca i32
  %x.addr.11 = alloca i32
  %x.init.11 = add i32 0, 10
  store i32 %x.init.11, ptr %x.addr.11
  %y.addr.16 = alloca i32
  %y.init.16 = add i32 0, 20
  store i32 %y.init.16, ptr %y.addr.16
  %a.init.7.left = load i32, ptr %x.addr.11
  %a.init.7.right = load i32, ptr %y.addr.16
  %a.init.7 = add i32 %a.init.7.left, %a.init.7.right
  store i32 %a.init.7, ptr %a.addr.7
  %b.addr.27 = alloca i32
  %b.init.27 = add i32 0, 42
  store i32 %b.init.27, ptr %b.addr.27
  %c.addr.35 = alloca i32
  %temp.addr.39 = alloca i32
  %temp.init.39.left = load i32, ptr %a.addr.7
  %temp.init.39.right = load i32, ptr %b.addr.27
  %temp.init.39 = add i32 %temp.init.39.left, %temp.init.39.right
  store i32 %temp.init.39, ptr %temp.addr.39
  %c.init.35.left = load i32, ptr %temp.addr.39
  %c.init.35.right = add i32 0, 2
  %c.init.35 = mul i32 %c.init.35.left, %c.init.35.right
  store i32 %c.init.35, ptr %c.addr.35
  %ret.52 = load i32, ptr %c.addr.35
  ret i32 %ret.52
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

