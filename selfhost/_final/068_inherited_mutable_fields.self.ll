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

%class.Base = type { i32, i32 }

define i32 @Base_current(ptr %arg.this) {
entry:
  %value = getelementptr inbounds %class.Base, ptr %arg.this, i32 0, i32 0
  %count.addr.8 = getelementptr inbounds %class.Base, ptr %arg.this, i32 0, i32 1
  %count = getelementptr inbounds %class.Base, ptr %arg.this, i32 0, i32 1
  %ret.22.left = load i32, ptr %value
  %ret.22.right = load i32, ptr %count
  %ret.22 = add i32 %ret.22.left, %ret.22.right
  ret i32 %ret.22
}

%class.Child = type { i32, i32, i32 }

define i32 @Child_inherited(ptr %arg.this) {
entry:
  %value = getelementptr inbounds %class.Child, ptr %arg.this, i32 0, i32 0
  %bonus.addr.39 = getelementptr inbounds %class.Child, ptr %arg.this, i32 0, i32 2
  %bonus = getelementptr inbounds %class.Child, ptr %arg.this, i32 0, i32 2
  %ret.53.left = call i32 @Base_current(ptr %arg.this)
  %ret.53.right = load i32, ptr %bonus
  %ret.53 = add i32 %ret.53.left, %ret.53.right
  ret i32 %ret.53
}

define i32 @csec_user_main() {
entry:
  %child.object.71 = alloca %class.Child
  %child.addr.71 = alloca ptr
  store ptr %child.object.71, ptr %child.addr.71
  %child.ctor.0 = add i32 0, 10
  %child.field.0 = getelementptr inbounds %class.Child, ptr %child.object.71, i32 0, i32 0
  store i32 %child.ctor.0, ptr %child.field.0
  %child.init.1 = add i32 0, 1
  %child.field.1 = getelementptr inbounds %class.Child, ptr %child.object.71, i32 0, i32 1
  store i32 %child.init.1, ptr %child.field.1
  %child.init.2 = add i32 0, 2
  %child.field.2 = getelementptr inbounds %class.Child, ptr %child.object.71, i32 0, i32 2
  store i32 %child.init.2, ptr %child.field.2
  %ret.80.this = load ptr, ptr %child.addr.71
  %ret.80 = call i32 @Child_inherited(ptr %ret.80.this)
  ret i32 %ret.80
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

