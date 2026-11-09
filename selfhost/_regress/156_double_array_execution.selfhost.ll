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

define double @sum(ptr %arg.values) {
entry:
  %values = alloca ptr
  store ptr %arg.values, ptr %values
  %ret.13.left.left.index = add i32 0, 0
  %ret.13.left.left.data = load ptr, ptr %values
  %ret.13.left.left.element = getelementptr inbounds double, ptr %ret.13.left.left.data, i32 %ret.13.left.left.index
  %ret.13.left.left = load double, ptr %ret.13.left.left.element
  %ret.13.left.right.index = add i32 0, 1
  %ret.13.left.right.data = load ptr, ptr %values
  %ret.13.left.right.element = getelementptr inbounds double, ptr %ret.13.left.right.data, i32 %ret.13.left.right.index
  %ret.13.left.right = load double, ptr %ret.13.left.right.element
  %ret.13.left = fadd double %ret.13.left.left, %ret.13.left.right
  %ret.13.right.index = add i32 0, 2
  %ret.13.right.data = load ptr, ptr %values
  %ret.13.right.element = getelementptr inbounds double, ptr %ret.13.right.data, i32 %ret.13.right.index
  %ret.13.right = load double, ptr %ret.13.right.element
  %ret.13 = fadd double %ret.13.left, %ret.13.right
  ret double %ret.13
}

define i32 @csec_user_main() {
entry:
  %values.addr.37 = alloca ptr
  %values.count.37 = add i32 0, 1
  %values.size.37.0 = add i32 0, 3
  %values.count.37.1 = mul i32 %values.count.37, %values.size.37.0
  %values.data.37 = alloca double, i32 %values.count.37.1
  store ptr %values.data.37, ptr %values.addr.37
  %values.index.46 = add i32 0, 0
  %values.data.46 = load ptr, ptr %values.addr.37
  %values.element.46 = getelementptr inbounds double, ptr %values.data.46, i32 %values.index.46
  %values.rhs.46 = fadd double 0.000000e+00, 0x3FF4000000000000
  store double %values.rhs.46, ptr %values.element.46
  %values.index.53 = add i32 0, 1
  %values.data.53 = load ptr, ptr %values.addr.37
  %values.element.53 = getelementptr inbounds double, ptr %values.data.53, i32 %values.index.53
  %values.rhs.53 = fadd double 0.000000e+00, 0x4004000000000000
  store double %values.rhs.53, ptr %values.element.53
  %values.index.60 = add i32 0, 2
  %values.data.60 = load ptr, ptr %values.addr.37
  %values.element.60 = getelementptr inbounds double, ptr %values.data.60, i32 %values.index.60
  %values.rhs.60 = fadd double 0.000000e+00, 0x400E000000000000
  store double %values.rhs.60, ptr %values.element.60
  %ifcond.67.left.left.arg0 = load ptr, ptr %values.addr.37
  %ifcond.67.left.left = call double @sum(ptr %ifcond.67.left.left.arg0)
  %ifcond.67.left.right = fadd double 0.000000e+00, 0x401E000000000000
  %ifcond.67.left = fcmp oeq double %ifcond.67.left.left, %ifcond.67.left.right
  %ifcond.67.right.left.left.index = add i32 0, 0
  %ifcond.67.right.left.left.data = load ptr, ptr %values.addr.37
  %ifcond.67.right.left.left.element = getelementptr inbounds double, ptr %ifcond.67.right.left.left.data, i32 %ifcond.67.right.left.left.index
  %ifcond.67.right.left.left = load double, ptr %ifcond.67.right.left.left.element
  %ifcond.67.right.left.right.index = add i32 0, 1
  %ifcond.67.right.left.right.data = load ptr, ptr %values.addr.37
  %ifcond.67.right.left.right.element = getelementptr inbounds double, ptr %ifcond.67.right.left.right.data, i32 %ifcond.67.right.left.right.index
  %ifcond.67.right.left.right = load double, ptr %ifcond.67.right.left.right.element
  %ifcond.67.right.left = fadd double %ifcond.67.right.left.left, %ifcond.67.right.left.right
  %ifcond.67.right.right = fadd double 0.000000e+00, 0x400E000000000000
  %ifcond.67.right = fcmp oeq double %ifcond.67.right.left, %ifcond.67.right.right
  %ifcond.67 = and i1 %ifcond.67.left, %ifcond.67.right
  br i1 %ifcond.67, label %if.then.67, label %if.else.67
if.then.67:
  %ret.89 = add i32 0, 0
  ret i32 %ret.89
if.else.67:
  br label %if.end.67
if.end.67:
  %ret.93 = add i32 0, 1
  ret i32 %ret.93
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

