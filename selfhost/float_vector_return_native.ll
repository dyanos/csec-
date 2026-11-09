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

define ptr @_identity(ptr %0) {
entry:
  ret ptr %0
}

define i32 @_main() {
entry:
  %Float = alloca float, i32 2, align 4
  %arrayelem = getelementptr float, ptr %Float, i32 0
  %arrayload = load float, ptr %arrayelem, align 4
  %arrayelem.addr = getelementptr float, ptr %Float, i32 0
  store float 1.250000e+00, ptr %arrayelem.addr, align 4
  %arrayelem1 = getelementptr float, ptr %Float, i32 1
  %arrayload2 = load float, ptr %arrayelem1, align 4
  %arrayelem.addr3 = getelementptr float, ptr %Float, i32 1
  store float 2.500000e+00, ptr %arrayelem.addr3, align 4
  %calltmp = call ptr @_identity(ptr %Float)
  %arrayelem4 = getelementptr float, ptr %calltmp, i32 0
  %arrayload5 = load float, ptr %arrayelem4, align 4
  %arrayelem7 = getelementptr float, ptr %calltmp, i32 1
  %arrayload8 = load float, ptr %arrayelem7, align 4
  %faddtmp = fadd float %arrayload5, %arrayload8
  %eqtmp = fcmp oeq float %faddtmp, 3.750000e+00
  %ifcond = icmp ne i1 %eqtmp, false
  br i1 %ifcond, label %then, label %ifcont

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
