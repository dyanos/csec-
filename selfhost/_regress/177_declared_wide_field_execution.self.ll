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
  %tally.object.61 = alloca %class.Tally
  %tally.addr.61 = alloca ptr
  store ptr %tally.object.61, ptr %tally.addr.61
  %tally.init.0 = add i64 0, 0
  %tally.field.0 = getelementptr inbounds %class.Tally, ptr %tally.object.61, i32 0, i32 0
  store i64 %tally.init.0, ptr %tally.field.0
  %tally.init.1 = fadd double 0.000000e+00, 0x0000000000000000
  %tally.field.1 = getelementptr inbounds %class.Tally, ptr %tally.object.61, i32 0, i32 1
  store double %tally.init.1, ptr %tally.field.1
  %first.addr.69 = alloca i64
  %first.init.69.this = load ptr, ptr %tally.addr.61
  %first.init.69 = call i64 @Tally_bump(ptr %first.init.69.this)
  store i64 %first.init.69, ptr %first.addr.69
  %second.addr.80 = alloca i64
  %second.init.80.this = load ptr, ptr %tally.addr.61
  %second.init.80 = call i64 @Tally_bump(ptr %second.init.80.this)
  store i64 %second.init.80, ptr %second.addr.80
  %ratio.addr.91 = alloca double
  %ratio.init.91.this = load ptr, ptr %tally.addr.61
  %ratio.init.91 = call double @Tally_scale(ptr %ratio.init.91.this)
  store double %ratio.init.91, ptr %ratio.addr.91
  %ifcond.102.left.left.left.left = load i64, ptr %first.addr.69
  %ifcond.102.left.left.left.right = add i64 0, 2147483650
  %ifcond.102.left.left.left = icmp eq i64 %ifcond.102.left.left.left.left, %ifcond.102.left.left.left.right
  %ifcond.102.left.left.right.left = load i64, ptr %second.addr.80
  %ifcond.102.left.left.right.right = add i64 0, 4294967300
  %ifcond.102.left.left.right = icmp eq i64 %ifcond.102.left.left.right.left, %ifcond.102.left.left.right.right
  %ifcond.102.left.left = and i1 %ifcond.102.left.left.left, %ifcond.102.left.left.right
  %ifcond.102.left.right.left = load double, ptr %ratio.addr.91
  %ifcond.102.left.right.right = fadd double 0.000000e+00, 0x3FF6666666666666
  %ifcond.102.left.right = fcmp ogt double %ifcond.102.left.right.left, %ifcond.102.left.right.right
  %ifcond.102.left = and i1 %ifcond.102.left.left, %ifcond.102.left.right
  %ifcond.102.right.left = load double, ptr %ratio.addr.91
  %ifcond.102.right.right = fadd double 0.000000e+00, 0x3FF999999999999A
  %ifcond.102.right = fcmp olt double %ifcond.102.right.left, %ifcond.102.right.right
  %ifcond.102 = and i1 %ifcond.102.left, %ifcond.102.right
  br i1 %ifcond.102, label %if.then.102, label %if.else.102
if.then.102:
  %ret.121 = add i32 0, 0
  ret i32 %ret.121
if.else.102:
  br label %if.end.102
if.end.102:
  %ret.125 = add i32 0, 1
  ret i32 %ret.125
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

