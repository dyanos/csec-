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

define i32 @dayName(i32 %arg.d) {
entry:
  %d = alloca i32
  store i32 %arg.d, ptr %d
  %ret.match.subject = load i32, ptr %d
  %ret.match.default = add i32 0, 99
  %ret.match.pattern.6 = add i32 0, 6
  %ret.match.value.6 = add i32 0, 60
  %ret.match.comparison.6 = icmp eq i32 %ret.match.subject, %ret.match.pattern.6
  %ret.match.selected.6 = select i1 %ret.match.comparison.6, i32 %ret.match.value.6, i32 %ret.match.default
  %ret.match.pattern.5 = add i32 0, 5
  %ret.match.value.5 = add i32 0, 50
  %ret.match.comparison.5 = icmp eq i32 %ret.match.subject, %ret.match.pattern.5
  %ret.match.selected.5 = select i1 %ret.match.comparison.5, i32 %ret.match.value.5, i32 %ret.match.selected.6
  %ret.match.pattern.4 = add i32 0, 4
  %ret.match.value.4 = add i32 0, 40
  %ret.match.comparison.4 = icmp eq i32 %ret.match.subject, %ret.match.pattern.4
  %ret.match.selected.4 = select i1 %ret.match.comparison.4, i32 %ret.match.value.4, i32 %ret.match.selected.5
  %ret.match.pattern.3 = add i32 0, 3
  %ret.match.value.3 = add i32 0, 30
  %ret.match.comparison.3 = icmp eq i32 %ret.match.subject, %ret.match.pattern.3
  %ret.match.selected.3 = select i1 %ret.match.comparison.3, i32 %ret.match.value.3, i32 %ret.match.selected.4
  %ret.match.pattern.2 = add i32 0, 2
  %ret.match.value.2 = add i32 0, 20
  %ret.match.comparison.2 = icmp eq i32 %ret.match.subject, %ret.match.pattern.2
  %ret.match.selected.2 = select i1 %ret.match.comparison.2, i32 %ret.match.value.2, i32 %ret.match.selected.3
  %ret.match.pattern.1 = add i32 0, 1
  %ret.match.value.1 = add i32 0, 10
  %ret.match.comparison.1 = icmp eq i32 %ret.match.subject, %ret.match.pattern.1
  %ret.match.selected.1 = select i1 %ret.match.comparison.1, i32 %ret.match.value.1, i32 %ret.match.selected.2
  %ret.match.pattern.0 = add i32 0, 0
  %ret.match.value.0 = add i32 0, 0
  %ret.match.comparison.0 = icmp eq i32 %ret.match.subject, %ret.match.pattern.0
  %ret.match.selected.0 = select i1 %ret.match.comparison.0, i32 %ret.match.value.0, i32 %ret.match.selected.1
  %ret = add i32 0, %ret.match.selected.0
  ret i32 %ret
}

define i32 @grade(i32 %arg.score) {
entry:
  %score = alloca i32
  store i32 %arg.score, ptr %score
  %ret.match.subject = load i32, ptr %score
  %ret.match.default = add i32 0, 0
  %ret.match.pattern.3 = add i32 0, 70
  %ret.match.value.3 = add i32 0, 1
  %ret.match.comparison.3 = icmp eq i32 %ret.match.subject, %ret.match.pattern.3
  %ret.match.selected.3 = select i1 %ret.match.comparison.3, i32 %ret.match.value.3, i32 %ret.match.default
  %ret.match.pattern.2 = add i32 0, 80
  %ret.match.value.2 = add i32 0, 2
  %ret.match.comparison.2 = icmp eq i32 %ret.match.subject, %ret.match.pattern.2
  %ret.match.selected.2 = select i1 %ret.match.comparison.2, i32 %ret.match.value.2, i32 %ret.match.selected.3
  %ret.match.pattern.1 = add i32 0, 90
  %ret.match.value.1 = add i32 0, 3
  %ret.match.comparison.1 = icmp eq i32 %ret.match.subject, %ret.match.pattern.1
  %ret.match.selected.1 = select i1 %ret.match.comparison.1, i32 %ret.match.value.1, i32 %ret.match.selected.2
  %ret.match.pattern.0 = add i32 0, 100
  %ret.match.value.0 = add i32 0, 4
  %ret.match.comparison.0 = icmp eq i32 %ret.match.subject, %ret.match.pattern.0
  %ret.match.selected.0 = select i1 %ret.match.comparison.0, i32 %ret.match.value.0, i32 %ret.match.selected.1
  %ret = add i32 0, %ret.match.selected.0
  ret i32 %ret
}

define i32 @csec_user_main() {
entry:
  %a.addr.87 = alloca i32
  %a.init.87.arg0 = add i32 0, 3
  %a.init.87 = call i32 @dayName(i32 %a.init.87.arg0)
  store i32 %a.init.87, ptr %a.addr.87
  %b.addr.95 = alloca i32
  %b.init.95.arg0 = add i32 0, 90
  %b.init.95 = call i32 @grade(i32 %b.init.95.arg0)
  store i32 %b.init.95, ptr %b.addr.95
  %ret.103.left = load i32, ptr %a.addr.87
  %ret.103.right = load i32, ptr %b.addr.95
  %ret.103 = add i32 %ret.103.left, %ret.103.right
  ret i32 %ret.103
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

