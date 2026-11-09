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

@.str.15 = private unnamed_addr constant [1 x i8] c"\00"
@.str.26 = private unnamed_addr constant [4 x i8] c"one\00"
@.str.39 = private unnamed_addr constant [4 x i8] c"two\00"
@.str.52 = private unnamed_addr constant [6 x i8] c"three\00"
@.str.69 = private unnamed_addr constant [5 x i8] c"none\00"
@.str.94 = private unnamed_addr constant [1 x i8] c"\00"
@.str.107 = private unnamed_addr constant [2 x i8] c"x\00"

define ptr @pick(i32 %arg.value) {
entry:
  %value = alloca i32
  store i32 %arg.value, ptr %value
  %result.addr.10 = alloca ptr
  %result.init.10 = getelementptr inbounds [1 x i8], ptr @.str.15, i32 0, i32 0
  store ptr %result.init.10, ptr %result.addr.10
  %ifcond.17.i32.left = load i32, ptr %value
  %ifcond.17.i32.right = add i32 0, 1
  %ifcond.17.i32.comparison = icmp eq i32 %ifcond.17.i32.left, %ifcond.17.i32.right
  %ifcond.17.i32 = zext i1 %ifcond.17.i32.comparison to i32
  %ifcond.17 = icmp ne i32 %ifcond.17.i32, 0
  br i1 %ifcond.17, label %if.then.17, label %if.else.17
if.then.17:
  %result.assign.24 = getelementptr inbounds [4 x i8], ptr @.str.26, i32 0, i32 0
  store ptr %result.assign.24, ptr %result.addr.10
  br label %if.end.17
if.else.17:
  %ifcond.30.i32.left = load i32, ptr %value
  %ifcond.30.i32.right = add i32 0, 2
  %ifcond.30.i32.comparison = icmp eq i32 %ifcond.30.i32.left, %ifcond.30.i32.right
  %ifcond.30.i32 = zext i1 %ifcond.30.i32.comparison to i32
  %ifcond.30 = icmp ne i32 %ifcond.30.i32, 0
  br i1 %ifcond.30, label %if.then.30, label %if.else.30
if.then.30:
  %result.assign.37 = getelementptr inbounds [4 x i8], ptr @.str.39, i32 0, i32 0
  store ptr %result.assign.37, ptr %result.addr.10
  br label %if.end.30
if.else.30:
  %ifcond.43.i32.left = load i32, ptr %value
  %ifcond.43.i32.right = add i32 0, 3
  %ifcond.43.i32.comparison = icmp eq i32 %ifcond.43.i32.left, %ifcond.43.i32.right
  %ifcond.43.i32 = zext i1 %ifcond.43.i32.comparison to i32
  %ifcond.43 = icmp ne i32 %ifcond.43.i32, 0
  br i1 %ifcond.43, label %if.then.43, label %if.else.43
if.then.43:
  %result.assign.50 = getelementptr inbounds [6 x i8], ptr @.str.52, i32 0, i32 0
  store ptr %result.assign.50, ptr %result.addr.10
  br label %if.end.43
if.else.43:
  br label %if.end.43
if.end.43:
  br label %if.end.30
if.end.30:
  br label %if.end.17
if.end.17:
  %ifcond.55.i32.left.string = load ptr, ptr %result.addr.10
  %ifcond.55.i32.left.length64 = call i64 @csec_string_length(ptr %ifcond.55.i32.left.string)
  %ifcond.55.i32.left = trunc i64 %ifcond.55.i32.left.length64 to i32
  %ifcond.55.i32.right = add i32 0, 0
  %ifcond.55.i32.comparison = icmp sgt i32 %ifcond.55.i32.left, %ifcond.55.i32.right
  %ifcond.55.i32 = zext i1 %ifcond.55.i32.comparison to i32
  %ifcond.55 = icmp ne i32 %ifcond.55.i32, 0
  br i1 %ifcond.55, label %if.then.55, label %if.else.55
if.then.55:
  %ret.64 = load ptr, ptr %result.addr.10
  ret ptr %ret.64
if.else.55:
  br label %if.end.55
if.end.55:
  %ret.68 = getelementptr inbounds [5 x i8], ptr @.str.69, i32 0, i32 0
  ret ptr %ret.68
}

define ptr @describe(i32 %arg.value) {
entry:
  %value = alloca i32
  store i32 %arg.value, ptr %value
  %cursor.addr.82 = alloca i32
  %cursor.init.82 = add i32 0, 0
  store i32 %cursor.init.82, ptr %cursor.addr.82
  %label.addr.89 = alloca ptr
  %label.init.89 = getelementptr inbounds [1 x i8], ptr @.str.94, i32 0, i32 0
  store ptr %label.init.89, ptr %label.addr.89
  br label %while.cond.96
while.cond.96:
  %whilecond.96.i32.left = load i32, ptr %cursor.addr.82
  %whilecond.96.i32.right = load i32, ptr %value
  %whilecond.96.i32.comparison = icmp slt i32 %whilecond.96.i32.left, %whilecond.96.i32.right
  %whilecond.96.i32 = zext i1 %whilecond.96.i32.comparison to i32
  %whilecond.96 = icmp ne i32 %whilecond.96.i32, 0
  br i1 %whilecond.96, label %while.body.96, label %while.end.96
while.body.96:
  %label.assign.103.left = load ptr, ptr %label.addr.89
  %label.assign.103.right = getelementptr inbounds [2 x i8], ptr @.str.107, i32 0, i32 0
  %label.assign.103 = call ptr @csec_string_concat(ptr %label.assign.103.left, ptr %label.assign.103.right)
  store ptr %label.assign.103, ptr %label.addr.89
  %cursor.assign.109.left = load i32, ptr %cursor.addr.82
  %cursor.assign.109.right = add i32 0, 1
  %cursor.assign.109 = add i32 %cursor.assign.109.left, %cursor.assign.109.right
  store i32 %cursor.assign.109, ptr %cursor.addr.82
  br label %while.cond.96
while.end.96:
  %ret.116 = load ptr, ptr %label.addr.89
  ret ptr %ret.116
}

define i32 @csec_user_main() {
entry:
  %chosen.addr.127 = alloca ptr
  %chosen.init.127.arg0 = add i32 0, 3
  %chosen.init.127 = call ptr @pick(i32 %chosen.init.127.arg0)
  store ptr %chosen.init.127, ptr %chosen.addr.127
  %fallback.addr.137 = alloca ptr
  %fallback.init.137.arg0 = add i32 0, 9
  %fallback.init.137 = call ptr @pick(i32 %fallback.init.137.arg0)
  store ptr %fallback.init.137, ptr %fallback.addr.137
  %repeated.addr.147 = alloca ptr
  %repeated.init.147.arg0 = add i32 0, 4
  %repeated.init.147 = call ptr @describe(i32 %repeated.init.147.arg0)
  store ptr %repeated.init.147, ptr %repeated.addr.147
  %ifcond.157.left.left.i32.left.string = load ptr, ptr %chosen.addr.127
  %ifcond.157.left.left.i32.left.length64 = call i64 @csec_string_length(ptr %ifcond.157.left.left.i32.left.string)
  %ifcond.157.left.left.i32.left = trunc i64 %ifcond.157.left.left.i32.left.length64 to i32
  %ifcond.157.left.left.i32.right = add i32 0, 5
  %ifcond.157.left.left.i32.comparison = icmp eq i32 %ifcond.157.left.left.i32.left, %ifcond.157.left.left.i32.right
  %ifcond.157.left.left.i32 = zext i1 %ifcond.157.left.left.i32.comparison to i32
  %ifcond.157.left.left = icmp ne i32 %ifcond.157.left.left.i32, 0
  %ifcond.157.left.right.i32.left.string = load ptr, ptr %fallback.addr.137
  %ifcond.157.left.right.i32.left.length64 = call i64 @csec_string_length(ptr %ifcond.157.left.right.i32.left.string)
  %ifcond.157.left.right.i32.left = trunc i64 %ifcond.157.left.right.i32.left.length64 to i32
  %ifcond.157.left.right.i32.right = add i32 0, 4
  %ifcond.157.left.right.i32.comparison = icmp eq i32 %ifcond.157.left.right.i32.left, %ifcond.157.left.right.i32.right
  %ifcond.157.left.right.i32 = zext i1 %ifcond.157.left.right.i32.comparison to i32
  %ifcond.157.left.right = icmp ne i32 %ifcond.157.left.right.i32, 0
  %ifcond.157.left = and i1 %ifcond.157.left.left, %ifcond.157.left.right
  %ifcond.157.right.i32.left.string = load ptr, ptr %repeated.addr.147
  %ifcond.157.right.i32.left.length64 = call i64 @csec_string_length(ptr %ifcond.157.right.i32.left.string)
  %ifcond.157.right.i32.left = trunc i64 %ifcond.157.right.i32.left.length64 to i32
  %ifcond.157.right.i32.right = add i32 0, 4
  %ifcond.157.right.i32.comparison = icmp eq i32 %ifcond.157.right.i32.left, %ifcond.157.right.i32.right
  %ifcond.157.right.i32 = zext i1 %ifcond.157.right.i32.comparison to i32
  %ifcond.157.right = icmp ne i32 %ifcond.157.right.i32, 0
  %ifcond.157 = and i1 %ifcond.157.left, %ifcond.157.right
  br i1 %ifcond.157, label %if.then.157, label %if.else.157
if.then.157:
  %ret.178 = add i32 0, 0
  ret i32 %ret.178
if.else.157:
  br label %if.end.157
if.end.157:
  %ret.182 = add i32 0, 1
  ret i32 %ret.182
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

