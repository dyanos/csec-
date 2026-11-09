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
declare i32 @csec_string_equals(ptr, ptr)
declare i64 @csec_string_length(ptr)
declare i32 @csec_string_starts_with(ptr, ptr)
declare ptr @csec_string_substring(ptr, i32, i32)
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

@.str.17 = private unnamed_addr constant [2 x i8] c"!\00"
@.str.32 = private unnamed_addr constant [6 x i8] c"hello\00"

%class.Greeting = type { ptr }

define ptr @Greeting_loud(ptr %arg.this) {
entry:
  %field = getelementptr inbounds %class.Greeting, ptr %arg.this, i32 0, i32 0
  %left = load ptr, ptr %field
  %right = getelementptr inbounds [2 x i8], ptr @.str.17, i32 0, i32 0
  %ret = call ptr @csec_string_concat(ptr %left, ptr %right)
  ret ptr %ret
}

define i32 @csec_user_main() {
entry:
  %greeting.object.26 = alloca %class.Greeting
  %greeting.addr.26 = alloca ptr
  store ptr %greeting.object.26, ptr %greeting.addr.26
  %greeting.ctor.0 = getelementptr inbounds [6 x i8], ptr @.str.32, i32 0, i32 0
  %greeting.field.0 = getelementptr inbounds %class.Greeting, ptr %greeting.object.26, i32 0, i32 0
  store ptr %greeting.ctor.0, ptr %greeting.field.0
  %text.addr.35 = alloca ptr
  %text.init.35.this = load ptr, ptr %greeting.addr.26
  %text.init.35 = call ptr @Greeting_loud(ptr %text.init.35.this)
  store ptr %text.init.35, ptr %text.addr.35
  %ret.46.string = load ptr, ptr %text.addr.35
  %ret.46.length64 = call i64 @csec_string_length(ptr %ret.46.string)
  %ret.46 = trunc i64 %ret.46.length64 to i32
  ret i32 %ret.46
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

