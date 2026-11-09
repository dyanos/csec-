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

define i32 @MathLib_factorial(i32 %arg.n) {
entry:
  %n = alloca i32
  store i32 %arg.n, ptr %n
  %ifcond.13.left.left = load i32, ptr %n
  %ifcond.13.left.right = add i32 0, 1
  %ifcond.13.left.comparison = icmp sle i32 %ifcond.13.left.left, %ifcond.13.left.right
  %ifcond.13.left = zext i1 %ifcond.13.left.comparison to i32
  %ifcond.13 = icmp ne i32 %ifcond.13.left, 0
  br i1 %ifcond.13, label %if.then.13, label %if.else.13
if.then.13:
  %if.then.ret.13 = add i32 0, 1
  ret i32 %if.then.ret.13
if.else.13:
  %if.else.ret.13.left = load i32, ptr %n
  %if.else.ret.13.right.arg0.left = load i32, ptr %n
  %if.else.ret.13.right.arg0.right = add i32 0, 1
  %if.else.ret.13.right.arg0 = sub i32 %if.else.ret.13.right.arg0.left, %if.else.ret.13.right.arg0.right
  %if.else.ret.13.right = call i32 @MathLib_factorial(i32 %if.else.ret.13.right.arg0)
  %if.else.ret.13 = mul i32 %if.else.ret.13.left, %if.else.ret.13.right
  ret i32 %if.else.ret.13
if.end.13:
  unreachable
}

define i32 @MathLib_fibonacci(i32 %arg.n) {
entry:
  %n = alloca i32
  store i32 %arg.n, ptr %n
  %ifcond.48.left.left = load i32, ptr %n
  %ifcond.48.left.right = add i32 0, 1
  %ifcond.48.left.comparison = icmp sle i32 %ifcond.48.left.left, %ifcond.48.left.right
  %ifcond.48.left = zext i1 %ifcond.48.left.comparison to i32
  %ifcond.48 = icmp ne i32 %ifcond.48.left, 0
  br i1 %ifcond.48, label %if.then.48, label %if.else.48
if.then.48:
  %if.then.ret.48 = load i32, ptr %n
  ret i32 %if.then.ret.48
if.else.48:
  %if.else.ret.48.left.arg0.left = load i32, ptr %n
  %if.else.ret.48.left.arg0.right = add i32 0, 1
  %if.else.ret.48.left.arg0 = sub i32 %if.else.ret.48.left.arg0.left, %if.else.ret.48.left.arg0.right
  %if.else.ret.48.left = call i32 @MathLib_fibonacci(i32 %if.else.ret.48.left.arg0)
  %if.else.ret.48.right.arg0.left = load i32, ptr %n
  %if.else.ret.48.right.arg0.right = add i32 0, 2
  %if.else.ret.48.right.arg0 = sub i32 %if.else.ret.48.right.arg0.left, %if.else.ret.48.right.arg0.right
  %if.else.ret.48.right = call i32 @MathLib_fibonacci(i32 %if.else.ret.48.right.arg0)
  %if.else.ret.48 = add i32 %if.else.ret.48.left, %if.else.ret.48.right
  ret i32 %if.else.ret.48
if.end.48:
  unreachable
}

define i32 @MathLib_power(i32 %arg.base, i32 %arg.exp) {
entry:
  %base = alloca i32
  store i32 %arg.base, ptr %base
  %exp = alloca i32
  store i32 %arg.exp, ptr %exp
  %ifcond.92.left.left = load i32, ptr %exp
  %ifcond.92.left.right = add i32 0, 0
  %ifcond.92.left.comparison = icmp eq i32 %ifcond.92.left.left, %ifcond.92.left.right
  %ifcond.92.left = zext i1 %ifcond.92.left.comparison to i32
  %ifcond.92 = icmp ne i32 %ifcond.92.left, 0
  br i1 %ifcond.92, label %if.then.92, label %if.else.92
if.then.92:
  %if.then.ret.92 = add i32 0, 1
  ret i32 %if.then.ret.92
if.else.92:
  %if.else.ret.92.left = load i32, ptr %base
  %if.else.ret.92.right.arg0 = load i32, ptr %base
  %if.else.ret.92.right.arg1.left = load i32, ptr %exp
  %if.else.ret.92.right.arg1.right = add i32 0, 1
  %if.else.ret.92.right.arg1 = sub i32 %if.else.ret.92.right.arg1.left, %if.else.ret.92.right.arg1.right
  %if.else.ret.92.right = call i32 @MathLib_power(i32 %if.else.ret.92.right.arg0, i32 %if.else.ret.92.right.arg1)
  %if.else.ret.92 = mul i32 %if.else.ret.92.left, %if.else.ret.92.right
  ret i32 %if.else.ret.92
if.end.92:
  unreachable
}

define i32 @MathLib_gcd(i32 %arg.a, i32 %arg.b) {
entry:
  %a = alloca i32
  store i32 %arg.a, ptr %a
  %b = alloca i32
  store i32 %arg.b, ptr %b
  %ifcond.133.left.left = load i32, ptr %b
  %ifcond.133.left.right = add i32 0, 0
  %ifcond.133.left.comparison = icmp eq i32 %ifcond.133.left.left, %ifcond.133.left.right
  %ifcond.133.left = zext i1 %ifcond.133.left.comparison to i32
  %ifcond.133 = icmp ne i32 %ifcond.133.left, 0
  br i1 %ifcond.133, label %if.then.133, label %if.else.133
if.then.133:
  %if.then.ret.133 = load i32, ptr %a
  ret i32 %if.then.ret.133
if.else.133:
  %if.else.ret.133.arg0 = load i32, ptr %b
  %if.else.ret.133.arg1.left = load i32, ptr %a
  %if.else.ret.133.arg1.right = load i32, ptr %b
  %if.else.ret.133.arg1 = srem i32 %if.else.ret.133.arg1.left, %if.else.ret.133.arg1.right
  %if.else.ret.133 = call i32 @MathLib_gcd(i32 %if.else.ret.133.arg0, i32 %if.else.ret.133.arg1)
  ret i32 %if.else.ret.133
if.end.133:
  unreachable
}

define i32 @MathLib_sumRange(i32 %arg.start, i32 %arg.end) {
entry:
  %start = alloca i32
  store i32 %arg.start, ptr %start
  %end = alloca i32
  store i32 %arg.end, ptr %end
  %total.addr.172 = alloca i32
  %total.init.172 = add i32 0, 0
  store i32 %total.init.172, ptr %total.addr.172
  %i = alloca i32
  %forstart.179 = load i32, ptr %start
  store i32 %forstart.179, ptr %i
  br label %for.cond.179
for.cond.179:
  %forvalue.179 = load i32, ptr %i
  %forend.179 = load i32, ptr %end
  %forcond.179 = icmp sle i32 %forvalue.179, %forend.179
  br i1 %forcond.179, label %for.body.179, label %for.end.179
for.body.179:
  %total.assign.188.left = load i32, ptr %total.addr.172
  %total.assign.188.right = load i32, ptr %i
  %total.assign.188 = add i32 %total.assign.188.left, %total.assign.188.right
  store i32 %total.assign.188, ptr %total.addr.172
  %fornext.179 = add i32 %forvalue.179, 1
  store i32 %fornext.179, ptr %i
  br label %for.cond.179
for.end.179:
  %ret.195 = load i32, ptr %total.addr.172
  ret i32 %ret.195
}

define i32 @csec_user_main() {
entry:
  %f5.addr.207 = alloca i32
  %f5.init.207.arg0 = add i32 0, 5
  %f5.init.207 = call i32 @MathLib_factorial(i32 %f5.init.207.arg0)
  store i32 %f5.init.207, ptr %f5.addr.207
  %fib10.addr.217 = alloca i32
  %fib10.init.217.arg0 = add i32 0, 10
  %fib10.init.217 = call i32 @MathLib_fibonacci(i32 %fib10.init.217.arg0)
  store i32 %fib10.init.217, ptr %fib10.addr.217
  %pow.addr.227 = alloca i32
  %pow.init.227.arg0 = add i32 0, 2
  %pow.init.227.arg1 = add i32 0, 8
  %pow.init.227 = call i32 @MathLib_power(i32 %pow.init.227.arg0, i32 %pow.init.227.arg1)
  store i32 %pow.init.227, ptr %pow.addr.227
  %g.addr.239 = alloca i32
  %g.init.239.arg0 = add i32 0, 48
  %g.init.239.arg1 = add i32 0, 18
  %g.init.239 = call i32 @MathLib_gcd(i32 %g.init.239.arg0, i32 %g.init.239.arg1)
  store i32 %g.init.239, ptr %g.addr.239
  %s.addr.251 = alloca i32
  %s.init.251.arg0 = add i32 0, 1
  %s.init.251.arg1 = add i32 0, 100
  %s.init.251 = call i32 @MathLib_sumRange(i32 %s.init.251.arg0, i32 %s.init.251.arg1)
  store i32 %s.init.251, ptr %s.addr.251
  %ret.263.left.left.left.left = load i32, ptr %f5.addr.207
  %ret.263.left.left.left.right = load i32, ptr %fib10.addr.217
  %ret.263.left.left.left = add i32 %ret.263.left.left.left.left, %ret.263.left.left.left.right
  %ret.263.left.left.right = load i32, ptr %pow.addr.227
  %ret.263.left.left = add i32 %ret.263.left.left.left, %ret.263.left.left.right
  %ret.263.left.right = load i32, ptr %g.addr.239
  %ret.263.left = add i32 %ret.263.left.left, %ret.263.left.right
  %ret.263.right = load i32, ptr %s.addr.251
  %ret.263 = add i32 %ret.263.left, %ret.263.right
  ret i32 %ret.263
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

