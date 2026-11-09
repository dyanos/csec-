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
  %math.call3 = call double @csec_math_sqrt(double 9.000000e+00)
  %math.call4 = call double @csec_math_pow(double 2.000000e+00, double 8.000000e+00)
  %math.call5 = call double @csec_math_log_base(double 2.000000e+00, double 8.000000e+00)
  %math.call6 = call double @csec_math_exp(double 1.000000e+00)
  %math.call7 = call double @csec_math_log(double %math.call6)
  %math.call8 = call double @csec_math_log10(double 1.000000e+02)
  %math.fold = call double @csec_math_min(double 3.000000e+00, double 2.500000e+00)
  %math.fold9 = call double @csec_math_min(double %math.fold, double 8.000000e+00)
  %math.fold10 = call double @csec_math_max(double 3.000000e+00, double 2.500000e+00)
  %math.fold11 = call double @csec_math_max(double %math.fold10, double 8.000000e+00)
  %math.fold12 = call double @csec_math_gcd(double 8.400000e+01, double 1.800000e+01)
  %math.call13 = call double @csec_math_frac(double 1.000000e+00, double 2.000000e+00)
  %math.call14 = call double @csec_math_binom(double 5.000000e+00, double 2.000000e+00)
  %math.call15 = call double @csec_math_cot(double 1.000000e+00)
  %math.call16 = call double @csec_math_sec(double 1.000000e+00)
  %faddtmp = fadd double %math.call15, %math.call16
  %math.call17 = call double @csec_math_csc(double 1.000000e+00)
  %faddtmp18 = fadd double %faddtmp, %math.call17
  %math.call19 = call double @csec_math_coth(double 1.000000e+00)
  %faddtmp20 = fadd double %faddtmp18, %math.call19
  %math.call21 = call double @csec_math_asin(double 5.000000e-01)
  %math.call22 = call double @csec_math_acos(double 5.000000e-01)
  %faddtmp23 = fadd double %math.call21, %math.call22
  %math.call24 = call double @csec_math_atan(double 1.000000e+00)
  %faddtmp25 = fadd double %faddtmp23, %math.call24
  %math.call26 = call double @csec_math_sinh(double 1.000000e+00)
  %math.call27 = call double @csec_math_cosh(double 1.000000e+00)
  %faddtmp28 = fadd double %math.call26, %math.call27
  %math.call29 = call double @csec_math_tanh(double 1.000000e+00)
  %faddtmp30 = fadd double %faddtmp28, %math.call29
  %faddtmp31 = fadd double %math.call, %math.call1
  %faddtmp32 = fadd double %faddtmp31, %math.call2
  %faddtmp33 = fadd double %faddtmp32, %math.call3
  %faddtmp34 = fadd double %faddtmp33, %math.call4
  %faddtmp35 = fadd double %faddtmp34, %math.call5
  %faddtmp36 = fadd double %faddtmp35, %math.call7
  %faddtmp37 = fadd double %faddtmp36, %math.call8
  %faddtmp38 = fadd double %faddtmp37, %math.fold9
  %faddtmp39 = fadd double %faddtmp38, %math.fold11
  %faddtmp40 = fadd double %faddtmp39, %math.fold12
  %faddtmp41 = fadd double %faddtmp40, %math.call13
  %faddtmp42 = fadd double %faddtmp41, %math.call14
  %faddtmp43 = fadd double %faddtmp42, %faddtmp20
  %faddtmp44 = fadd double %faddtmp43, %faddtmp25
  %faddtmp45 = fadd double %faddtmp44, %faddtmp30
  call void @csec_print_double(double %faddtmp45)
  call void @csec_print_newline()
  ret i32 0
}

declare double @csec_math_sin(double)

declare double @csec_math_cos(double)

declare double @csec_math_tan(double)

declare double @csec_math_sqrt(double)

declare double @csec_math_pow(double, double)

declare double @csec_math_log_base(double, double)

declare double @csec_math_exp(double)

declare double @csec_math_log(double)

declare double @csec_math_log10(double)

declare double @csec_math_min(double, double)

declare double @csec_math_max(double, double)

declare double @csec_math_gcd(double, double)

declare double @csec_math_frac(double, double)

declare double @csec_math_binom(double, double)

declare double @csec_math_cot(double)

declare double @csec_math_sec(double)

declare double @csec_math_csc(double)

declare double @csec_math_coth(double)

declare double @csec_math_asin(double)

declare double @csec_math_acos(double)

declare double @csec_math_atan(double)

declare double @csec_math_sinh(double)

declare double @csec_math_cosh(double)

declare double @csec_math_tanh(double)

declare void @csec_print_double(double)

declare void @csec_print_newline()

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
