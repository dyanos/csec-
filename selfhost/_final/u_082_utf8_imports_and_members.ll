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
  %calltmp = call i32 @"\EA\B3\84\EC\82\B0\EA\B8\B0#\EB\91\90\EB\B0\B0"(i32 3)
  ret i32 %calltmp
}

define i32 @"\EA\B3\84\EC\82\B0\EA\B8\B0#\EB\91\90\EB\B0\B0"(i32 %0) {
entry:
  %addtmp = add i32 %0, %0
  ret i32 %addtmp
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
