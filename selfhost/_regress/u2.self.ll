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

@.str.18 = private unnamed_addr constant [4 x i8] c"pos\00"
@.str.29 = private unnamed_addr constant [4 x i8] c"neg\00"
@.str.33 = private unnamed_addr constant [5 x i8] c"zero\00"
@.str.67 = private unnamed_addr constant [4 x i8] c"pos\00"
@.str.71 = private unnamed_addr constant [5 x i8] c"zero\00"

define ptr @describe(i32 %arg.n) {
entry:
  %n = alloca i32
  store i32 %arg.n, ptr %n
  %ifcond.10.i32.left = load i32, ptr %n
  %ifcond.10.i32.right = add i32 0, 0
  %ifcond.10.i32.comparison = icmp sgt i32 %ifcond.10.i32.left, %ifcond.10.i32.right
  %ifcond.10.i32 = zext i1 %ifcond.10.i32.comparison to i32
  %ifcond.10 = icmp ne i32 %ifcond.10.i32, 0
  br i1 %ifcond.10, label %if.then.10, label %if.else.10
if.then.10:
  %ret.17 = getelementptr inbounds [4 x i8], ptr @.str.18, i32 0, i32 0
  ret ptr %ret.17
if.else.10:
  br label %if.end.10
if.end.10:
  %ifcond.21.i32.left = load i32, ptr %n
  %ifcond.21.i32.right = add i32 0, 0
  %ifcond.21.i32.comparison = icmp slt i32 %ifcond.21.i32.left, %ifcond.21.i32.right
  %ifcond.21.i32 = zext i1 %ifcond.21.i32.comparison to i32
  %ifcond.21 = icmp ne i32 %ifcond.21.i32, 0
  br i1 %ifcond.21, label %if.then.21, label %if.else.21
if.then.21:
  %ret.28 = getelementptr inbounds [4 x i8], ptr @.str.29, i32 0, i32 0
  ret ptr %ret.28
if.else.21:
  br label %if.end.21
if.end.21:
  %ret.32 = getelementptr inbounds [5 x i8], ptr @.str.33, i32 0, i32 0
  ret ptr %ret.32
}

define i32 @csec_user_main() {
entry:
  %p.addr.43 = alloca ptr
  %p.init.43.arg0 = add i32 0, 5
  %p.init.43 = call ptr @describe(i32 %p.init.43.arg0)
  store ptr %p.init.43, ptr %p.addr.43
  %z.addr.53 = alloca ptr
  %z.init.53.arg0 = add i32 0, 0
  %z.init.53 = call ptr @describe(i32 %z.init.53.arg0)
  store ptr %z.init.53, ptr %z.addr.53
  %ifcond.63.left.i32.left = load ptr, ptr %p.addr.43
  %ifcond.63.left.i32.right = getelementptr inbounds [4 x i8], ptr @.str.67, i32 0, i32 0
  %ifcond.63.left.i32.equals = call i32 @csec_string_equals(ptr %ifcond.63.left.i32.left, ptr %ifcond.63.left.i32.right)
  %ifcond.63.left.i32.comparison = icmp ne i32 %ifcond.63.left.i32.equals, 0
  %ifcond.63.left.i32 = zext i1 %ifcond.63.left.i32.comparison to i32
  %ifcond.63.left = icmp ne i32 %ifcond.63.left.i32, 0
  %ifcond.63.right.i32.left = load ptr, ptr %z.addr.53
  %ifcond.63.right.i32.right = getelementptr inbounds [5 x i8], ptr @.str.71, i32 0, i32 0
  %ifcond.63.right.i32.equals = call i32 @csec_string_equals(ptr %ifcond.63.right.i32.left, ptr %ifcond.63.right.i32.right)
  %ifcond.63.right.i32.comparison = icmp ne i32 %ifcond.63.right.i32.equals, 0
  %ifcond.63.right.i32 = zext i1 %ifcond.63.right.i32.comparison to i32
  %ifcond.63.right = icmp ne i32 %ifcond.63.right.i32, 0
  %ifcond.63 = and i1 %ifcond.63.left, %ifcond.63.right
  br i1 %ifcond.63, label %if.then.63, label %if.else.63
if.then.63:
  %ret.74 = add i32 0, 0
  ret i32 %ret.74
if.else.63:
  br label %if.end.63
if.end.63:
  %ret.78 = add i32 0, 1
  ret i32 %ret.78
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

