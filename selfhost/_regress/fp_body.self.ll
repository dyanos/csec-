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

@.str.29 = private unnamed_addr constant [5 x i8] c"step\00"

define float @scaled(i32 %arg.count) {
entry:
  %count = alloca i32
  store i32 %arg.count, ptr %count
  %total.addr.10 = alloca float
  %total.init.10 = fadd float 0.000000e+00, 0x0000000000000000
  store float %total.init.10, ptr %total.addr.10
  %cursor.addr.17 = alloca i32
  %cursor.init.17 = add i32 0, 0
  store i32 %cursor.init.17, ptr %cursor.addr.17
  %label.addr.24 = alloca ptr
  %label.init.24 = getelementptr inbounds [5 x i8], ptr @.str.29, i32 0, i32 0
  store ptr %label.init.24, ptr %label.addr.24
  br label %while.cond.31
while.cond.31:
  %whilecond.31.i32.left = load i32, ptr %cursor.addr.17
  %whilecond.31.i32.right = load i32, ptr %count
  %whilecond.31.i32.comparison = icmp slt i32 %whilecond.31.i32.left, %whilecond.31.i32.right
  %whilecond.31.i32 = zext i1 %whilecond.31.i32.comparison to i32
  %whilecond.31 = icmp ne i32 %whilecond.31.i32, 0
  br i1 %whilecond.31, label %while.body.31, label %while.end.31
while.body.31:
  %total.assign.38.left = load float, ptr %total.addr.10
  %total.assign.38.right = fadd float 0.000000e+00, 0x3FF8000000000000
  %total.assign.38 = fadd float %total.assign.38.left, %total.assign.38.right
  store float %total.assign.38, ptr %total.addr.10
  %cursor.assign.44.left = load i32, ptr %cursor.addr.17
  %cursor.assign.44.right = add i32 0, 1
  %cursor.assign.44 = add i32 %cursor.assign.44.left, %cursor.assign.44.right
  store i32 %cursor.assign.44, ptr %cursor.addr.17
  br label %while.cond.31
while.end.31:
  %ifcond.51.i32.left.string = load ptr, ptr %label.addr.24
  %ifcond.51.i32.left.length64 = call i64 @csec_string_length(ptr %ifcond.51.i32.left.string)
  %ifcond.51.i32.left = trunc i64 %ifcond.51.i32.left.length64 to i32
  %ifcond.51.i32.right = add i32 0, 4
  %ifcond.51.i32.comparison = icmp eq i32 %ifcond.51.i32.left, %ifcond.51.i32.right
  %ifcond.51.i32 = zext i1 %ifcond.51.i32.comparison to i32
  %ifcond.51 = icmp ne i32 %ifcond.51.i32, 0
  br i1 %ifcond.51, label %if.then.51, label %if.else.51
if.then.51:
  %ret.60 = load float, ptr %total.addr.10
  ret float %ret.60
if.else.51:
  br label %if.end.51
if.end.51:
  %ret.64 = fadd float 0.000000e+00, 0x0000000000000000
  ret float %ret.64
}

define double @scaledDouble(i32 %arg.count) {
entry:
  %count = alloca i32
  store i32 %arg.count, ptr %count
  %total.addr.78 = alloca double
  %total.init.78 = fadd double 0.000000e+00, 0x0000000000000000
  store double %total.init.78, ptr %total.addr.78
  %cursor.addr.85 = alloca i32
  %cursor.init.85 = add i32 0, 0
  store i32 %cursor.init.85, ptr %cursor.addr.85
  br label %while.cond.92
while.cond.92:
  %whilecond.92.i32.left = load i32, ptr %cursor.addr.85
  %whilecond.92.i32.right = load i32, ptr %count
  %whilecond.92.i32.comparison = icmp slt i32 %whilecond.92.i32.left, %whilecond.92.i32.right
  %whilecond.92.i32 = zext i1 %whilecond.92.i32.comparison to i32
  %whilecond.92 = icmp ne i32 %whilecond.92.i32, 0
  br i1 %whilecond.92, label %while.body.92, label %while.end.92
while.body.92:
  %total.assign.99.left = load double, ptr %total.addr.78
  %total.assign.99.right = fadd double 0.000000e+00, 0x4004000000000000
  %total.assign.99 = fadd double %total.assign.99.left, %total.assign.99.right
  store double %total.assign.99, ptr %total.addr.78
  %cursor.assign.105.left = load i32, ptr %cursor.addr.85
  %cursor.assign.105.right = add i32 0, 1
  %cursor.assign.105 = add i32 %cursor.assign.105.left, %cursor.assign.105.right
  store i32 %cursor.assign.105, ptr %cursor.addr.85
  br label %while.cond.92
while.end.92:
  %ret.112 = load double, ptr %total.addr.78
  ret double %ret.112
}

define i32 @csec_user_main() {
entry:
  %a.addr.123 = alloca float
  %a.init.123.arg0 = add i32 0, 4
  %a.init.123 = call float @scaled(i32 %a.init.123.arg0)
  store float %a.init.123, ptr %a.addr.123
  %b.addr.133 = alloca double
  %b.init.133.arg0 = add i32 0, 4
  %b.init.133 = call double @scaledDouble(i32 %b.init.133.arg0)
  store double %b.init.133, ptr %b.addr.133
  %ifcond.143.left.left.left.left = load float, ptr %a.addr.123
  %ifcond.143.left.left.left.right = fadd float 0.000000e+00, 0x40179999A0000000
  %ifcond.143.left.left.left = fcmp ogt float %ifcond.143.left.left.left.left, %ifcond.143.left.left.left.right
  %ifcond.143.left.left.right.left = load float, ptr %a.addr.123
  %ifcond.143.left.left.right.right = fadd float 0.000000e+00, 0x4018666660000000
  %ifcond.143.left.left.right = fcmp olt float %ifcond.143.left.left.right.left, %ifcond.143.left.left.right.right
  %ifcond.143.left.left = and i1 %ifcond.143.left.left.left, %ifcond.143.left.left.right
  %ifcond.143.left.right.left = load double, ptr %b.addr.133
  %ifcond.143.left.right.right = fadd double 0.000000e+00, 0x4023CCCCCCCCCCCD
  %ifcond.143.left.right = fcmp ogt double %ifcond.143.left.right.left, %ifcond.143.left.right.right
  %ifcond.143.left = and i1 %ifcond.143.left.left, %ifcond.143.left.right
  %ifcond.143.right.left = load double, ptr %b.addr.133
  %ifcond.143.right.right = fadd double 0.000000e+00, 0x4024333333333333
  %ifcond.143.right = fcmp olt double %ifcond.143.right.left, %ifcond.143.right.right
  %ifcond.143 = and i1 %ifcond.143.left, %ifcond.143.right
  br i1 %ifcond.143, label %if.then.143, label %if.else.143
if.then.143:
  %ret.162 = add i32 0, 0
  ret i32 %ret.162
if.else.143:
  br label %if.end.143
if.end.143:
  %ret.166 = add i32 0, 1
  ret i32 %ret.166
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

