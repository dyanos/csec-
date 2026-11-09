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
  %math.call = call double @csec_math_frac(double 1.000000e+00, double 2.000000e+00)
  %math.call1 = call double @csec_math_frac(double 1.000000e+00, double 3.000000e+00)
  %faddtmp = fadd double %math.call, %math.call1
  %math.call2 = call double @csec_math_frac(double 1.000000e+00, double 4.000000e+00)
  %math.call3 = call double @csec_math_frac(double %faddtmp, double %math.call2)
  %i_ptr = alloca i32, align 4
  store i32 1, ptr %i_ptr, align 4
  br label %forcond

forcond:                                          ; preds = %loop, %entry
  %i = load i32, ptr %i_ptr, align 4
  %cond = icmp sle i32 %i, 0
  br i1 %cond, label %loop, label %afterloop

loop:                                             ; preds = %forcond
  %i.load = load float, ptr %i_ptr, align 4
  %i.load4 = load float, ptr %i_ptr, align 4
  %faddtmp5 = fadd float %i.load4, 1.000000e+00
  %math.fpext = fpext float %faddtmp5 to double
  %math.call6 = call double @csec_math_frac(double 0.000000e+00, double %math.fpext)
  %i7 = load i32, ptr %i_ptr, align 4
  %next_i = add i32 %i7, 1
  store i32 %next_i, ptr %i_ptr, align 4
  br label %forcond

afterloop:                                        ; preds = %forcond
  %math.call8 = call double @csec_math_frac(double 0.000000e+00, double 4.000000e+00)
  %math.call9 = call double @csec_math_sin(double %math.call8)
  %trigExpr = alloca double, align 8
  store double %math.call9, ptr %trigExpr, align 8
  %math.call10 = call double @csec_math_sqrt(double 0.000000e+00)
  %rootSum = alloca double, align 8
  store double %math.call10, ptr %rootSum, align 8
  %mixed = alloca double, align 8
  store double poison, ptr %mixed, align 8
  ret i32 0
}

declare double @csec_math_frac(double, double)

declare double @csec_math_sin(double)

declare double @csec_math_sqrt(double)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
