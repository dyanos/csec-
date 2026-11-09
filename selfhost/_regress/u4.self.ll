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

@.str.12 = private unnamed_addr constant [12 x i8] c"hello world\00"
@.str.49 = private unnamed_addr constant [6 x i8] c"hello\00"

define i32 @csec_user_main() {
entry:
  %s.addr.7 = alloca ptr
  %s.init.7 = getelementptr inbounds [12 x i8], ptr @.str.12, i32 0, i32 0
  store ptr %s.init.7, ptr %s.addr.7
  %up.addr.14 = alloca ptr
  %up.init.14.string = load ptr, ptr %s.addr.7
  %up.init.14 = call ptr @csec_string_to_upper(ptr %up.init.14.string)
  store ptr %up.init.14, ptr %up.addr.14
  %sub.addr.25 = alloca ptr
  %sub.init.25.string = load ptr, ptr %s.addr.7
  %sub.init.25.offset = add i32 0, 0
  %sub.init.25.length = add i32 0, 5
  %sub.init.25 = call ptr @csec_string_substring(ptr %sub.init.25.string, i32 %sub.init.25.offset, i32 %sub.init.25.length)
  store ptr %sub.init.25, ptr %sub.addr.25
  %ifcond.39.left.i32.left.string = load ptr, ptr %up.addr.14
  %ifcond.39.left.i32.left.length64 = call i64 @csec_string_length(ptr %ifcond.39.left.i32.left.string)
  %ifcond.39.left.i32.left = trunc i64 %ifcond.39.left.i32.left.length64 to i32
  %ifcond.39.left.i32.right = add i32 0, 11
  %ifcond.39.left.i32.comparison = icmp eq i32 %ifcond.39.left.i32.left, %ifcond.39.left.i32.right
  %ifcond.39.left.i32 = zext i1 %ifcond.39.left.i32.comparison to i32
  %ifcond.39.left = icmp ne i32 %ifcond.39.left.i32, 0
  %ifcond.39.right.i32.left = load ptr, ptr %sub.addr.25
  %ifcond.39.right.i32.right = getelementptr inbounds [6 x i8], ptr @.str.49, i32 0, i32 0
  %ifcond.39.right.i32.equals = call i32 @csec_string_equals(ptr %ifcond.39.right.i32.left, ptr %ifcond.39.right.i32.right)
  %ifcond.39.right.i32.comparison = icmp ne i32 %ifcond.39.right.i32.equals, 0
  %ifcond.39.right.i32 = zext i1 %ifcond.39.right.i32.comparison to i32
  %ifcond.39.right = icmp ne i32 %ifcond.39.right.i32, 0
  %ifcond.39 = and i1 %ifcond.39.left, %ifcond.39.right
  br i1 %ifcond.39, label %if.then.39, label %if.else.39
if.then.39:
  %ret.52 = add i32 0, 0
  ret i32 %ret.52
if.else.39:
  br label %if.end.39
if.end.39:
  %ret.56 = add i32 0, 1
  ret i32 %ret.56
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

