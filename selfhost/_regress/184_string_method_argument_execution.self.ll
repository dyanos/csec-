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

@.str.18 = private unnamed_addr constant [2 x i8] c"!\00"
@.str.66 = private unnamed_addr constant [3 x i8] c"hi\00"
@.str.78 = private unnamed_addr constant [2 x i8] c"[\00"
@.str.80 = private unnamed_addr constant [2 x i8] c"x\00"
@.str.87 = private unnamed_addr constant [4 x i8] c"hi!\00"

define ptr @Greeter_greet(ptr %arg.name) {
entry:
  %name = alloca ptr
  store ptr %arg.name, ptr %name
  %ret.15.left = load ptr, ptr %name
  %ret.15.right = getelementptr inbounds [2 x i8], ptr @.str.18, i32 0, i32 0
  %ret.15 = call ptr @csec_string_concat(ptr %ret.15.left, ptr %ret.15.right)
  ret ptr %ret.15
}

define ptr @Greeter_wrap(ptr %arg.prefix, ptr %arg.name) {
entry:
  %prefix = alloca ptr
  store ptr %arg.prefix, ptr %prefix
  %name = alloca ptr
  store ptr %arg.name, ptr %name
  %ret.35.left = load ptr, ptr %prefix
  %ret.35.right = load ptr, ptr %name
  %ret.35 = call ptr @csec_string_concat(ptr %ret.35.left, ptr %ret.35.right)
  ret ptr %ret.35
}

define i32 @csec_user_main() {
entry:
  %g.addr.49 = alloca i32
  store i32 0, ptr %g.addr.49
  %greeting.addr.57 = alloca ptr
  %greeting.init.57.arg0 = getelementptr inbounds [3 x i8], ptr @.str.66, i32 0, i32 0
  %greeting.init.57 = call ptr @Greeter_greet(ptr %greeting.init.57.arg0)
  store ptr %greeting.init.57, ptr %greeting.addr.57
  %wrapped.addr.69 = alloca ptr
  %wrapped.init.69.arg0 = getelementptr inbounds [2 x i8], ptr @.str.78, i32 0, i32 0
  %wrapped.init.69.arg1 = getelementptr inbounds [2 x i8], ptr @.str.80, i32 0, i32 0
  %wrapped.init.69 = call ptr @Greeter_wrap(ptr %wrapped.init.69.arg0, ptr %wrapped.init.69.arg1)
  store ptr %wrapped.init.69, ptr %wrapped.addr.69
  %ifcond.83.left.i32.left = load ptr, ptr %greeting.addr.57
  %ifcond.83.left.i32.right = getelementptr inbounds [4 x i8], ptr @.str.87, i32 0, i32 0
  %ifcond.83.left.i32.equals = call i32 @csec_string_equals(ptr %ifcond.83.left.i32.left, ptr %ifcond.83.left.i32.right)
  %ifcond.83.left.i32.comparison = icmp ne i32 %ifcond.83.left.i32.equals, 0
  %ifcond.83.left.i32 = zext i1 %ifcond.83.left.i32.comparison to i32
  %ifcond.83.left = icmp ne i32 %ifcond.83.left.i32, 0
  %ifcond.83.right.i32.left.string = load ptr, ptr %wrapped.addr.69
  %ifcond.83.right.i32.left.length64 = call i64 @csec_string_length(ptr %ifcond.83.right.i32.left.string)
  %ifcond.83.right.i32.left = trunc i64 %ifcond.83.right.i32.left.length64 to i32
  %ifcond.83.right.i32.right = add i32 0, 2
  %ifcond.83.right.i32.comparison = icmp eq i32 %ifcond.83.right.i32.left, %ifcond.83.right.i32.right
  %ifcond.83.right.i32 = zext i1 %ifcond.83.right.i32.comparison to i32
  %ifcond.83.right = icmp ne i32 %ifcond.83.right.i32, 0
  %ifcond.83 = and i1 %ifcond.83.left, %ifcond.83.right
  br i1 %ifcond.83, label %if.then.83, label %if.else.83
if.then.83:
  %ret.96 = add i32 0, 0
  ret i32 %ret.96
if.else.83:
  br label %if.end.83
if.end.83:
  %ret.100 = add i32 0, 1
  ret i32 %ret.100
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

