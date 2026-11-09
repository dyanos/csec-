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

define double @_decay(double %0, double %1) {
entry:
  %fsubtmp = fsub double 0.000000e+00, %1
  ret double %fsubtmp
}

define i32 @_main() {
entry:
  br label %ode.euler.cond

ode.euler.cond:                                   ; preds = %ode.euler.body, %entry
  %ode.y.0 = phi double [ 1.000000e+00, %entry ], [ %ode.next.y, %ode.euler.body ]
  %ode.t.0 = phi double [ 0.000000e+00, %entry ], [ %ode.next.t, %ode.euler.body ]
  %ode.i.0 = phi i32 [ 0, %entry ], [ %ode.next.i, %ode.euler.body ]
  %ode.keep = icmp slt i32 %ode.i.0, 100
  br i1 %ode.keep, label %ode.euler.body, label %ode.euler.end

ode.euler.body:                                   ; preds = %ode.euler.cond
  %ode.dy = call double @_decay(double %ode.t.0, double %ode.y.0)
  %ode.delta = fmul double 0x3F847AE140000000, %ode.dy
  %ode.next.y = fadd double %ode.y.0, %ode.delta
  %ode.next.t = fadd double %ode.t.0, 0x3F847AE140000000
  %ode.next.i = add i32 %ode.i.0, 1
  br label %ode.euler.cond

ode.euler.end:                                    ; preds = %ode.euler.cond
  %finalValue = alloca double, align 8
  store double %ode.y.0, ptr %finalValue, align 8
  %finalValue.load = load double, ptr %finalValue, align 8
  %lttmp = fcmp olt double %finalValue.load, 1.000000e+00
  br i1 %lttmp, label %then, label %ifcont

then:                                             ; preds = %ode.euler.end
  ret i32 0

ifcont:                                           ; preds = %ode.euler.end
  ret i32 1
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
