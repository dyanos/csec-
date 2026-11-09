; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [8 x i8] c"isAlpha\00", align 1
@1 = private unnamed_addr constant [34 x i8] c"selfhost/helper_runtime_output.ll\00", align 1

define i32 @main(i32 %0, ptr %1) {
entry:
  call void @csec_set_command_line_args(i32 %0, ptr %1)
  %user.main = call i32 @_main()
  ret i32 %user.main
}

declare ptr @malloc(i64)

declare void @free(ptr)

declare ptr @toString(ptr)

declare ptr @"operator+"(ptr, ptr)

declare void @print(ptr)

declare void @println(ptr)

declare ptr @csec_llvm_lexer_helper_definition(ptr)

declare i64 @csec_string_builder_new()

declare i32 @csec_string_builder_append(i64, ptr)

declare i32 @csec_string_builder_write_to_file(i64, ptr)

define i32 @_main() {
entry:
  %calltmp = call ptr @csec_llvm_lexer_helper_definition(ptr @0)
  %calltmp1 = call i64 @csec_string_builder_new()
  %calltmp2 = call i32 @csec_string_builder_append(i64 %calltmp1, ptr %calltmp)
  %calltmp4 = call i32 @csec_string_builder_write_to_file(i64 %calltmp1, ptr @1)
  ret i32 0
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
