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

@.str.41 = private unnamed_addr constant [6 x i8] c"alpha\00"
@.str.48 = private unnamed_addr constant [5 x i8] c"beta\00"

define ptr @second(ptr %arg.values) {
entry:
  %values = alloca ptr
  store ptr %arg.values, ptr %values
  %ret.13.index = add i32 0, 1
  %ret.13.data = load ptr, ptr %values
  %ret.13.element = getelementptr inbounds ptr, ptr %ret.13.data, i32 %ret.13.index
  %ret.13 = load ptr, ptr %ret.13.element
  ret ptr %ret.13
}

define i32 @csec_user_main() {
entry:
  %values.addr.27 = alloca ptr
  %values.count.27 = add i32 0, 1
  %values.size.27.0 = add i32 0, 2
  %values.count.27.1 = mul i32 %values.count.27, %values.size.27.0
  %values.data.27 = alloca ptr, i32 %values.count.27.1
  store ptr %values.data.27, ptr %values.addr.27
  %values.index.36 = add i32 0, 0
  %values.data.36 = load ptr, ptr %values.addr.27
  %values.element.36 = getelementptr inbounds ptr, ptr %values.data.36, i32 %values.index.36
  %values.rhs.36 = getelementptr inbounds [6 x i8], ptr @.str.41, i32 0, i32 0
  store ptr %values.rhs.36, ptr %values.element.36
  %values.index.43 = add i32 0, 1
  %values.data.43 = load ptr, ptr %values.addr.27
  %values.element.43 = getelementptr inbounds ptr, ptr %values.data.43, i32 %values.index.43
  %values.rhs.43 = getelementptr inbounds [5 x i8], ptr @.str.48, i32 0, i32 0
  store ptr %values.rhs.43, ptr %values.element.43
  %selected.addr.50 = alloca ptr
  %selected.init.50.arg0 = load ptr, ptr %values.addr.27
  %selected.init.50 = call ptr @second(ptr %selected.init.50.arg0)
  store ptr %selected.init.50, ptr %selected.addr.50
  %ifcond.58.i32.left.string = load ptr, ptr %selected.addr.50
  %ifcond.58.i32.left.length64 = call i64 @csec_string_length(ptr %ifcond.58.i32.left.string)
  %ifcond.58.i32.left = trunc i64 %ifcond.58.i32.left.length64 to i32
  %ifcond.58.i32.right = add i32 0, 4
  %ifcond.58.i32.comparison = icmp eq i32 %ifcond.58.i32.left, %ifcond.58.i32.right
  %ifcond.58.i32 = zext i1 %ifcond.58.i32.comparison to i32
  %ifcond.58 = icmp ne i32 %ifcond.58.i32, 0
  br i1 %ifcond.58, label %if.then.58, label %if.else.58
if.then.58:
  %ret.67 = add i32 0, 0
  ret i32 %ret.67
if.else.58:
  br label %if.end.58
if.end.58:
  %ret.71 = add i32 0, 1
  ret i32 %ret.71
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

