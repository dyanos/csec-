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
  %float.if.15.left = load float, ptr %x
  %float.if.15.right = fadd float 0.000000e+00, 0x0000000000000000
  %float.if.15 = fcmp olt float %float.if.15.left, %float.if.15.right
  br i1 %float.if.15, label %float.if.then.15, label %float.if.else.15
float.if.then.15:
  %ret.22.left = fadd float 0.000000e+00, 0x0000000000000000
  %ret.22.right = load float, ptr %x
  %ret.22 = fsub float %ret.22.left, %ret.22.right
  ret float %ret.22
float.if.else.15:
  br label %float.if.end.15
float.if.end.15:
  %ret.28 = load float, ptr %x
  ret float %ret.28
}

define float @BasicMath_sign(float %arg.x) {
entry:
  %x = alloca float
  store float %arg.x, ptr %x
  %float.if.42.left = load float, ptr %x
  %float.if.42.right = fadd float 0.000000e+00, 0x0000000000000000
  %float.if.42 = fcmp olt float %float.if.42.left, %float.if.42.right
  br i1 %float.if.42, label %float.if.then.42, label %float.if.else.42
float.if.then.42:
  %ret.49.left = fadd float 0.000000e+00, 0x0000000000000000
  %ret.49.right = fadd float 0.000000e+00, 0x3FF0000000000000
  %ret.49 = fsub float %ret.49.left, %ret.49.right
  ret float %ret.49
float.if.else.42:
  br label %float.if.end.42
float.if.end.42:
  %float.if.55.left = load float, ptr %x
  %float.if.55.right = fadd float 0.000000e+00, 0x0000000000000000
  %float.if.55 = fcmp ogt float %float.if.55.left, %float.if.55.right
  br i1 %float.if.55, label %float.if.then.55, label %float.if.else.55
float.if.then.55:
  %ret.62 = fadd float 0.000000e+00, 0x3FF0000000000000
  ret float %ret.62
float.if.else.55:
  br label %float.if.end.55
float.if.end.55:
  %ret.66 = fadd float 0.000000e+00, 0x0000000000000000
  ret float %ret.66
}

define float @BasicMath_floor(float %arg.x) {
entry:
  %x = alloca float
  store float %arg.x, ptr %x
  %whole.addr.80 = alloca float
  %whole.init.80 = fadd float 0.000000e+00, 0x0000000000000000
  store float %whole.init.80, ptr %whole.addr.80
  %float.if.87.left = load float, ptr %x
  %float.if.87.right = fadd float 0.000000e+00, 0x0000000000000000
  %float.if.87 = fcmp oge float %float.if.87.left, %float.if.87.right
  br i1 %float.if.87, label %float.if.then.87, label %float.if.else.87
float.if.then.87:
  br label %float.while.cond.94
float.while.cond.94:
  %float.while.94.left.left = load float, ptr %whole.addr.80
  %float.while.94.left.right = fadd float 0.000000e+00, 0x3FF0000000000000
  %float.while.94.left = fadd float %float.while.94.left.left, %float.while.94.left.right
  %float.while.94.right = load float, ptr %x
  %float.while.94 = fcmp ole float %float.while.94.left, %float.while.94.right
  br i1 %float.while.94, label %float.while.body.94, label %float.while.end.94
float.while.body.94:
  %whole.assign.103.left = load float, ptr %whole.addr.80
  %whole.assign.103.right = fadd float 0.000000e+00, 0x3FF0000000000000
  %whole.assign.103 = fadd float %whole.assign.103.left, %whole.assign.103.right
  store float %whole.assign.103, ptr %whole.addr.80
  br label %float.while.cond.94
float.while.end.94:
  %ret.110 = load float, ptr %whole.addr.80
  ret float %ret.110
float.if.else.87:
  br label %float.if.end.87
float.if.end.87:
  br label %float.while.cond.114
float.while.cond.114:
  %float.while.114.left = load float, ptr %whole.addr.80
  %float.while.114.right = load float, ptr %x
  %float.while.114 = fcmp ogt float %float.while.114.left, %float.while.114.right
  br i1 %float.while.114, label %float.while.body.114, label %float.while.end.114
float.while.body.114:
  %whole.assign.121.left = load float, ptr %whole.addr.80
  %whole.assign.121.right = fadd float 0.000000e+00, 0x3FF0000000000000
  %whole.assign.121 = fsub float %whole.assign.121.left, %whole.assign.121.right
  store float %whole.assign.121, ptr %whole.addr.80
  br label %float.while.cond.114
float.while.end.114:
  %ret.128 = load float, ptr %whole.addr.80
  ret float %ret.128
}

define float @BasicMath_ceil(float %arg.x) {
entry:
  %x = alloca float
  store float %arg.x, ptr %x
  %whole.addr.142 = alloca float
  %whole.init.142 = fadd float 0.000000e+00, 0x0000000000000000
  store float %whole.init.142, ptr %whole.addr.142
  %float.if.149.left = load float, ptr %x
  %float.if.149.right = fadd float 0.000000e+00, 0x0000000000000000
  %float.if.149 = fcmp oge float %float.if.149.left, %float.if.149.right
  br i1 %float.if.149, label %float.if.then.149, label %float.if.else.149
float.if.then.149:
  br label %float.while.cond.156
float.while.cond.156:
  %float.while.156.left = load float, ptr %whole.addr.142
  %float.while.156.right = load float, ptr %x
  %float.while.156 = fcmp olt float %float.while.156.left, %float.while.156.right
  br i1 %float.while.156, label %float.while.body.156, label %float.while.end.156
float.while.body.156:
  %whole.assign.163.left = load float, ptr %whole.addr.142
  %whole.assign.163.right = fadd float 0.000000e+00, 0x3FF0000000000000
  %whole.assign.163 = fadd float %whole.assign.163.left, %whole.assign.163.right
  store float %whole.assign.163, ptr %whole.addr.142
  br label %float.while.cond.156
float.while.end.156:
  %ret.170 = load float, ptr %whole.addr.142
  ret float %ret.170
float.if.else.149:
  br label %float.if.end.149
float.if.end.149:
  br label %float.while.cond.174
float.while.cond.174:
  %float.while.174.left.left = load float, ptr %whole.addr.142
  %float.while.174.left.right = fadd float 0.000000e+00, 0x3FF0000000000000
  %float.while.174.left = fsub float %float.while.174.left.left, %float.while.174.left.right
  %float.while.174.right = load float, ptr %x
  %float.while.174 = fcmp oge float %float.while.174.left, %float.while.174.right
  br i1 %float.while.174, label %float.while.body.174, label %float.while.end.174
float.while.body.174:
  %whole.assign.183.left = load float, ptr %whole.addr.142
  %whole.assign.183.right = fadd float 0.000000e+00, 0x3FF0000000000000
  %whole.assign.183 = fsub float %whole.assign.183.left, %whole.assign.183.right
  store float %whole.assign.183, ptr %whole.addr.142
  br label %float.while.cond.174
float.while.end.174:
  %ret.190 = load float, ptr %whole.addr.142
  ret float %ret.190
}

define float @BasicMath_round(float %arg.x) {
entry:
  %x = alloca float
  store float %arg.x, ptr %x
  %whole.addr.204 = alloca float
  %whole.init.204 = fadd float 0.000000e+00, 0x0000000000000000
  store float %whole.init.204, ptr %whole.addr.204
  %float.if.211.left = load float, ptr %x
  %float.if.211.right = fadd float 0.000000e+00, 0x0000000000000000
  %float.if.211 = fcmp oge float %float.if.211.left, %float.if.211.right
  br i1 %float.if.211, label %float.if.then.211, label %float.if.else.211
float.if.then.211:
  %target.addr.218 = alloca float
  %target.init.218.left = load float, ptr %x
  %target.init.218.right = fadd float 0.000000e+00, 0x3FE0000000000000
  %target.init.218 = fadd float %target.init.218.left, %target.init.218.right
  store float %target.init.218, ptr %target.addr.218
  br label %float.while.cond.227
float.while.cond.227:
  %float.while.227.left.left = load float, ptr %whole.addr.204
  %float.while.227.left.right = fadd float 0.000000e+00, 0x3FF0000000000000
  %float.while.227.left = fadd float %float.while.227.left.left, %float.while.227.left.right
  %float.while.227.right = load float, ptr %target.addr.218
  %float.while.227 = fcmp ole float %float.while.227.left, %float.while.227.right
  br i1 %float.while.227, label %float.while.body.227, label %float.while.end.227
float.while.body.227:
  %whole.assign.236.left = load float, ptr %whole.addr.204
  %whole.assign.236.right = fadd float 0.000000e+00, 0x3FF0000000000000
  %whole.assign.236 = fadd float %whole.assign.236.left, %whole.assign.236.right
  store float %whole.assign.236, ptr %whole.addr.204
  br label %float.while.cond.227
float.while.end.227:
  %ret.243 = load float, ptr %whole.addr.204
  ret float %ret.243
float.if.else.211:
  br label %float.if.end.211
float.if.end.211:
  %target.addr.247 = alloca float
  %target.init.247.left = load float, ptr %x
  %target.init.247.right = fadd float 0.000000e+00, 0x3FE0000000000000
  %target.init.247 = fsub float %target.init.247.left, %target.init.247.right
  store float %target.init.247, ptr %target.addr.247
  br label %float.while.cond.256
float.while.cond.256:
  %float.while.256.left.left = load float, ptr %whole.addr.204
  %float.while.256.left.right = fadd float 0.000000e+00, 0x3FF0000000000000
  %float.while.256.left = fsub float %float.while.256.left.left, %float.while.256.left.right
  %float.while.256.right = load float, ptr %target.addr.247
  %float.while.256 = fcmp oge float %float.while.256.left, %float.while.256.right
  br i1 %float.while.256, label %float.while.body.256, label %float.while.end.256
float.while.body.256:
  %whole.assign.265.left = load float, ptr %whole.addr.204
  %whole.assign.265.right = fadd float 0.000000e+00, 0x3FF0000000000000
  %whole.assign.265 = fsub float %whole.assign.265.left, %whole.assign.265.right
  store float %whole.assign.265, ptr %whole.addr.204
  br label %float.while.cond.256
float.while.end.256:
  %ret.272 = load float, ptr %whole.addr.204
  ret float %ret.272
}

define float @BasicMath_min(float %arg.left, float %arg.right) {
entry:
  %left = alloca float
  store float %arg.left, ptr %left
  %right = alloca float
  store float %arg.right, ptr %right
  %float.if.290.left = load float, ptr %left
  %float.if.290.right = load float, ptr %right
  %float.if.290 = fcmp olt float %float.if.290.left, %float.if.290.right
  br i1 %float.if.290, label %float.if.then.290, label %float.if.else.290
float.if.then.290:
  %ret.297 = load float, ptr %left
  ret float %ret.297
float.if.else.290:
  br label %float.if.end.290
float.if.end.290:
  %ret.301 = load float, ptr %right
  ret float %ret.301
}

define float @BasicMath_max(float %arg.left, float %arg.right) {
entry:
  %left = alloca float
  store float %arg.left, ptr %left
  %right = alloca float
  store float %arg.right, ptr %right
  %float.if.319.left = load float, ptr %left
  %float.if.319.right = load float, ptr %right
  %float.if.319 = fcmp ogt float %float.if.319.left, %float.if.319.right
  br i1 %float.if.319, label %float.if.then.319, label %float.if.else.319
float.if.then.319:
  %ret.326 = load float, ptr %left
  ret float %ret.326
float.if.else.319:
  br label %float.if.end.319
float.if.end.319:
  %ret.330 = load float, ptr %right
  ret float %ret.330
}

define float @BasicMath_clamp(float %arg.value, float %arg.low, float %arg.high) {
entry:
  %value = alloca float
  store float %arg.value, ptr %value
  %low = alloca float
  store float %arg.low, ptr %low
  %high = alloca float
  store float %arg.high, ptr %high
  %float.if.352.left = load float, ptr %value
  %float.if.352.right = load float, ptr %low
  %float.if.352 = fcmp olt float %float.if.352.left, %float.if.352.right
  br i1 %float.if.352, label %float.if.then.352, label %float.if.else.352
float.if.then.352:
  %ret.359 = load float, ptr %low
  ret float %ret.359
float.if.else.352:
  br label %float.if.end.352
float.if.end.352:
  %float.if.363.left = load float, ptr %value
  %float.if.363.right = load float, ptr %high
  %float.if.363 = fcmp ogt float %float.if.363.left, %float.if.363.right
  br i1 %float.if.363, label %float.if.then.363, label %float.if.else.363
float.if.then.363:
  %ret.370 = load float, ptr %high
  ret float %ret.370
float.if.else.363:
  br label %float.if.end.363
float.if.end.363:
  %ret.374 = load float, ptr %value
  ret float %ret.374
}

define i1 @BasicMath_between(float %arg.value, float %arg.low, float %arg.high) {
entry:
  %value = alloca float
  store float %arg.value, ptr %value
  %low = alloca float
  store float %arg.low, ptr %low
  %high = alloca float
  store float %arg.high, ptr %high
  %ret.396.left.left = load float, ptr %value
  %ret.396.left.right = load float, ptr %low
  %ret.396.left = fcmp oge float %ret.396.left.left, %ret.396.left.right
  %ret.396.right.left = load float, ptr %value
  %ret.396.right.right = load float, ptr %high
  %ret.396.right = fcmp ole float %ret.396.right.left, %ret.396.right.right
  %ret.396 = and i1 %ret.396.left, %ret.396.right
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
  %diff.addr.424 = alloca float
  %diff.init.424.left = load float, ptr %left
  %diff.init.424.right = load float, ptr %right
  %diff.init.424 = fsub float %diff.init.424.left, %diff.init.424.right
  store float %diff.init.424, ptr %diff.addr.424
  %bool.if.433.left = load float, ptr %diff.addr.424
  %bool.if.433.right = fadd float 0.000000e+00, 0x0000000000000000
  %bool.if.433 = fcmp olt float %bool.if.433.left, %bool.if.433.right
  br i1 %bool.if.433, label %bool.if.then.433, label %bool.if.else.433
bool.if.then.433:
  %diff.assign.440.left = fadd float 0.000000e+00, 0x0000000000000000
  %diff.assign.440.right = load float, ptr %diff.addr.424
  %diff.assign.440 = fsub float %diff.assign.440.left, %diff.assign.440.right
  store float %diff.assign.440, ptr %diff.addr.424
  br label %bool.if.end.433
bool.if.else.433:
  br label %bool.if.end.433
bool.if.end.433:
  %ret.447.left = load float, ptr %diff.addr.424
  %ret.447.right = load float, ptr %epsilon
  %ret.447 = fcmp ole float %ret.447.left, %ret.447.right
  ret i1 %ret.447
}

define i32 @csec_user_main() {
entry:
  %math.addr.461 = alloca i32
  store i32 0, ptr %math.addr.461
  %a.addr.469 = alloca float
  %a.init.469.arg0.left = fadd float 0.000000e+00, 0x0000000000000000
  %a.init.469.arg0.right = fadd float 0.000000e+00, 0x401E000000000000
  %a.init.469.arg0 = fsub float %a.init.469.arg0.left, %a.init.469.arg0.right
  %a.init.469 = call float @BasicMath_abs(float %a.init.469.arg0)
  store float %a.init.469, ptr %a.addr.469
  %s1.addr.483 = alloca float
  %s1.init.483.arg0.left = fadd float 0.000000e+00, 0x0000000000000000
  %s1.init.483.arg0.right = fadd float 0.000000e+00, 0x4022000000000000
  %s1.init.483.arg0 = fsub float %s1.init.483.arg0.left, %s1.init.483.arg0.right
  %s1.init.483 = call float @BasicMath_sign(float %s1.init.483.arg0)
  store float %s1.init.483, ptr %s1.addr.483
  %s2.addr.497 = alloca float
  %s2.init.497.arg0 = fadd float 0.000000e+00, 0x0000000000000000
  %s2.init.497 = call float @BasicMath_sign(float %s2.init.497.arg0)
  store float %s2.init.497, ptr %s2.addr.497
  %s3.addr.509 = alloca float
  %s3.init.509.arg0 = fadd float 0.000000e+00, 0x4028000000000000
  %s3.init.509 = call float @BasicMath_sign(float %s3.init.509.arg0)
  store float %s3.init.509, ptr %s3.addr.509
  %f1.addr.521 = alloca float
  %f1.init.521.arg0 = fadd float 0.000000e+00, 0x400F333340000000
  %f1.init.521 = call float @BasicMath_floor(float %f1.init.521.arg0)
  store float %f1.init.521, ptr %f1.addr.521
  %f2.addr.533 = alloca float
  %f2.init.533.arg0.left = fadd float 0.000000e+00, 0x0000000000000000
  %f2.init.533.arg0.right = fadd float 0.000000e+00, 0x4008CCCCC0000000
  %f2.init.533.arg0 = fsub float %f2.init.533.arg0.left, %f2.init.533.arg0.right
  %f2.init.533 = call float @BasicMath_floor(float %f2.init.533.arg0)
  store float %f2.init.533, ptr %f2.addr.533
  %c1.addr.547 = alloca float
  %c1.init.547.arg0 = fadd float 0.000000e+00, 0x4008CCCCC0000000
  %c1.init.547 = call float @BasicMath_ceil(float %c1.init.547.arg0)
  store float %c1.init.547, ptr %c1.addr.547
  %c2.addr.559 = alloca float
  %c2.init.559.arg0.left = fadd float 0.000000e+00, 0x0000000000000000
  %c2.init.559.arg0.right = fadd float 0.000000e+00, 0x400F333340000000
  %c2.init.559.arg0 = fsub float %c2.init.559.arg0.left, %c2.init.559.arg0.right
  %c2.init.559 = call float @BasicMath_ceil(float %c2.init.559.arg0)
  store float %c2.init.559, ptr %c2.addr.559
  %r1.addr.573 = alloca float
  %r1.init.573.arg0 = fadd float 0.000000e+00, 0x400CCCCCC0000000
  %r1.init.573 = call float @BasicMath_round(float %r1.init.573.arg0)
  store float %r1.init.573, ptr %r1.addr.573
  %r2.addr.585 = alloca float
  %r2.init.585.arg0.left = fadd float 0.000000e+00, 0x0000000000000000
  %r2.init.585.arg0.right = fadd float 0.000000e+00, 0x400CCCCCC0000000
  %r2.init.585.arg0 = fsub float %r2.init.585.arg0.left, %r2.init.585.arg0.right
  %r2.init.585 = call float @BasicMath_round(float %r2.init.585.arg0)
  store float %r2.init.585, ptr %r2.addr.585
  %clamped.addr.599 = alloca float
  %clamped.init.599.arg0 = fadd float 0.000000e+00, 0x4028000000000000
  %clamped.init.599.arg1 = fadd float 0.000000e+00, 0x0000000000000000
  %clamped.init.599.arg2 = fadd float 0.000000e+00, 0x4024000000000000
  %clamped.init.599 = call float @BasicMath_clamp(float %clamped.init.599.arg0, float %clamped.init.599.arg1, float %clamped.init.599.arg2)
  store float %clamped.init.599, ptr %clamped.addr.599
  %inRange.addr.615 = alloca i1
  %inRange.init.615.arg0 = fadd float 0.000000e+00, 0x4014000000000000
  %inRange.init.615.arg1 = fadd float 0.000000e+00, 0x3FF0000000000000
  %inRange.init.615.arg2 = fadd float 0.000000e+00, 0x4022000000000000
  %inRange.init.615 = call i1 @BasicMath_between(float %inRange.init.615.arg0, float %inRange.init.615.arg1, float %inRange.init.615.arg2)
  store i1 %inRange.init.615, ptr %inRange.addr.615
  %close.addr.631 = alloca i1
  %close.init.631.arg0.left = fadd float 0.000000e+00, 0x3FB99999A0000000
  %close.init.631.arg0.right = fadd float 0.000000e+00, 0x3FC99999A0000000
  %close.init.631.arg0 = fadd float %close.init.631.arg0.left, %close.init.631.arg0.right
  %close.init.631.arg1 = fadd float 0.000000e+00, 0x3FD3333340000000
  %close.init.631.arg2 = fadd float 0.000000e+00, 0x3EB0C6F7A0000000
  %close.init.631 = call i1 @BasicMath_approxEq(float %close.init.631.arg0, float %close.init.631.arg1, float %close.init.631.arg2)
  store i1 %close.init.631, ptr %close.addr.631
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left = load float, ptr %a.addr.469
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right = fadd float 0.000000e+00, 0x401E000000000000
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.left = fcmp oeq float %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.left.left, %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.left.right
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.right.left = load float, ptr %s1.addr.483
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.right.right.left = fadd float 0.000000e+00, 0x0000000000000000
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.right.right.right = fadd float 0.000000e+00, 0x3FF0000000000000
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.right.right = fsub float %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.right.right.left, %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.right.right.right
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.right = fcmp oeq float %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.right.left, %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.right.right
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left = and i1 %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.left, %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left.right
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.right.left = load float, ptr %s2.addr.497
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.right.right = fadd float 0.000000e+00, 0x0000000000000000
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.right = fcmp oeq float %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.right.left, %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.right.right
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left = and i1 %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.left, %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left.right
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.right.left = load float, ptr %s3.addr.509
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.right.right = fadd float 0.000000e+00, 0x3FF0000000000000
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.right = fcmp oeq float %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.right.left, %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.right.right
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.left = and i1 %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.left, %ifcond.649.left.left.left.left.left.left.left.left.left.left.left.right
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.right.left = load float, ptr %f1.addr.521
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.right.right = fadd float 0.000000e+00, 0x4008000000000000
  %ifcond.649.left.left.left.left.left.left.left.left.left.left.right = fcmp oeq float %ifcond.649.left.left.left.left.left.left.left.left.left.left.right.left, %ifcond.649.left.left.left.left.left.left.left.left.left.left.right.right
  %ifcond.649.left.left.left.left.left.left.left.left.left.left = and i1 %ifcond.649.left.left.left.left.left.left.left.left.left.left.left, %ifcond.649.left.left.left.left.left.left.left.left.left.left.right
  %ifcond.649.left.left.left.left.left.left.left.left.left.right.left = load float, ptr %f2.addr.533
  %ifcond.649.left.left.left.left.left.left.left.left.left.right.right.left = fadd float 0.000000e+00, 0x0000000000000000
  %ifcond.649.left.left.left.left.left.left.left.left.left.right.right.right = fadd float 0.000000e+00, 0x4010000000000000
  %ifcond.649.left.left.left.left.left.left.left.left.left.right.right = fsub float %ifcond.649.left.left.left.left.left.left.left.left.left.right.right.left, %ifcond.649.left.left.left.left.left.left.left.left.left.right.right.right
  %ifcond.649.left.left.left.left.left.left.left.left.left.right = fcmp oeq float %ifcond.649.left.left.left.left.left.left.left.left.left.right.left, %ifcond.649.left.left.left.left.left.left.left.left.left.right.right
  %ifcond.649.left.left.left.left.left.left.left.left.left = and i1 %ifcond.649.left.left.left.left.left.left.left.left.left.left, %ifcond.649.left.left.left.left.left.left.left.left.left.right
  %ifcond.649.left.left.left.left.left.left.left.left.right.left = load float, ptr %c1.addr.547
  %ifcond.649.left.left.left.left.left.left.left.left.right.right = fadd float 0.000000e+00, 0x4010000000000000
  %ifcond.649.left.left.left.left.left.left.left.left.right = fcmp oeq float %ifcond.649.left.left.left.left.left.left.left.left.right.left, %ifcond.649.left.left.left.left.left.left.left.left.right.right
  %ifcond.649.left.left.left.left.left.left.left.left = and i1 %ifcond.649.left.left.left.left.left.left.left.left.left, %ifcond.649.left.left.left.left.left.left.left.left.right
  %ifcond.649.left.left.left.left.left.left.left.right.left = load float, ptr %c2.addr.559
  %ifcond.649.left.left.left.left.left.left.left.right.right.left = fadd float 0.000000e+00, 0x0000000000000000
  %ifcond.649.left.left.left.left.left.left.left.right.right.right = fadd float 0.000000e+00, 0x4008000000000000
  %ifcond.649.left.left.left.left.left.left.left.right.right = fsub float %ifcond.649.left.left.left.left.left.left.left.right.right.left, %ifcond.649.left.left.left.left.left.left.left.right.right.right
  %ifcond.649.left.left.left.left.left.left.left.right = fcmp oeq float %ifcond.649.left.left.left.left.left.left.left.right.left, %ifcond.649.left.left.left.left.left.left.left.right.right
  %ifcond.649.left.left.left.left.left.left.left = and i1 %ifcond.649.left.left.left.left.left.left.left.left, %ifcond.649.left.left.left.left.left.left.left.right
  %ifcond.649.left.left.left.left.left.left.right.left = load float, ptr %r1.addr.573
  %ifcond.649.left.left.left.left.left.left.right.right = fadd float 0.000000e+00, 0x4010000000000000
  %ifcond.649.left.left.left.left.left.left.right = fcmp oeq float %ifcond.649.left.left.left.left.left.left.right.left, %ifcond.649.left.left.left.left.left.left.right.right
  %ifcond.649.left.left.left.left.left.left = and i1 %ifcond.649.left.left.left.left.left.left.left, %ifcond.649.left.left.left.left.left.left.right
  %ifcond.649.left.left.left.left.left.right.left = load float, ptr %r2.addr.585
  %ifcond.649.left.left.left.left.left.right.right.left = fadd float 0.000000e+00, 0x0000000000000000
  %ifcond.649.left.left.left.left.left.right.right.right = fadd float 0.000000e+00, 0x4010000000000000
  %ifcond.649.left.left.left.left.left.right.right = fsub float %ifcond.649.left.left.left.left.left.right.right.left, %ifcond.649.left.left.left.left.left.right.right.right
  %ifcond.649.left.left.left.left.left.right = fcmp oeq float %ifcond.649.left.left.left.left.left.right.left, %ifcond.649.left.left.left.left.left.right.right
  %ifcond.649.left.left.left.left.left = and i1 %ifcond.649.left.left.left.left.left.left, %ifcond.649.left.left.left.left.left.right
  %ifcond.649.left.left.left.left.right.left.arg0 = fadd float 0.000000e+00, 0x4000000000000000
  %ifcond.649.left.left.left.left.right.left.arg1 = fadd float 0.000000e+00, 0x4014000000000000
  %ifcond.649.left.left.left.left.right.left = call float @BasicMath_min(float %ifcond.649.left.left.left.left.right.left.arg0, float %ifcond.649.left.left.left.left.right.left.arg1)
  %ifcond.649.left.left.left.left.right.right = fadd float 0.000000e+00, 0x4000000000000000
  %ifcond.649.left.left.left.left.right = fcmp oeq float %ifcond.649.left.left.left.left.right.left, %ifcond.649.left.left.left.left.right.right
  %ifcond.649.left.left.left.left = and i1 %ifcond.649.left.left.left.left.left, %ifcond.649.left.left.left.left.right
  %ifcond.649.left.left.left.right.left.arg0 = fadd float 0.000000e+00, 0x4000000000000000
  %ifcond.649.left.left.left.right.left.arg1 = fadd float 0.000000e+00, 0x4014000000000000
  %ifcond.649.left.left.left.right.left = call float @BasicMath_max(float %ifcond.649.left.left.left.right.left.arg0, float %ifcond.649.left.left.left.right.left.arg1)
  %ifcond.649.left.left.left.right.right = fadd float 0.000000e+00, 0x4014000000000000
  %ifcond.649.left.left.left.right = fcmp oeq float %ifcond.649.left.left.left.right.left, %ifcond.649.left.left.left.right.right
  %ifcond.649.left.left.left = and i1 %ifcond.649.left.left.left.left, %ifcond.649.left.left.left.right
  %ifcond.649.left.left.right.left = load float, ptr %clamped.addr.599
  %ifcond.649.left.left.right.right = fadd float 0.000000e+00, 0x4024000000000000
  %ifcond.649.left.left.right = fcmp oeq float %ifcond.649.left.left.right.left, %ifcond.649.left.left.right.right
  %ifcond.649.left.left = and i1 %ifcond.649.left.left.left, %ifcond.649.left.left.right
  %ifcond.649.left.right = load i1, ptr %inRange.addr.615
  %ifcond.649.left = and i1 %ifcond.649.left.left, %ifcond.649.left.right
  %ifcond.649.right = load i1, ptr %close.addr.631
  %ifcond.649 = and i1 %ifcond.649.left, %ifcond.649.right
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

