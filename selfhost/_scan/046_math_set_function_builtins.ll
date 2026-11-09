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
  %setunion = or i64 10, 4
  %math.call = call double @csec_math_abs(double -7.500000e+00)
  %a = alloca double, align 8
  store double %math.call, ptr %a, align 8
  %math.call1 = call double @csec_math_sign(double -9.000000e+00)
  %math.call2 = call double @csec_math_sign(double 0.000000e+00)
  %math.call3 = call double @csec_math_sign(double 1.200000e+01)
  %math.call4 = call double @csec_math_floor(double 0x400F333340000000)
  %math.call5 = call double @csec_math_ceil(double 0x4008CCCCC0000000)
  %math.call6 = call double @csec_math_round(double 0x400CCCCCC0000000)
  %math.call7 = call double @csec_math_lcm(double 1.200000e+01, double 1.800000e+01)
  %approx.abs = call double @csec_math_abs(double 0.000000e+00)
  %approx.eq = fcmp ole double %approx.abs, 0x3EB0C6F7A0000000
  %set.cardinality = call i64 @csec_set_cardinality(i64 10)
  %set.cardinality9 = call i64 @csec_set_cardinality(i64 30)
  %set.overlap = and i64 10, 20
  %set.disjoint = icmp eq i64 %set.overlap, 0
  %set.overlap12 = and i64 10, %setunion
  %set.disjoint13 = icmp eq i64 %set.overlap12, 0
  %set.not = xor i64 10, -1
  %set.complement = and i64 30, %set.not
  %a.load = load ptr, ptr %a, align 8
  ret i32 1
}

declare double @csec_math_abs(double)

declare double @csec_math_sign(double)

declare double @csec_math_floor(double)

declare double @csec_math_ceil(double)

declare double @csec_math_round(double)

declare double @csec_math_lcm(double, double)

declare i64 @csec_set_cardinality(i64)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
