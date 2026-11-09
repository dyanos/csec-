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

define double @floorPositive(double %arg.value) {
entry:
  %value = alloca double
  store double %arg.value, ptr %value
  %whole.addr.10 = alloca double
  %whole.init.10 = fadd double 0.000000e+00, 0x0000000000000000
  store double %whole.init.10, ptr %whole.addr.10
  %double.if.17.left = load double, ptr %value
  %double.if.17.right = fadd double 0.000000e+00, 0x0000000000000000
  %double.if.17 = fcmp oge double %double.if.17.left, %double.if.17.right
  br i1 %double.if.17, label %double.if.then.17, label %double.if.else.17
double.if.then.17:
  br label %double.while.cond.24
double.while.cond.24:
  %double.while.24.left.left = load double, ptr %whole.addr.10
  %double.while.24.left.right = fadd double 0.000000e+00, 0x3FF0000000000000
  %double.while.24.left = fadd double %double.while.24.left.left, %double.while.24.left.right
  %double.while.24.right = load double, ptr %value
  %double.while.24 = fcmp ole double %double.while.24.left, %double.while.24.right
  br i1 %double.while.24, label %double.while.body.24, label %double.while.end.24
double.while.body.24:
  %whole.assign.33.left = load double, ptr %whole.addr.10
  %whole.assign.33.right = fadd double 0.000000e+00, 0x3FF0000000000000
  %whole.assign.33 = fadd double %whole.assign.33.left, %whole.assign.33.right
  store double %whole.assign.33, ptr %whole.addr.10
  br label %double.while.cond.24
double.while.end.24:
  %ret.40 = load double, ptr %whole.addr.10
  ret double %ret.40
double.if.else.17:
  br label %double.if.end.17
double.if.end.17:
  %ret.44.left = fadd double 0.000000e+00, 0x0000000000000000
  %ret.44.right = fadd double 0.000000e+00, 0x3FF0000000000000
  %ret.44 = fsub double %ret.44.left, %ret.44.right
  ret double %ret.44
}

define i32 @csec_user_main() {
entry:
  %ifcond.57.left.left.arg0 = fadd double 0.000000e+00, 0x400F333333333333
  %ifcond.57.left.left = call double @floorPositive(double %ifcond.57.left.left.arg0)
  %ifcond.57.left.right = fadd double 0.000000e+00, 0x4008000000000000
  %ifcond.57.left = fcmp oeq double %ifcond.57.left.left, %ifcond.57.left.right
  %ifcond.57.right.left.arg0.left = fadd double 0.000000e+00, 0x0000000000000000
  %ifcond.57.right.left.arg0.right = fadd double 0.000000e+00, 0x4000000000000000
  %ifcond.57.right.left.arg0 = fsub double %ifcond.57.right.left.arg0.left, %ifcond.57.right.left.arg0.right
  %ifcond.57.right.left = call double @floorPositive(double %ifcond.57.right.left.arg0)
  %ifcond.57.right.right.left = fadd double 0.000000e+00, 0x0000000000000000
  %ifcond.57.right.right.right = fadd double 0.000000e+00, 0x3FF0000000000000
  %ifcond.57.right.right = fsub double %ifcond.57.right.right.left, %ifcond.57.right.right.right
  %ifcond.57.right = fcmp oeq double %ifcond.57.right.left, %ifcond.57.right.right
  %ifcond.57 = and i1 %ifcond.57.left, %ifcond.57.right
  br i1 %ifcond.57, label %if.then.57, label %if.else.57
if.then.57:
  %if.then.ret.57 = add i32 0, 0
  ret i32 %if.then.ret.57
if.else.57:
  br label %if.end.57
if.end.57:
  %ret.84 = add i32 0, 1
  ret i32 %ret.84
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

