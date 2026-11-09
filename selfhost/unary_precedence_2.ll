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
  %a.init.7.left = add i32 0, 2
  %a.init.7.right.left = add i32 0, 3
  %a.init.7.right.right = add i32 0, 4
  %a.init.7.right = mul i32 %a.init.7.right.left, %a.init.7.right.right
  %a.init.7 = add i32 %a.init.7.left, %a.init.7.right
  store i32 %a.init.7, ptr %a.addr.7
  %b.addr.18 = alloca i32
  %b.init.18.left = add i32 0, 1
  %b.init.18.right = add i32 0, 3
  %b.init.18 = shl i32 %b.init.18.left, %b.init.18.right
  store i32 %b.init.18, ptr %b.addr.18
  %c.addr.27 = alloca i32
  %c.init.27 = add i32 0, 1
  store i32 %c.init.27, ptr %c.addr.27
  %d.addr.36 = alloca i32
  %d.init.36.left = add i32 0, 1
  %d.init.36.right = add i32 0, 2
  %d.init.36 = and i32 %d.init.36.left, %d.init.36.right
  store i32 %d.init.36, ptr %d.addr.36
  %e.addr.45 = alloca i32
  %e.init.45 = add i32 0, 1
  store i32 %e.init.45, ptr %e.addr.45
  %f.addr.56 = alloca i32
  %f.init.56.left.left = add i32 0, 2
  %f.init.56.left.right = add i32 0, 3
  %f.init.56.left = add i32 %f.init.56.left.left, %f.init.56.left.right
  %f.init.56.right = add i32 0, 4
  %f.init.56 = mul i32 %f.init.56.left, %f.init.56.right
  store i32 %f.init.56, ptr %f.addr.56
  %g.addr.69 = alloca i32
  %g.init.69.left = add i32 0, 2
  %g.init.69.right.left = add i32 0, 3
  %g.init.69.right.right = add i32 0, 4
  %g.init.69.right = add i32 %g.init.69.right.left, %g.init.69.right.right
  %g.init.69 = mul i32 %g.init.69.left, %g.init.69.right
  store i32 %g.init.69, ptr %g.addr.69
  %h.addr.82 = alloca i32
  %h.init.82.left.left = add i32 0, 10
  %h.init.82.left.right = add i32 0, 3
  %h.init.82.left = sub i32 %h.init.82.left.left, %h.init.82.left.right
  %h.init.82.right = add i32 0, 2
  %h.init.82 = sub i32 %h.init.82.left, %h.init.82.right
  store i32 %h.init.82, ptr %h.addr.82
  %i.addr.93 = alloca i32
  %i.init.93.left.left = add i32 0, 100
  %i.init.93.left.right = add i32 0, 10
  %i.init.93.left = sdiv i32 %i.init.93.left.left, %i.init.93.left.right
  %i.init.93.right = add i32 0, 2
  %i.init.93 = sdiv i32 %i.init.93.left, %i.init.93.right
  store i32 %i.init.93, ptr %i.addr.93
  %ret.104 = load i32, ptr %a.addr.7
  ret i32 %ret.104
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

