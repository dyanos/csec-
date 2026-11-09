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

define i32 @csec_user_main() {
entry:
  %size.addr.7 = alloca i32
  %size.init.7 = add i32 0, 4
  store i32 %size.init.7, ptr %size.addr.7
  %xs.addr.12 = alloca ptr
  %xs.count.12 = add i32 0, 1
  %xs.size.12.0 = load i32, ptr %size.addr.7
  %xs.count.12.1 = mul i32 %xs.count.12, %xs.size.12.0
  %xs.data.12 = alloca i32, i32 %xs.count.12.1
  store ptr %xs.data.12, ptr %xs.addr.12
  %i.addr.21 = alloca i32
  %i.init.21 = add i32 0, 0
  store i32 %i.init.21, ptr %i.addr.21
  br label %while.cond.26
while.cond.26:
  %whilecond.26.value.left = load i32, ptr %i.addr.21
  %whilecond.26.value.right = load i32, ptr %size.addr.7
  %whilecond.26.value.comparison = icmp slt i32 %whilecond.26.value.left, %whilecond.26.value.right
  %whilecond.26.value = zext i1 %whilecond.26.value.comparison to i32
  %whilecond.26 = icmp ne i32 %whilecond.26.value, 0
  br i1 %whilecond.26, label %while.body.26, label %while.end.26
while.body.26:
  %xs.index.33 = load i32, ptr %i.addr.21
  %xs.data.33 = load ptr, ptr %xs.addr.12
  %xs.element.33 = getelementptr inbounds i32, ptr %xs.data.33, i32 %xs.index.33
  %xs.rhs.33.left = load i32, ptr %i.addr.21
  %xs.rhs.33.right = add i32 0, 10
  %xs.rhs.33 = mul i32 %xs.rhs.33.left, %xs.rhs.33.right
  store i32 %xs.rhs.33, ptr %xs.element.33
  %i.compound.left.42 = load i32, ptr %i.addr.21
  %i.compound.right.42 = add i32 0, 1
  %i.compound.42 = add i32 %i.compound.left.42, %i.compound.right.42
  store i32 %i.compound.42, ptr %i.addr.21
  br label %while.cond.26
while.end.26:
  %xs.index.47 = add i32 0, 1
  %xs.data.47 = load ptr, ptr %xs.addr.12
  %xs.element.47 = getelementptr inbounds i32, ptr %xs.data.47, i32 %xs.index.47
  %xs.rhs.47 = add i32 0, 5
  %xs.old.47 = load i32, ptr %xs.element.47
  %xs.next.47 = add i32 %xs.old.47, %xs.rhs.47
  store i32 %xs.next.47, ptr %xs.element.47
  %result.addr.54 = alloca i32
  %result.init.54.left.index = add i32 0, 3
  %result.init.54.left.data = load ptr, ptr %xs.addr.12
  %result.init.54.left.element = getelementptr inbounds i32, ptr %result.init.54.left.data, i32 %result.init.54.left.index
  %result.init.54.left = load i32, ptr %result.init.54.left.element
  %result.init.54.right.index = add i32 0, 1
  %result.init.54.right.data = load ptr, ptr %xs.addr.12
  %result.init.54.right.element = getelementptr inbounds i32, ptr %result.init.54.right.data, i32 %result.init.54.right.index
  %result.init.54.right = load i32, ptr %result.init.54.right.element
  %result.init.54 = add i32 %result.init.54.left, %result.init.54.right
  store i32 %result.init.54, ptr %result.addr.54
  %ret.67 = load i32, ptr %result.addr.54
  ret i32 %ret.67
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

