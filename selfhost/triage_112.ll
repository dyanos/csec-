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

define float @BasicMath_abs(float %arg.x) {
entry:
  %x = alloca float
  store float %arg.x, ptr %x
  ret i32 0
}

define float @BasicMath_sign(float %arg.x) {
entry:
  %x = alloca float
  store float %arg.x, ptr %x
  ret i32 0
}

define float @BasicMath_floor(float %arg.x) {
entry:
  %x = alloca float
  store float %arg.x, ptr %x
  ret i32 0
}

define float @BasicMath_ceil(float %arg.x) {
entry:
  %x = alloca float
  store float %arg.x, ptr %x
  ret i32 0
}

define float @BasicMath_round(float %arg.x) {
entry:
  %x = alloca float
  store float %arg.x, ptr %x
  ret i32 0
}

define float @BasicMath_min(float %arg.left, float %arg.right) {
entry:
  %left = alloca float
  store float %arg.left, ptr %left
  %right = alloca float
  store float %arg.right, ptr %right
  ret i32 0
}

define float @BasicMath_max(float %arg.left, float %arg.right) {
entry:
  %left = alloca float
  store float %arg.left, ptr %left
  %right = alloca float
  store float %arg.right, ptr %right
  ret i32 0
}

define float @BasicMath_clamp(float %arg.value, float %arg.low, float %arg.high) {
entry:
  %value = alloca float
  store float %arg.value, ptr %value
  %low = alloca float
  store float %arg.low, ptr %low
  %high = alloca float
  store float %arg.high, ptr %high
  ret i32 0
}

define i1 @BasicMath_between(float %arg.value, float %arg.low, float %arg.high) {
entry:
  %value = alloca float
  store float %arg.value, ptr %value
  %low = alloca float
  store float %arg.low, ptr %low
  %high = alloca float
  store float %arg.high, ptr %high
  %ret.396.i32.left.left = load i32, ptr %value
  %ret.396.i32.left.right = load i32, ptr %low
  %ret.396.i32.left.comparison = icmp sge i32 %ret.396.i32.left.left, %ret.396.i32.left.right
  %ret.396.i32.left = zext i1 %ret.396.i32.left.comparison to i32
  %ret.396.i32.right.left = load i32, ptr %value
  %ret.396.i32.right.right = load i32, ptr %high
  %ret.396.i32.right.comparison = icmp sle i32 %ret.396.i32.right.left, %ret.396.i32.right.right
  %ret.396.i32.right = zext i1 %ret.396.i32.right.comparison to i32
  %ret.396.i32 = and i32 %ret.396.i32.left, %ret.396.i32.right
  %ret.396 = icmp ne i32 %ret.396.i32, 0
  ret i1 %ret.396
}

define i1 @BasicMath_approxEq(float %arg.left, float %arg.right, float %arg.epsilon) {
entry:
  %left = alloca float
  store float %arg.left, ptr %left
  %right = alloca float
  store float %arg.right, ptr %right
  %epsilon = alloca float
  store float %arg.epsilon, ptr %epsilon
  %diff.addr.424 = alloca i1
  %diff.init.424.i32.left = load i32, ptr %left
  %diff.init.424.i32.right = load i32, ptr %right
  %diff.init.424.i32 = sub i32 %diff.init.424.i32.left, %diff.init.424.i32.right
  %diff.init.424 = icmp ne i32 %diff.init.424.i32, 0
  store i1 %diff.init.424, ptr %diff.addr.424
  %ret.447.i32.left = load i32, ptr %diff.addr.424
  %ret.447.i32.right = load i32, ptr %epsilon
  %ret.447.i32.comparison = icmp sle i32 %ret.447.i32.left, %ret.447.i32.right
  %ret.447.i32 = zext i1 %ret.447.i32.comparison to i32
  %ret.447 = icmp ne i32 %ret.447.i32, 0
  ret i1 %ret.447
}

define i32 @csec_user_main() {
entry:
  %math.addr.461 = alloca i32
  store i32 0, ptr %math.addr.461
  %a.addr.469 = alloca i32
  %a.init.469.arg0.left = add i32 0, 0
  %a.init.469.arg0.right = add i32 0, 0
  %a.init.469.arg0 = sub i32 %a.init.469.arg0.left, %a.init.469.arg0.right
  %a.init.469 = call i32 @BasicMath_abs(i32 %a.init.469.arg0)
  store i32 %a.init.469, ptr %a.addr.469
  %s1.addr.483 = alloca i32
  %s1.init.483.arg0.left = add i32 0, 0
  %s1.init.483.arg0.right = add i32 0, 0
  %s1.init.483.arg0 = sub i32 %s1.init.483.arg0.left, %s1.init.483.arg0.right
  %s1.init.483 = call i32 @BasicMath_sign(i32 %s1.init.483.arg0)
  store i32 %s1.init.483, ptr %s1.addr.483
  %s2.addr.497 = alloca i32
  %s2.init.497.arg0 = add i32 0, 0
  %s2.init.497 = call i32 @BasicMath_sign(i32 %s2.init.497.arg0)
  store i32 %s2.init.497, ptr %s2.addr.497
  %s3.addr.509 = alloca i32
  %s3.init.509.arg0 = add i32 0, 0
  %s3.init.509 = call i32 @BasicMath_sign(i32 %s3.init.509.arg0)
  store i32 %s3.init.509, ptr %s3.addr.509
  %f1.addr.521 = alloca i32
  %f1.init.521.arg0 = add i32 0, 0
  %f1.init.521 = call i32 @BasicMath_floor(i32 %f1.init.521.arg0)
  store i32 %f1.init.521, ptr %f1.addr.521
  %f2.addr.533 = alloca i32
  %f2.init.533.arg0.left = add i32 0, 0
  %f2.init.533.arg0.right = add i32 0, 0
  %f2.init.533.arg0 = sub i32 %f2.init.533.arg0.left, %f2.init.533.arg0.right
  %f2.init.533 = call i32 @BasicMath_floor(i32 %f2.init.533.arg0)
  store i32 %f2.init.533, ptr %f2.addr.533
  %c1.addr.547 = alloca i32
  %c1.init.547.arg0 = add i32 0, 0
  %c1.init.547 = call i32 @BasicMath_ceil(i32 %c1.init.547.arg0)
  store i32 %c1.init.547, ptr %c1.addr.547
  %c2.addr.559 = alloca i32
  %c2.init.559.arg0.left = add i32 0, 0
  %c2.init.559.arg0.right = add i32 0, 0
  %c2.init.559.arg0 = sub i32 %c2.init.559.arg0.left, %c2.init.559.arg0.right
  %c2.init.559 = call i32 @BasicMath_ceil(i32 %c2.init.559.arg0)
  store i32 %c2.init.559, ptr %c2.addr.559
  %r1.addr.573 = alloca i32
  %r1.init.573.arg0 = add i32 0, 0
  %r1.init.573 = call i32 @BasicMath_round(i32 %r1.init.573.arg0)
  store i32 %r1.init.573, ptr %r1.addr.573
  %r2.addr.585 = alloca i32
  %r2.init.585.arg0.left = add i32 0, 0
  %r2.init.585.arg0.right = add i32 0, 0
  %r2.init.585.arg0 = sub i32 %r2.init.585.arg0.left, %r2.init.585.arg0.right
  %r2.init.585 = call i32 @BasicMath_round(i32 %r2.init.585.arg0)
  store i32 %r2.init.585, ptr %r2.addr.585
  %clamped.addr.599 = alloca i32
  %clamped.init.599.arg0 = add i32 0, 0
  %clamped.init.599.arg1 = add i32 0, 0
  %clamped.init.599.arg2 = add i32 0, 0
  %clamped.init.599 = call i32 @BasicMath_clamp(i32 %clamped.init.599.arg0, i32 %clamped.init.599.arg1, i32 %clamped.init.599.arg2)
  store i32 %clamped.init.599, ptr %clamped.addr.599
  %inRange.addr.615 = alloca i1
  %inRange.init.615.i32.arg0 = add i32 0, 0
  %inRange.init.615.i32.arg1 = add i32 0, 0
  %inRange.init.615.i32.arg2 = add i32 0, 0
  %inRange.init.615.i32.i1 = call i1 @BasicMath_between(i32 %inRange.init.615.i32.arg0, i32 %inRange.init.615.i32.arg1, i32 %inRange.init.615.i32.arg2)
  %inRange.init.615.i32 = zext i1 %inRange.init.615.i32.i1 to i32
  %inRange.init.615 = icmp ne i32 %inRange.init.615.i32, 0
  store i1 %inRange.init.615, ptr %inRange.addr.615
  %close.addr.631 = alloca i1
  %close.init.631.i32.arg0.left = add i32 0, 0
  %close.init.631.i32.arg0.right = add i32 0, 0
  %close.init.631.i32.arg0 = add i32 %close.init.631.i32.arg0.left, %close.init.631.i32.arg0.right
  %close.init.631.i32.arg1 = add i32 0, 0
  %close.init.631.i32.arg2 = add i32 0, 0
  %close.init.631.i32.i1 = call i1 @BasicMath_approxEq(i32 %close.init.631.i32.arg0, i32 %close.init.631.i32.arg1, i32 %close.init.631.i32.arg2)
  %close.init.631.i32 = zext i1 %close.init.631.i32.i1 to i32
  %close.init.631 = icmp ne i32 %close.init.631.i32, 0
  store i1 %close.init.631, ptr %close.addr.631
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = load i32, ptr %a.addr.469
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = add i32 0, 0
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.comparison = icmp eq i32 %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = zext i1 %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left.comparison to i32
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right.left = load i32, ptr %s1.addr.483
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right.right.left = add i32 0, 0
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right.right.right = add i32 0, 0
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right.right = sub i32 %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right.right.left, %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right.right.right
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right.comparison = icmp eq i32 %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right.left, %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right.right
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = zext i1 %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right.comparison to i32
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.left = and i32 %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.right.left = load i32, ptr %s2.addr.497
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.right.right = add i32 0, 0
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.right.comparison = icmp eq i32 %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.right.left, %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.right.right
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.right = zext i1 %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.right.comparison to i32
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left = and i32 %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.left, %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.right
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.right.left = load i32, ptr %s3.addr.509
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.right.right = add i32 0, 0
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.right.comparison = icmp eq i32 %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.right.left, %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.right.right
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.right = zext i1 %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.right.comparison to i32
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left = and i32 %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left, %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.right
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.right.left = load i32, ptr %f1.addr.521
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.right.right = add i32 0, 0
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.right.comparison = icmp eq i32 %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.right.left, %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.right.right
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.right = zext i1 %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.right.comparison to i32
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left = and i32 %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left, %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.right
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.right.left = load i32, ptr %f2.addr.533
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.right.right.left = add i32 0, 0
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.right.right.right = add i32 0, 0
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.right.right = sub i32 %ifcond.649.left.left.left.left.left.left.left.left.left.left.right.right.left, %ifcond.649.left.left.left.left.left.left.left.left.left.left.right.right.right
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.right.comparison = icmp eq i32 %ifcond.649.left.left.left.left.left.left.left.left.left.left.right.left, %ifcond.649.left.left.left.left.left.left.left.left.left.left.right.right
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.right = zext i1 %ifcond.649.left.left.left.left.left.left.left.left.left.left.right.comparison to i32
  %ifcond.649.left.left.left.left.left.left.left.left.left.left = and i32 %ifcond.649.left.left.left.left.left.left.left.left.left.left.left, %ifcond.649.left.left.left.left.left.left.left.left.left.left.right
  %ifcond.649.left.left.left.left.left.left.left.left.left.right.left = load i32, ptr %c1.addr.547
  %ifcond.649.left.left.left.left.left.left.left.left.left.right.right = add i32 0, 0
  %ifcond.649.left.left.left.left.left.left.left.left.left.right.comparison = icmp eq i32 %ifcond.649.left.left.left.left.left.left.left.left.left.right.left, %ifcond.649.left.left.left.left.left.left.left.left.left.right.right
  %ifcond.649.left.left.left.left.left.left.left.left.left.right = zext i1 %ifcond.649.left.left.left.left.left.left.left.left.left.right.comparison to i32
  %ifcond.649.left.left.left.left.left.left.left.left.left = and i32 %ifcond.649.left.left.left.left.left.left.left.left.left.left, %ifcond.649.left.left.left.left.left.left.left.left.left.right
  %ifcond.649.left.left.left.left.left.left.left.left.right.left = load i32, ptr %c2.addr.559
  %ifcond.649.left.left.left.left.left.left.left.left.right.right.left = add i32 0, 0
  %ifcond.649.left.left.left.left.left.left.left.left.right.right.right = add i32 0, 0
  %ifcond.649.left.left.left.left.left.left.left.left.right.right = sub i32 %ifcond.649.left.left.left.left.left.left.left.left.right.right.left, %ifcond.649.left.left.left.left.left.left.left.left.right.right.right
  %ifcond.649.left.left.left.left.left.left.left.left.right.comparison = icmp eq i32 %ifcond.649.left.left.left.left.left.left.left.left.right.left, %ifcond.649.left.left.left.left.left.left.left.left.right.right
  %ifcond.649.left.left.left.left.left.left.left.left.right = zext i1 %ifcond.649.left.left.left.left.left.left.left.left.right.comparison to i32
  %ifcond.649.left.left.left.left.left.left.left.left = and i32 %ifcond.649.left.left.left.left.left.left.left.left.left, %ifcond.649.left.left.left.left.left.left.left.left.right
  %ifcond.649.left.left.left.left.left.left.left.right.left = load i32, ptr %r1.addr.573
  %ifcond.649.left.left.left.left.left.left.left.right.right = add i32 0, 0
  %ifcond.649.left.left.left.left.left.left.left.right.comparison = icmp eq i32 %ifcond.649.left.left.left.left.left.left.left.right.left, %ifcond.649.left.left.left.left.left.left.left.right.right
  %ifcond.649.left.left.left.left.left.left.left.right = zext i1 %ifcond.649.left.left.left.left.left.left.left.right.comparison to i32
  %ifcond.649.left.left.left.left.left.left.left = and i32 %ifcond.649.left.left.left.left.left.left.left.left, %ifcond.649.left.left.left.left.left.left.left.right
  %ifcond.649.left.left.left.left.left.left.right.left = load i32, ptr %r2.addr.585
  %ifcond.649.left.left.left.left.left.left.right.right.left = add i32 0, 0
  %ifcond.649.left.left.left.left.left.left.right.right.right = add i32 0, 0
  %ifcond.649.left.left.left.left.left.left.right.right = sub i32 %ifcond.649.left.left.left.left.left.left.right.right.left, %ifcond.649.left.left.left.left.left.left.right.right.right
  %ifcond.649.left.left.left.left.left.left.right.comparison = icmp eq i32 %ifcond.649.left.left.left.left.left.left.right.left, %ifcond.649.left.left.left.left.left.left.right.right
  %ifcond.649.left.left.left.left.left.left.right = zext i1 %ifcond.649.left.left.left.left.left.left.right.comparison to i32
  %ifcond.649.left.left.left.left.left.left = and i32 %ifcond.649.left.left.left.left.left.left.left, %ifcond.649.left.left.left.left.left.left.right
  %ifcond.649.left.left.left.left.left.right.left.arg0 = add i32 0, 0
  %ifcond.649.left.left.left.left.left.right.left.arg1 = add i32 0, 0
  %ifcond.649.left.left.left.left.left.right.left = call i32 @BasicMath_min(i32 %ifcond.649.left.left.left.left.left.right.left.arg0, i32 %ifcond.649.left.left.left.left.left.right.left.arg1)
  %ifcond.649.left.left.left.left.left.right.right = add i32 0, 0
  %ifcond.649.left.left.left.left.left.right.comparison = icmp eq i32 %ifcond.649.left.left.left.left.left.right.left, %ifcond.649.left.left.left.left.left.right.right
  %ifcond.649.left.left.left.left.left.right = zext i1 %ifcond.649.left.left.left.left.left.right.comparison to i32
  %ifcond.649.left.left.left.left.left = and i32 %ifcond.649.left.left.left.left.left.left, %ifcond.649.left.left.left.left.left.right
  %ifcond.649.left.left.left.left.right.left.arg0 = add i32 0, 0
  %ifcond.649.left.left.left.left.right.left.arg1 = add i32 0, 0
  %ifcond.649.left.left.left.left.right.left = call i32 @BasicMath_max(i32 %ifcond.649.left.left.left.left.right.left.arg0, i32 %ifcond.649.left.left.left.left.right.left.arg1)
  %ifcond.649.left.left.left.left.right.right = add i32 0, 0
  %ifcond.649.left.left.left.left.right.comparison = icmp eq i32 %ifcond.649.left.left.left.left.right.left, %ifcond.649.left.left.left.left.right.right
  %ifcond.649.left.left.left.left.right = zext i1 %ifcond.649.left.left.left.left.right.comparison to i32
  %ifcond.649.left.left.left.left = and i32 %ifcond.649.left.left.left.left.left, %ifcond.649.left.left.left.left.right
  %ifcond.649.left.left.left.right.left = load i32, ptr %clamped.addr.599
  %ifcond.649.left.left.left.right.right = add i32 0, 0
  %ifcond.649.left.left.left.right.comparison = icmp eq i32 %ifcond.649.left.left.left.right.left, %ifcond.649.left.left.left.right.right
  %ifcond.649.left.left.left.right = zext i1 %ifcond.649.left.left.left.right.comparison to i32
  %ifcond.649.left.left.left = and i32 %ifcond.649.left.left.left.left, %ifcond.649.left.left.left.right
  %ifcond.649.left.left.right.i1 = load i1, ptr %inRange.addr.615
  %ifcond.649.left.left.right = zext i1 %ifcond.649.left.left.right.i1 to i32
  %ifcond.649.left.left = and i32 %ifcond.649.left.left.left, %ifcond.649.left.left.right
  %ifcond.649.left.right.i1 = load i1, ptr %close.addr.631
  %ifcond.649.left.right = zext i1 %ifcond.649.left.right.i1 to i32
  %ifcond.649.left = and i32 %ifcond.649.left.left, %ifcond.649.left.right
  %ifcond.649 = icmp ne i32 %ifcond.649.left, 0
  br i1 %ifcond.649, label %if.then.649, label %if.else.649
if.then.649:
  %if.then.ret.649 = add i32 0, 0
  ret i32 %if.then.ret.649
if.else.649:
  br label %if.end.649
if.end.649:
  %ret.742 = add i32 0, 1
  ret i32 %ret.742
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

