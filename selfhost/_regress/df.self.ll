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

%class.Tally = type { i64, double }

define i64 @Tally_bump(ptr %arg.this) {
entry:
  %total.addr.5 = getelementptr inbounds %class.Tally, ptr %arg.this, i32 0, i32 0
  %total = getelementptr inbounds %class.Tally, ptr %arg.this, i32 0, i32 0
  %ratio.addr.12 = getelementptr inbounds %class.Tally, ptr %arg.this, i32 0, i32 1
  %ratio = getelementptr inbounds %class.Tally, ptr %arg.this, i32 0, i32 1
  %total.assign.26.left = load i64, ptr %total
  %total.assign.26.right = add i64 0, 2147483650
  %total.assign.26 = add i64 %total.assign.26.left, %total.assign.26.right
  store i64 %total.assign.26, ptr %total
  %ret.32 = load i64, ptr %total
  ret i64 %ret.32
}

define double @Tally_scale(ptr %arg.this) {
entry:
  %total.addr.5 = getelementptr inbounds %class.Tally, ptr %arg.this, i32 0, i32 0
  %total = getelementptr inbounds %class.Tally, ptr %arg.this, i32 0, i32 0
  %ratio.addr.12 = getelementptr inbounds %class.Tally, ptr %arg.this, i32 0, i32 1
  %ratio = getelementptr inbounds %class.Tally, ptr %arg.this, i32 0, i32 1
  %ratio.assign.43.left = load double, ptr %ratio
  %ratio.assign.43.right = fadd double 0.000000e+00, 0x3FF8000000000000
  %ratio.assign.43 = fadd double %ratio.assign.43.left, %ratio.assign.43.right
  store double %ratio.assign.43, ptr %ratio
  %ret.49 = load double, ptr %ratio
  ret double %ret.49
}

define i32 @csec_user_main() {
entry:
  %t.object.61 = alloca %class.Tally
  %t.addr.61 = alloca ptr
  store ptr %t.object.61, ptr %t.addr.61
  %t.init.0 = add i64 0, 0
  %t.field.0 = getelementptr inbounds %class.Tally, ptr %t.object.61, i32 0, i32 0
  store i64 %t.init.0, ptr %t.field.0
  %t.init.1 = fadd double 0.000000e+00, 0x0000000000000000
  %t.field.1 = getelementptr inbounds %class.Tally, ptr %t.object.61, i32 0, i32 1
  store double %t.init.1, ptr %t.field.1
  %a.addr.69 = alloca i64
  %a.init.69.this = load ptr, ptr %t.addr.61
  %a.init.69 = call i64 @Tally_bump(ptr %a.init.69.this)
  store i64 %a.init.69, ptr %a.addr.69
  %b.addr.80 = alloca double
  %b.init.80.this = load ptr, ptr %t.addr.61
  %b.init.80 = call double @Tally_scale(ptr %b.init.80.this)
  store double %b.init.80, ptr %b.addr.80
  %ifcond.91.left.left.left = load i64, ptr %a.addr.69
  %ifcond.91.left.left.right = add i64 0, 2147483650
  %ifcond.91.left.left = icmp eq i64 %ifcond.91.left.left.left, %ifcond.91.left.left.right
  %ifcond.91.left.right.left = load double, ptr %b.addr.80
  %ifcond.91.left.right.right = fadd double 0.000000e+00, 0x3FF6666666666666
  %ifcond.91.left.right = fcmp ogt double %ifcond.91.left.right.left, %ifcond.91.left.right.right
  %ifcond.91.left = and i1 %ifcond.91.left.left, %ifcond.91.left.right
  %ifcond.91.right.left = load double, ptr %b.addr.80
  %ifcond.91.right.right = fadd double 0.000000e+00, 0x3FF999999999999A
  %ifcond.91.right = fcmp olt double %ifcond.91.right.left, %ifcond.91.right.right
  %ifcond.91 = and i1 %ifcond.91.left, %ifcond.91.right
  br i1 %ifcond.91, label %if.then.91, label %if.else.91
if.then.91:
  %ret.106 = add i32 0, 0
  ret i32 %ret.106
if.else.91:
  br label %if.end.91
if.end.91:
  %ret.110 = add i32 0, 1
  ret i32 %ret.110
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

