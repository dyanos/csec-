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

%class.Node = type { i32, ptr }

define i32 @Node_getValue(ptr %arg.this) {
entry:
  %value = getelementptr inbounds %class.Node, ptr %arg.this, i32 0, i32 0
  %next.addr.8 = getelementptr inbounds %class.Node, ptr %arg.this, i32 0, i32 1
  %next = getelementptr inbounds %class.Node, ptr %arg.this, i32 0, i32 1
  %ret = load i32, ptr %value
  ret i32 %ret
}

%class.List = type { ptr, i32 }

define i32 @List_getSize(ptr %arg.this) {
entry:
  %head = getelementptr inbounds %class.List, ptr %arg.this, i32 0, i32 0
  %size.addr.36 = getelementptr inbounds %class.List, ptr %arg.this, i32 0, i32 1
  %size = getelementptr inbounds %class.List, ptr %arg.this, i32 0, i32 1
  %ret = load i32, ptr %size.addr.36
  ret i32 %ret
}

define ptr @List_getHead(ptr %arg.this) {
entry:
  %head = getelementptr inbounds %class.List, ptr %arg.this, i32 0, i32 0
  %size.addr.36 = getelementptr inbounds %class.List, ptr %arg.this, i32 0, i32 1
  %size = getelementptr inbounds %class.List, ptr %arg.this, i32 0, i32 1
  %ret = getelementptr i8, ptr null, i32 0
  ret ptr %ret
}

define i32 @csec_user_main() {
entry:
  %n1.object.67 = alloca %class.Node
  %n1.addr.67 = alloca ptr
  store ptr %n1.object.67, ptr %n1.addr.67
  %n1.ctor.0 = add i32 0, 10
  %n1.field.0 = getelementptr inbounds %class.Node, ptr %n1.object.67, i32 0, i32 0
  store i32 %n1.ctor.0, ptr %n1.field.0
  %n1.init.1 = getelementptr i8, ptr null, i32 0
  %n1.field.1 = getelementptr inbounds %class.Node, ptr %n1.object.67, i32 0, i32 1
  store ptr %n1.init.1, ptr %n1.field.1
  %n2.object.76 = alloca %class.Node
  %n2.addr.76 = alloca ptr
  store ptr %n2.object.76, ptr %n2.addr.76
  %n2.ctor.0 = add i32 0, 20
  %n2.field.0 = getelementptr inbounds %class.Node, ptr %n2.object.76, i32 0, i32 0
  store i32 %n2.ctor.0, ptr %n2.field.0
  %n2.init.1 = getelementptr i8, ptr null, i32 0
  %n2.field.1 = getelementptr inbounds %class.Node, ptr %n2.object.76, i32 0, i32 1
  store ptr %n2.init.1, ptr %n2.field.1
  %n3.object.85 = alloca %class.Node
  %n3.addr.85 = alloca ptr
  store ptr %n3.object.85, ptr %n3.addr.85
  %n3.ctor.0 = add i32 0, 30
  %n3.field.0 = getelementptr inbounds %class.Node, ptr %n3.object.85, i32 0, i32 0
  store i32 %n3.ctor.0, ptr %n3.field.0
  %n3.init.1 = getelementptr i8, ptr null, i32 0
  %n3.field.1 = getelementptr inbounds %class.Node, ptr %n3.object.85, i32 0, i32 1
  store ptr %n3.init.1, ptr %n3.field.1
  %list.object.94 = alloca %class.List
  %list.addr.94 = alloca ptr
  store ptr %list.object.94, ptr %list.addr.94
  %list.ctor.0 = getelementptr i8, ptr null, i32 0
  %list.field.0 = getelementptr inbounds %class.List, ptr %list.object.94, i32 0, i32 0
  store ptr %list.ctor.0, ptr %list.field.0
  %list.init.1 = add i32 0, 1
  %list.field.1 = getelementptr inbounds %class.List, ptr %list.object.94, i32 0, i32 1
  store i32 %list.init.1, ptr %list.field.1
  %ret.103.this = load ptr, ptr %list.addr.94
  %ret.103 = call i32 @List_getSize(ptr %ret.103.this)
  ret i32 %ret.103
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

