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
  %total.addr.7 = alloca i32
  store i32 0, ptr %total.addr.7
  %i = alloca i32
  %forstart.14 = add i32 0, 0
  store i32 %forstart.14, ptr %i
  br label %for.cond.14
for.cond.14:
  %forvalue.14 = load i32, ptr %i
  %forend.14 = add i32 0, 5
  %forcond.14 = icmp sle i32 %forvalue.14, %forend.14
  br i1 %forcond.14, label %for.body.14, label %for.end.14
for.body.14:
  %total.assign.23.left = load i32, ptr %total.addr.7
  %total.assign.23.right = load i32, ptr %i
  %total.assign.23 = add i32 %total.assign.23.left, %total.assign.23.right
  store i32 %total.assign.23, ptr %total.addr.7
  %fornext.14 = add i32 %forvalue.14, 1
  store i32 %fornext.14, ptr %i
  br label %for.cond.14
for.end.14:
  %j = alloca i32
  %forstart.30 = add i32 0, 0
  store i32 %forstart.30, ptr %j
  br label %for.cond.30
for.cond.30:
  %forvalue.30 = load i32, ptr %j
  %forend.30 = add i32 0, 5
  %forcond.30 = icmp slt i32 %forvalue.30, %forend.30
  br i1 %forcond.30, label %for.body.30, label %for.end.30
for.body.30:
  %total.assign.39.left = load i32, ptr %total.addr.7
  %total.assign.39.right = load i32, ptr %j
  %total.assign.39 = add i32 %total.assign.39.left, %total.assign.39.right
  store i32 %total.assign.39, ptr %total.addr.7
  %fornext.30 = add i32 %forvalue.30, 1
  store i32 %fornext.30, ptr %j
  br label %for.cond.30
for.end.30:
  %ret.46 = load i32, ptr %total.addr.7
  ret i32 %ret.46
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

