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
declare i32 @csec_string_equals(ptr, ptr)
declare i64 @csec_string_length(ptr)
declare i32 @csec_string_starts_with(ptr, ptr)
declare ptr @csec_string_substring(ptr, i32, i32)
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

define i32 @StringUtils_length(ptr %arg.s) {
entry:
  %s = alloca ptr
  store ptr %arg.s, ptr %s
  %ret = add i32 0, 0
  ret i32 %ret
}

define i32 @MathUtils_max(i32 %arg.a, i32 %arg.b) {
entry:
  %a = alloca i32
  store i32 %arg.a, ptr %a
  %b = alloca i32
  store i32 %arg.b, ptr %b
  %ifcond.58.left.left = load i32, ptr %a
  %ifcond.58.left.right = load i32, ptr %b
  %ifcond.58.left.comparison = icmp sgt i32 %ifcond.58.left.left, %ifcond.58.left.right
  %ifcond.58.left = zext i1 %ifcond.58.left.comparison to i32
  %ifcond.58 = icmp ne i32 %ifcond.58.left, 0
  br i1 %ifcond.58, label %if.then.58, label %if.else.58
if.then.58:
  %if.then.ret.58 = load i32, ptr %a
  ret i32 %if.then.ret.58
if.else.58:
  %if.else.ret.58 = load i32, ptr %b
  ret i32 %if.else.ret.58
if.end.58:
  unreachable
}

define i32 @MathUtils_min(i32 %arg.a, i32 %arg.b) {
entry:
  %a = alloca i32
  store i32 %arg.a, ptr %a
  %b = alloca i32
  store i32 %arg.b, ptr %b
  %ifcond.90.left.left = load i32, ptr %a
  %ifcond.90.left.right = load i32, ptr %b
  %ifcond.90.left.comparison = icmp slt i32 %ifcond.90.left.left, %ifcond.90.left.right
  %ifcond.90.left = zext i1 %ifcond.90.left.comparison to i32
  %ifcond.90 = icmp ne i32 %ifcond.90.left, 0
  br i1 %ifcond.90, label %if.then.90, label %if.else.90
if.then.90:
  %if.then.ret.90 = load i32, ptr %a
  ret i32 %if.then.ret.90
if.else.90:
  %if.else.ret.90 = load i32, ptr %b
  ret i32 %if.else.ret.90
if.end.90:
  unreachable
}

define i32 @MathUtils_abs(i32 %arg.x) {
entry:
  %x = alloca i32
  store i32 %arg.x, ptr %x
  %ifcond.118.left.left = load i32, ptr %x
  %ifcond.118.left.right = add i32 0, 0
  %ifcond.118.left.comparison = icmp slt i32 %ifcond.118.left.left, %ifcond.118.left.right
  %ifcond.118.left = zext i1 %ifcond.118.left.comparison to i32
  %ifcond.118 = icmp ne i32 %ifcond.118.left, 0
  br i1 %ifcond.118, label %if.then.118, label %if.else.118
if.then.118:
  %if.then.ret.118.left = add i32 0, 0
  %if.then.ret.118.right = load i32, ptr %x
  %if.then.ret.118 = sub i32 %if.then.ret.118.left, %if.then.ret.118.right
  ret i32 %if.then.ret.118
if.else.118:
  br label %if.end.118
if.end.118:
  %ret.131 = load i32, ptr %x
  ret i32 %ret.131
}

define i32 @MathUtils_clamp(i32 %arg.x, i32 %arg.lo, i32 %arg.hi) {
entry:
  %x = alloca i32
  store i32 %arg.x, ptr %x
  %lo = alloca i32
  store i32 %arg.lo, ptr %lo
  %hi = alloca i32
  store i32 %arg.hi, ptr %hi
  %ifcond.153.left.left = load i32, ptr %x
  %ifcond.153.left.right = load i32, ptr %lo
  %ifcond.153.left.comparison = icmp slt i32 %ifcond.153.left.left, %ifcond.153.left.right
  %ifcond.153.left = zext i1 %ifcond.153.left.comparison to i32
  %ifcond.153 = icmp ne i32 %ifcond.153.left, 0
  br i1 %ifcond.153, label %if.then.153, label %if.else.153
if.then.153:
  %if.then.ret.153 = load i32, ptr %lo
  ret i32 %if.then.ret.153
if.else.153:
  br label %if.end.153
if.end.153:
  %ifcond.164.left.left = load i32, ptr %x
  %ifcond.164.left.right = load i32, ptr %hi
  %ifcond.164.left.comparison = icmp sgt i32 %ifcond.164.left.left, %ifcond.164.left.right
  %ifcond.164.left = zext i1 %ifcond.164.left.comparison to i32
  %ifcond.164 = icmp ne i32 %ifcond.164.left, 0
  br i1 %ifcond.164, label %if.then.164, label %if.else.164
if.then.164:
  %if.then.ret.164 = load i32, ptr %hi
  ret i32 %if.then.ret.164
if.else.164:
  br label %if.end.164
if.end.164:
  %ret.175 = load i32, ptr %x
  ret i32 %ret.175
}

define i32 @csec_user_main() {
entry:
  %a.addr.187 = alloca i32
  %a.init.187.arg0 = add i32 0, 10
  %a.init.187.arg1 = add i32 0, 20
  %a.init.187 = call i32 @MathUtils_max(i32 %a.init.187.arg0, i32 %a.init.187.arg1)
  store i32 %a.init.187, ptr %a.addr.187
  %b.addr.199 = alloca i32
  %b.init.199.arg0 = add i32 0, 10
  %b.init.199.arg1 = add i32 0, 20
  %b.init.199 = call i32 @MathUtils_min(i32 %b.init.199.arg0, i32 %b.init.199.arg1)
  store i32 %b.init.199, ptr %b.addr.199
  %c.addr.211 = alloca i32
  %c.init.211.arg0.left = add i32 0, 0
  %c.init.211.arg0.right = add i32 0, 5
  %c.init.211.arg0 = sub i32 %c.init.211.arg0.left, %c.init.211.arg0.right
  %c.init.211 = call i32 @MathUtils_abs(i32 %c.init.211.arg0)
  store i32 %c.init.211, ptr %c.addr.211
  %d.addr.223 = alloca i32
  %d.init.223.arg0 = add i32 0, 50
  %d.init.223.arg1 = add i32 0, 0
  %d.init.223.arg2 = add i32 0, 100
  %d.init.223 = call i32 @MathUtils_clamp(i32 %d.init.223.arg0, i32 %d.init.223.arg1, i32 %d.init.223.arg2)
  store i32 %d.init.223, ptr %d.addr.223
  %ret.237.left.left.left = load i32, ptr %a.addr.187
  %ret.237.left.left.right = load i32, ptr %b.addr.199
  %ret.237.left.left = add i32 %ret.237.left.left.left, %ret.237.left.left.right
  %ret.237.left.right = load i32, ptr %c.addr.211
  %ret.237.left = add i32 %ret.237.left.left, %ret.237.left.right
  %ret.237.right = load i32, ptr %d.addr.223
  %ret.237 = add i32 %ret.237.left, %ret.237.right
  ret i32 %ret.237
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

