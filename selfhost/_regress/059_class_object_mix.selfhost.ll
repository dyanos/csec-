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

@.str.126 = private unnamed_addr constant [5 x i8] c"test\00"

define i32 @Config_getMaxRetries() {
entry:
  %maxRetries.addr.3 = alloca i32
  %object.maxRetries.addr.3 = add i32 0, 3
  store i32 %object.maxRetries.addr.3, ptr %maxRetries.addr.3
  %timeout.addr.10 = alloca i32
  %object.timeout.addr.10 = add i32 0, 30
  store i32 %object.timeout.addr.10, ptr %timeout.addr.10
  %ret = load i32, ptr %maxRetries.addr.3
  ret i32 %ret
}

define i32 @Config_getTimeout() {
entry:
  %maxRetries.addr.3 = alloca i32
  %object.maxRetries.addr.3 = add i32 0, 3
  store i32 %object.maxRetries.addr.3, ptr %maxRetries.addr.3
  %timeout.addr.10 = alloca i32
  %object.timeout.addr.10 = add i32 0, 30
  store i32 %object.timeout.addr.10, ptr %timeout.addr.10
  %ret = load i32, ptr %timeout.addr.10
  ret i32 %ret
}

%class.Client = type { ptr, i32 }

define i32 @Client_connect(ptr %arg.this) {
entry:
  %name = getelementptr inbounds %class.Client, ptr %arg.this, i32 0, i32 0
  %retries.addr.42 = getelementptr inbounds %class.Client, ptr %arg.this, i32 0, i32 1
  %retries = getelementptr inbounds %class.Client, ptr %arg.this, i32 0, i32 1
  %maxR.addr.56 = alloca i32
  %maxR.init.56 = call i32 @Config_getMaxRetries()
  store i32 %maxR.init.56, ptr %maxR.addr.56
  %tout.addr.65 = alloca i32
  %tout.init.65 = call i32 @Config_getTimeout()
  store i32 %tout.init.65, ptr %tout.addr.65
  %ret.74.left = load i32, ptr %maxR.addr.56
  %ret.74.right = load i32, ptr %tout.addr.65
  %ret.74 = add i32 %ret.74.left, %ret.74.right
  ret i32 %ret.74
}

define i32 @Server_start(i32 %arg.this.port) {
entry:
  %port = alloca i32
  store i32 %arg.this.port, ptr %port
  %ret = load i32, ptr %port
  ret i32 %ret
}

define i32 @Server_configure(i32 %arg.this.port) {
entry:
  %port = alloca i32
  store i32 %arg.this.port, ptr %port
  %ret.104 = call i32 @Config_getTimeout()
  ret i32 %ret.104
}

define i32 @csec_user_main() {
entry:
  %client.object.120 = alloca %class.Client
  %client.addr.120 = alloca ptr
  store ptr %client.object.120, ptr %client.addr.120
  %client.ctor.0 = getelementptr inbounds [5 x i8], ptr @.str.126, i32 0, i32 0
  %client.field.0 = getelementptr inbounds %class.Client, ptr %client.object.120, i32 0, i32 0
  store ptr %client.ctor.0, ptr %client.field.0
  %client.init.1 = add i32 0, 0
  %client.field.1 = getelementptr inbounds %class.Client, ptr %client.object.120, i32 0, i32 1
  store i32 %client.init.1, ptr %client.field.1
  %server.addr.129 = alloca i32
  store i32 0, ptr %server.addr.129
  %a.addr.138 = alloca i32
  %a.init.138.this = load ptr, ptr %client.addr.120
  %a.init.138 = call i32 @Client_connect(ptr %a.init.138.this)
  store i32 %a.init.138, ptr %a.addr.138
  %b.addr.147 = alloca i32
  %b.init.147.arg0 = add i32 0, 8080
  %b.init.147 = call i32 @Server_start(i32 %b.init.147.arg0)
  store i32 %b.init.147, ptr %b.addr.147
  %ret.156.left = load i32, ptr %a.addr.138
  %ret.156.right = load i32, ptr %b.addr.147
  %ret.156 = add i32 %ret.156.left, %ret.156.right
  ret i32 %ret.156
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

