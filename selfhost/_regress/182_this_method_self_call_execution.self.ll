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

define i32 @Stack_size(i32 %arg.this.capacity) {
entry:
  %capacity = alloca i32
  store i32 %arg.this.capacity, ptr %capacity
  %ret.15 = load i32, ptr %capacity
  ret i32 %ret.15
}

define i32 @Stack_doubled(i32 %arg.this.capacity) {
entry:
  %capacity = alloca i32
  store i32 %arg.this.capacity, ptr %capacity
  %ret.26.left.this.recv0 = load i32, ptr %capacity
  %ret.26.left = call i32 @Stack_size(i32 %ret.26.left.this.recv0)
  %ret.26.right.this.recv0 = load i32, ptr %capacity
  %ret.26.right = call i32 @Stack_size(i32 %ret.26.right.this.recv0)
  %ret.26 = add i32 %ret.26.left, %ret.26.right
  ret i32 %ret.26
}

define i32 @Stack_plus(i32 %arg.this.capacity, i32 %arg.extra) {
entry:
  %capacity = alloca i32
  store i32 %arg.this.capacity, ptr %capacity
  %extra = alloca i32
  store i32 %arg.extra, ptr %extra
  %ret.50.left.this.recv0 = load i32, ptr %capacity
  %ret.50.left = call i32 @Stack_size(i32 %ret.50.left.this.recv0)
  %ret.50.right = load i32, ptr %extra
  %ret.50 = add i32 %ret.50.left, %ret.50.right
  ret i32 %ret.50
}

define i32 @csec_user_main() {
entry:
  %s.addr.68 = alloca i32
  store i32 0, ptr %s.addr.68
  %ifcond.77.left.i32.left.arg0 = add i32 0, 21
  %ifcond.77.left.i32.left = call i32 @Stack_doubled(i32 %ifcond.77.left.i32.left.arg0)
  %ifcond.77.left.i32.right = add i32 0, 42
  %ifcond.77.left.i32.comparison = icmp eq i32 %ifcond.77.left.i32.left, %ifcond.77.left.i32.right
  %ifcond.77.left.i32 = zext i1 %ifcond.77.left.i32.comparison to i32
  %ifcond.77.left = icmp ne i32 %ifcond.77.left.i32, 0
  %ifcond.77.right.i32.left.arg0 = add i32 0, 21
  %ifcond.77.right.i32.left.arg1 = add i32 0, 8
  %ifcond.77.right.i32.left = call i32 @Stack_plus(i32 %ifcond.77.right.i32.left.arg0, i32 %ifcond.77.right.i32.left.arg1)
  %ifcond.77.right.i32.right = add i32 0, 29
  %ifcond.77.right.i32.comparison = icmp eq i32 %ifcond.77.right.i32.left, %ifcond.77.right.i32.right
  %ifcond.77.right.i32 = zext i1 %ifcond.77.right.i32.comparison to i32
  %ifcond.77.right = icmp ne i32 %ifcond.77.right.i32, 0
  %ifcond.77 = and i1 %ifcond.77.left, %ifcond.77.right
  br i1 %ifcond.77, label %if.then.77, label %if.else.77
if.then.77:
  %ret.97 = add i32 0, 0
  ret i32 %ret.97
if.else.77:
  br label %if.end.77
if.end.77:
  %ret.101 = add i32 0, 1
  ret i32 %ret.101
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

