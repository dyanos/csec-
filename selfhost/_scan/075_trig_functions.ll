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
  %math.call = call double @csec_math_sin(double 0.000000e+00)
  %math.call1 = call double @csec_math_cos(double 0.000000e+00)
  %math.call2 = call double @csec_math_tan(double 0.000000e+00)
  %math.call3 = call double @csec_math_asin(double 0.000000e+00)
  %math.call4 = call double @csec_math_acos(double 0.000000e+00)
  %math.call5 = call double @csec_math_atan(double 0.000000e+00)
  %math.call6 = call double @csec_math_sinh(double 0.000000e+00)
  %math.call7 = call double @csec_math_cosh(double 0.000000e+00)
  %math.call8 = call double @csec_math_tanh(double 0.000000e+00)
  %math.call9 = call double @csec_math_cot(double 0.000000e+00)
  %math.call10 = call double @csec_math_sec(double 0.000000e+00)
  %math.call11 = call double @csec_math_csc(double 0.000000e+00)
  ret i32 0
}

declare double @csec_math_sin(double)

declare double @csec_math_cos(double)

declare double @csec_math_tan(double)

declare double @csec_math_asin(double)

declare double @csec_math_acos(double)

declare double @csec_math_atan(double)

declare double @csec_math_sinh(double)

declare double @csec_math_cosh(double)

declare double @csec_math_tanh(double)

declare double @csec_math_cot(double)

declare double @csec_math_sec(double)

declare double @csec_math_csc(double)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
