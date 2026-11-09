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

define i32 @_double(i32 %0) {
entry:
  %addtmp = add i32 %0, %0
  ret i32 %addtmp
}

define i32 @_triple(i32 %0) {
entry:
  %addtmp = add i32 %0, %0
  %addtmp1 = add i32 %addtmp, %0
  ret i32 %addtmp1
}

define i32 @_inc(i32 %0) {
entry:
  %addtmp = add i32 %0, 1
  ret i32 %addtmp
}

define i32 @_main() {
entry:
  %calltmp = call i32 @_triple(i32 2)
  %calltmp1 = call i32 @_double(i32 %calltmp)
  %calltmp2 = call i32 @_inc(i32 %calltmp1)
  ret i32 %calltmp2
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
