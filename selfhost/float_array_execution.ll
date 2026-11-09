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

define float @_sum(ptr %0) {
entry:
  %arrayelem = getelementptr float, ptr %0, i32 0
  %arrayload = load float, ptr %arrayelem, align 4
  %arrayelem1 = getelementptr float, ptr %0, i32 1
  %arrayload2 = load float, ptr %arrayelem1, align 4
  %faddtmp = fadd float %arrayload, %arrayload2
  %arrayelem3 = getelementptr float, ptr %0, i32 2
  %arrayload4 = load float, ptr %arrayelem3, align 4
  %faddtmp5 = fadd float %faddtmp, %arrayload4
  ret float %faddtmp5
}

define i32 @_main() {
entry:
  %Float = alloca float, i32 3, align 4
  %arrayelem = getelementptr float, ptr %Float, i32 0
  %arrayload = load float, ptr %arrayelem, align 4
  %arrayelem.addr = getelementptr float, ptr %Float, i32 0
  store float 1.500000e+00, ptr %arrayelem.addr, align 4
  %arrayelem1 = getelementptr float, ptr %Float, i32 1
  %arrayload2 = load float, ptr %arrayelem1, align 4
  %arrayelem.addr3 = getelementptr float, ptr %Float, i32 1
  store float 2.500000e+00, ptr %arrayelem.addr3, align 4
  %arrayelem4 = getelementptr float, ptr %Float, i32 2
  %arrayload5 = load float, ptr %arrayelem4, align 4
  %arrayelem.addr6 = getelementptr float, ptr %Float, i32 2
  store float 3.500000e+00, ptr %arrayelem.addr6, align 4
  %calltmp = call float @_sum(ptr %Float)
  %eqtmp = fcmp oeq float %calltmp, 7.500000e+00
  br i1 %eqtmp, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  %arrayelem7 = getelementptr float, ptr %Float, i32 0
  %arrayload8 = load float, ptr %arrayelem7, align 4
  %arrayelem9 = getelementptr float, ptr %Float, i32 1
  %arrayload10 = load float, ptr %arrayelem9, align 4
  %faddtmp = fadd float %arrayload8, %arrayload10
  %eqtmp11 = fcmp oeq float %faddtmp, 4.000000e+00
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %and_result.0 = phi i1 [ %eqtmp11, %and_rhs ], [ false, %entry ]
  %ifcond = icmp ne i1 %and_result.0, false
  br i1 %ifcond, label %then, label %ifcont

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
