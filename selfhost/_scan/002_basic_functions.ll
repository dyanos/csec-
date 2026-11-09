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

define i32 @_add(i32 %0, i32 %1) {
entry:
  %addtmp = add i32 %0, %1
  ret i32 %addtmp
}

define i32 @_sub(i32 %0, i32 %1) {
entry:
  %subtmp = sub i32 %0, %1
  ret i32 %subtmp
}

define i32 @_mul(i32 %0, i32 %1) {
entry:
  %multmp = mul i32 %0, %1
  ret i32 %multmp
}

define i32 @_main() {
entry:
  %calltmp = call i32 @_add(i32 4, i32 5)
  %calltmp2 = call i32 @_sub(i32 10, i32 3)
  %addtmp = add i32 %calltmp, %calltmp2
  %calltmp5 = call i32 @_mul(i32 2, i32 3)
  %addtmp6 = add i32 %addtmp, %calltmp5
  ret i32 %addtmp6
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
