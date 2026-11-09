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

%csec.lambda.closure.7 = type { ptr, ptr }
%csec.lambda.closure.25 = type { ptr, ptr }
%csec.lambda.environment.25 = type { i32, i32 }
%csec.lambda.closure.47 = type { ptr, ptr }

define i32 @csec_lambda_7(ptr %arg.env, i32 %arg.x) {
entry:
  %x = alloca i32
  store i32 %arg.x, ptr %x
  %ret.18.left = load i32, ptr %x
  %ret.18.right = add i32 0, 1
  %ret.18 = add i32 %ret.18.left, %ret.18.right
  ret i32 %ret.18
}

define i32 @csec_lambda_25(ptr %arg.env, i32 %arg.value) {
entry:
  %capture.env.0 = getelementptr inbounds %csec.lambda.environment.25, ptr %arg.env, i32 0, i32 0
  %left = alloca i32
  %capture.value.0 = load i32, ptr %capture.env.0
  store i32 %capture.value.0, ptr %left
  %capture.env.1 = getelementptr inbounds %csec.lambda.environment.25, ptr %arg.env, i32 0, i32 1
  %right = alloca i32
  %capture.value.1 = load i32, ptr %capture.env.1
  store i32 %capture.value.1, ptr %right
  %value = alloca i32
  store i32 %arg.value, ptr %value
  %ret.38.left.left = load i32, ptr %value
  %ret.38.left.right = load i32, ptr %left
  %ret.38.left = add i32 %ret.38.left.left, %ret.38.left.right
  %ret.38.right = load i32, ptr %right
  %ret.38 = add i32 %ret.38.left, %ret.38.right
  ret i32 %ret.38
}

define i32 @csec_lambda_47(ptr %arg.env, i32 %arg.x) {
entry:
  %x = alloca i32
  store i32 %arg.x, ptr %x
  %ret.58 = load i32, ptr %x
  ret i32 %ret.58
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
  %blend.closure.25 = alloca %csec.lambda.closure.25
  %blend.addr.25 = alloca ptr
  %blend.closure.code.25 = getelementptr inbounds %csec.lambda.closure.25, ptr %blend.closure.25, i32 0, i32 0
  store ptr @csec_lambda_25, ptr %blend.closure.code.25
  %blend.closure.env.25 = getelementptr inbounds %csec.lambda.closure.25, ptr %blend.closure.25, i32 0, i32 1
  %blend.environment.25 = alloca %csec.lambda.environment.25
  %blend.capture.25.0 = getelementptr inbounds %csec.lambda.environment.25, ptr %blend.environment.25, i32 0, i32 0
  %blend.capture.value.25.0 = load i32, ptr %left
  store i32 %blend.capture.value.25.0, ptr %blend.capture.25.0
  %blend.capture.25.1 = getelementptr inbounds %csec.lambda.environment.25, ptr %blend.environment.25, i32 0, i32 1
  %blend.capture.value.25.1 = load i32, ptr %right
  store i32 %blend.capture.value.25.1, ptr %blend.capture.25.1
  store ptr %blend.environment.25, ptr %blend.closure.env.25
  store ptr %blend.closure.25, ptr %blend.addr.25
  %refCapture.closure.47 = alloca %csec.lambda.closure.47
  %refCapture.addr.47 = alloca ptr
  %refCapture.closure.code.47 = getelementptr inbounds %csec.lambda.closure.47, ptr %refCapture.closure.47, i32 0, i32 0
  store ptr @csec_lambda_47, ptr %refCapture.closure.code.47
  %refCapture.closure.env.47 = getelementptr inbounds %csec.lambda.closure.47, ptr %refCapture.closure.47, i32 0, i32 1
  store ptr null, ptr %refCapture.closure.env.47
  store ptr %refCapture.closure.47, ptr %refCapture.addr.47
  %ret.63 = add i32 0, 0
  ret i32 %ret.63
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

