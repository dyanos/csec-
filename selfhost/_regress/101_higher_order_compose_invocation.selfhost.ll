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

%csec.lambda.closure.43 = type { ptr, ptr }
%csec.lambda.closure.61 = type { ptr, ptr }

define i32 @csec_lambda_43(ptr %arg.env, i32 %arg.x) {
entry:
  %x = alloca i32
  store i32 %arg.x, ptr %x
  %ret.54.left = load i32, ptr %x
  %ret.54.right = add i32 0, 1
  %ret.54 = add i32 %ret.54.left, %ret.54.right
  ret i32 %ret.54
}

define i32 @csec_lambda_61(ptr %arg.env, i32 %arg.x) {
entry:
  %x = alloca i32
  store i32 %arg.x, ptr %x
  %ret.72.left = load i32, ptr %x
  %ret.72.right = add i32 0, 2
  %ret.72 = mul i32 %ret.72.left, %ret.72.right
  ret i32 %ret.72
}

define i32 @compose(ptr %arg.f, ptr %arg.g, i32 %arg.x) {
entry:
  %f = alloca ptr
  store ptr %arg.f, ptr %f
  %g = alloca ptr
  store ptr %arg.g, ptr %g
  %x = alloca i32
  store i32 %arg.x, ptr %x
  %ret.26.arg0.arg0 = load i32, ptr %x
  %ret.26.arg0.closure = load ptr, ptr %g
  %ret.26.arg0.code.field = getelementptr inbounds { ptr, ptr }, ptr %ret.26.arg0.closure, i32 0, i32 0
  %ret.26.arg0.fn = load ptr, ptr %ret.26.arg0.code.field
  %ret.26.arg0.environment.field = getelementptr inbounds { ptr, ptr }, ptr %ret.26.arg0.closure, i32 0, i32 1
  %ret.26.arg0.environment = load ptr, ptr %ret.26.arg0.environment.field
  %ret.26.arg0 = call i32 %ret.26.arg0.fn(ptr %ret.26.arg0.environment, i32 %ret.26.arg0.arg0)
  %ret.26.closure = load ptr, ptr %f
  %ret.26.code.field = getelementptr inbounds { ptr, ptr }, ptr %ret.26.closure, i32 0, i32 0
  %ret.26.fn = load ptr, ptr %ret.26.code.field
  %ret.26.environment.field = getelementptr inbounds { ptr, ptr }, ptr %ret.26.closure, i32 0, i32 1
  %ret.26.environment = load ptr, ptr %ret.26.environment.field
  %ret.26 = call i32 %ret.26.fn(ptr %ret.26.environment, i32 %ret.26.arg0)
  ret i32 %ret.26
}

define i32 @csec_user_main() {
entry:
  %addOne.closure.43 = alloca %csec.lambda.closure.43
  %addOne.addr.43 = alloca ptr
  %addOne.closure.code.43 = getelementptr inbounds %csec.lambda.closure.43, ptr %addOne.closure.43, i32 0, i32 0
  store ptr @csec_lambda_43, ptr %addOne.closure.code.43
  %addOne.closure.env.43 = getelementptr inbounds %csec.lambda.closure.43, ptr %addOne.closure.43, i32 0, i32 1
  store ptr null, ptr %addOne.closure.env.43
  store ptr %addOne.closure.43, ptr %addOne.addr.43
  %double.closure.61 = alloca %csec.lambda.closure.61
  %double.addr.61 = alloca ptr
  %double.closure.code.61 = getelementptr inbounds %csec.lambda.closure.61, ptr %double.closure.61, i32 0, i32 0
  store ptr @csec_lambda_61, ptr %double.closure.code.61
  %double.closure.env.61 = getelementptr inbounds %csec.lambda.closure.61, ptr %double.closure.61, i32 0, i32 1
  store ptr null, ptr %double.closure.env.61
  store ptr %double.closure.61, ptr %double.addr.61
  %ret.79.closure.arg0 = load ptr, ptr %addOne.addr.43
  %ret.79.closure.arg1 = load ptr, ptr %double.addr.61
  %ret.79.arg2 = add i32 0, 20
  %ret.79 = call i32 @compose(ptr %ret.79.closure.arg0, ptr %ret.79.closure.arg1, i32 %ret.79.arg2)
  ret i32 %ret.79
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

