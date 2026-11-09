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
  %arrlit = alloca float, i32 2, align 4
  %0 = getelementptr float, ptr %arrlit, i32 0
  store float 1.000000e+00, ptr %0, align 4
  %1 = getelementptr float, ptr %arrlit, i32 1
  store float 2.000000e+00, ptr %1, align 4
  %arrlit1 = alloca ptr, i32 2, align 8
  %2 = getelementptr ptr, ptr %arrlit1, i32 0
  store ptr %arrlit, ptr %2, align 8
  %arrlit2 = alloca float, i32 2, align 4
  %3 = getelementptr float, ptr %arrlit2, i32 0
  store float 3.000000e+00, ptr %3, align 4
  %4 = getelementptr float, ptr %arrlit2, i32 1
  store float 4.000000e+00, ptr %4, align 4
  %5 = getelementptr ptr, ptr %arrlit1, i32 1
  store ptr %arrlit2, ptr %5, align 8
  %arrlit3 = alloca double, i32 2, align 8
  %6 = getelementptr double, ptr %arrlit3, i32 0
  store double 0.000000e+00, ptr %6, align 8
  %7 = getelementptr double, ptr %arrlit3, i32 1
  store double 0.000000e+00, ptr %7, align 8
  %arrlit4 = alloca ptr, i32 2, align 8
  %8 = getelementptr ptr, ptr %arrlit4, i32 0
  store ptr %arrlit3, ptr %8, align 8
  %arrlit5 = alloca double, i32 2, align 8
  %9 = getelementptr double, ptr %arrlit5, i32 0
  store double 0.000000e+00, ptr %9, align 8
  %10 = getelementptr double, ptr %arrlit5, i32 1
  store double 0.000000e+00, ptr %10, align 8
  %11 = getelementptr ptr, ptr %arrlit4, i32 1
  store ptr %arrlit5, ptr %11, align 8
  ret i32 0
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
