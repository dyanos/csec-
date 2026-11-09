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

@.str.55 = private unnamed_addr constant [6 x i8] c"ready\00"
@.str.59 = private unnamed_addr constant [5 x i8] c"done\00"

define i32 @adjust(i32 %arg.value) {
entry:
  %value = alloca i32
  store i32 %arg.value, ptr %value
  %local.addr.10 = alloca i32
  %local.init.10 = load i32, ptr %value
  store i32 %local.init.10, ptr %local.addr.10
  ret i32 0
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
  %text.pinit.50 = getelementptr inbounds [5 x i8], ptr @.str.55, i32 0, i32 0
  store ptr %text.pinit.50, ptr %text.addr.50
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

define i32 @csec_user_main() {
entry:
  %current.addr.152 = alloca i32
  %current.init.152 = add i32 0, 3
  store i32 %current.init.152, ptr %current.addr.152
  ret i32 0
}

define i32 @main(i32 %argc, ptr %argv) {
entry:
  call void @csec_set_command_line_args(i32 %argc, ptr %argv)
  %ret = call i32 @csec_user_main()
  ret i32 %ret
}
