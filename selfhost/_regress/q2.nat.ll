; ModuleID = 'main'
source_filename = "main"

%Point = type { float, double }

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

define double @Point_sumParts(ptr %this) {
entry:
  %x.field = getelementptr inbounds %Point, ptr %this, i32 0, i32 0
  %y.field = getelementptr inbounds %Point, ptr %this, i32 0, i32 1
  %y.load = load double, ptr %y.field, align 8
  ret double %y.load
}

define i32 @_main() {
entry:
  %newobj.malloc = call ptr @malloc(i64 16)
  %x.init = getelementptr inbounds %Point, ptr %newobj.malloc, i32 0, i32 0
  store float 1.500000e+00, ptr %x.init, align 4
  %y.init = getelementptr inbounds %Point, ptr %newobj.malloc, i32 0, i32 1
  store double 2.500000e+00, ptr %y.init, align 8
  %calltmp = call double @Point_sumParts(ptr %newobj.malloc)
  %gttmp = fcmp ogt double %calltmp, 0x4003333340000000
  br i1 %gttmp, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  %lttmp = fcmp olt double %calltmp, 0x4004CCCCC0000000
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %and_result.0 = phi i1 [ %lttmp, %and_rhs ], [ false, %entry ]
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
