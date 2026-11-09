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
  %negtmp = sub i32 0, 5
  %inc = add i32 5, 1
  %dec = sub i32 5, 1
  %inc5 = add i32 5, 1
  %dec7 = sub i32 5, 1
  %negtmp9 = sub i32 0, 5
  %negtmp10 = sub i32 0, %negtmp9
  ret i32 5
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
