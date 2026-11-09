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

define i32 @max3(i32 %arg.a, i32 %arg.b, i32 %arg.c) {
entry:
  %a = alloca i32
  store i32 %arg.a, ptr %a
  %b = alloca i32
  store i32 %arg.b, ptr %b
  %c = alloca i32
  store i32 %arg.c, ptr %c
  %m.addr.18 = alloca i32
  %m.init.18 = load i32, ptr %a
  store i32 %m.init.18, ptr %m.addr.18
  %ifcond.25.i32.left = load i32, ptr %b
  %ifcond.25.i32.right = load i32, ptr %m.addr.18
  %ifcond.25.i32.comparison = icmp sgt i32 %ifcond.25.i32.left, %ifcond.25.i32.right
  %ifcond.25.i32 = zext i1 %ifcond.25.i32.comparison to i32
  %ifcond.25 = icmp ne i32 %ifcond.25.i32, 0
  br i1 %ifcond.25, label %if.then.25, label %if.else.25
if.then.25:
  %m.assign.32 = load i32, ptr %b
  store i32 %m.assign.32, ptr %m.addr.18
  br label %if.end.25
if.else.25:
  br label %if.end.25
if.end.25:
  %ifcond.37.i32.left = load i32, ptr %c
  %ifcond.37.i32.right = load i32, ptr %m.addr.18
  %ifcond.37.i32.comparison = icmp sgt i32 %ifcond.37.i32.left, %ifcond.37.i32.right
  %ifcond.37.i32 = zext i1 %ifcond.37.i32.comparison to i32
  %ifcond.37 = icmp ne i32 %ifcond.37.i32, 0
  br i1 %ifcond.37, label %if.then.37, label %if.else.37
if.then.37:
  %m.assign.44 = load i32, ptr %c
  store i32 %m.assign.44, ptr %m.addr.18
  br label %if.end.37
if.else.37:
  br label %if.end.37
if.end.37:
  %ret.49 = load i32, ptr %m.addr.18
  ret i32 %ret.49
}

define i32 @csec_user_main() {
entry:
  %ifcond.60.left.i32.left.arg0 = add i32 0, 3
  %ifcond.60.left.i32.left.arg1 = add i32 0, 9
  %ifcond.60.left.i32.left.arg2 = add i32 0, 5
  %ifcond.60.left.i32.left = call i32 @max3(i32 %ifcond.60.left.i32.left.arg0, i32 %ifcond.60.left.i32.left.arg1, i32 %ifcond.60.left.i32.left.arg2)
  %ifcond.60.left.i32.right = add i32 0, 9
  %ifcond.60.left.i32.comparison = icmp eq i32 %ifcond.60.left.i32.left, %ifcond.60.left.i32.right
  %ifcond.60.left.i32 = zext i1 %ifcond.60.left.i32.comparison to i32
  %ifcond.60.left = icmp ne i32 %ifcond.60.left.i32, 0
  %ifcond.60.right.i32.left.arg0 = add i32 0, 7
  %ifcond.60.right.i32.left.arg1 = add i32 0, 2
  %ifcond.60.right.i32.left.arg2 = add i32 0, 4
  %ifcond.60.right.i32.left = call i32 @max3(i32 %ifcond.60.right.i32.left.arg0, i32 %ifcond.60.right.i32.left.arg1, i32 %ifcond.60.right.i32.left.arg2)
  %ifcond.60.right.i32.right = add i32 0, 7
  %ifcond.60.right.i32.comparison = icmp eq i32 %ifcond.60.right.i32.left, %ifcond.60.right.i32.right
  %ifcond.60.right.i32 = zext i1 %ifcond.60.right.i32.comparison to i32
  %ifcond.60.right = icmp ne i32 %ifcond.60.right.i32, 0
  %ifcond.60 = and i1 %ifcond.60.left, %ifcond.60.right
  br i1 %ifcond.60, label %if.then.60, label %if.else.60
if.then.60:
  %ret.85 = add i32 0, 0
  ret i32 %ret.85
if.else.60:
  br label %if.end.60
if.end.60:
  %ret.89 = add i32 0, 1
  ret i32 %ret.89
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

