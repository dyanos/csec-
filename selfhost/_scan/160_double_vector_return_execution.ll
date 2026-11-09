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
  %Double = call ptr @malloc(i64 16)
  %arrayelem = getelementptr double, ptr %Double, i32 0
  %arrayload = load double, ptr %arrayelem, align 8
  %arrayelem.addr = getelementptr double, ptr %Double, i32 0
  store double 1.250000e+00, ptr %arrayelem.addr, align 8
  %arrayelem1 = getelementptr double, ptr %Double, i32 1
  %arrayload2 = load double, ptr %arrayelem1, align 8
  %arrayelem.addr3 = getelementptr double, ptr %Double, i32 1
  store double 2.500000e+00, ptr %arrayelem.addr3, align 8
  %calltmp = call ptr @_identity(ptr %Double)
  %arrayelem4 = getelementptr double, ptr %calltmp, i32 0
  %arrayload5 = load double, ptr %arrayelem4, align 8
  %arrayelem6 = getelementptr double, ptr %calltmp, i32 1
  %arrayload7 = load double, ptr %arrayelem6, align 8
  %faddtmp = fadd double %arrayload5, %arrayload7
  %eqtmp = fcmp oeq double %faddtmp, 3.750000e+00
  br i1 %eqtmp, label %then, label %ifcont

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
