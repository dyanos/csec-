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

define i32 @Point_sum(i32 %arg.this.x, i32 %arg.this.y) {
entry:
  %x = alloca i32
  store i32 %arg.this.x, ptr %x
  %y = alloca i32
  store i32 %arg.this.y, ptr %y
  %ret.left = load i32, ptr %x
  %ret.right = load i32, ptr %y
  %ret = add i32 %ret.left, %ret.right
  ret i32 %ret
}

define i32 @Node_get(i32 %arg.this.value) {
entry:
  %value = alloca i32
  store i32 %arg.this.value, ptr %value
  %ret = load i32, ptr %value
  ret i32 %ret
}

define i32 @Empty_zero() {
entry:
  %ret = add i32 0, 0
  ret i32 %ret
}

define i32 @csec_user_main() {
entry:
  %p.addr.61 = alloca i32
  store i32 0, ptr %p.addr.61
  %e.addr.72 = alloca i32
  %e.init.72 = add i32 0, 0
  store i32 %e.init.72, ptr %e.addr.72
  %e2.addr.78 = alloca i32
  store i32 0, ptr %e2.addr.78
  %arr1.addr.86 = alloca ptr
  %arr1.count.86 = add i32 0, 1
  %arr1.size.86.0 = add i32 0, 10
  %arr1.count.86.1 = mul i32 %arr1.count.86, %arr1.size.86.0
  %arr1.data.86 = alloca i32, i32 %arr1.count.86.1
  store ptr %arr1.data.86, ptr %arr1.addr.86
  %arr2.addr.95 = alloca ptr
  %arr2.count.95 = add i32 0, 1
  %arr2.size.95.0 = add i32 0, 3
  %arr2.count.95.1 = mul i32 %arr2.count.95, %arr2.size.95.0
  %arr2.size.95.1 = add i32 0, 4
  %arr2.count.95.2 = mul i32 %arr2.count.95.1, %arr2.size.95.1
  %arr2.data.95 = alloca i32, i32 %arr2.count.95.2
  store ptr %arr2.data.95, ptr %arr2.addr.95
  %arr3.addr.106 = alloca ptr
  %arr3.count.106 = add i32 0, 1
  %arr3.size.106.0 = add i32 0, 2
  %arr3.count.106.1 = mul i32 %arr3.count.106, %arr3.size.106.0
  %arr3.size.106.1 = add i32 0, 3
  %arr3.count.106.2 = mul i32 %arr3.count.106.1, %arr3.size.106.1
  %arr3.size.106.2 = add i32 0, 4
  %arr3.count.106.3 = mul i32 %arr3.count.106.2, %arr3.size.106.2
  %arr3.data.106 = alloca double, i32 %arr3.count.106.3
  store ptr %arr3.data.106, ptr %arr3.addr.106
  %n1.addr.119 = alloca i32
  store i32 0, ptr %n1.addr.119
  %n2.addr.128 = alloca i32
  store i32 0, ptr %n2.addr.128
  %n3.addr.137 = alloca i32
  store i32 0, ptr %n3.addr.137
  %ret.146 = add i32 0, 0
  ret i32 %ret.146
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

