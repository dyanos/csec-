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

@.str.34 = private unnamed_addr constant [6 x i8] c"base+\00"
@.str.76 = private unnamed_addr constant [8 x i8] c"scaled+\00"
@.str.116 = private unnamed_addr constant [3 x i8] c"ok\00"
@.str.130 = private unnamed_addr constant [3 x i8] c"ok\00"

define i32 @Accumulator_operator_add_Int(i32 %arg.right) {
entry:
  %right = alloca i32
  store i32 %arg.right, ptr %right
  %ret.16.left = load i32, ptr %right
  %ret.16.right = add i32 0, 1
  %ret.16 = add i32 %ret.16.left, %ret.16.right
  ret i32 %ret.16
}

define ptr @Accumulator_operator_add_String(ptr %arg.right) {
entry:
  %right = alloca ptr
  store ptr %arg.right, ptr %right
  %ret.33.left = getelementptr inbounds [6 x i8], ptr @.str.34, i32 0, i32 0
  %ret.33.right = load ptr, ptr %right
  %ret.33 = call ptr @csec_string_concat(ptr %ret.33.left, ptr %ret.33.right)
  ret ptr %ret.33
}

define i32 @ScaledAccumulator_operator_add_Int(i32 %arg.right) {
entry:
  %right = alloca i32
  store i32 %arg.right, ptr %right
  %ret.57.left = load i32, ptr %right
  %ret.57.right = add i32 0, 10
  %ret.57 = add i32 %ret.57.left, %ret.57.right
  ret i32 %ret.57
}

define ptr @ScaledAccumulator_operator_add_String(ptr %arg.right) {
entry:
  %right = alloca ptr
  store ptr %arg.right, ptr %right
  %ret.75.left = getelementptr inbounds [8 x i8], ptr @.str.76, i32 0, i32 0
  %ret.75.right = load ptr, ptr %right
  %ret.75 = call ptr @csec_string_concat(ptr %ret.75.left, ptr %ret.75.right)
  ret ptr %ret.75
}

define i32 @csec_user_main() {
entry:
  %base.addr.89 = alloca i32
  store i32 0, ptr %base.addr.89
  %scaled.addr.97 = alloca i32
  store i32 0, ptr %scaled.addr.97
  %println.105.value.oparg = add i32 0, 4
  %println.105.value = call i32 @Accumulator_operator_add_Int(i32 %println.105.value.oparg)
  %println.105.wide = sext i32 %println.105.value to i64
  call void @csec_print_i64(i64 %println.105.wide)
  call void @csec_print_newline()
  %println.112.string.oparg = getelementptr inbounds [3 x i8], ptr @.str.116, i32 0, i32 0
  %println.112.string = call ptr @Accumulator_operator_add_String(ptr %println.112.string.oparg)
  call void @csec_print_string(ptr %println.112.string)
  call void @csec_print_newline()
  %println.119.value.oparg = add i32 0, 4
  %println.119.value = call i32 @ScaledAccumulator_operator_add_Int(i32 %println.119.value.oparg)
  %println.119.wide = sext i32 %println.119.value to i64
  call void @csec_print_i64(i64 %println.119.wide)
  call void @csec_print_newline()
  %println.126.string.oparg = getelementptr inbounds [3 x i8], ptr @.str.130, i32 0, i32 0
  %println.126.string = call ptr @ScaledAccumulator_operator_add_String(ptr %println.126.string.oparg)
  call void @csec_print_string(ptr %println.126.string)
  call void @csec_print_newline()
  %ret.133 = add i32 0, 0
  ret i32 %ret.133
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

