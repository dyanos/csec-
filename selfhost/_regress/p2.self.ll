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

define i32 @findFor(i32 %arg.limit) {
entry:
  %limit = alloca i32
  store i32 %arg.limit, ptr %limit
  %i = alloca i32
  %forstart.10 = add i32 0, 0
  store i32 %forstart.10, ptr %i
  br label %for.cond.10
for.cond.10:
  %forvalue.10 = load i32, ptr %i
  %forend.10 = load i32, ptr %limit
  %forcond.10 = icmp sle i32 %forvalue.10, %forend.10
  br i1 %forcond.10, label %for.body.10, label %for.end.10
for.body.10:
  %ifcond.19.i32.left = load i32, ptr %i
  %ifcond.19.i32.right = add i32 0, 3
  %ifcond.19.i32.comparison = icmp eq i32 %ifcond.19.i32.left, %ifcond.19.i32.right
  %ifcond.19.i32 = zext i1 %ifcond.19.i32.comparison to i32
  %ifcond.19 = icmp ne i32 %ifcond.19.i32, 0
  br i1 %ifcond.19, label %if.then.19, label %if.else.19
if.then.19:
  %ret.26 = load i32, ptr %i
  ret i32 %ret.26
if.else.19:
  br label %if.end.19
if.end.19:
  %fornext.10 = add i32 %forvalue.10, 1
  store i32 %fornext.10, ptr %i
  br label %for.cond.10
for.end.10:
  %ret.31.value = add i32 0, 1
  %ret.31 = sub i32 0, %ret.31.value
  ret i32 %ret.31
}

define i32 @csec_user_main() {
entry:
  %ifcond.43.i32.left.arg0 = add i32 0, 10
  %ifcond.43.i32.left = call i32 @findFor(i32 %ifcond.43.i32.left.arg0)
  %ifcond.43.i32.right = add i32 0, 3
  %ifcond.43.i32.comparison = icmp eq i32 %ifcond.43.i32.left, %ifcond.43.i32.right
  %ifcond.43.i32 = zext i1 %ifcond.43.i32.comparison to i32
  %ifcond.43 = icmp ne i32 %ifcond.43.i32, 0
  br i1 %ifcond.43, label %if.then.43, label %if.else.43
if.then.43:
  %ret.53 = add i32 0, 0
  ret i32 %ret.53
if.else.43:
  br label %if.end.43
if.end.43:
  %ret.57 = add i32 0, 1
  ret i32 %ret.57
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

