; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [6 x i8] c"hello\00", align 1

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

define i32 @_count(ptr %0) {
entry:
  %str.length = call i64 @csec_string_length(ptr %0)
  %abi.trunc = trunc i64 %str.length to i32
  ret i32 %abi.trunc
}

define i32 @_main() {
entry:
  %calltmp = call i32 @_count(ptr @0)
  %str.length = call i64 @csec_string_length(ptr @0)
  %num.sext = sext i32 %calltmp to i64
  %addtmp = add i64 %num.sext, %str.length
  %abi.trunc = trunc i64 %addtmp to i32
  ret i32 %abi.trunc
}

declare i64 @csec_string_length(ptr)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
