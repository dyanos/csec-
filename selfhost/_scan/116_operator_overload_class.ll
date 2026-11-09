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
  %newobj.malloc = call ptr @malloc(i64 0)
  %op.call = call i32 @"Counter_operator+"(ptr %newobj.malloc, i32 4)
  %math.sext = sext i32 %op.call to i64
  call void @csec_print_i64(i64 %math.sext)
  call void @csec_print_newline()
  ret i32 0
}

define i32 @"Counter_operator+"(ptr %this, i32 %right) {
entry:
  %addtmp = add i32 %right, 1
  ret i32 %addtmp
}

declare void @csec_print_i64(i64)

declare void @csec_print_newline()

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
