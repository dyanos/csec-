; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [6 x i8] c"hello\00", align 1
@1 = private unnamed_addr constant [2 x i8] c"!\00", align 1

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

define ptr @_join(ptr %0, ptr %1) {
entry:
  %str.concat = call ptr @csec_string_concat(ptr %0, ptr %1)
  ret ptr %str.concat
}

define i32 @_main() {
entry:
  %calltmp = call ptr @_join(ptr @0, ptr @1)
  %str.length = call i64 @csec_string_length(ptr %calltmp)
  %abi.trunc = trunc i64 %str.length to i32
  ret i32 %abi.trunc
}

declare ptr @csec_string_concat(ptr, ptr)

declare i64 @csec_string_length(ptr)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
