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
  %a.init.7.left.left.left = add i32 0, 1
  %a.init.7.left.left.right = add i32 0, 2
  %a.init.7.left.left = add i32 %a.init.7.left.left.left, %a.init.7.left.left.right
  %a.init.7.left.right.left = add i32 0, 3
  %a.init.7.left.right.right = add i32 0, 4
  %a.init.7.left.right = add i32 %a.init.7.left.right.left, %a.init.7.left.right.right
  %a.init.7.left = mul i32 %a.init.7.left.left, %a.init.7.left.right
  %a.init.7.right.left = add i32 0, 5
  %a.init.7.right.right = add i32 0, 2
  %a.init.7.right = sub i32 %a.init.7.right.left, %a.init.7.right.right
  %a.init.7 = sdiv i32 %a.init.7.left, %a.init.7.right
  store i32 %a.init.7, ptr %a.addr.7
  %b.addr.32 = alloca i32
  %b.init.32.left.left.left.left = add i32 0, 10
  %b.init.32.left.left.left.right = add i32 0, 20
  %b.init.32.left.left.left = add i32 %b.init.32.left.left.left.left, %b.init.32.left.left.left.right
  %b.init.32.left.left.right = add i32 0, 3
  %b.init.32.left.left = mul i32 %b.init.32.left.left.left, %b.init.32.left.left.right
  %b.init.32.left.right = add i32 0, 50
  %b.init.32.left = sub i32 %b.init.32.left.left, %b.init.32.left.right
  %b.init.32.right = add i32 0, 2
  %b.init.32 = sdiv i32 %b.init.32.left, %b.init.32.right
  store i32 %b.init.32, ptr %b.addr.32
  %c.addr.53 = alloca i32
  %c.init.53.left.left.left.left.left.left.left.left.left = add i32 0, 1
  %c.init.53.left.left.left.left.left.left.left.left.right = add i32 0, 2
  %c.init.53.left.left.left.left.left.left.left.left = add i32 %c.init.53.left.left.left.left.left.left.left.left.left, %c.init.53.left.left.left.left.left.left.left.left.right
  %c.init.53.left.left.left.left.left.left.left.right = add i32 0, 3
  %c.init.53.left.left.left.left.left.left.left = add i32 %c.init.53.left.left.left.left.left.left.left.left, %c.init.53.left.left.left.left.left.left.left.right
  %c.init.53.left.left.left.left.left.left.right = add i32 0, 4
  %c.init.53.left.left.left.left.left.left = add i32 %c.init.53.left.left.left.left.left.left.left, %c.init.53.left.left.left.left.left.left.right
  %c.init.53.left.left.left.left.left.right = add i32 0, 5
  %c.init.53.left.left.left.left.left = add i32 %c.init.53.left.left.left.left.left.left, %c.init.53.left.left.left.left.left.right
  %c.init.53.left.left.left.left.right = add i32 0, 6
  %c.init.53.left.left.left.left = add i32 %c.init.53.left.left.left.left.left, %c.init.53.left.left.left.left.right
  %c.init.53.left.left.left.right = add i32 0, 7
  %c.init.53.left.left.left = add i32 %c.init.53.left.left.left.left, %c.init.53.left.left.left.right
  %c.init.53.left.left.right = add i32 0, 8
  %c.init.53.left.left = add i32 %c.init.53.left.left.left, %c.init.53.left.left.right
  %c.init.53.left.right = add i32 0, 9
  %c.init.53.left = add i32 %c.init.53.left.left, %c.init.53.left.right
  %c.init.53.right = add i32 0, 10
  %c.init.53 = add i32 %c.init.53.left, %c.init.53.right
  store i32 %c.init.53, ptr %c.addr.53
  %d.addr.78 = alloca i32
  %d.init.78.left.left.left = add i32 0, 2
  %d.init.78.left.left.right = add i32 0, 3
  %d.init.78.left.left = mul i32 %d.init.78.left.left.left, %d.init.78.left.left.right
  %d.init.78.left.right = add i32 0, 4
  %d.init.78.left = mul i32 %d.init.78.left.left, %d.init.78.left.right
  %d.init.78.right = add i32 0, 5
  %d.init.78 = mul i32 %d.init.78.left, %d.init.78.right
  store i32 %d.init.78, ptr %d.addr.78
  %e.addr.91 = alloca i32
  %e.init.91.left.left = add i32 0, 100
  %e.init.91.left.right = add i32 0, 10
  %e.init.91.left = sdiv i32 %e.init.91.left.left, %e.init.91.left.right
  %e.init.91.right = add i32 0, 5
  %e.init.91 = sdiv i32 %e.init.91.left, %e.init.91.right
  store i32 %e.init.91, ptr %e.addr.91
  %f.addr.102 = alloca i32
  %f.init.102.left.left = add i32 0, 100
  %f.init.102.left.right = add i32 0, 7
  %f.init.102.left = srem i32 %f.init.102.left.left, %f.init.102.left.right
  %f.init.102.right = add i32 0, 3
  %f.init.102 = srem i32 %f.init.102.left, %f.init.102.right
  store i32 %f.init.102, ptr %f.addr.102
  %g.addr.113 = alloca i32
  %g.init.113.left.left.left = load i32, ptr %a.addr.7
  %g.init.113.left.left.right = load i32, ptr %b.addr.32
  %g.init.113.left.left = add i32 %g.init.113.left.left.left, %g.init.113.left.left.right
  %g.init.113.left.right.left = load i32, ptr %c.addr.53
  %g.init.113.left.right.right = load i32, ptr %d.addr.78
  %g.init.113.left.right = sub i32 %g.init.113.left.right.left, %g.init.113.left.right.right
  %g.init.113.left = mul i32 %g.init.113.left.left, %g.init.113.left.right
  %g.init.113.right.left = load i32, ptr %e.addr.91
  %g.init.113.right.right = load i32, ptr %f.addr.102
  %g.init.113.right = srem i32 %g.init.113.right.left, %g.init.113.right.right
  %g.init.113 = add i32 %g.init.113.left, %g.init.113.right
  store i32 %g.init.113, ptr %g.addr.113
  %ret.136 = load i32, ptr %g.addr.113
  ret i32 %ret.136
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

