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

%class.Point = type { float, double }

define double @Point_sumParts(ptr %arg.this) {
entry:
  %x = getelementptr inbounds %class.Point, ptr %arg.this, i32 0, i32 0
  %y = getelementptr inbounds %class.Point, ptr %arg.this, i32 0, i32 1
  %ret.19 = load double, ptr %y
  ret double %ret.19
}

define i32 @csec_user_main() {
entry:
  %p.object.31 = alloca %class.Point
  %p.addr.31 = alloca ptr
  store ptr %p.object.31, ptr %p.addr.31
  %p.ctor.0 = fadd float 0.000000e+00, 0x3FF8000000000000
  %p.field.0 = getelementptr inbounds %class.Point, ptr %p.object.31, i32 0, i32 0
  store float %p.ctor.0, ptr %p.field.0
  %p.ctor.1 = fadd double 0.000000e+00, 0x4004000000000000
  %p.field.1 = getelementptr inbounds %class.Point, ptr %p.object.31, i32 0, i32 1
  store double %p.ctor.1, ptr %p.field.1
  %s.addr.42 = alloca double
  %s.init.42.this = load ptr, ptr %p.addr.31
  %s.init.42 = call double @Point_sumParts(ptr %s.init.42.this)
  store double %s.init.42, ptr %s.addr.42
  %ifcond.53.left.left = load double, ptr %s.addr.42
  %ifcond.53.left.right = fadd double 0.000000e+00, 0x4003333333333333
  %ifcond.53.left = fcmp ogt double %ifcond.53.left.left, %ifcond.53.left.right
  %ifcond.53.right.left = load double, ptr %s.addr.42
  %ifcond.53.right.right = fadd double 0.000000e+00, 0x4004CCCCCCCCCCCD
  %ifcond.53.right = fcmp olt double %ifcond.53.right.left, %ifcond.53.right.right
  %ifcond.53 = and i1 %ifcond.53.left, %ifcond.53.right
  br i1 %ifcond.53, label %if.then.53, label %if.else.53
if.then.53:
  %ret.64 = add i32 0, 0
  ret i32 %ret.64
if.else.53:
  br label %if.end.53
if.end.53:
  %ret.68 = add i32 0, 1
  ret i32 %ret.68
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

