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
  %math.call = call double @csec_math_frac(double 0.000000e+00, double 0.000000e+00)
  %math.call1 = call double @csec_math_sqrt(double 0.000000e+00)
  %arrlit = alloca float, i32 2, align 4
  %0 = getelementptr float, ptr %arrlit, i32 0
  store float 1.000000e+00, ptr %0, align 4
  %1 = getelementptr float, ptr %arrlit, i32 1
  store float 0.000000e+00, ptr %1, align 4
  %arrlit2 = alloca ptr, i32 2, align 8
  %2 = getelementptr ptr, ptr %arrlit2, i32 0
  store ptr %arrlit, ptr %2, align 8
  %arrlit3 = alloca float, i32 2, align 4
  %3 = getelementptr float, ptr %arrlit3, i32 0
  store float 0.000000e+00, ptr %3, align 4
  %4 = getelementptr float, ptr %arrlit3, i32 1
  store float 1.000000e+00, ptr %4, align 4
  %5 = getelementptr ptr, ptr %arrlit2, i32 1
  store ptr %arrlit3, ptr %5, align 8
  ret i32 0
}

declare double @csec_math_frac(double, double)

declare double @csec_math_sqrt(double)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
