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

%csec.lambda.closure.7 = type { ptr, ptr }

define i32 @csec_lambda_7(ptr %arg.env, i32 %arg.x) {
entry:
  %x = alloca i32
  store i32 %arg.x, ptr %x
  %ret.18.left = load i32, ptr %x
  %ret.18.right = add i32 0, 1
  %ret.18 = add i32 %ret.18.left, %ret.18.right
  ret i32 %ret.18
}

define i32 @csec_user_main() {
entry:
  %addOne.closure.7 = alloca %csec.lambda.closure.7
  %addOne.addr.7 = alloca ptr
  %addOne.closure.code.7 = getelementptr inbounds %csec.lambda.closure.7, ptr %addOne.closure.7, i32 0, i32 0
  store ptr @csec_lambda_7, ptr %addOne.closure.code.7
  %addOne.closure.env.7 = getelementptr inbounds %csec.lambda.closure.7, ptr %addOne.closure.7, i32 0, i32 1
  store ptr null, ptr %addOne.closure.env.7
  store ptr %addOne.closure.7, ptr %addOne.addr.7
  %ret.25.closure = load ptr, ptr %addOne.addr.7
  %ret.25.code.field = getelementptr inbounds %csec.lambda.closure.7, ptr %ret.25.closure, i32 0, i32 0
  %ret.25.code = load ptr, ptr %ret.25.code.field
  %ret.25.environment.field = getelementptr inbounds %csec.lambda.closure.7, ptr %ret.25.closure, i32 0, i32 1
  %ret.25.environment = load ptr, ptr %ret.25.environment.field
  %ret.25.arg0 = add i32 0, 41
  %ret.25 = call i32 %ret.25.code(ptr %ret.25.environment, i32 %ret.25.arg0)
  ret i32 %ret.25
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

