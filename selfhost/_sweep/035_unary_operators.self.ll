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

define i32 @csec_user_main() {
entry:
  %a.addr.7 = alloca i32
  %a.init.7 = add i32 0, 5
  store i32 %a.init.7, ptr %a.addr.7
  %b.addr.14 = alloca i32
  %b.init.14.value = load i32, ptr %a.addr.7
  %b.init.14 = sub i32 0, %b.init.14.value
  store i32 %b.init.14, ptr %b.addr.14
  %c.addr.22 = alloca i32
  %c.init.22 = load i32, ptr %a.addr.7
  store i32 %c.init.22, ptr %c.addr.22
  %d.addr.30 = alloca i32
  %d.init.30.value = add i32 0, 1
  %d.init.30.comparison = icmp eq i32 %d.init.30.value, 0
  %d.init.30 = zext i1 %d.init.30.comparison to i32
  store i32 %d.init.30, ptr %d.addr.30
  %e.addr.36 = alloca i32
  %e.init.36.value = add i32 0, 0
  %e.init.36.comparison = icmp eq i32 %e.init.36.value, 0
  %e.init.36 = zext i1 %e.init.36.comparison to i32
  store i32 %e.init.36, ptr %e.addr.36
  %f.addr.42 = alloca i32
  %f.init.42.value = add i32 0, 0
  %f.init.42 = xor i32 %f.init.42.value, -1
  store i32 %f.init.42, ptr %f.addr.42
  %g.addr.50 = alloca i32
  %g.init.50.value = add i32 0, 255
  %g.init.50 = xor i32 %g.init.50.value, -1
  store i32 %g.init.50, ptr %g.addr.50
  %h.addr.70 = alloca i32
  %h.init.70.value.value = load i32, ptr %a.addr.7
  %h.init.70.value = sub i32 0, %h.init.70.value.value
  %h.init.70 = sub i32 0, %h.init.70.value
  store i32 %h.init.70, ptr %h.addr.70
  %ret.81 = load i32, ptr %a.addr.7
  ret i32 %ret.81
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

