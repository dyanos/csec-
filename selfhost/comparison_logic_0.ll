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
  %less.addr.7 = alloca i32
  %less.init.7.left = add i32 0, 1
  %less.init.7.right = add i32 0, 2
  %less.init.7.comparison = icmp slt i32 %less.init.7.left, %less.init.7.right
  %less.init.7 = zext i1 %less.init.7.comparison to i32
  store i32 %less.init.7, ptr %less.addr.7
  %greater.addr.14 = alloca i32
  %greater.init.14.left = add i32 0, 3
  %greater.init.14.right = add i32 0, 2
  %greater.init.14.comparison = icmp sgt i32 %greater.init.14.left, %greater.init.14.right
  %greater.init.14 = zext i1 %greater.init.14.comparison to i32
  store i32 %greater.init.14, ptr %greater.addr.14
  %equal.addr.21 = alloca i32
  %equal.init.21.left = add i32 0, 4
  %equal.init.21.right = add i32 0, 4
  %equal.init.21.comparison = icmp eq i32 %equal.init.21.left, %equal.init.21.right
  %equal.init.21 = zext i1 %equal.init.21.comparison to i32
  store i32 %equal.init.21, ptr %equal.addr.21
  %notequal.addr.28 = alloca i32
  %notequal.init.28.left = add i32 0, 5
  %notequal.init.28.right = add i32 0, 6
  %notequal.init.28.comparison = icmp ne i32 %notequal.init.28.left, %notequal.init.28.right
  %notequal.init.28 = zext i1 %notequal.init.28.comparison to i32
  store i32 %notequal.init.28, ptr %notequal.addr.28
  %logic.addr.35 = alloca i32
  %logic.init.35.left.left = load i32, ptr %less.addr.7
  %logic.init.35.left.right = load i32, ptr %greater.addr.14
  %logic.init.35.left = and i32 %logic.init.35.left.left, %logic.init.35.left.right
  %logic.init.35.right.left = load i32, ptr %equal.addr.21
  %logic.init.35.right.right = load i32, ptr %notequal.addr.28
  %logic.init.35.right = xor i32 %logic.init.35.right.left, %logic.init.35.right.right
  %logic.init.35 = or i32 %logic.init.35.left, %logic.init.35.right
  store i32 %logic.init.35, ptr %logic.addr.35
  %bits.addr.46 = alloca i32
  %bits.init.46.left = add i32 0, 1
  %bits.init.46.right = add i32 0, 3
  %bits.init.46 = shl i32 %bits.init.46.left, %bits.init.46.right
  store i32 %bits.init.46, ptr %bits.addr.46
  %bits.assign.55.left = load i32, ptr %bits.addr.46
  %bits.assign.55.right = add i32 0, 2
  %bits.assign.55 = or i32 %bits.assign.55.left, %bits.assign.55.right
  store i32 %bits.assign.55, ptr %bits.addr.46
  %bits.assign.61.left = load i32, ptr %bits.addr.46
  %bits.assign.61.right = add i32 0, 15
  %bits.assign.61 = and i32 %bits.assign.61.left, %bits.assign.61.right
  store i32 %bits.assign.61, ptr %bits.addr.46
  %bits.assign.67.left = load i32, ptr %bits.addr.46
  %bits.assign.67.right = add i32 0, 7
  %bits.assign.67 = xor i32 %bits.assign.67.left, %bits.assign.67.right
  store i32 %bits.assign.67, ptr %bits.addr.46
  %ret.73 = load i32, ptr %bits.addr.46
  ret i32 %ret.73
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

