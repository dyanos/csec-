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

define double @_floorPositive(double %0) {
entry:
  %getmp = fcmp oge double %0, 0.000000e+00
  br i1 %getmp, label %then, label %ifcont

then:                                             ; preds = %entry
  br label %whilecond

ifcont:                                           ; preds = %entry
  ret double -1.000000e+00

whilecond:                                        ; preds = %whilebody, %then
  %whole.0 = phi double [ 0.000000e+00, %then ], [ %faddtmp3, %whilebody ]
  %faddtmp = fadd double %whole.0, 1.000000e+00
  %letmp = fcmp ole double %faddtmp, %0
  br i1 %letmp, label %whilebody, label %afterwhile

whilebody:                                        ; preds = %whilecond
  %faddtmp3 = fadd double %whole.0, 1.000000e+00
  br label %whilecond

afterwhile:                                       ; preds = %whilecond
  ret double %whole.0
}

define i32 @_main() {
entry:
  %calltmp = call double @_floorPositive(double 0x400F333340000000)
  %eqtmp = fcmp oeq double %calltmp, 3.000000e+00
  br i1 %eqtmp, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  %calltmp1 = call double @_floorPositive(double -2.000000e+00)
  %eqtmp2 = fcmp oeq double %calltmp1, -1.000000e+00
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %and_result.0 = phi i1 [ %eqtmp2, %and_rhs ], [ false, %entry ]
  br i1 %and_result.0, label %then, label %ifcont

then:                                             ; preds = %and_end
  ret i32 0

ifcont:                                           ; preds = %and_end
  ret i32 1
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
