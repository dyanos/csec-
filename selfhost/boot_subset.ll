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

@.str.55 = private unnamed_addr constant [6 x i8] c"ready\00"
@.str.59 = private unnamed_addr constant [5 x i8] c"done\00"

define i32 @adjust(i32 %arg.value) {
entry:
  %value = alloca i32
  store i32 %arg.value, ptr %value
  %local.addr.10 = alloca i32
  %local.init.10 = load i32, ptr %value
  store i32 %local.init.10, ptr %local.addr.10
  %local.assign.17.left = load i32, ptr %local.addr.10
  %local.assign.17.right = add i32 0, 2
  %local.assign.17 = add i32 %local.assign.17.left, %local.assign.17.right
  store i32 %local.assign.17, ptr %local.addr.10
  %local.ret = load i32, ptr %local.addr.10
  ret i32 %local.ret
}

define i1 @positive(i32 %arg.value) {
entry:
  %value = alloca i32
  store i32 %arg.value, ptr %value
  %ret.37.left.i32 = load i32, ptr %value
  %ret.37.right.i32 = add i32 0, 0
  %ret.37 = icmp sgt i32 %ret.37.left.i32, %ret.37.right.i32
  ret i1 %ret.37
}

define ptr @label() {
entry:
  %text.addr.50 = alloca ptr
  %text.pinit.50 = getelementptr inbounds [6 x i8], ptr @.str.55, i32 0, i32 0
  store ptr %text.pinit.50, ptr %text.addr.50
  %text.passign.57 = getelementptr inbounds [5 x i8], ptr @.str.59, i32 0, i32 0
  store ptr %text.passign.57, ptr %text.addr.50
  %ret = load ptr, ptr %text.addr.50
  ret ptr %ret
}

define i8 @marker() {
entry:
  ret i8 120
}

define double @ratio() {
entry:
  ret double 1.5
}

define i64 @wide() {
entry:
  ret i64 1000
}

define void @touch() {
entry:
  ret void
}

define i32 @main(i32 %argc, ptr %argv) {
entry:
  call void @csec_set_command_line_args(i32 %argc, ptr %argv)
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}
define i32 @csec_user_main() {
entry:
  %current.addr.152 = alloca i32
  %current.init.152 = add i32 0, 3
  store i32 %current.init.152, ptr %current.addr.152
  %enabled.addr.159 = alloca i1
  %enabled.binit.159 = icmp eq i1 true, true
  store i1 %enabled.binit.159, ptr %enabled.addr.159
  %scale.addr.166 = alloca double
  %scale.finit.166 = fadd double 0.000000e+00, 2.5
  store double %scale.finit.166, ptr %scale.addr.166
  %name.addr.173 = alloca ptr
  %name.pinit.173 = call ptr @label()
  store ptr %name.pinit.173, ptr %name.addr.173
  %code.addr.182 = alloca i8
  %code.cinit.182 = call i8 @marker()
  store i8 %code.cinit.182, ptr %code.addr.182
  %wideValue.addr.191 = alloca i64
  %wideValue.linit.191 = call i64 @wide()
  store i64 %wideValue.linit.191, ptr %wideValue.addr.191
  %enabled.bassign.200 = icmp eq i1 false, true
  store i1 %enabled.bassign.200, ptr %enabled.addr.159
  %enabled.bassign.204.arg0 = load i32, ptr %current.addr.152
  %enabled.bassign.204 = call i1 @positive(i32 %enabled.bassign.204.arg0)
  store i1 %enabled.bassign.204, ptr %enabled.addr.159
  %scale.fassign.211 = call double @ratio()
  store double %scale.fassign.211, ptr %scale.addr.166
  %name.passign.217 = call ptr @label()
  store ptr %name.passign.217, ptr %name.addr.173
  %code.cassign.223 = call i8 @marker()
  store i8 %code.cassign.223, ptr %code.addr.182
  %wideValue.lassign.229 = call i64 @wide()
  store i64 %wideValue.lassign.229, ptr %wideValue.addr.191
  %cond.235.left = load i1, ptr %enabled.addr.159
  %cond.235.right.left.i32 = load i32, ptr %current.addr.152
  %cond.235.right.right.i32 = add i32 0, 0
  %cond.235.right = icmp sgt i32 %cond.235.right.left.i32, %cond.235.right.right.i32
  %cond.235 = and i1 %cond.235.left, %cond.235.right
  ; bool operands %enabled.bval, %btmp
  br i1 %cond.235, label %if.then.235, label %if.else.235
if.then.235:
  %current.assign.244.left = load i32, ptr %current.addr.152
  %current.assign.244.right = add i32 0, 1
  %current.assign.244 = add i32 %current.assign.244.left, %current.assign.244.right
  store i32 %current.assign.244, ptr %current.addr.152
  br label %if.end.235
if.else.235:
  %current.assign.253.left = load i32, ptr %current.addr.152
  %current.assign.253.right = add i32 0, 1
  %current.assign.253 = sub i32 %current.assign.253.left, %current.assign.253.right
  store i32 %current.assign.253, ptr %current.addr.152
  br label %if.end.235
if.end.235:
  br label %while.cond.260
while.cond.260:
  %whilecond.260.left.i32 = load i32, ptr %current.addr.152
  %whilecond.260.right.i32 = add i32 0, 1
  %whilecond.260 = icmp sgt i32 %whilecond.260.left.i32, %whilecond.260.right.i32
  br i1 %whilecond.260, label %while.body.260, label %while.end.260
while.body.260:
  %current.assign.267.left = load i32, ptr %current.addr.152
  %current.assign.267.right = add i32 0, 1
  %current.assign.267 = sub i32 %current.assign.267.left, %current.assign.267.right
  store i32 %current.assign.267, ptr %current.addr.152
  br label %while.cond.260
while.end.260:
  %i = alloca i32
  %i.start = add i32 0, 0
  store i32 %i.start, ptr %i
  br label %for.cond.274
for.cond.274:
  %i.val = load i32, ptr %i
  %i.end = add i32 0, 3
  %forcond.274 = icmp slt i32 %i.val, %i.end
  br i1 %forcond.274, label %for.body.274, label %for.end.274
for.body.274:
  %current.assign.283.left = load i32, ptr %current.addr.152
  %current.assign.283.right = load i32, ptr %i
  %current.assign.283 = add i32 %current.assign.283.left, %current.assign.283.right
  store i32 %current.assign.283, ptr %current.addr.152
  %i.step.274 = load i32, ptr %i
  %i.next.274 = add i32 %i.step.274, 1
  store i32 %i.next.274, ptr %i
  br label %for.cond.274
for.end.274:
  %j = alloca i32
  %j.start = add i32 0, 1
  store i32 %j.start, ptr %j
  br label %for.cond.290
for.cond.290:
  %j.val = load i32, ptr %j
  %j.end = add i32 0, 2
  %forcond.290 = icmp sle i32 %j.val, %j.end
  br i1 %forcond.290, label %for.body.290, label %for.end.290
for.body.290:
  %current.old.299 = load i32, ptr %current.addr.152
  %current.rhs.299 = load i32, ptr %j
  %current.next.299 = add i32 %current.old.299, %current.rhs.299
  store i32 %current.next.299, ptr %current.addr.152
  %j.step.290 = load i32, ptr %j
  %j.next.290 = add i32 %j.step.290, 1
  store i32 %j.next.290, ptr %j
  br label %for.cond.290
for.end.290:
  %current.assign.304.arg0.left = load i32, ptr %current.addr.152
  %current.assign.304.arg0.right = add i32 0, 1
  %current.assign.304.arg0 = add i32 %current.assign.304.arg0.left, %current.assign.304.arg0.right
  %current.assign.304 = call i32 @adjust(i32 %current.assign.304.arg0)
  store i32 %current.assign.304, ptr %current.addr.152
  %current.ret = load i32, ptr %current.addr.152
  ret i32 %current.ret
}

