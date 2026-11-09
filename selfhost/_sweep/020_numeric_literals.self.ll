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

@.str.50 = private unnamed_addr constant [6 x i8] c"hello\00"

define i32 @csec_user_main() {
entry:
  %a.addr.7 = alloca i32
  %a.init.7 = add i32 0, 42
  store i32 %a.init.7, ptr %a.addr.7
  %b.addr.12 = alloca i32
  %b.init.12 = add i32 0, 42
  store i32 %b.init.12, ptr %b.addr.12
  %c.addr.17 = alloca i32
  %c.init.17 = add i32 0, 42
  store i32 %c.init.17, ptr %c.addr.17
  %d.addr.22 = alloca i32
  %d.init.22 = add i32 0, 42
  store i32 %d.init.22, ptr %d.addr.22
  %e.addr.27 = alloca double
  %e.init.27 = fadd double 0.000000e+00, 0x40091EB851EB851F
  store double %e.init.27, ptr %e.addr.27
  %f.addr.32 = alloca double
  %f.init.32 = fadd double 0.000000e+00, 0x4093880000000000
  store double %f.init.32, ptr %f.addr.32
  %g.addr.37 = alloca i1
  %g.init.37 = icmp eq i32 0, 0
  store i1 %g.init.37, ptr %g.addr.37
  %h.addr.42 = alloca i1
  %h.init.42 = icmp eq i32 0, 1
  store i1 %h.init.42, ptr %h.addr.42
  %i.addr.47 = alloca ptr
  %i.init.47 = getelementptr inbounds [6 x i8], ptr @.str.50, i32 0, i32 0
  store ptr %i.init.47, ptr %i.addr.47
  %ret.52.left.left.left = load i32, ptr %a.addr.7
  %ret.52.left.left.right = load i32, ptr %b.addr.12
  %ret.52.left.left = add i32 %ret.52.left.left.left, %ret.52.left.left.right
  %ret.52.left.right = load i32, ptr %c.addr.17
  %ret.52.left = add i32 %ret.52.left.left, %ret.52.left.right
  %ret.52.right = load i32, ptr %d.addr.22
  %ret.52 = add i32 %ret.52.left, %ret.52.right
  ret i32 %ret.52
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

