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

define double @_eulerSolve(ptr %0, double %1, double %2, double %3, i32 %4) {
entry:
  br label %whilecond

whilecond:                                        ; preds = %whilebody, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %addtmp, %whilebody ]
  %y.0 = phi double [ %2, %entry ], [ %faddtmp, %whilebody ]
  %t.0 = phi double [ %1, %entry ], [ %faddtmp5, %whilebody ]
  %lttmp = icmp slt i32 %i.0, %4
  br i1 %lttmp, label %whilebody, label %afterwhile

whilebody:                                        ; preds = %whilecond
  %closure.code = getelementptr inbounds { ptr, ptr }, ptr %0, i32 0, i32 0
  %closure.code.fn = load ptr, ptr %closure.code, align 8
  %closure.env = getelementptr inbounds { ptr, ptr }, ptr %0, i32 0, i32 1
  %closure.env.ptr = load ptr, ptr %closure.env, align 8
  %closure.call = call double %closure.code.fn(ptr %closure.env.ptr, double %t.0, double %y.0)
  %fmultmp = fmul double %3, %closure.call
  %faddtmp = fadd double %y.0, %fmultmp
  %faddtmp5 = fadd double %t.0, %3
  %addtmp = add i32 %i.0, 1
  br label %whilecond

afterwhile:                                       ; preds = %whilecond
  ret double %y.0
}

define double @_decay(double %0, double %1) {
entry:
  %fsubtmp = fsub double 0.000000e+00, %1
  ret double %fsubtmp
}

define i32 @_main() {
entry:
  %calltmp = call double @_eulerSolve(ptr @_decay, double 0.000000e+00, double 1.000000e+00, double 0x3F847AE140000000, i32 100)
  %lttmp = fcmp olt double %calltmp, 1.000000e+00
  br i1 %lttmp, label %then, label %ifcont

then:                                             ; preds = %entry
  ret i32 0

ifcont:                                           ; preds = %entry
  ret i32 1
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
