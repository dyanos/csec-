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

%class.Counter = type { i64 }

define i64 @Counter_value(ptr %arg.this) {
entry:
  %start = getelementptr inbounds %class.Counter, ptr %arg.this, i32 0, i32 0
  %ret = load i64, ptr %start
  ret i64 %ret
}

define i32 @csec_user_main() {
entry:
  %c.object.27 = alloca %class.Counter
  %c.addr.27 = alloca ptr
  store ptr %c.object.27, ptr %c.addr.27
  %c.ctor.0 = add i64 0, 2147483653
  %c.field.0 = getelementptr inbounds %class.Counter, ptr %c.object.27, i32 0, i32 0
  store i64 %c.ctor.0, ptr %c.field.0
  %v.addr.36 = alloca i64
  %v.init.36.this = load ptr, ptr %c.addr.27
  %v.init.36 = call i64 @Counter_value(ptr %v.init.36.this)
  store i64 %v.init.36, ptr %v.addr.36
  %ifcond.47.left = load i64, ptr %v.addr.36
  %ifcond.47.right = add i64 0, 2147483653
  %ifcond.47 = icmp eq i64 %ifcond.47.left, %ifcond.47.right
  br i1 %ifcond.47, label %if.then.47, label %if.else.47
if.then.47:
  %ret.54 = add i32 0, 0
  ret i32 %ret.54
if.else.47:
  br label %if.end.47
if.end.47:
  %ret.58 = add i32 0, 1
  ret i32 %ret.58
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

