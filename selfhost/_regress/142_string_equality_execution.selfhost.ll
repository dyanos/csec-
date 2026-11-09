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

@.str.13 = private unnamed_addr constant [6 x i8] c"hello\00"
@.str.26 = private unnamed_addr constant [6 x i8] c"hello\00"
@.str.37 = private unnamed_addr constant [6 x i8] c"world\00"

define i1 @isHello(ptr %arg.text) {
entry:
  %text = alloca ptr
  store ptr %arg.text, ptr %text
  %ret.10.i32.left = load ptr, ptr %text
  %ret.10.i32.right = getelementptr inbounds [6 x i8], ptr @.str.13, i32 0, i32 0
  %ret.10.i32.equals = call i32 @csec_string_equals(ptr %ret.10.i32.left, ptr %ret.10.i32.right)
  %ret.10.i32.comparison = icmp ne i32 %ret.10.i32.equals, 0
  %ret.10.i32 = zext i1 %ret.10.i32.comparison to i32
  %ret.10 = icmp ne i32 %ret.10.i32, 0
  ret i1 %ret.10
}

define i32 @csec_user_main() {
entry:
  %text.addr.23 = alloca ptr
  %text.init.23 = getelementptr inbounds [6 x i8], ptr @.str.26, i32 0, i32 0
  store ptr %text.init.23, ptr %text.addr.23
  %ifcond.28.left.arg0 = load ptr, ptr %text.addr.23
  %ifcond.28.left = call i1 @isHello(ptr %ifcond.28.left.arg0)
  %ifcond.28.right.i32.left = load ptr, ptr %text.addr.23
  %ifcond.28.right.i32.right = getelementptr inbounds [6 x i8], ptr @.str.37, i32 0, i32 0
  %ifcond.28.right.i32.equals = call i32 @csec_string_equals(ptr %ifcond.28.right.i32.left, ptr %ifcond.28.right.i32.right)
  %ifcond.28.right.i32.comparison = icmp eq i32 %ifcond.28.right.i32.equals, 0
  %ifcond.28.right.i32 = zext i1 %ifcond.28.right.i32.comparison to i32
  %ifcond.28.right = icmp ne i32 %ifcond.28.right.i32, 0
  %ifcond.28 = and i1 %ifcond.28.left, %ifcond.28.right
  br i1 %ifcond.28, label %if.then.28, label %if.else.28
if.then.28:
  %ret.40 = add i32 0, 42
  ret i32 %ret.40
if.else.28:
  br label %if.end.28
if.end.28:
  %ret.44 = add i32 0, 0
  ret i32 %ret.44
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

