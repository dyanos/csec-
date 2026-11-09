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
%csec.lambda.environment.12 = type { ptr }

define i32 @csec_lambda_12(ptr %arg.env, i32 %arg.x) {
entry:
  %capture.env.0 = getelementptr inbounds %csec.lambda.environment.12, ptr %arg.env, i32 0, i32 0
  %total.addr.7 = load ptr, ptr %capture.env.0
  %x = alloca i32
  store i32 %arg.x, ptr %x
  %total.assign.23.left = load i32, ptr %total.addr.7
  %total.assign.23.right = load i32, ptr %x
  %total.assign.23 = add i32 %total.assign.23.left, %total.assign.23.right
  store i32 %total.assign.23, ptr %total.addr.7
  %ret.29 = load i32, ptr %total.addr.7
  ret i32 %ret.29
}

define i32 @csec_user_main() {
entry:
  %total.addr.7 = alloca i32
  %total.init.7 = add i32 0, 10
  store i32 %total.init.7, ptr %total.addr.7
  %addToTotal.closure.12 = alloca %csec.lambda.closure.12
  %addToTotal.addr.12 = alloca ptr
  %addToTotal.closure.code.12 = getelementptr inbounds %csec.lambda.closure.12, ptr %addToTotal.closure.12, i32 0, i32 0
  store ptr @csec_lambda_12, ptr %addToTotal.closure.code.12
  %addToTotal.closure.env.12 = getelementptr inbounds %csec.lambda.closure.12, ptr %addToTotal.closure.12, i32 0, i32 1
  %addToTotal.environment.12 = alloca %csec.lambda.environment.12
  %addToTotal.capture.12.0 = getelementptr inbounds %csec.lambda.environment.12, ptr %addToTotal.environment.12, i32 0, i32 0
  store ptr %total.addr.7, ptr %addToTotal.capture.12.0
  store ptr %addToTotal.environment.12, ptr %addToTotal.closure.env.12
  store ptr %addToTotal.closure.12, ptr %addToTotal.addr.12
  %discard.34.closure = load ptr, ptr %addToTotal.addr.12
  %discard.34.code.field = getelementptr inbounds %csec.lambda.closure.12, ptr %discard.34.closure, i32 0, i32 0
  %discard.34.code = load ptr, ptr %discard.34.code.field
  %discard.34.environment.field = getelementptr inbounds %csec.lambda.closure.12, ptr %discard.34.closure, i32 0, i32 1
  %discard.34.environment = load ptr, ptr %discard.34.environment.field
  %discard.34.arg0 = add i32 0, 1
  %discard.34 = call i32 %discard.34.code(ptr %discard.34.environment, i32 %discard.34.arg0)
  %ret.39.closure = load ptr, ptr %addToTotal.addr.12
  %ret.39.code.field = getelementptr inbounds %csec.lambda.closure.12, ptr %ret.39.closure, i32 0, i32 0
  %ret.39.code = load ptr, ptr %ret.39.code.field
  %ret.39.environment.field = getelementptr inbounds %csec.lambda.closure.12, ptr %ret.39.closure, i32 0, i32 1
  %ret.39.environment = load ptr, ptr %ret.39.environment.field
  %ret.39.arg0 = add i32 0, 1
  %ret.39 = call i32 %ret.39.code(ptr %ret.39.environment, i32 %ret.39.arg0)
  ret i32 %ret.39
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

