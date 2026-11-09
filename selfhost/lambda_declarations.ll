; ModuleID = 'main'
source_filename = "main"

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

define i32 @_main() {
entry:
  ret i32 0
}

define internal i32 @__lambda_0(i32 %0) {
entry:
  %addtmp = add i32 %0, 1
  ret i32 %addtmp
}

define internal i32 @__lambda_1(i32 %0) {
entry:
  ret i32 0
}

define internal i32 @__lambda_2(i32 %0) {
entry:
  ret i32 %0
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
