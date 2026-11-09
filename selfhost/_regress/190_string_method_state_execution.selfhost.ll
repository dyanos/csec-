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

@.str.38 = private unnamed_addr constant [4 x i8] c"Hi \00"
@.str.48 = private unnamed_addr constant [4 x i8] c"Bob\00"

%class.Name = type { ptr }

define ptr @Name_greet(ptr %arg.this, ptr %arg.who) {
entry:
  %prefix = getelementptr inbounds %class.Name, ptr %arg.this, i32 0, i32 0
  %who = alloca ptr
  store ptr %arg.who, ptr %who
  %ret.18.left = load ptr, ptr %prefix
  %ret.18.right = load ptr, ptr %who
  %ret.18 = call ptr @csec_string_concat(ptr %ret.18.left, ptr %ret.18.right)
  ret ptr %ret.18
}

define i32 @csec_user_main() {
entry:
  %n.object.32 = alloca %class.Name
  %n.addr.32 = alloca ptr
  store ptr %n.object.32, ptr %n.addr.32
  %n.ctor.0 = getelementptr inbounds [4 x i8], ptr @.str.38, i32 0, i32 0
  %n.field.0 = getelementptr inbounds %class.Name, ptr %n.object.32, i32 0, i32 0
  store ptr %n.ctor.0, ptr %n.field.0
  %g.addr.41 = alloca ptr
  %g.init.41.this = load ptr, ptr %n.addr.32
  %g.init.41.arg0 = getelementptr inbounds [4 x i8], ptr @.str.48, i32 0, i32 0
  %g.init.41 = call ptr @Name_greet(ptr %g.init.41.this, ptr %g.init.41.arg0)
  store ptr %g.init.41, ptr %g.addr.41
  %ret.51.string = load ptr, ptr %g.addr.41
  %ret.51.length64 = call i64 @csec_string_length(ptr %ret.51.string)
  %ret.51 = trunc i64 %ret.51.length64 to i32
  ret i32 %ret.51
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

