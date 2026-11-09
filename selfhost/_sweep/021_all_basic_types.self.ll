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

@.str.75 = private unnamed_addr constant [12 x i8] c"hello world\00"

define i32 @csec_user_main() {
entry:
  %a.addr.7 = alloca i32
  %a.init.7 = add i32 0, 42
  store i32 %a.init.7, ptr %a.addr.7
  %b.addr.14 = alloca float
  %b.init.14 = fadd float 0.000000e+00, 0x40091EB860000000
  store float %b.init.14, ptr %b.addr.14
  %c.addr.21 = alloca double
  %c.init.21 = fadd double 0.000000e+00, 0x4005BE76C8B43958
  store double %c.init.21, ptr %c.addr.21
  %d.addr.28 = alloca i64
  %d.init.28 = add i64 0, 1000000
  store i64 %d.init.28, ptr %d.addr.28
  %e.addr.35 = alloca i16
  %e.init.35.i32 = add i32 0, 100
  %e.init.35 = trunc i32 %e.init.35.i32 to i16
  store i16 %e.init.35, ptr %e.addr.35
  %f.addr.42 = alloca i8
  %f.init.42 = trunc i32 8 to i8
  store i8 %f.init.42, ptr %f.addr.42
  %g.addr.49 = alloca i1
  %g.init.49 = icmp eq i32 0, 0
  store i1 %g.init.49, ptr %g.addr.49
  %h.addr.56 = alloca ptr
  %h.init.56 = getelementptr i8, ptr null, i32 0
  store ptr %h.init.56, ptr %h.addr.56
  %i.addr.63 = alloca i8
  %i.init.63 = add i8 0, 65
  store i8 %i.init.63, ptr %i.addr.63
  %j.addr.70 = alloca ptr
  %j.init.70 = getelementptr inbounds [12 x i8], ptr @.str.75, i32 0, i32 0
  store ptr %j.init.70, ptr %j.addr.70
  %ret.77 = load i32, ptr %a.addr.7
  ret i32 %ret.77
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

