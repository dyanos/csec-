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
@.str.35 = private unnamed_addr constant [2 x i8] c"x\00"

define ptr @describe(i32 %arg.value) {
entry:
  %value = alloca i32
  store i32 %arg.value, ptr %value
  %cursor.addr.10 = alloca i32
  %cursor.init.10 = add i32 0, 0
  store i32 %cursor.init.10, ptr %cursor.addr.10
  %label.addr.17 = alloca ptr
  %label.init.17 = getelementptr inbounds [1 x i8], ptr @.str.22, i32 0, i32 0
  store ptr %label.init.17, ptr %label.addr.17
  br label %while.cond.24
while.cond.24:
  %whilecond.24.i32.left = load i32, ptr %cursor.addr.10
  %whilecond.24.i32.right = load i32, ptr %value
  %whilecond.24.i32.comparison = icmp slt i32 %whilecond.24.i32.left, %whilecond.24.i32.right
  %whilecond.24.i32 = zext i1 %whilecond.24.i32.comparison to i32
  %whilecond.24 = icmp ne i32 %whilecond.24.i32, 0
  br i1 %whilecond.24, label %while.body.24, label %while.end.24
while.body.24:
  %label.assign.31.left = load ptr, ptr %label.addr.17
  %label.assign.31.right = getelementptr inbounds [2 x i8], ptr @.str.35, i32 0, i32 0
  %label.assign.31 = call ptr @csec_string_concat(ptr %label.assign.31.left, ptr %label.assign.31.right)
  store ptr %label.assign.31, ptr %label.addr.17
  %cursor.assign.37.left = load i32, ptr %cursor.addr.10
  %cursor.assign.37.right = add i32 0, 1
  %cursor.assign.37 = add i32 %cursor.assign.37.left, %cursor.assign.37.right
  store i32 %cursor.assign.37, ptr %cursor.addr.10
  br label %while.cond.24
while.end.24:
  %ret.44 = load ptr, ptr %label.addr.17
  ret ptr %ret.44
}

define i32 @csec_user_main() {
entry:
  %repeated.addr.55 = alloca ptr
  %repeated.init.55.arg0 = add i32 0, 4
  %repeated.init.55 = call ptr @describe(i32 %repeated.init.55.arg0)
  store ptr %repeated.init.55, ptr %repeated.addr.55
  %ifcond.65.i32.left.string = load ptr, ptr %repeated.addr.55
  %ifcond.65.i32.left.length64 = call i64 @csec_string_length(ptr %ifcond.65.i32.left.string)
  %ifcond.65.i32.left = trunc i64 %ifcond.65.i32.left.length64 to i32
  %ifcond.65.i32.right = add i32 0, 4
  %ifcond.65.i32.comparison = icmp eq i32 %ifcond.65.i32.left, %ifcond.65.i32.right
  %ifcond.65.i32 = zext i1 %ifcond.65.i32.comparison to i32
  %ifcond.65 = icmp ne i32 %ifcond.65.i32, 0
  br i1 %ifcond.65, label %if.then.65, label %if.else.65
if.then.65:
  %ret.74 = add i32 0, 0
  ret i32 %ret.74
if.else.65:
  br label %if.end.65
if.end.65:
  %ret.78 = add i32 0, 1
  ret i32 %ret.78
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

