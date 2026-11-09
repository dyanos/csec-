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
  %a.init.7.left = add i32 0, 255
  %a.init.7.right = add i32 0, 15
  %a.init.7 = and i32 %a.init.7.left, %a.init.7.right
  store i32 %a.init.7, ptr %a.addr.7
  %b.addr.16 = alloca i32
  %b.init.16.left = add i32 0, 240
  %b.init.16.right = add i32 0, 15
  %b.init.16 = or i32 %b.init.16.left, %b.init.16.right
  store i32 %b.init.16, ptr %b.addr.16
  %c.addr.25 = alloca i32
  %c.init.25.left = add i32 0, 255
  %c.init.25.right = add i32 0, 170
  %c.init.25 = xor i32 %c.init.25.left, %c.init.25.right
  store i32 %c.init.25, ptr %c.addr.25
  %d.addr.34 = alloca i32
  %d.init.34.value = add i32 0, 0
  %d.init.34 = xor i32 %d.init.34.value, -1
  store i32 %d.init.34, ptr %d.addr.34
  %e.addr.42 = alloca i32
  %e.init.42.left = add i32 0, 1
  %e.init.42.right = add i32 0, 8
  %e.init.42 = shl i32 %e.init.42.left, %e.init.42.right
  store i32 %e.init.42, ptr %e.addr.42
  %f.addr.51 = alloca i32
  %f.init.51.left = add i32 0, 256
  %f.init.51.right = add i32 0, 4
  %f.init.51 = ashr i32 %f.init.51.left, %f.init.51.right
  store i32 %f.init.51, ptr %f.addr.51
  %g.addr.60 = alloca i32
  %g.init.60.left.left = load i32, ptr %a.addr.7
  %g.init.60.left.right = load i32, ptr %b.addr.16
  %g.init.60.left = and i32 %g.init.60.left.left, %g.init.60.left.right
  %g.init.60.right.left = load i32, ptr %c.addr.25
  %g.init.60.right.right = load i32, ptr %d.addr.34
  %g.init.60.right = xor i32 %g.init.60.right.left, %g.init.60.right.right
  %g.init.60 = or i32 %g.init.60.left, %g.init.60.right
  store i32 %g.init.60, ptr %g.addr.60
  %h.addr.77 = alloca i32
  %h.init.77.left.left.left = add i32 0, 1
  %h.init.77.left.left.right = add i32 0, 4
  %h.init.77.left.left = shl i32 %h.init.77.left.left.left, %h.init.77.left.left.right
  %h.init.77.left.right.left = add i32 0, 1
  %h.init.77.left.right.right = add i32 0, 2
  %h.init.77.left.right = shl i32 %h.init.77.left.right.left, %h.init.77.left.right.right
  %h.init.77.left = or i32 %h.init.77.left.left, %h.init.77.left.right
  %h.init.77.right.left = add i32 0, 1
  %h.init.77.right.right = add i32 0, 0
  %h.init.77.right = shl i32 %h.init.77.right.left, %h.init.77.right.right
  %h.init.77 = or i32 %h.init.77.left, %h.init.77.right
  store i32 %h.init.77, ptr %h.addr.77
  %ret.100 = load i32, ptr %h.addr.77
  ret i32 %ret.100
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

