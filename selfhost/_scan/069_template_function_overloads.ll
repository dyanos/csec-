; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [6 x i8] c"hello\00", align 1
@1 = private unnamed_addr constant [6 x i8] c"world\00", align 1

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
  %calltmp = call i32 @"_first$Int"(i32 1, i32 2)
  %calltmp1 = call i32 @"_second$Int"(i32 1, i32 2)
  %calltmp2 = call ptr @"_first$String"(ptr @0, ptr @1)
  %calltmp3 = call float @"_second$Float"(float 1.000000e+00, float 2.000000e+00)
  %addtmp = add i32 %calltmp, %calltmp1
  ret i32 %addtmp
}

define i32 @"_first$Int"(i32 %0, i32 %1) {
entry:
  ret i32 %0
}

define i32 @"_second$Int"(i32 %0, i32 %1) {
entry:
  ret i32 %1
}

define ptr @"_first$String"(ptr %0, ptr %1) {
entry:
  ret ptr %0
}

define float @"_second$Float"(float %0, float %1) {
entry:
  ret float %1
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
