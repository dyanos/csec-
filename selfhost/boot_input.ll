; ModuleID = 'csec.selfhost'
source_filename = "csec.selfhost"

declare i64 @csec_string_length(ptr)
declare i8 @csec_string_char_at(ptr, i32)

declare i32 @csec_lex_quoted(ptr, i32)
declare i32 @csec_lex_number(ptr, i32)
declare i32 @csec_lex_identifier(ptr, i32)
declare i32 @csec_lex_line_comment(ptr, i32)
declare i32 @csec_lex_block_comment(ptr, i32)
declare i32 @csec_digit_value(i8)
declare i32 @csec_is_keyword(ptr)
declare i32 @csec_to_int(ptr)
declare i32 @csec_line_start(ptr, i32)
declare i32 @csec_line_end(ptr, i32)
declare i32 @csec_validate_balanced(ptr)
declare i32 @csec_starts_top_level_declaration(ptr, i32)
declare i32 @csec_validate_top_level(ptr)
declare ptr @csec_top_level_decl_kind(ptr, i32)
declare ptr @csec_top_level_decl_name(ptr, i32)
declare i32 @csec_count_function_params(ptr, i32)
declare i32 @csec_token_is_top_level_operator(ptr, i32, i32)
declare i32 @csec_find_top_level_operator(ptr, i32, i32, i32)
declare i32 @csec_find_top_level_match(ptr, i32, i32)
declare i32 @csec_find_lambda_arrow(ptr, i32, i32)
declare ptr @csec_generate_symbol_table(ptr)
declare ptr @csec_append_expression_until(ptr, i32, i32)
declare ptr @csec_generate_expression_ast(ptr, i32, i32)
declare ptr @csec_generate_statement_ast(ptr, i32, i32)
declare ptr @csec_generate_body_ast(ptr, i32, i32)
declare i32 @csec_find_function_param_start(ptr, i32)
declare ptr @csec_generate_c_body(ptr, i32, i32, ptr)
declare ptr @csec_generate_c_expression(ptr, i32, i32)
declare ptr @csec_ir_operator_name(ptr)
declare ptr @csec_ir_type_name(ptr)
declare i32 @csec_expression_top_level_operator(ptr, i32, i32)
declare i32 @csec_find_token_text_in_range(ptr, i32, i32, ptr)
declare i32 @csec_find_closing_token(ptr, i32, i32, ptr, ptr)
declare i32 @csec_find_statement_paren_start(ptr, i32, i32)
declare i32 @csec_find_statement_paren_end(ptr, i32, i32)
declare i32 @csec_find_statement_block_start(ptr, i32, i32)
declare i32 @csec_find_statement_block_end(ptr, i32, i32)
declare i32 @csec_count_comma_separated(ptr, i32, i32)
declare i32 @csec_find_last_top_level_token(ptr, i32, i32, ptr)
declare ptr @csec_llvm_lexer_helper_definition(ptr)
declare i64 @csec_string_builder_new()
declare i64 @csec_string_builder_new_file(ptr)
declare i32 @csec_string_builder_append(i64, ptr)
declare ptr @csec_string_builder_finish(i64)
declare i32 @csec_string_builder_write_to_file(i64, ptr)
declare void @csec_set_command_line_args(i32, ptr)
declare i32 @csec_command_line_arg_count()
declare ptr @csec_command_line_arg(i32)
declare ptr @csec_file_read_all_text(ptr)
declare i32 @csec_file_write_all_text(ptr, ptr)
declare void @csec_print_string(ptr)
declare void @csec_print_newline()
declare ptr @csec_string_concat(ptr, ptr)
declare i32 @csec_string_equals(ptr, ptr)
declare i32 @csec_string_starts_with(ptr, ptr)
declare ptr @csec_string_substring(ptr, i32, i32)
declare ptr @csec_to_string_i64(i64)
declare ptr @csec_to_string_double(double)
declare double @sqrt(double)
declare double @cos(double)
declare double @sin(double)
declare ptr @csec_to_string_char(i8)
declare ptr @csec_bigint_from_i64(i64)
declare ptr @csec_bigint_from_decimal(ptr)
declare ptr @csec_bigint_add(ptr, ptr)
declare ptr @csec_bigint_sub(ptr, ptr)
declare ptr @csec_bigint_mul(ptr, ptr)
declare i32 @csec_bigint_cmp(ptr, ptr)
declare ptr @csec_bigint_to_string(ptr)
declare ptr @csec_tensor_new(i64, double)
declare double @csec_tensor_get(ptr, i64)
declare void @csec_tensor_set(ptr, i64, double)
declare ptr @csec_tensor_new2(i64, i64, double)
declare double @csec_tensor_get2(ptr, i64, i64)
declare void @csec_tensor_set2(ptr, i64, i64, double)
declare ptr @csec_tensor_add(ptr, ptr)
declare ptr @csec_tensor_sub(ptr, ptr)
declare ptr @csec_tensor_mul(ptr, ptr)
declare ptr @csec_tensor_scale(ptr, double)
declare ptr @csec_tensor_div_scalar(ptr, double)
declare double @csec_tensor_inner(ptr, ptr)
declare ptr @csec_token_append_owned(ptr, i8, ptr)
declare i64 @csec_token_builder_new()
declare i32 @csec_token_builder_append(i64, i8, ptr)
declare ptr @csec_token_builder_finish(i64)
declare ptr @csec_tokenize_source(ptr)
declare i8 @csec_token_kind_at(ptr, i32)
declare ptr @csec_token_text_at(ptr, i32)
declare i32 @csec_token_is(ptr, i32, i8, ptr)
declare i32 @csec_advance_statement(ptr, i32, i32)
declare i32 @csec_advance_top_level_decl(ptr, i32)
declare i32 @csec_find_decl_body_start(ptr, i32)
declare i32 @csec_find_decl_body_end(ptr, i32)
declare i32 @csec_function_param_end(ptr, i32)
declare ptr @csec_function_llvm_param_list(ptr, i32)
declare ptr @csec_function_llvm_param_allocas(ptr, i32)
declare ptr @csec_llvm_name_with_number(ptr, i32)
declare ptr @csec_llvm_string_literal_bytes(ptr)
declare i32 @csec_llvm_string_literal_byte_length(ptr)
declare ptr @csec_function_return_type_at(ptr, i32)
declare ptr @csec_collect_type_name(ptr, i32, i32)
declare i32 @csec_enclosing_function_decl_start(ptr, i32)
declare i32 @csec_enclosing_function_body_start(ptr, i32)
declare i32 @csec_enclosing_function_body_end(ptr, i32)
declare ptr @csec_lookup_function_return_type(ptr, ptr)
declare ptr @csec_lookup_visible_value_type(ptr, i32, ptr)
declare ptr @csec_lookup_visible_storage_name(ptr, i32, ptr)
declare ptr @csec_expand_imports(ptr)

define i32 @main(i32 %argc, ptr %argv) {
entry:
  call void @csec_set_command_line_args(i32 %argc, ptr %argv)
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}
define i32 @csec_user_main() {
entry:
  %seed.addr.7 = alloca i32
  %seed.init.7 = add i32 0, 1
  store i32 %seed.init.7, ptr %seed.addr.7
  %ratio.addr.14 = alloca double
  %ratio.finit.14 = fadd double 0.000000e+00, 2.5
  store double %ratio.finit.14, ptr %ratio.addr.14
  %enabled.addr.21 = alloca i1
  %enabled.binit.21 = icmp eq i1 true, true
  store i1 %enabled.binit.21, ptr %enabled.addr.21
  %current.addr.28 = alloca i32
  %current.init.28.left = load i32, ptr %seed.addr.7
  %current.init.28.right = add i32 0, 6
  %current.init.28 = add i32 %current.init.28.left, %current.init.28.right
  store i32 %current.init.28, ptr %current.addr.28
  %flags.addr.37 = alloca i32
  %flags.init.37.left = add i32 0, 0
  %flags.init.37.right = add i32 0, 3
  %flags.init.37 = or i32 %flags.init.37.left, %flags.init.37.right
  store i32 %flags.init.37, ptr %flags.addr.37
  %flags.assign.50.left = load i32, ptr %flags.addr.37
  %flags.assign.50.right = add i32 0, 7
  %flags.assign.50 = and i32 %flags.assign.50.left, %flags.assign.50.right
  store i32 %flags.assign.50, ptr %flags.addr.37
  %flags.old.56 = load i32, ptr %flags.addr.37
  %flags.rhs.56 = add i32 0, 1
  %flags.next.56 = add i32 %flags.old.56, %flags.rhs.56
  store i32 %flags.next.56, ptr %flags.addr.37
  %flags.old.60 = load i32, ptr %flags.addr.37
  %flags.rhs.60 = add i32 0, 1
  %flags.next.60 = sub i32 %flags.old.60, %flags.rhs.60
  store i32 %flags.next.60, ptr %flags.addr.37
  %cond.64.left = load i1, ptr %enabled.addr.21
  %cond.64.right.left.i32 = load i32, ptr %current.addr.28
  %cond.64.right.right.i32 = add i32 0, 0
  %cond.64.right = icmp sgt i32 %cond.64.right.left.i32, %cond.64.right.right.i32
  %cond.64 = and i1 %cond.64.left, %cond.64.right
  ; bool operands %enabled.bval, %btmp
  br i1 %cond.64, label %if.then.64, label %if.else.64
if.then.64:
  %current.assign.73.left = load i32, ptr %current.addr.28
  %current.assign.73.right = add i32 0, 0
  %current.assign.73 = add i32 %current.assign.73.left, %current.assign.73.right
  store i32 %current.assign.73, ptr %current.addr.28
  br label %if.end.64
if.else.64:
  %current.assign.82.left = load i32, ptr %current.addr.28
  %current.assign.82.right = add i32 0, 1
  %current.assign.82 = add i32 %current.assign.82.left, %current.assign.82.right
  store i32 %current.assign.82, ptr %current.addr.28
  br label %if.end.64
if.end.64:
  br label %while.cond.89
while.cond.89:
  %whilecond.89.left.i32 = load i32, ptr %flags.addr.37
  %whilecond.89.right.i32 = add i32 0, 0
  %whilecond.89 = icmp sgt i32 %whilecond.89.left.i32, %whilecond.89.right.i32
  br i1 %whilecond.89, label %while.body.89, label %while.end.89
while.body.89:
  %flags.assign.96.left = load i32, ptr %flags.addr.37
  %flags.assign.96.right = add i32 0, 1
  %flags.assign.96 = sub i32 %flags.assign.96.left, %flags.assign.96.right
  store i32 %flags.assign.96, ptr %flags.addr.37
  br label %while.cond.89
while.end.89:
  ret i32 7
}

