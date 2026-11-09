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

define i32 @Logger_info(i32 %arg.x) {
entry:
  %x = alloca i32
  store i32 %arg.x, ptr %x
  %ret = load i32, ptr %x
  ret i32 %ret
}

%class.Service = type { i32, i32 }

define i32 @Service_run(ptr %arg.this, i32 %arg.x) {
entry:
  %id = getelementptr inbounds %class.Service, ptr %arg.this, i32 0, i32 0
  %version.addr.23 = getelementptr inbounds %class.Service, ptr %arg.this, i32 0, i32 1
  %version = getelementptr inbounds %class.Service, ptr %arg.this, i32 0, i32 1
  %x = alloca i32
  store i32 %arg.x, ptr %x
  %ret.40.arg0.left.left = load i32, ptr %id
  %ret.40.arg0.left.right = load i32, ptr %x
  %ret.40.arg0.left = add i32 %ret.40.arg0.left.left, %ret.40.arg0.left.right
  %ret.40.arg0.right = load i32, ptr %version.addr.23
  %ret.40.arg0 = add i32 %ret.40.arg0.left, %ret.40.arg0.right
  %ret.40 = call i32 @Logger_info(i32 %ret.40.arg0)
  ret i32 %ret.40
}

define i32 @csec_user_main() {
entry:
  %service.object.61 = alloca %class.Service
  %service.addr.61 = alloca ptr
  store ptr %service.object.61, ptr %service.addr.61
  %service.ctor.0 = add i32 0, 10
  %service.field.0 = getelementptr inbounds %class.Service, ptr %service.object.61, i32 0, i32 0
  store i32 %service.ctor.0, ptr %service.field.0
  %service.init.1 = add i32 0, 1
  %service.field.1 = getelementptr inbounds %class.Service, ptr %service.object.61, i32 0, i32 1
  store i32 %service.init.1, ptr %service.field.1
  %ret.70.this = load ptr, ptr %service.addr.61
  %ret.70.marg0 = add i32 0, 5
  %ret.70 = call i32 @Service_run(ptr %ret.70.this, i32 %ret.70.marg0)
  ret i32 %ret.70
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

