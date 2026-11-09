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
  %math.call = call double @csec_math_sqrt(double 1.600000e+01)
  %math.call1 = call double @csec_math_log(double 0.000000e+00)
  %math.call2 = call double @csec_math_log_base(double 0.000000e+00, double 0.000000e+00)
  %math.call3 = call double @csec_math_exp(double 0.000000e+00)
  %math.call4 = call double @csec_math_frac(double 1.000000e+00, double 2.000000e+00)
  %faddtmp = fadd double %math.call, %math.call1
  %fsubtmp = fsub double %math.call2, %math.call3
  %math.call5 = call double @csec_math_frac(double %faddtmp, double %fsubtmp)
  %math.call6 = call double @csec_math_binom(double 1.000000e+01, double 3.000000e+00)
  %math.call7 = call double @csec_math_sin(double 0.000000e+00)
  %math.call8 = call double @csec_math_frac(double %math.call7, double 0.000000e+00)
  %math.fold = call double @csec_math_min(double %math.call, double 0.000000e+00)
  %math.fold11 = call double @csec_math_max(double %math.call1, double 0.000000e+00)
  ret i32 0
}

declare double @csec_math_sqrt(double)

declare double @csec_math_log(double)

declare double @csec_math_log_base(double, double)

declare double @csec_math_exp(double)

declare double @csec_math_frac(double, double)

declare double @csec_math_binom(double, double)

declare double @csec_math_sin(double)

declare double @csec_math_min(double, double)

declare double @csec_math_max(double, double)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
