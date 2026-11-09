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

define i32 @csec_user_main() {
entry:
  %a.addr.7 = alloca i32
  %a.init.7 = add i32 0, 7
  store i32 %a.init.7, ptr %a.addr.7
  %b.addr.14 = alloca i32
  %b.init.14 = add i32 0, 3
  store i32 %b.init.14, ptr %b.addr.14
  %q.addr.21 = alloca i32
  %q.init.21.left = load i32, ptr %a.addr.7
  %q.init.21.right = load i32, ptr %b.addr.14
  %q.init.21 = sdiv i32 %q.init.21.left, %q.init.21.right
  store i32 %q.init.21, ptr %q.addr.21
  %r.addr.30 = alloca i32
  %r.init.30.left = load i32, ptr %a.addr.7
  %r.init.30.right = load i32, ptr %b.addr.14
  %r.init.30 = srem i32 %r.init.30.left, %r.init.30.right
  store i32 %r.init.30, ptr %r.addr.30
  %neg.addr.39 = alloca i32
  %neg.init.39.left = add i32 0, 0
  %neg.init.39.right = add i32 0, 5
  %neg.init.39 = sub i32 %neg.init.39.left, %neg.init.39.right
  store i32 %neg.init.39, ptr %neg.addr.39
  %ifcond.48.left.left.i32.left = load i32, ptr %q.addr.21
  %ifcond.48.left.left.i32.right = add i32 0, 2
  %ifcond.48.left.left.i32.comparison = icmp eq i32 %ifcond.48.left.left.i32.left, %ifcond.48.left.left.i32.right
  %ifcond.48.left.left.i32 = zext i1 %ifcond.48.left.left.i32.comparison to i32
  %ifcond.48.left.left = icmp ne i32 %ifcond.48.left.left.i32, 0
  %ifcond.48.left.right.i32.left = load i32, ptr %r.addr.30
  %ifcond.48.left.right.i32.right = add i32 0, 1
  %ifcond.48.left.right.i32.comparison = icmp eq i32 %ifcond.48.left.right.i32.left, %ifcond.48.left.right.i32.right
  %ifcond.48.left.right.i32 = zext i1 %ifcond.48.left.right.i32.comparison to i32
  %ifcond.48.left.right = icmp ne i32 %ifcond.48.left.right.i32, 0
  %ifcond.48.left = and i1 %ifcond.48.left.left, %ifcond.48.left.right
  %ifcond.48.right.i32.left = load i32, ptr %neg.addr.39
  %ifcond.48.right.i32.right.left = add i32 0, 0
  %ifcond.48.right.i32.right.right = add i32 0, 5
  %ifcond.48.right.i32.right = sub i32 %ifcond.48.right.i32.right.left, %ifcond.48.right.i32.right.right
  %ifcond.48.right.i32.comparison = icmp eq i32 %ifcond.48.right.i32.left, %ifcond.48.right.i32.right
  %ifcond.48.right.i32 = zext i1 %ifcond.48.right.i32.comparison to i32
  %ifcond.48.right = icmp ne i32 %ifcond.48.right.i32, 0
  %ifcond.48 = and i1 %ifcond.48.left, %ifcond.48.right
  br i1 %ifcond.48, label %if.then.48, label %if.else.48
if.then.48:
  %ret.65 = add i32 0, 0
  ret i32 %ret.65
if.else.48:
  br label %if.end.48
if.end.48:
  %ret.69 = add i32 0, 1
  ret i32 %ret.69
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

