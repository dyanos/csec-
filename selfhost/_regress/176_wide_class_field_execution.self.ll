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

%class.Counter = type { i64 }

define i64 @Counter_value(ptr %arg.this) {
entry:
  %start = getelementptr inbounds %class.Counter, ptr %arg.this, i32 0, i32 0
  %ret = load i64, ptr %start
  ret i64 %ret
}

%class.Measure = type { float, double }

define double @Measure_area(ptr %arg.this) {
entry:
  %width = getelementptr inbounds %class.Measure, ptr %arg.this, i32 0, i32 0
  %depth = getelementptr inbounds %class.Measure, ptr %arg.this, i32 0, i32 1
  %ret.39 = load double, ptr %depth
  ret double %ret.39
}

define i32 @csec_user_main() {
entry:
  %counter.object.51 = alloca %class.Counter
  %counter.addr.51 = alloca ptr
  store ptr %counter.object.51, ptr %counter.addr.51
  %counter.ctor.0 = add i64 0, 2147483653
  %counter.field.0 = getelementptr inbounds %class.Counter, ptr %counter.object.51, i32 0, i32 0
  store i64 %counter.ctor.0, ptr %counter.field.0
  %total.addr.60 = alloca i64
  %total.init.60.this = load ptr, ptr %counter.addr.51
  %total.init.60 = call i64 @Counter_value(ptr %total.init.60.this)
  store i64 %total.init.60, ptr %total.addr.60
  %measure.object.71 = alloca %class.Measure
  %measure.addr.71 = alloca ptr
  store ptr %measure.object.71, ptr %measure.addr.71
  %measure.ctor.0 = fadd float 0.000000e+00, 0x3FF8000000000000
  %measure.field.0 = getelementptr inbounds %class.Measure, ptr %measure.object.71, i32 0, i32 0
  store float %measure.ctor.0, ptr %measure.field.0
  %measure.ctor.1 = fadd double 0.000000e+00, 0x4004000000000000
  %measure.field.1 = getelementptr inbounds %class.Measure, ptr %measure.object.71, i32 0, i32 1
  store double %measure.ctor.1, ptr %measure.field.1
  %depth.addr.82 = alloca double
  %depth.init.82.this = load ptr, ptr %measure.addr.71
  %depth.init.82 = call double @Measure_area(ptr %depth.init.82.this)
  store double %depth.init.82, ptr %depth.addr.82
  %ifcond.93.left.left.left = load i64, ptr %total.addr.60
  %ifcond.93.left.left.right = add i64 0, 2147483653
  %ifcond.93.left.left = icmp eq i64 %ifcond.93.left.left.left, %ifcond.93.left.left.right
  %ifcond.93.left.right.left = load double, ptr %depth.addr.82
  %ifcond.93.left.right.right = fadd double 0.000000e+00, 0x4003333333333333
  %ifcond.93.left.right = fcmp ogt double %ifcond.93.left.right.left, %ifcond.93.left.right.right
  %ifcond.93.left = and i1 %ifcond.93.left.left, %ifcond.93.left.right
  %ifcond.93.right.left = load double, ptr %depth.addr.82
  %ifcond.93.right.right = fadd double 0.000000e+00, 0x4004CCCCCCCCCCCD
  %ifcond.93.right = fcmp olt double %ifcond.93.right.left, %ifcond.93.right.right
  %ifcond.93 = and i1 %ifcond.93.left, %ifcond.93.right
  br i1 %ifcond.93, label %if.then.93, label %if.else.93
if.then.93:
  %ret.108 = add i32 0, 0
  ret i32 %ret.108
if.else.93:
  br label %if.end.93
if.end.93:
  %ret.112 = add i32 0, 1
  ret i32 %ret.112
}

define i32 @main() {
entry:
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}

