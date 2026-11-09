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

define i32 @_main() {
entry:
  %calltmp = call i32 @"_identity$Int"(i32 1)
  %calltmp1 = call float @"_identity$Float"(float 0x40091EB860000000)
  %calltmp2 = call double @"_identity$Double"(double 0x4005BE76C0000000)
  %calltmp3 = call i1 @"_identity$Boolean"(i1 true)
  %calltmp4 = call ptr @"_identity$String"(ptr @0)
  %calltmp5 = call i64 @"_identity$Long"(i64 999)
  ret i32 %calltmp
}

define i32 @"_identity$Int"(i32 %0) {
entry:
  ret i32 %0
}

define float @"_identity$Float"(float %0) {
entry:
  ret float %0
}

define double @"_identity$Double"(double %0) {
entry:
  ret double %0
}

define i1 @"_identity$Boolean"(i1 %0) {
entry:
  ret i1 %0
}

define ptr @"_identity$String"(ptr %0) {
entry:
  ret ptr %0
}

define i64 @"_identity$Long"(i64 %0) {
entry:
  ret i64 %0
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
