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

@.str.12 = private unnamed_addr constant [13 x i8] c"csec-runtime\00"
@.str.20 = private unnamed_addr constant [5 x i8] c"csec\00"
@.str.27 = private unnamed_addr constant [5 x i8] c"time\00"
@.str.34 = private unnamed_addr constant [4 x i8] c"run\00"
@.str.50 = private unnamed_addr constant [8 x i8] c"runtime\00"

define i32 @csec_user_main() {
entry:
  %text.addr.7 = alloca ptr
  %text.init.7 = getelementptr inbounds [13 x i8], ptr @.str.12, i32 0, i32 0
  store ptr %text.init.7, ptr %text.addr.7
  %ifcond.14.left.left.left.i32.string = load ptr, ptr %text.addr.7
  %ifcond.14.left.left.left.i32.needle = getelementptr inbounds [5 x i8], ptr @.str.20, i32 0, i32 0
  %ifcond.14.left.left.left.i32 = call i32 @csec_string_starts_with(ptr %ifcond.14.left.left.left.i32.string, ptr %ifcond.14.left.left.left.i32.needle)
  %ifcond.14.left.left.left = icmp ne i32 %ifcond.14.left.left.left.i32, 0
  %ifcond.14.left.left.right.i32.string = load ptr, ptr %text.addr.7
  %ifcond.14.left.left.right.i32.needle = getelementptr inbounds [5 x i8], ptr @.str.27, i32 0, i32 0
  %ifcond.14.left.left.right.i32 = call i32 @csec_string_ends_with(ptr %ifcond.14.left.left.right.i32.string, ptr %ifcond.14.left.left.right.i32.needle)
  %ifcond.14.left.left.right = icmp ne i32 %ifcond.14.left.left.right.i32, 0
  %ifcond.14.left.left = and i1 %ifcond.14.left.left.left, %ifcond.14.left.left.right
  %ifcond.14.left.right.i32.string = load ptr, ptr %text.addr.7
  %ifcond.14.left.right.i32.needle = getelementptr inbounds [4 x i8], ptr @.str.34, i32 0, i32 0
  %ifcond.14.left.right.i32 = call i32 @csec_string_contains(ptr %ifcond.14.left.right.i32.string, ptr %ifcond.14.left.right.i32.needle)
  %ifcond.14.left.right = icmp ne i32 %ifcond.14.left.right.i32, 0
  %ifcond.14.left = and i1 %ifcond.14.left.left, %ifcond.14.left.right
  %ifcond.14.right.value.i32.string = load ptr, ptr %text.addr.7
  %ifcond.14.right.value.i32 = call i32 @csec_string_is_empty(ptr %ifcond.14.right.value.i32.string)
  %ifcond.14.right.value = icmp ne i32 %ifcond.14.right.value.i32, 0
  %ifcond.14.right = xor i1 %ifcond.14.right.value, true
  %ifcond.14 = and i1 %ifcond.14.left, %ifcond.14.right
  br i1 %ifcond.14, label %if.then.14, label %if.else.14
if.then.14:
  %ret.45.left.string = load ptr, ptr %text.addr.7
  %ret.45.left.needle = getelementptr inbounds [8 x i8], ptr @.str.50, i32 0, i32 0
  %ret.45.left.index64 = call i64 @csec_string_index_of(ptr %ret.45.left.string, ptr %ret.45.left.needle)
  %ret.45.left = trunc i64 %ret.45.left.index64 to i32
  %ret.45.right = add i32 0, 35
  %ret.45 = add i32 %ret.45.left, %ret.45.right
  ret i32 %ret.45
if.else.14:
  br label %if.end.14
if.end.14:
  %ret.56 = add i32 0, 0
  ret i32 %ret.56
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

