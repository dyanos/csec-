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
  %total.addr.7 = alloca i32
  %total.init.7 = add i32 0, 0
  store i32 %total.init.7, ptr %total.addr.7
  %i.addr.14 = alloca i32
  %i.init.14 = add i32 0, 0
  store i32 %i.init.14, ptr %i.addr.14
  br label %while.cond.21
while.cond.21:
  %whilecond.21.i32.left = load i32, ptr %i.addr.14
  %whilecond.21.i32.right = add i32 0, 5
  %whilecond.21.i32.comparison = icmp slt i32 %whilecond.21.i32.left, %whilecond.21.i32.right
  %whilecond.21.i32 = zext i1 %whilecond.21.i32.comparison to i32
  %whilecond.21 = icmp ne i32 %whilecond.21.i32, 0
  br i1 %whilecond.21, label %while.body.21, label %while.end.21
while.body.21:
  %j.addr.28 = alloca i32
  %j.init.28 = add i32 0, 0
  store i32 %j.init.28, ptr %j.addr.28
  br label %while.cond.35
while.cond.35:
  %whilecond.35.i32.left = load i32, ptr %j.addr.28
  %whilecond.35.i32.right = add i32 0, 5
  %whilecond.35.i32.comparison = icmp slt i32 %whilecond.35.i32.left, %whilecond.35.i32.right
  %whilecond.35.i32 = zext i1 %whilecond.35.i32.comparison to i32
  %whilecond.35 = icmp ne i32 %whilecond.35.i32, 0
  br i1 %whilecond.35, label %while.body.35, label %while.end.35
while.body.35:
  %total.assign.42.left = load i32, ptr %total.addr.7
  %total.assign.42.right = add i32 0, 1
  %total.assign.42 = add i32 %total.assign.42.left, %total.assign.42.right
  store i32 %total.assign.42, ptr %total.addr.7
  %j.assign.48.left = load i32, ptr %j.addr.28
  %j.assign.48.right = add i32 0, 1
  %j.assign.48 = add i32 %j.assign.48.left, %j.assign.48.right
  store i32 %j.assign.48, ptr %j.addr.28
  br label %while.cond.35
while.end.35:
  %i.assign.55.left = load i32, ptr %i.addr.14
  %i.assign.55.right = add i32 0, 1
  %i.assign.55 = add i32 %i.assign.55.left, %i.assign.55.right
  store i32 %i.assign.55, ptr %i.addr.14
  br label %while.cond.21
while.end.21:
  %ifcond.62.i32.left = load i32, ptr %total.addr.7
  %ifcond.62.i32.right = add i32 0, 25
  %ifcond.62.i32.comparison = icmp eq i32 %ifcond.62.i32.left, %ifcond.62.i32.right
  %ifcond.62.i32 = zext i1 %ifcond.62.i32.comparison to i32
  %ifcond.62 = icmp ne i32 %ifcond.62.i32, 0
  br i1 %ifcond.62, label %if.then.62, label %if.else.62
if.then.62:
  %ret.69 = add i32 0, 0
  ret i32 %ret.69
if.else.62:
  br label %if.end.62
if.end.62:
  %ret.73 = add i32 0, 1
  ret i32 %ret.73
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

