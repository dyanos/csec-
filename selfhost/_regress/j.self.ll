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

@.str.22 = private unnamed_addr constant [1 x i8] c"\00"
@.str.50 = private unnamed_addr constant [2 x i8] c"<\00"
@.str.54 = private unnamed_addr constant [2 x i8] c"x\00"
@.str.59 = private unnamed_addr constant [2 x i8] c">\00"

define ptr @rep(ptr %arg.s, i32 %arg.n) {
entry:
  %s = alloca ptr
  store ptr %arg.s, ptr %s
  %n = alloca i32
  store i32 %arg.n, ptr %n
  %ifcond.14.i32.left = load i32, ptr %n
  %ifcond.14.i32.right = add i32 0, 0
  %ifcond.14.i32.comparison = icmp eq i32 %ifcond.14.i32.left, %ifcond.14.i32.right
  %ifcond.14.i32 = zext i1 %ifcond.14.i32.comparison to i32
  %ifcond.14 = icmp ne i32 %ifcond.14.i32, 0
  br i1 %ifcond.14, label %if.then.14, label %if.else.14
if.then.14:
  %ret.21 = getelementptr inbounds [1 x i8], ptr @.str.22, i32 0, i32 0
  ret ptr %ret.21
if.else.14:
  br label %if.end.14
if.end.14:
  %ret.25.left = load ptr, ptr %s
  %ret.25.right.arg0 = load ptr, ptr %s
  %ret.25.right.arg1.left = load i32, ptr %n
  %ret.25.right.arg1.right = add i32 0, 1
  %ret.25.right.arg1 = sub i32 %ret.25.right.arg1.left, %ret.25.right.arg1.right
  %ret.25.right = call ptr @rep(ptr %ret.25.right.arg0, i32 %ret.25.right.arg1)
  %ret.25 = call ptr @csec_string_concat(ptr %ret.25.left, ptr %ret.25.right)
  ret ptr %ret.25
}

define i32 @csec_user_main() {
entry:
  %joined.addr.45 = alloca ptr
  %joined.init.45 = getelementptr i8, ptr null, i32 0
  store ptr %joined.init.45, ptr %joined.addr.45
  %ifcond.61.i32.left.string = load ptr, ptr %joined.addr.45
  %ifcond.61.i32.left.length64 = call i64 @csec_string_length(ptr %ifcond.61.i32.left.string)
  %ifcond.61.i32.left = trunc i64 %ifcond.61.i32.left.length64 to i32
  %ifcond.61.i32.right = add i32 0, 4
  %ifcond.61.i32.comparison = icmp eq i32 %ifcond.61.i32.left, %ifcond.61.i32.right
  %ifcond.61.i32 = zext i1 %ifcond.61.i32.comparison to i32
  %ifcond.61 = icmp ne i32 %ifcond.61.i32, 0
  br i1 %ifcond.61, label %if.then.61, label %if.else.61
if.then.61:
  %ret.70 = add i32 0, 0
  ret i32 %ret.70
if.else.61:
  br label %if.end.61
if.end.61:
  %ret.74 = add i32 0, 1
  ret i32 %ret.74
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

