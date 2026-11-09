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

define i32 @Calculator_add(i32 %arg.this.base, i32 %arg.x) {
entry:
  %base = alloca i32
  store i32 %arg.this.base, ptr %base
  %x = alloca i32
  store i32 %arg.x, ptr %x
  %ret.left = load i32, ptr %base
  %ret.right = load i32, ptr %x
  %ret = add i32 %ret.left, %ret.right
  ret i32 %ret
}

define i32 @Calculator_sub(i32 %arg.this.base, i32 %arg.x) {
entry:
  %base = alloca i32
  store i32 %arg.this.base, ptr %base
  %x = alloca i32
  store i32 %arg.x, ptr %x
  %ret.left = load i32, ptr %base
  %ret.right = load i32, ptr %x
  %ret = sub i32 %ret.left, %ret.right
  ret i32 %ret
}

define i32 @Calculator_mul(i32 %arg.this.base, i32 %arg.x) {
entry:
  %base = alloca i32
  store i32 %arg.this.base, ptr %base
  %x = alloca i32
  store i32 %arg.x, ptr %x
  %ret.left = load i32, ptr %base
  %ret.right = load i32, ptr %x
  %ret = mul i32 %ret.left, %ret.right
  ret i32 %ret
}

define i32 @Calculator_div(i32 %arg.this.base, i32 %arg.x) {
entry:
  %base = alloca i32
  store i32 %arg.this.base, ptr %base
  %x = alloca i32
  store i32 %arg.x, ptr %x
  %ret.left = load i32, ptr %base
  %ret.right = load i32, ptr %x
  %ret = sdiv i32 %ret.left, %ret.right
  ret i32 %ret
}

define i32 @Calculator_mod(i32 %arg.this.base, i32 %arg.x) {
entry:
  %base = alloca i32
  store i32 %arg.this.base, ptr %base
  %x = alloca i32
  store i32 %arg.x, ptr %x
  %ret.left = load i32, ptr %base
  %ret.right = load i32, ptr %x
  %ret = srem i32 %ret.left, %ret.right
  ret i32 %ret
}

define i32 @Calculator_neg(i32 %arg.this.base) {
entry:
  %base = alloca i32
  store i32 %arg.this.base, ptr %base
  %ret.left = add i32 0, 0
  %ret.right = load i32, ptr %base
  %ret = sub i32 %ret.left, %ret.right
  ret i32 %ret
}

define i1 @Calculator_isZero(i32 %arg.this.base) {
entry:
  %base = alloca i32
  store i32 %arg.this.base, ptr %base
  %ret.i32.left = load i32, ptr %base
  %ret.i32.right = add i32 0, 0
  %ret.i32.comparison = icmp eq i32 %ret.i32.left, %ret.i32.right
  %ret.i32 = zext i1 %ret.i32.comparison to i32
  %ret = icmp ne i32 %ret.i32, 0
  ret i1 %ret
}

define i1 @Calculator_isPositive(i32 %arg.this.base) {
entry:
  %base = alloca i32
  store i32 %arg.this.base, ptr %base
  %ret.i32.left = load i32, ptr %base
  %ret.i32.right = add i32 0, 0
  %ret.i32.comparison = icmp sgt i32 %ret.i32.left, %ret.i32.right
  %ret.i32 = zext i1 %ret.i32.comparison to i32
  %ret = icmp ne i32 %ret.i32, 0
  ret i1 %ret
}

define i32 @Calculator_double(i32 %arg.this.base) {
entry:
  %base = alloca i32
  store i32 %arg.this.base, ptr %base
  %ret.left = load i32, ptr %base
  %ret.right = load i32, ptr %base
  %ret = add i32 %ret.left, %ret.right
  ret i32 %ret
}

define i32 @Calculator_square(i32 %arg.this.base) {
entry:
  %base = alloca i32
  store i32 %arg.this.base, ptr %base
  %ret.left = load i32, ptr %base
  %ret.right = load i32, ptr %base
  %ret = mul i32 %ret.left, %ret.right
  ret i32 %ret
}

define i32 @csec_user_main() {
entry:
  %calc.addr.131 = alloca i32
  store i32 0, ptr %calc.addr.131
  %a.addr.140 = alloca i32
  %a.init.140.arg0 = add i32 0, 10
  %a.init.140.marg0 = add i32 0, 5
  %a.init.140 = call i32 @Calculator_add(i32 %a.init.140.arg0, i32 %a.init.140.marg0)
  store i32 %a.init.140, ptr %a.addr.140
  %b.addr.150 = alloca i32
  %b.init.150.arg0 = add i32 0, 10
  %b.init.150.marg0 = add i32 0, 3
  %b.init.150 = call i32 @Calculator_sub(i32 %b.init.150.arg0, i32 %b.init.150.marg0)
  store i32 %b.init.150, ptr %b.addr.150
  %c.addr.160 = alloca i32
  %c.init.160.arg0 = add i32 0, 10
  %c.init.160.marg0 = add i32 0, 2
  %c.init.160 = call i32 @Calculator_mul(i32 %c.init.160.arg0, i32 %c.init.160.marg0)
  store i32 %c.init.160, ptr %c.addr.160
  %d.addr.170 = alloca i32
  %d.init.170.arg0 = add i32 0, 10
  %d.init.170 = call i32 @Calculator_double(i32 %d.init.170.arg0)
  store i32 %d.init.170, ptr %d.addr.170
  %ret.179.left.left.left = load i32, ptr %a.addr.140
  %ret.179.left.left.right = load i32, ptr %b.addr.150
  %ret.179.left.left = add i32 %ret.179.left.left.left, %ret.179.left.left.right
  %ret.179.left.right = load i32, ptr %c.addr.160
  %ret.179.left = add i32 %ret.179.left.left, %ret.179.left.right
  %ret.179.right = load i32, ptr %d.addr.170
  %ret.179 = add i32 %ret.179.left, %ret.179.right
  ret i32 %ret.179
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

