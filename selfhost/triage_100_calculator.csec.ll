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

define i32 @Calculator_add(i32 %arg.a, i32 %arg.b) {
entry:
  %a = alloca i32
  store i32 %arg.a, ptr %a
  %b = alloca i32
  store i32 %arg.b, ptr %b
  %ret.left = load i32, ptr %a
  %ret.right = load i32, ptr %b
  %ret = add i32 %ret.left, %ret.right
  ret i32 %ret
}

define i32 @Calculator_sub(i32 %arg.a, i32 %arg.b) {
entry:
  %a = alloca i32
  store i32 %arg.a, ptr %a
  %b = alloca i32
  store i32 %arg.b, ptr %b
  %ret.left = load i32, ptr %a
  %ret.right = load i32, ptr %b
  %ret = sub i32 %ret.left, %ret.right
  ret i32 %ret
}

define i32 @Calculator_mul(i32 %arg.a, i32 %arg.b) {
entry:
  %a = alloca i32
  store i32 %arg.a, ptr %a
  %b = alloca i32
  store i32 %arg.b, ptr %b
  %ret.left = load i32, ptr %a
  %ret.right = load i32, ptr %b
  %ret = mul i32 %ret.left, %ret.right
  ret i32 %ret
}

define i32 @Calculator_div(i32 %arg.a, i32 %arg.b) {
entry:
  %a = alloca i32
  store i32 %arg.a, ptr %a
  %b = alloca i32
  store i32 %arg.b, ptr %b
  %ifcond.68.left.left = load i32, ptr %b
  %ifcond.68.left.right = add i32 0, 0
  %ifcond.68.left.comparison = icmp eq i32 %ifcond.68.left.left, %ifcond.68.left.right
  %ifcond.68.left = zext i1 %ifcond.68.left.comparison to i32
  %ifcond.68 = icmp ne i32 %ifcond.68.left, 0
  br i1 %ifcond.68, label %if.then.68, label %if.else.68
if.then.68:
  %if.then.ret.68 = add i32 0, 0
  ret i32 %if.then.ret.68
if.else.68:
  br label %if.end.68
if.end.68:
  %ret.79.left = load i32, ptr %a
  %ret.79.right = load i32, ptr %b
  %ret.79 = sdiv i32 %ret.79.left, %ret.79.right
  ret i32 %ret.79
}

define i32 @Calculator_mod(i32 %arg.a, i32 %arg.b) {
entry:
  %a = alloca i32
  store i32 %arg.a, ptr %a
  %b = alloca i32
  store i32 %arg.b, ptr %b
  %ifcond.99.left.left = load i32, ptr %b
  %ifcond.99.left.right = add i32 0, 0
  %ifcond.99.left.comparison = icmp eq i32 %ifcond.99.left.left, %ifcond.99.left.right
  %ifcond.99.left = zext i1 %ifcond.99.left.comparison to i32
  %ifcond.99 = icmp ne i32 %ifcond.99.left, 0
  br i1 %ifcond.99, label %if.then.99, label %if.else.99
if.then.99:
  %if.then.ret.99 = add i32 0, 0
  ret i32 %if.then.ret.99
if.else.99:
  br label %if.end.99
if.end.99:
  %ret.110.left = load i32, ptr %a
  %ret.110.right = load i32, ptr %b
  %ret.110 = srem i32 %ret.110.left, %ret.110.right
  ret i32 %ret.110
}

define i32 @Calculator_abs(i32 %arg.x) {
entry:
  %x = alloca i32
  store i32 %arg.x, ptr %x
  %ifcond.126.left.left = load i32, ptr %x
  %ifcond.126.left.right = add i32 0, 0
  %ifcond.126.left.comparison = icmp slt i32 %ifcond.126.left.left, %ifcond.126.left.right
  %ifcond.126.left = zext i1 %ifcond.126.left.comparison to i32
  %ifcond.126 = icmp ne i32 %ifcond.126.left, 0
  br i1 %ifcond.126, label %if.then.126, label %if.else.126
if.then.126:
  %if.then.ret.126.left = add i32 0, 0
  %if.then.ret.126.right = load i32, ptr %x
  %if.then.ret.126 = sub i32 %if.then.ret.126.left, %if.then.ret.126.right
  ret i32 %if.then.ret.126
if.else.126:
  br label %if.end.126
if.end.126:
  %ret.139 = load i32, ptr %x
  ret i32 %ret.139
}

define i32 @Calculator_max(i32 %arg.a, i32 %arg.b) {
entry:
  %a = alloca i32
  store i32 %arg.a, ptr %a
  %b = alloca i32
  store i32 %arg.b, ptr %b
  %ifcond.157.left.left = load i32, ptr %a
  %ifcond.157.left.right = load i32, ptr %b
  %ifcond.157.left.comparison = icmp sgt i32 %ifcond.157.left.left, %ifcond.157.left.right
  %ifcond.157.left = zext i1 %ifcond.157.left.comparison to i32
  %ifcond.157 = icmp ne i32 %ifcond.157.left, 0
  br i1 %ifcond.157, label %if.then.157, label %if.else.157
if.then.157:
  %if.then.ret.157 = load i32, ptr %a
  ret i32 %if.then.ret.157
if.else.157:
  br label %if.end.157
if.end.157:
  %ret.168 = load i32, ptr %b
  ret i32 %ret.168
}

define i32 @Calculator_min(i32 %arg.a, i32 %arg.b) {
entry:
  %a = alloca i32
  store i32 %arg.a, ptr %a
  %b = alloca i32
  store i32 %arg.b, ptr %b
  %ifcond.186.left.left = load i32, ptr %a
  %ifcond.186.left.right = load i32, ptr %b
  %ifcond.186.left.comparison = icmp slt i32 %ifcond.186.left.left, %ifcond.186.left.right
  %ifcond.186.left = zext i1 %ifcond.186.left.comparison to i32
  %ifcond.186 = icmp ne i32 %ifcond.186.left, 0
  br i1 %ifcond.186, label %if.then.186, label %if.else.186
if.then.186:
  %if.then.ret.186 = load i32, ptr %a
  ret i32 %if.then.ret.186
if.else.186:
  br label %if.end.186
if.end.186:
  %ret.197 = load i32, ptr %b
  ret i32 %ret.197
}

define i32 @csec_user_main() {
entry:
  %a.addr.209 = alloca i32
  %a.init.209.arg0 = add i32 0, 10
  %a.init.209.arg1 = add i32 0, 20
  %a.init.209 = call i32 @Calculator_add(i32 %a.init.209.arg0, i32 %a.init.209.arg1)
  store i32 %a.init.209, ptr %a.addr.209
  %b.addr.221 = alloca i32
  %b.init.221.arg0 = add i32 0, 50
  %b.init.221.arg1 = add i32 0, 30
  %b.init.221 = call i32 @Calculator_sub(i32 %b.init.221.arg0, i32 %b.init.221.arg1)
  store i32 %b.init.221, ptr %b.addr.221
  %c.addr.233 = alloca i32
  %c.init.233.arg0 = add i32 0, 3
  %c.init.233.arg1 = add i32 0, 4
  %c.init.233 = call i32 @Calculator_mul(i32 %c.init.233.arg0, i32 %c.init.233.arg1)
  store i32 %c.init.233, ptr %c.addr.233
  %d.addr.245 = alloca i32
  %d.init.245.arg0 = add i32 0, 100
  %d.init.245.arg1 = add i32 0, 5
  %d.init.245 = call i32 @Calculator_div(i32 %d.init.245.arg0, i32 %d.init.245.arg1)
  store i32 %d.init.245, ptr %d.addr.245
  %e.addr.257 = alloca i32
  %e.init.257.arg0 = add i32 0, 17
  %e.init.257.arg1 = add i32 0, 5
  %e.init.257 = call i32 @Calculator_mod(i32 %e.init.257.arg0, i32 %e.init.257.arg1)
  store i32 %e.init.257, ptr %e.addr.257
  %f.addr.269 = alloca i32
  %f.init.269.arg0.left = add i32 0, 0
  %f.init.269.arg0.right = add i32 0, 42
  %f.init.269.arg0 = sub i32 %f.init.269.arg0.left, %f.init.269.arg0.right
  %f.init.269 = call i32 @Calculator_abs(i32 %f.init.269.arg0)
  store i32 %f.init.269, ptr %f.addr.269
  %g.addr.281 = alloca i32
  %g.init.281.arg0 = load i32, ptr %a.addr.209
  %g.init.281.arg1 = load i32, ptr %b.addr.221
  %g.init.281 = call i32 @Calculator_max(i32 %g.init.281.arg0, i32 %g.init.281.arg1)
  store i32 %g.init.281, ptr %g.addr.281
  %h.addr.293 = alloca i32
  %h.init.293.arg0 = load i32, ptr %c.addr.233
  %h.init.293.arg1 = load i32, ptr %d.addr.245
  %h.init.293 = call i32 @Calculator_min(i32 %h.init.293.arg0, i32 %h.init.293.arg1)
  store i32 %h.init.293, ptr %h.addr.293
  %ret.305.left.left.left.left.left.left.left = load i32, ptr %a.addr.209
  %ret.305.left.left.left.left.left.left.right = load i32, ptr %b.addr.221
  %ret.305.left.left.left.left.left.left = add i32 %ret.305.left.left.left.left.left.left.left, %ret.305.left.left.left.left.left.left.right
  %ret.305.left.left.left.left.left.right = load i32, ptr %c.addr.233
  %ret.305.left.left.left.left.left = add i32 %ret.305.left.left.left.left.left.left, %ret.305.left.left.left.left.left.right
  %ret.305.left.left.left.left.right = load i32, ptr %d.addr.245
  %ret.305.left.left.left.left = add i32 %ret.305.left.left.left.left.left, %ret.305.left.left.left.left.right
  %ret.305.left.left.left.right = load i32, ptr %e.addr.257
  %ret.305.left.left.left = add i32 %ret.305.left.left.left.left, %ret.305.left.left.left.right
  %ret.305.left.left.right = load i32, ptr %f.addr.269
  %ret.305.left.left = add i32 %ret.305.left.left.left, %ret.305.left.left.right
  %ret.305.left.right = load i32, ptr %g.addr.281
  %ret.305.left = add i32 %ret.305.left.left, %ret.305.left.right
  %ret.305.right = load i32, ptr %h.addr.293
  %ret.305 = add i32 %ret.305.left, %ret.305.right
  ret i32 %ret.305
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

