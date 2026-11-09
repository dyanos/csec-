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

%csec.lambda.closure.12 = type { ptr, ptr }
%csec.lambda.environment.12 = type { i32 }

define i1 @csec_lambda_12(ptr %arg.env, i32 %arg.x) {
entry:
  %capture.env.0 = getelementptr inbounds %csec.lambda.environment.12, ptr %arg.env, i32 0, i32 0
  %threshold.addr.7 = alloca i32
  %capture.value.0 = load i32, ptr %capture.env.0
  store i32 %capture.value.0, ptr %threshold.addr.7
  %x = alloca i32
  store i32 %arg.x, ptr %x
  %ret.i32.left = load i32, ptr %x
  %ret.i32.right = load i32, ptr %threshold.addr.7
  %ret.i32.comparison = icmp sgt i32 %ret.i32.left, %ret.i32.right
  %ret.i32 = zext i1 %ret.i32.comparison to i32
  %ret = icmp ne i32 %ret.i32, 0
  ret i1 %ret
}

define i32 @csec_user_main() {
entry:
  %threshold.addr.7 = alloca i32
  %threshold.init.7 = add i32 0, 40
  store i32 %threshold.init.7, ptr %threshold.addr.7
  %isAbove.closure.12 = alloca %csec.lambda.closure.12
  %isAbove.addr.12 = alloca ptr
  %isAbove.closure.code.12 = getelementptr inbounds %csec.lambda.closure.12, ptr %isAbove.closure.12, i32 0, i32 0
  store ptr @csec_lambda_12, ptr %isAbove.closure.code.12
  %isAbove.closure.env.12 = getelementptr inbounds %csec.lambda.closure.12, ptr %isAbove.closure.12, i32 0, i32 1
  %isAbove.environment.12 = alloca %csec.lambda.environment.12
  %isAbove.capture.12.0 = getelementptr inbounds %csec.lambda.environment.12, ptr %isAbove.environment.12, i32 0, i32 0
  %isAbove.capture.value.12.0 = load i32, ptr %threshold.addr.7
  store i32 %isAbove.capture.value.12.0, ptr %isAbove.capture.12.0
  store ptr %isAbove.environment.12, ptr %isAbove.closure.env.12
  store ptr %isAbove.closure.12, ptr %isAbove.addr.12
  %ifcond.30.left.closure = load ptr, ptr %isAbove.addr.12
  %ifcond.30.left.code.field = getelementptr inbounds %csec.lambda.closure.12, ptr %ifcond.30.left.closure, i32 0, i32 0
  %ifcond.30.left.code = load ptr, ptr %ifcond.30.left.code.field
  %ifcond.30.left.environment.field = getelementptr inbounds %csec.lambda.closure.12, ptr %ifcond.30.left.closure, i32 0, i32 1
  %ifcond.30.left.environment = load ptr, ptr %ifcond.30.left.environment.field
  %ifcond.30.left.arg0 = add i32 0, 42
  %ifcond.30.left = call i32 %ifcond.30.left.code(ptr %ifcond.30.left.environment, i32 %ifcond.30.left.arg0)
  %ifcond.30 = icmp ne i32 %ifcond.30.left, 0
  br i1 %ifcond.30, label %if.then.30, label %if.else.30
if.then.30:
  %ret.38 = add i32 0, 42
  ret i32 %ret.38
if.else.30:
  br label %if.end.30
if.end.30:
  %ret.42 = add i32 0, 0
  ret i32 %ret.42
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

