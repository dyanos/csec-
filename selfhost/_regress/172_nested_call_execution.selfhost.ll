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

define i32 @addPair(i32 %arg.left, i32 %arg.right) {
entry:
  %left = alloca i32
  store i32 %arg.left, ptr %left
  %right = alloca i32
  store i32 %arg.right, ptr %right
  %ret.14.left = load i32, ptr %left
  %ret.14.right = load i32, ptr %right
  %ret.14 = add i32 %ret.14.left, %ret.14.right
  ret i32 %ret.14
}

define i32 @scale(i32 %arg.value, i32 %arg.factor) {
entry:
  %value = alloca i32
  store i32 %arg.value, ptr %value
  %factor = alloca i32
  store i32 %arg.factor, ptr %factor
  %ret.34.left = load i32, ptr %value
  %ret.34.right = load i32, ptr %factor
  %ret.34 = mul i32 %ret.34.left, %ret.34.right
  ret i32 %ret.34
}

define i32 @csec_user_main() {
entry:
  %nested.addr.47 = alloca i32
  %nested.init.47.arg0.arg0 = add i32 0, 1
  %nested.init.47.arg0.arg1 = add i32 0, 2
  %nested.init.47.arg0 = call i32 @addPair(i32 %nested.init.47.arg0.arg0, i32 %nested.init.47.arg0.arg1)
  %nested.init.47.arg1.arg0 = add i32 0, 3
  %nested.init.47.arg1.arg1 = add i32 0, 4
  %nested.init.47.arg1 = call i32 @addPair(i32 %nested.init.47.arg1.arg0, i32 %nested.init.47.arg1.arg1)
  %nested.init.47 = call i32 @addPair(i32 %nested.init.47.arg0, i32 %nested.init.47.arg1)
  store i32 %nested.init.47, ptr %nested.addr.47
  %mixed.addr.67 = alloca i32
  %mixed.init.67.arg0.arg0 = add i32 0, 2
  %mixed.init.67.arg0.arg1 = add i32 0, 3
  %mixed.init.67.arg0 = call i32 @addPair(i32 %mixed.init.67.arg0.arg0, i32 %mixed.init.67.arg0.arg1)
  %mixed.init.67.arg1.arg0 = add i32 0, 1
  %mixed.init.67.arg1.arg1 = add i32 0, 1
  %mixed.init.67.arg1 = call i32 @addPair(i32 %mixed.init.67.arg1.arg0, i32 %mixed.init.67.arg1.arg1)
  %mixed.init.67 = call i32 @scale(i32 %mixed.init.67.arg0, i32 %mixed.init.67.arg1)
  store i32 %mixed.init.67, ptr %mixed.addr.67
  %ifcond.87.left.i32.left = load i32, ptr %nested.addr.47
  %ifcond.87.left.i32.right = add i32 0, 10
  %ifcond.87.left.i32.comparison = icmp eq i32 %ifcond.87.left.i32.left, %ifcond.87.left.i32.right
  %ifcond.87.left.i32 = zext i1 %ifcond.87.left.i32.comparison to i32
  %ifcond.87.left = icmp ne i32 %ifcond.87.left.i32, 0
  %ifcond.87.right.i32.left = load i32, ptr %mixed.addr.67
  %ifcond.87.right.i32.right = add i32 0, 10
  %ifcond.87.right.i32.comparison = icmp eq i32 %ifcond.87.right.i32.left, %ifcond.87.right.i32.right
  %ifcond.87.right.i32 = zext i1 %ifcond.87.right.i32.comparison to i32
  %ifcond.87.right = icmp ne i32 %ifcond.87.right.i32, 0
  %ifcond.87 = and i1 %ifcond.87.left, %ifcond.87.right
  br i1 %ifcond.87, label %if.then.87, label %if.else.87
if.then.87:
  %ret.98 = add i32 0, 0
  ret i32 %ret.98
if.else.87:
  br label %if.end.87
if.end.87:
  %ret.102 = add i32 0, 1
  ret i32 %ret.102
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

