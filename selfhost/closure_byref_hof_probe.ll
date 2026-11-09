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

%csec.lambda.closure.37 = type { ptr, ptr }
%csec.lambda.environment.37 = type { ptr }

define i32 @csec_lambda_37(ptr %arg.env, i32 %arg.x) {
entry:
  %capture.env.0 = getelementptr inbounds %csec.lambda.environment.37, ptr %arg.env, i32 0, i32 0
  %total.addr.32 = load ptr, ptr %capture.env.0
  %x = alloca i32
  store i32 %arg.x, ptr %x
  %total.assign.48.left = load i32, ptr %total.addr.32
  %total.assign.48.right = load i32, ptr %x
  %total.assign.48 = add i32 %total.assign.48.left, %total.assign.48.right
  store i32 %total.assign.48, ptr %total.addr.32
  %ret.54 = load i32, ptr %total.addr.32
  ret i32 %ret.54
}

define i32 @invoke(ptr %arg.f, i32 %arg.x) {
entry:
  %f = alloca ptr
  store ptr %arg.f, ptr %f
  %x = alloca i32
  store i32 %arg.x, ptr %x
  %ret.18.arg0 = load i32, ptr %x
  %ret.18.closure = load ptr, ptr %f
  %ret.18.code.field = getelementptr inbounds { ptr, ptr }, ptr %ret.18.closure, i32 0, i32 0
  %ret.18.fn = load ptr, ptr %ret.18.code.field
  %ret.18.environment.field = getelementptr inbounds { ptr, ptr }, ptr %ret.18.closure, i32 0, i32 1
  %ret.18.environment = load ptr, ptr %ret.18.environment.field
  %ret.18 = call i32 %ret.18.fn(ptr %ret.18.environment, i32 %ret.18.arg0)
  ret i32 %ret.18
}

define i32 @csec_user_main() {
entry:
  %total.addr.32 = alloca i32
  %total.init.32 = add i32 0, 10
  store i32 %total.init.32, ptr %total.addr.32
  %addToTotal.closure.37 = alloca %csec.lambda.closure.37
  %addToTotal.addr.37 = alloca ptr
  %addToTotal.closure.code.37 = getelementptr inbounds %csec.lambda.closure.37, ptr %addToTotal.closure.37, i32 0, i32 0
  store ptr @csec_lambda_37, ptr %addToTotal.closure.code.37
  %addToTotal.closure.env.37 = getelementptr inbounds %csec.lambda.closure.37, ptr %addToTotal.closure.37, i32 0, i32 1
  %addToTotal.environment.37 = alloca %csec.lambda.environment.37
  %addToTotal.capture.37.0 = getelementptr inbounds %csec.lambda.environment.37, ptr %addToTotal.environment.37, i32 0, i32 0
  store ptr %total.addr.32, ptr %addToTotal.capture.37.0
  store ptr %addToTotal.environment.37, ptr %addToTotal.closure.env.37
  store ptr %addToTotal.closure.37, ptr %addToTotal.addr.37
  %discard.59.closure.arg0 = load ptr, ptr %addToTotal.addr.37
  %discard.59.arg1 = add i32 0, 1
  %discard.59 = call i32 @invoke(ptr %discard.59.closure.arg0, i32 %discard.59.arg1)
  %ret.66.closure.arg0 = load ptr, ptr %addToTotal.addr.37
  %ret.66.arg1 = add i32 0, 1
  %ret.66 = call i32 @invoke(ptr %ret.66.closure.arg0, i32 %ret.66.arg1)
  ret i32 %ret.66
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

