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
  %i.addr.7 = alloca i32
  %i.init.7 = add i32 0, 0
  store i32 %i.init.7, ptr %i.addr.7
  %j.addr.14 = alloca i32
  %j.init.14 = add i32 0, 100
  store i32 %j.init.14, ptr %j.addr.14
  br label %while.cond.21
while.cond.21:
  %whilecond.21.value.left.left = load i32, ptr %i.addr.7
  %whilecond.21.value.left.right = add i32 0, 10
  %whilecond.21.value.left.comparison = icmp slt i32 %whilecond.21.value.left.left, %whilecond.21.value.left.right
  %whilecond.21.value.left = zext i1 %whilecond.21.value.left.comparison to i32
  %whilecond.21.value.right.left = load i32, ptr %j.addr.14
  %whilecond.21.value.right.right = add i32 0, 50
  %whilecond.21.value.right.comparison = icmp sgt i32 %whilecond.21.value.right.left, %whilecond.21.value.right.right
  %whilecond.21.value.right = zext i1 %whilecond.21.value.right.comparison to i32
  %whilecond.21.value = and i32 %whilecond.21.value.left, %whilecond.21.value.right
  %whilecond.21 = icmp ne i32 %whilecond.21.value, 0
  br i1 %whilecond.21, label %while.body.21, label %while.end.21
while.body.21:
  %i.assign.32.left = load i32, ptr %i.addr.7
  %i.assign.32.right = add i32 0, 1
  %i.assign.32 = add i32 %i.assign.32.left, %i.assign.32.right
  store i32 %i.assign.32, ptr %i.addr.7
  %j.assign.38.left = load i32, ptr %j.addr.14
  %j.assign.38.right = add i32 0, 5
  %j.assign.38 = sub i32 %j.assign.38.left, %j.assign.38.right
  store i32 %j.assign.38, ptr %j.addr.14
  br label %while.cond.21
while.end.21:
  %x.addr.45 = alloca i32
  %x.init.45 = add i32 0, 0
  store i32 %x.init.45, ptr %x.addr.45
  br label %while.cond.52
while.cond.52:
  %whilecond.52.value.left = load i32, ptr %x.addr.45
  %whilecond.52.value.right = add i32 0, 100
  %whilecond.52.value.comparison = icmp slt i32 %whilecond.52.value.left, %whilecond.52.value.right
  %whilecond.52.value = zext i1 %whilecond.52.value.comparison to i32
  %whilecond.52 = icmp ne i32 %whilecond.52.value, 0
  br i1 %whilecond.52, label %while.body.52, label %while.end.52
while.body.52:
  %x.assign.59.left = load i32, ptr %x.addr.45
  %x.assign.59.right = add i32 0, 1
  %x.assign.59 = add i32 %x.assign.59.left, %x.assign.59.right
  store i32 %x.assign.59, ptr %x.addr.45
  %ifcond.65.left.left = load i32, ptr %x.addr.45
  %ifcond.65.left.right = add i32 0, 50
  %ifcond.65.left.comparison = icmp eq i32 %ifcond.65.left.left, %ifcond.65.left.right
  %ifcond.65.left = zext i1 %ifcond.65.left.comparison to i32
  %ifcond.65 = icmp ne i32 %ifcond.65.left, 0
  br i1 %ifcond.65, label %if.then.65, label %if.else.65
if.then.65:
  %if.then.ret.65 = load i32, ptr %x.addr.45
  ret i32 %if.then.ret.65
if.else.65:
  br label %if.end.65
if.end.65:
  br label %while.cond.52
while.end.52:
  %ret.77 = load i32, ptr %i.addr.7
  ret i32 %ret.77
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

