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
  %acc.addr.7 = alloca i32
  %acc.init.7 = add i32 0, 0
  store i32 %acc.init.7, ptr %acc.addr.7
  %i = alloca i32
  %forstart.14 = add i32 0, 1
  store i32 %forstart.14, ptr %i
  br label %for.cond.14
for.cond.14:
  %forvalue.14 = load i32, ptr %i
  %forend.14 = add i32 0, 100
  %forcond.14 = icmp sle i32 %forvalue.14, %forend.14
  br i1 %forcond.14, label %for.body.14, label %for.end.14
for.body.14:
  %acc.assign.23.left = load i32, ptr %acc.addr.7
  %acc.assign.23.right = load i32, ptr %i
  %acc.assign.23 = add i32 %acc.assign.23.left, %acc.assign.23.right
  store i32 %acc.assign.23, ptr %acc.addr.7
  %fornext.14 = add i32 %forvalue.14, 1
  store i32 %fornext.14, ptr %i
  br label %for.cond.14
for.end.14:
  %ifcond.30.i32.left = load i32, ptr %acc.addr.7
  %ifcond.30.i32.right = add i32 0, 5050
  %ifcond.30.i32.comparison = icmp eq i32 %ifcond.30.i32.left, %ifcond.30.i32.right
  %ifcond.30.i32 = zext i1 %ifcond.30.i32.comparison to i32
  %ifcond.30 = icmp ne i32 %ifcond.30.i32, 0
  br i1 %ifcond.30, label %if.then.30, label %if.else.30
if.then.30:
  %ret.37 = add i32 0, 0
  ret i32 %ret.37
if.else.30:
  br label %if.end.30
if.end.30:
  %ret.41 = add i32 0, 1
  ret i32 %ret.41
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

