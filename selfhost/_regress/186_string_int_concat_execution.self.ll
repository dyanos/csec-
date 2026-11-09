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

@.str.11 = private unnamed_addr constant [7 x i8] c"count=\00"
@.str.38 = private unnamed_addr constant [2 x i8] c"a\00"
@.str.42 = private unnamed_addr constant [2 x i8] c"b\00"
@.str.48 = private unnamed_addr constant [8 x i8] c"count=7\00"

define ptr @render(i32 %arg.count) {
entry:
  %count = alloca i32
  store i32 %arg.count, ptr %count
  %ret.10.left = getelementptr inbounds [7 x i8], ptr @.str.11, i32 0, i32 0
  %ret.10.right.i32 = load i32, ptr %count
  %ret.10.right.i64 = sext i32 %ret.10.right.i32 to i64
  %ret.10.right = call ptr @csec_to_string_i64(i64 %ret.10.right.i64)
  %ret.10 = call ptr @csec_string_concat(ptr %ret.10.left, ptr %ret.10.right)
  ret ptr %ret.10
}

define i32 @csec_user_main() {
entry:
  %label.addr.23 = alloca ptr
  %label.init.23.arg0 = add i32 0, 7
  %label.init.23 = call ptr @render(i32 %label.init.23.arg0)
  store ptr %label.init.23, ptr %label.addr.23
  %mixed.addr.33 = alloca ptr
  %mixed.init.33.left.i32.left = add i32 0, 0
  %mixed.init.33.left.i32.right = add i32 0, 1
  %mixed.init.33.left.i32 = add i32 %mixed.init.33.left.i32.left, %mixed.init.33.left.i32.right
  %mixed.init.33.left.i64 = sext i32 %mixed.init.33.left.i32 to i64
  %mixed.init.33.left = call ptr @csec_to_string_i64(i64 %mixed.init.33.left.i64)
  %mixed.init.33.right = getelementptr inbounds [2 x i8], ptr @.str.42, i32 0, i32 0
  %mixed.init.33 = call ptr @csec_string_concat(ptr %mixed.init.33.left, ptr %mixed.init.33.right)
  store ptr %mixed.init.33, ptr %mixed.addr.33
  %ifcond.44.left.i32.left = load ptr, ptr %label.addr.23
  %ifcond.44.left.i32.right = getelementptr inbounds [8 x i8], ptr @.str.48, i32 0, i32 0
  %ifcond.44.left.i32.equals = call i32 @csec_string_equals(ptr %ifcond.44.left.i32.left, ptr %ifcond.44.left.i32.right)
  %ifcond.44.left.i32.comparison = icmp ne i32 %ifcond.44.left.i32.equals, 0
  %ifcond.44.left.i32 = zext i1 %ifcond.44.left.i32.comparison to i32
  %ifcond.44.left = icmp ne i32 %ifcond.44.left.i32, 0
  %ifcond.44.right.i32.left.string = load ptr, ptr %mixed.addr.33
  %ifcond.44.right.i32.left.length64 = call i64 @csec_string_length(ptr %ifcond.44.right.i32.left.string)
  %ifcond.44.right.i32.left = trunc i64 %ifcond.44.right.i32.left.length64 to i32
  %ifcond.44.right.i32.right = add i32 0, 3
  %ifcond.44.right.i32.comparison = icmp eq i32 %ifcond.44.right.i32.left, %ifcond.44.right.i32.right
  %ifcond.44.right.i32 = zext i1 %ifcond.44.right.i32.comparison to i32
  %ifcond.44.right = icmp ne i32 %ifcond.44.right.i32, 0
  %ifcond.44 = and i1 %ifcond.44.left, %ifcond.44.right
  br i1 %ifcond.44, label %if.then.44, label %if.else.44
if.then.44:
  %ret.57 = add i32 0, 0
  ret i32 %ret.57
if.else.44:
  br label %if.end.44
if.end.44:
  %ret.61 = add i32 0, 1
  ret i32 %ret.61
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

