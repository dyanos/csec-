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

define double @_sum(ptr %0) {
entry:
  %arrayelem = getelementptr double, ptr %0, i32 0
  %arrayload = load double, ptr %arrayelem, align 8
  %arrayelem1 = getelementptr double, ptr %0, i32 1
  %arrayload2 = load double, ptr %arrayelem1, align 8
  %faddtmp = fadd double %arrayload, %arrayload2
  %arrayelem3 = getelementptr double, ptr %0, i32 2
  %arrayload4 = load double, ptr %arrayelem3, align 8
  %faddtmp5 = fadd double %faddtmp, %arrayload4
  ret double %faddtmp5
}

define i32 @_main() {
entry:
  %Double = call ptr @malloc(i64 24)
  %arrayelem = getelementptr double, ptr %Double, i32 0
  %arrayload = load double, ptr %arrayelem, align 8
  %arrayelem.addr = getelementptr double, ptr %Double, i32 0
  store double 1.250000e+00, ptr %arrayelem.addr, align 8
  %arrayelem1 = getelementptr double, ptr %Double, i32 1
  %arrayload2 = load double, ptr %arrayelem1, align 8
  %arrayelem.addr3 = getelementptr double, ptr %Double, i32 1
  store double 2.500000e+00, ptr %arrayelem.addr3, align 8
  %arrayelem4 = getelementptr double, ptr %Double, i32 2
  %arrayload5 = load double, ptr %arrayelem4, align 8
  %arrayelem.addr6 = getelementptr double, ptr %Double, i32 2
  store double 3.750000e+00, ptr %arrayelem.addr6, align 8
  %calltmp = call double @_sum(ptr %Double)
  %eqtmp = fcmp oeq double %calltmp, 7.500000e+00
  br i1 %eqtmp, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  %arrayelem7 = getelementptr double, ptr %Double, i32 0
  %arrayload8 = load double, ptr %arrayelem7, align 8
  %arrayelem9 = getelementptr double, ptr %Double, i32 1
  %arrayload10 = load double, ptr %arrayelem9, align 8
  %faddtmp = fadd double %arrayload8, %arrayload10
  %eqtmp11 = fcmp oeq double %faddtmp, 3.750000e+00
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %and_result.0 = phi i1 [ %eqtmp11, %and_rhs ], [ false, %entry ]
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
