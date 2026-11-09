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

@.str.13 = private unnamed_addr constant [8 x i8] c"default\00"

%class.DataHolder = type { i32, i32 }

define i32 @DataHolder_getId(ptr %arg.this) {
entry:
  %id = getelementptr inbounds %class.DataHolder, ptr %arg.this, i32 0, i32 0
  %count.addr.29 = getelementptr inbounds %class.DataHolder, ptr %arg.this, i32 0, i32 1
  %count = getelementptr inbounds %class.DataHolder, ptr %arg.this, i32 0, i32 1
  %ret = load i32, ptr %id
  ret i32 %ret
}

define i32 @DataHolder_getCount(ptr %arg.this) {
entry:
  %id = getelementptr inbounds %class.DataHolder, ptr %arg.this, i32 0, i32 0
  %count.addr.29 = getelementptr inbounds %class.DataHolder, ptr %arg.this, i32 0, i32 1
  %count = getelementptr inbounds %class.DataHolder, ptr %arg.this, i32 0, i32 1
  %ret = load i32, ptr %count.addr.29
  ret i32 %ret
}

define i32 @DataHolder_increment(ptr %arg.this) {
entry:
  %id = getelementptr inbounds %class.DataHolder, ptr %arg.this, i32 0, i32 0
  %count.addr.29 = getelementptr inbounds %class.DataHolder, ptr %arg.this, i32 0, i32 1
  %count = getelementptr inbounds %class.DataHolder, ptr %arg.this, i32 0, i32 1
  %count.assign.66.left = load i32, ptr %count
  %count.assign.66.right = add i32 0, 1
  %count.assign.66 = add i32 %count.assign.66.left, %count.assign.66.right
  store i32 %count.assign.66, ptr %count
  %ret.72 = load i32, ptr %count
  ret i32 %ret.72
}

define i32 @csec_user_main() {
entry:
  %d.object.84 = alloca %class.DataHolder
  %d.addr.84 = alloca ptr
  store ptr %d.object.84, ptr %d.addr.84
  %d.ctor.0 = add i32 0, 42
  %d.field.0 = getelementptr inbounds %class.DataHolder, ptr %d.object.84, i32 0, i32 0
  store i32 %d.ctor.0, ptr %d.field.0
  %d.init.1 = add i32 0, 0
  %d.field.1 = getelementptr inbounds %class.DataHolder, ptr %d.object.84, i32 0, i32 1
  store i32 %d.init.1, ptr %d.field.1
  %id.addr.93 = alloca i32
  %id.init.93.this = load ptr, ptr %d.addr.84
  %id.init.93 = call i32 @DataHolder_getId(ptr %id.init.93.this)
  store i32 %id.init.93, ptr %id.addr.93
  %discard.102.this = load ptr, ptr %d.addr.84
  %discard.102 = call i32 @DataHolder_increment(ptr %discard.102.this)
  %discard.108.this = load ptr, ptr %d.addr.84
  %discard.108 = call i32 @DataHolder_increment(ptr %discard.108.this)
  %cnt.addr.114 = alloca i32
  %cnt.init.114.this = load ptr, ptr %d.addr.84
  %cnt.init.114 = call i32 @DataHolder_getCount(ptr %cnt.init.114.this)
  store i32 %cnt.init.114, ptr %cnt.addr.114
  %ret.123.left = load i32, ptr %id.addr.93
  %ret.123.right = load i32, ptr %cnt.addr.114
  %ret.123 = add i32 %ret.123.left, %ret.123.right
  ret i32 %ret.123
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

