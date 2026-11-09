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

define i32 @csec_user_main() {
entry:
  %a.addr.7 = alloca i1
  %a.init.7 = icmp eq i32 0, 0
  store i1 %a.init.7, ptr %a.addr.7
  %b.addr.12 = alloca i1
  %b.init.12 = icmp eq i32 0, 1
  store i1 %b.init.12, ptr %b.addr.12
  %c.addr.17 = alloca i1
  %c.init.17 = icmp eq i32 0, 0
  store i1 %c.init.17, ptr %c.addr.17
  %r1.addr.22 = alloca i32
  %r1.init.22.left.i1 = load i1, ptr %a.addr.7
  %r1.init.22.left = zext i1 %r1.init.22.left.i1 to i32
  %r1.init.22.right.i1 = load i1, ptr %b.addr.12
  %r1.init.22.right = zext i1 %r1.init.22.right.i1 to i32
  %r1.init.22 = and i32 %r1.init.22.left, %r1.init.22.right
  store i32 %r1.init.22, ptr %r1.addr.22
  %r2.addr.29 = alloca i32
  %r2.init.29.left.i1 = load i1, ptr %a.addr.7
  %r2.init.29.left = zext i1 %r2.init.29.left.i1 to i32
  %r2.init.29.right.i1 = load i1, ptr %b.addr.12
  %r2.init.29.right = zext i1 %r2.init.29.right.i1 to i32
  %r2.init.29 = or i32 %r2.init.29.left, %r2.init.29.right
  store i32 %r2.init.29, ptr %r2.addr.29
  %r3.addr.36 = alloca i32
  %r3.init.36.left.i1 = load i1, ptr %a.addr.7
  %r3.init.36.left = zext i1 %r3.init.36.left.i1 to i32
  %r3.init.36.right.i1 = load i1, ptr %b.addr.12
  %r3.init.36.right = zext i1 %r3.init.36.right.i1 to i32
  %r3.init.36 = xor i32 %r3.init.36.left, %r3.init.36.right
  store i32 %r3.init.36, ptr %r3.addr.36
  %r4.addr.43 = alloca i32
  %r4.init.43.left.left.i1 = load i1, ptr %a.addr.7
  %r4.init.43.left.left = zext i1 %r4.init.43.left.left.i1 to i32
  %r4.init.43.left.right.i1 = load i1, ptr %b.addr.12
  %r4.init.43.left.right = zext i1 %r4.init.43.left.right.i1 to i32
  %r4.init.43.left = and i32 %r4.init.43.left.left, %r4.init.43.left.right
  %r4.init.43.right.i1 = load i1, ptr %c.addr.17
  %r4.init.43.right = zext i1 %r4.init.43.right.i1 to i32
  %r4.init.43 = or i32 %r4.init.43.left, %r4.init.43.right
  store i32 %r4.init.43, ptr %r4.addr.43
  %r5.addr.52 = alloca i32
  %r5.init.52.left.left.i1 = load i1, ptr %a.addr.7
  %r5.init.52.left.left = zext i1 %r5.init.52.left.left.i1 to i32
  %r5.init.52.left.right.i1 = load i1, ptr %b.addr.12
  %r5.init.52.left.right = zext i1 %r5.init.52.left.right.i1 to i32
  %r5.init.52.left = or i32 %r5.init.52.left.left, %r5.init.52.left.right
  %r5.init.52.right.left.i1 = load i1, ptr %b.addr.12
  %r5.init.52.right.left = zext i1 %r5.init.52.right.left.i1 to i32
  %r5.init.52.right.right.i1 = load i1, ptr %c.addr.17
  %r5.init.52.right.right = zext i1 %r5.init.52.right.right.i1 to i32
  %r5.init.52.right = or i32 %r5.init.52.right.left, %r5.init.52.right.right
  %r5.init.52 = and i32 %r5.init.52.left, %r5.init.52.right
  store i32 %r5.init.52, ptr %r5.addr.52
  %r6.addr.67 = alloca i32
  %r6.init.67.left.left.i1 = load i1, ptr %a.addr.7
  %r6.init.67.left.left = zext i1 %r6.init.67.left.left.i1 to i32
  %r6.init.67.left.right.i1 = load i1, ptr %b.addr.12
  %r6.init.67.left.right = zext i1 %r6.init.67.left.right.i1 to i32
  %r6.init.67.left = and i32 %r6.init.67.left.left, %r6.init.67.left.right
  %r6.init.67.right.i1 = load i1, ptr %c.addr.17
  %r6.init.67.right = zext i1 %r6.init.67.right.i1 to i32
  %r6.init.67 = and i32 %r6.init.67.left, %r6.init.67.right
  store i32 %r6.init.67, ptr %r6.addr.67
  %r7.addr.76 = alloca i32
  %r7.init.76.left.left.i1 = load i1, ptr %a.addr.7
  %r7.init.76.left.left = zext i1 %r7.init.76.left.left.i1 to i32
  %r7.init.76.left.right.i1 = load i1, ptr %b.addr.12
  %r7.init.76.left.right = zext i1 %r7.init.76.left.right.i1 to i32
  %r7.init.76.left = or i32 %r7.init.76.left.left, %r7.init.76.left.right
  %r7.init.76.right.i1 = load i1, ptr %c.addr.17
  %r7.init.76.right = zext i1 %r7.init.76.right.i1 to i32
  %r7.init.76 = or i32 %r7.init.76.left, %r7.init.76.right
  store i32 %r7.init.76, ptr %r7.addr.76
  %r8.addr.85 = alloca i32
  %r8.init.85.left.left.i1 = load i1, ptr %a.addr.7
  %r8.init.85.left.left = zext i1 %r8.init.85.left.left.i1 to i32
  %r8.init.85.left.right.i1 = load i1, ptr %b.addr.12
  %r8.init.85.left.right = zext i1 %r8.init.85.left.right.i1 to i32
  %r8.init.85.left = xor i32 %r8.init.85.left.left, %r8.init.85.left.right
  %r8.init.85.right.left.i1 = load i1, ptr %b.addr.12
  %r8.init.85.right.left = zext i1 %r8.init.85.right.left.i1 to i32
  %r8.init.85.right.right.i1 = load i1, ptr %c.addr.17
  %r8.init.85.right.right = zext i1 %r8.init.85.right.right.i1 to i32
  %r8.init.85.right = xor i32 %r8.init.85.right.left, %r8.init.85.right.right
  %r8.init.85 = and i32 %r8.init.85.left, %r8.init.85.right
  store i32 %r8.init.85, ptr %r8.addr.85
  %x.addr.100 = alloca i32
  %x.init.100 = add i32 0, 10
  store i32 %x.init.100, ptr %x.addr.100
  %y.addr.107 = alloca i32
  %y.init.107 = add i32 0, 20
  store i32 %y.init.107, ptr %y.addr.107
  %z.addr.114 = alloca i32
  %z.init.114 = add i32 0, 30
  store i32 %z.init.114, ptr %z.addr.114
  %cmp1.addr.121 = alloca i32
  %cmp1.init.121.left = load i32, ptr %x.addr.100
  %cmp1.init.121.right = load i32, ptr %y.addr.107
  %cmp1.init.121.comparison = icmp slt i32 %cmp1.init.121.left, %cmp1.init.121.right
  %cmp1.init.121 = zext i1 %cmp1.init.121.comparison to i32
  store i32 %cmp1.init.121, ptr %cmp1.addr.121
  %cmp2.addr.128 = alloca i32
  %cmp2.init.128.left = load i32, ptr %y.addr.107
  %cmp2.init.128.right = load i32, ptr %z.addr.114
  %cmp2.init.128.comparison = icmp sle i32 %cmp2.init.128.left, %cmp2.init.128.right
  %cmp2.init.128 = zext i1 %cmp2.init.128.comparison to i32
  store i32 %cmp2.init.128, ptr %cmp2.addr.128
  %cmp3.addr.135 = alloca i32
  %cmp3.init.135.left = load i32, ptr %x.addr.100
  %cmp3.init.135.right = load i32, ptr %z.addr.114
  %cmp3.init.135.comparison = icmp ne i32 %cmp3.init.135.left, %cmp3.init.135.right
  %cmp3.init.135 = zext i1 %cmp3.init.135.comparison to i32
  store i32 %cmp3.init.135, ptr %cmp3.addr.135
  %cmp4.addr.142 = alloca i32
  %cmp4.init.142.left = load i32, ptr %x.addr.100
  %cmp4.init.142.right = add i32 0, 10
  %cmp4.init.142.comparison = icmp eq i32 %cmp4.init.142.left, %cmp4.init.142.right
  %cmp4.init.142 = zext i1 %cmp4.init.142.comparison to i32
  store i32 %cmp4.init.142, ptr %cmp4.addr.142
  %cmp5.addr.149 = alloca i32
  %cmp5.init.149.left.left = load i32, ptr %x.addr.100
  %cmp5.init.149.left.right = load i32, ptr %y.addr.107
  %cmp5.init.149.left.comparison = icmp slt i32 %cmp5.init.149.left.left, %cmp5.init.149.left.right
  %cmp5.init.149.left = zext i1 %cmp5.init.149.left.comparison to i32
  %cmp5.init.149.right.left = load i32, ptr %y.addr.107
  %cmp5.init.149.right.right = load i32, ptr %z.addr.114
  %cmp5.init.149.right.comparison = icmp slt i32 %cmp5.init.149.right.left, %cmp5.init.149.right.right
  %cmp5.init.149.right = zext i1 %cmp5.init.149.right.comparison to i32
  %cmp5.init.149 = and i32 %cmp5.init.149.left, %cmp5.init.149.right
  store i32 %cmp5.init.149, ptr %cmp5.addr.149
  %cmp6.addr.160 = alloca i32
  %cmp6.init.160.left.left = load i32, ptr %x.addr.100
  %cmp6.init.160.left.right = add i32 0, 0
  %cmp6.init.160.left.comparison = icmp sge i32 %cmp6.init.160.left.left, %cmp6.init.160.left.right
  %cmp6.init.160.left = zext i1 %cmp6.init.160.left.comparison to i32
  %cmp6.init.160.right.left = load i32, ptr %z.addr.114
  %cmp6.init.160.right.right = add i32 0, 100
  %cmp6.init.160.right.comparison = icmp sle i32 %cmp6.init.160.right.left, %cmp6.init.160.right.right
  %cmp6.init.160.right = zext i1 %cmp6.init.160.right.comparison to i32
  %cmp6.init.160 = or i32 %cmp6.init.160.left, %cmp6.init.160.right
  store i32 %cmp6.init.160, ptr %cmp6.addr.160
  %ret.171 = add i32 0, 0
  ret i32 %ret.171
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

