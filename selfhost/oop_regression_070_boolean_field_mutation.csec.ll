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

%class.Switch = type { i1 }

define i1 @Switch_enable(ptr %arg.this) {
entry:
  %enabled.addr.5 = getelementptr inbounds %class.Switch, ptr %arg.this, i32 0, i32 0
  %enabled = getelementptr inbounds %class.Switch, ptr %arg.this, i32 0, i32 0
  %enabled.assign.19 = icmp eq i32 0, 0
  store i1 %enabled.assign.19, ptr %enabled
  %ret.23 = load i1, ptr %enabled
  ret i1 %ret.23
}

define i1 @Switch_isEnabled(ptr %arg.this) {
entry:
  %enabled.addr.5 = getelementptr inbounds %class.Switch, ptr %arg.this, i32 0, i32 0
  %enabled = getelementptr inbounds %class.Switch, ptr %arg.this, i32 0, i32 0
  %ret.34 = load i1, ptr %enabled
  ret i1 %ret.34
}

define i32 @csec_user_main() {
entry:
  %value.object.46 = alloca %class.Switch
  %value.addr.46 = alloca ptr
  store ptr %value.object.46, ptr %value.addr.46
  %value.init.0 = icmp eq i32 0, 1
  %value.field.0 = getelementptr inbounds %class.Switch, ptr %value.object.46, i32 0, i32 0
  store i1 %value.init.0, ptr %value.field.0
  %discard.54.this = load ptr, ptr %value.addr.46
  %discard.54.i1 = call i1 @Switch_enable(ptr %discard.54.this)
  %discard.54 = zext i1 %discard.54.i1 to i32
  %ifcond.60.left.this = load ptr, ptr %value.addr.46
  %ifcond.60.left.i1 = call i1 @Switch_isEnabled(ptr %ifcond.60.left.this)
  %ifcond.60.left = zext i1 %ifcond.60.left.i1 to i32
  %ifcond.60 = icmp ne i32 %ifcond.60.left, 0
  br i1 %ifcond.60, label %if.then.60, label %if.else.60
if.then.60:
  %if.then.ret.60 = add i32 0, 42
  ret i32 %if.then.ret.60
if.else.60:
  br label %if.end.60
if.end.60:
  %ret.73 = add i32 0, 0
  ret i32 %ret.73
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

