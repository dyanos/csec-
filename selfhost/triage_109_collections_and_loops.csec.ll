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

define i32 @sumArray(ptr %arg.xs) {
entry:
  %xs = alloca ptr
  store ptr %arg.xs, ptr %xs
  %ret.27 = add i32 0, 0
  ret i32 %ret.27
}

define i32 @csec_user_main() {
entry:
  %small.addr.38 = alloca ptr
  %small.count.38 = add i32 0, 3
  %small.data.38 = alloca i32, i32 %small.count.38
  store ptr %small.data.38, ptr %small.addr.38
  %small.item.38.0 = add i32 0, 1
  %small.element.38.0 = getelementptr inbounds i32, ptr %small.data.38, i32 0
  store i32 %small.item.38.0, ptr %small.element.38.0
  %small.item.38.1 = add i32 0, 2
  %small.element.38.1 = getelementptr inbounds i32, ptr %small.data.38, i32 1
  store i32 %small.item.38.1, ptr %small.element.38.1
  %small.item.38.2 = add i32 0, 3
  %small.element.38.2 = getelementptr inbounds i32, ptr %small.data.38, i32 2
  store i32 %small.item.38.2, ptr %small.element.38.2
  %medium.addr.49 = alloca ptr
  %medium.count.49 = add i32 0, 5
  %medium.data.49 = alloca i32, i32 %medium.count.49
  store ptr %medium.data.49, ptr %medium.addr.49
  %medium.item.49.0 = add i32 0, 10
  %medium.element.49.0 = getelementptr inbounds i32, ptr %medium.data.49, i32 0
  store i32 %medium.item.49.0, ptr %medium.element.49.0
  %medium.item.49.1 = add i32 0, 20
  %medium.element.49.1 = getelementptr inbounds i32, ptr %medium.data.49, i32 1
  store i32 %medium.item.49.1, ptr %medium.element.49.1
  %medium.item.49.2 = add i32 0, 30
  %medium.element.49.2 = getelementptr inbounds i32, ptr %medium.data.49, i32 2
  store i32 %medium.item.49.2, ptr %medium.element.49.2
  %medium.item.49.3 = add i32 0, 40
  %medium.element.49.3 = getelementptr inbounds i32, ptr %medium.data.49, i32 3
  store i32 %medium.item.49.3, ptr %medium.element.49.3
  %medium.item.49.4 = add i32 0, 50
  %medium.element.49.4 = getelementptr inbounds i32, ptr %medium.data.49, i32 4
  store i32 %medium.item.49.4, ptr %medium.element.49.4
  %large.addr.64 = alloca ptr
  %large.count.64 = add i32 0, 10
  %large.data.64 = alloca i32, i32 %large.count.64
  store ptr %large.data.64, ptr %large.addr.64
  %large.item.64.0 = add i32 0, 1
  %large.element.64.0 = getelementptr inbounds i32, ptr %large.data.64, i32 0
  store i32 %large.item.64.0, ptr %large.element.64.0
  %large.item.64.1 = add i32 0, 2
  %large.element.64.1 = getelementptr inbounds i32, ptr %large.data.64, i32 1
  store i32 %large.item.64.1, ptr %large.element.64.1
  %large.item.64.2 = add i32 0, 3
  %large.element.64.2 = getelementptr inbounds i32, ptr %large.data.64, i32 2
  store i32 %large.item.64.2, ptr %large.element.64.2
  %large.item.64.3 = add i32 0, 4
  %large.element.64.3 = getelementptr inbounds i32, ptr %large.data.64, i32 3
  store i32 %large.item.64.3, ptr %large.element.64.3
  %large.item.64.4 = add i32 0, 5
  %large.element.64.4 = getelementptr inbounds i32, ptr %large.data.64, i32 4
  store i32 %large.item.64.4, ptr %large.element.64.4
  %large.item.64.5 = add i32 0, 6
  %large.element.64.5 = getelementptr inbounds i32, ptr %large.data.64, i32 5
  store i32 %large.item.64.5, ptr %large.element.64.5
  %large.item.64.6 = add i32 0, 7
  %large.element.64.6 = getelementptr inbounds i32, ptr %large.data.64, i32 6
  store i32 %large.item.64.6, ptr %large.element.64.6
  %large.item.64.7 = add i32 0, 8
  %large.element.64.7 = getelementptr inbounds i32, ptr %large.data.64, i32 7
  store i32 %large.item.64.7, ptr %large.element.64.7
  %large.item.64.8 = add i32 0, 9
  %large.element.64.8 = getelementptr inbounds i32, ptr %large.data.64, i32 8
  store i32 %large.item.64.8, ptr %large.element.64.8
  %large.item.64.9 = add i32 0, 10
  %large.element.64.9 = getelementptr inbounds i32, ptr %large.data.64, i32 9
  store i32 %large.item.64.9, ptr %large.element.64.9
  %matrix.addr.89 = alloca ptr
  %matrix.count.89 = add i32 0, 6
  %matrix.data.89 = alloca i32, i32 %matrix.count.89
  store ptr %matrix.data.89, ptr %matrix.addr.89
  %matrix.item.89.0 = add i32 0, 0
  %matrix.element.89.0 = getelementptr inbounds i32, ptr %matrix.data.89, i32 0
  store i32 %matrix.item.89.0, ptr %matrix.element.89.0
  %matrix.item.89.1 = add i32 0, 2
  %matrix.element.89.1 = getelementptr inbounds i32, ptr %matrix.data.89, i32 1
  store i32 %matrix.item.89.1, ptr %matrix.element.89.1
  %matrix.item.89.2 = add i32 0, 0
  %matrix.element.89.2 = getelementptr inbounds i32, ptr %matrix.data.89, i32 2
  store i32 %matrix.item.89.2, ptr %matrix.element.89.2
  %matrix.item.89.3 = add i32 0, 4
  %matrix.element.89.3 = getelementptr inbounds i32, ptr %matrix.data.89, i32 3
  store i32 %matrix.item.89.3, ptr %matrix.element.89.3
  %matrix.item.89.4 = add i32 0, 0
  %matrix.element.89.4 = getelementptr inbounds i32, ptr %matrix.data.89, i32 4
  store i32 %matrix.item.89.4, ptr %matrix.element.89.4
  %matrix.item.89.5 = add i32 0, 6
  %matrix.element.89.5 = getelementptr inbounds i32, ptr %matrix.data.89, i32 5
  store i32 %matrix.item.89.5, ptr %matrix.element.89.5
  %buffer.addr.145 = alloca ptr
  %buffer.count.145 = add i32 0, 1
  %buffer.size.145.0 = add i32 0, 100
  %buffer.count.145.1 = mul i32 %buffer.count.145, %buffer.size.145.0
  %buffer.data.145 = alloca i32, i32 %buffer.count.145.1
  store ptr %buffer.data.145, ptr %buffer.addr.145
  %gridData.addr.154 = alloca ptr
  %gridData.count.154 = add i32 0, 1
  %gridData.size.154.0 = add i32 0, 10
  %gridData.count.154.1 = mul i32 %gridData.count.154, %gridData.size.154.0
  %gridData.size.154.1 = add i32 0, 10
  %gridData.count.154.2 = mul i32 %gridData.count.154.1, %gridData.size.154.1
  %gridData.data.154 = alloca i32, i32 %gridData.count.154.2
  store ptr %gridData.data.154, ptr %gridData.addr.154
  %total.addr.215 = alloca i32
  %total.init.215 = add i32 0, 0
  store i32 %total.init.215, ptr %total.addr.215
  %i = alloca i32
  %forstart.222 = add i32 0, 1
  store i32 %forstart.222, ptr %i
  br label %for.cond.222
for.cond.222:
  %forvalue.222 = load i32, ptr %i
  %forend.222 = add i32 0, 10
  %forcond.222 = icmp sle i32 %forvalue.222, %forend.222
  br i1 %forcond.222, label %for.body.222, label %for.end.222
for.body.222:
  %total.assign.231.left = load i32, ptr %total.addr.215
  %total.assign.231.right = load i32, ptr %i
  %total.assign.231 = add i32 %total.assign.231.left, %total.assign.231.right
  store i32 %total.assign.231, ptr %total.addr.215
  %fornext.222 = add i32 %forvalue.222, 1
  store i32 %fornext.222, ptr %i
  br label %for.cond.222
for.end.222:
  %count.addr.238 = alloca i32
  %count.init.238 = add i32 0, 0
  store i32 %count.init.238, ptr %count.addr.238
  %j = alloca i32
  %forstart.245 = add i32 0, 0
  store i32 %forstart.245, ptr %j
  br label %for.cond.245
for.cond.245:
  %forvalue.245 = load i32, ptr %j
  %forend.245 = add i32 0, 20
  %forcond.245 = icmp slt i32 %forvalue.245, %forend.245
  br i1 %forcond.245, label %for.body.245, label %for.end.245
for.body.245:
  %count.assign.254.left = load i32, ptr %count.addr.238
  %count.assign.254.right = add i32 0, 1
  %count.assign.254 = add i32 %count.assign.254.left, %count.assign.254.right
  store i32 %count.assign.254, ptr %count.addr.238
  %fornext.245 = add i32 %forvalue.245, 1
  store i32 %fornext.245, ptr %j
  br label %for.cond.245
for.end.245:
  %ret.261.left = load i32, ptr %total.addr.215
  %ret.261.right = load i32, ptr %count.addr.238
  %ret.261 = add i32 %ret.261.left, %ret.261.right
  ret i32 %ret.261
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

