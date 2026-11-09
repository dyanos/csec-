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

define i32 @_zero() {
entry:
  ret i32 0
}

define i32 @_id(i32 %0) {
entry:
  ret i32 %0
}

define i32 @_add(i32 %0, i32 %1) {
entry:
  %addtmp = add i32 %0, %1
  ret i32 %addtmp
}

define i32 @_neg(i32 %0) {
entry:
  %subtmp = sub i32 0, %0
  ret i32 %subtmp
}

define ptr @_constant() {
entry:
  ret ptr @0
}

define i1 @_flag() {
entry:
  ret i1 true
}

define i32 @_main() {
entry:
  %calltmp = call i32 @_id(i32 3)
  %calltmp1 = call i32 @_neg(i32 1)
  %calltmp2 = call i32 @_add(i32 %calltmp, i32 %calltmp1)
  ret i32 %calltmp2
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
