; ModuleID = 'csec.selfhost'
source_filename = "csec.selfhost"

declare i64 @csec_string_length(ptr)
declare i8 @csec_string_char_at(ptr, i32)

declare i64 @csec_string_builder_new()
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
declare i32 @csec_string_starts_with(ptr, ptr)
declare ptr @csec_string_substring(ptr, i32, i32)
declare ptr @csec_to_string_i64(i64)
declare ptr @csec_to_string_char(i8)
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
declare ptr @csec_function_return_type_at(ptr, i32)
declare i32 @csec_enclosing_function_decl_start(ptr, i32)
declare i32 @csec_enclosing_function_body_start(ptr, i32)
declare i32 @csec_enclosing_function_body_end(ptr, i32)
declare ptr @csec_lookup_function_return_type(ptr, ptr)
declare ptr @csec_expand_imports(ptr)

@.str.29 = private unnamed_addr constant [6 x i8] c"%ret.\00"
@.str.39 = private unnamed_addr constant [3 x i8] c"  \00"
@.str.43 = private unnamed_addr constant [21 x i8] c" = icmp eq i32 0, 0\0A\00"
@.str.51 = private unnamed_addr constant [10 x i8] c"  %ret.42\00"

define i32 @csec_user_main() {
entry:
  %name.addr.22 = alloca ptr
  %name.pinit.22.arg0 = getelementptr inbounds [6 x i8], ptr @.str.29, i32 0, i32 0
  %name.pinit.22 = call ptr @csec_llvm_name_with_number(ptr %name.pinit.22.arg0, i32 42)
  store ptr %name.pinit.22, ptr %name.addr.22
  %instruction.addr.34 = alloca ptr
  %instruction.pinit.34.left.left = getelementptr inbounds [3 x i8], ptr @.str.39, i32 0, i32 0
  %instruction.pinit.34.left.right = load ptr, ptr %name.addr.22
  %instruction.pinit.34.left = call ptr @csec_string_concat(ptr %instruction.pinit.34.left.left, ptr %instruction.pinit.34.left.right)
  %instruction.pinit.34.right = getelementptr inbounds [22 x i8], ptr @.str.43, i32 0, i32 0
  %instruction.pinit.34 = call ptr @csec_string_concat(ptr %instruction.pinit.34.left, ptr %instruction.pinit.34.right)
  store ptr %instruction.pinit.34, ptr %instruction.addr.34
  %cond.45.obj = load ptr, ptr %instruction.addr.34
  %cond.45.needle = getelementptr inbounds [10 x i8], ptr @.str.51, i32 0, i32 0
  %cond.45.i32 = call i32 @csec_string_starts_with(ptr %cond.45.obj, ptr %cond.45.needle)
  %cond.45 = icmp ne i32 %cond.45.i32, 0
  br i1 %cond.45, label %if.then.45, label %if.else.45
if.then.45:
  %ret.55 = add i32 0, 0
  ret i32 %ret.55
if.else.45:
  br label %if.end.45
if.end.45:
  ret i32 1
}

define i32 @main(i32 %argc, ptr %argv) {
entry:
  call void @csec_set_command_line_args(i32 %argc, ptr %argv)
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}
