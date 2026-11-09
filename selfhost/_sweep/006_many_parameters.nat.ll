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

define i32 @_sum5(i32 %0, i32 %1, i32 %2, i32 %3, i32 %4) {
entry:
  %addtmp = add i32 %0, %1
  %addtmp1 = add i32 %addtmp, %2
  %addtmp2 = add i32 %addtmp1, %3
  %addtmp3 = add i32 %addtmp2, %4
  ret i32 %addtmp3
}

define i32 @_mixed(i32 %0, float %1, double %2, ptr %3, i1 %4) {
entry:
  ret i32 %0
}

define i32 @_main() {
entry:
  %calltmp = call i32 @_sum5(i32 1, i32 2, i32 3, i32 4, i32 5)
  ret i32 %calltmp
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
