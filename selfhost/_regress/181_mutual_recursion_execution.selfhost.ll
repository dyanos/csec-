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

define i1 @isEven(i32 %arg.n) {
entry:
  %n = alloca i32
  store i32 %arg.n, ptr %n
  %ifcond.10.i32.left = load i32, ptr %n
  %ifcond.10.i32.right = add i32 0, 0
  %ifcond.10.i32.comparison = icmp eq i32 %ifcond.10.i32.left, %ifcond.10.i32.right
  %ifcond.10.i32 = zext i1 %ifcond.10.i32.comparison to i32
  %ifcond.10 = icmp ne i32 %ifcond.10.i32, 0
  br i1 %ifcond.10, label %if.then.10, label %if.else.10
if.then.10:
  %ret.17 = icmp eq i32 0, 0
  ret i1 %ret.17
if.else.10:
  br label %if.end.10
if.end.10:
  %ret.21.arg0.left = load i32, ptr %n
  %ret.21.arg0.right = add i32 0, 1
  %ret.21.arg0 = sub i32 %ret.21.arg0.left, %ret.21.arg0.right
  %ret.21 = call i1 @isOdd(i32 %ret.21.arg0)
  ret i1 %ret.21
}

define i1 @isOdd(i32 %arg.n) {
entry:
  %n = alloca i32
  store i32 %arg.n, ptr %n
  %ifcond.40.i32.left = load i32, ptr %n
  %ifcond.40.i32.right = add i32 0, 0
  %ifcond.40.i32.comparison = icmp eq i32 %ifcond.40.i32.left, %ifcond.40.i32.right
  %ifcond.40.i32 = zext i1 %ifcond.40.i32.comparison to i32
  %ifcond.40 = icmp ne i32 %ifcond.40.i32, 0
  br i1 %ifcond.40, label %if.then.40, label %if.else.40
if.then.40:
  %ret.47 = icmp eq i32 0, 1
  ret i1 %ret.47
if.else.40:
  br label %if.end.40
if.end.40:
  %ret.51.arg0.left = load i32, ptr %n
  %ret.51.arg0.right = add i32 0, 1
  %ret.51.arg0 = sub i32 %ret.51.arg0.left, %ret.51.arg0.right
  %ret.51 = call i1 @isEven(i32 %ret.51.arg0)
  ret i1 %ret.51
}

define i32 @csec_user_main() {
entry:
  %ifcond.67.left.left.left.arg0 = add i32 0, 10
  %ifcond.67.left.left.left = call i1 @isEven(i32 %ifcond.67.left.left.left.arg0)
  %ifcond.67.left.left.right.arg0 = add i32 0, 7
  %ifcond.67.left.left.right = call i1 @isOdd(i32 %ifcond.67.left.left.right.arg0)
  %ifcond.67.left.left = and i1 %ifcond.67.left.left.left, %ifcond.67.left.left.right
  %ifcond.67.left.right.arg0 = add i32 0, 0
  %ifcond.67.left.right = call i1 @isEven(i32 %ifcond.67.left.right.arg0)
  %ifcond.67.left = and i1 %ifcond.67.left.left, %ifcond.67.left.right
  %ifcond.67.right.arg0 = add i32 0, 1
  %ifcond.67.right = call i1 @isOdd(i32 %ifcond.67.right.arg0)
  %ifcond.67 = and i1 %ifcond.67.left, %ifcond.67.right
  br i1 %ifcond.67, label %if.then.67, label %if.else.67
if.then.67:
  %ret.90 = add i32 0, 0
  ret i32 %ret.90
if.else.67:
  br label %if.end.67
if.end.67:
  %ret.94 = add i32 0, 1
  ret i32 %ret.94
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

