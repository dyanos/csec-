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
  %Char = call ptr @malloc(i64 2)
  %arrayelem = getelementptr i8, ptr %Char, i32 0
  %arrayload = load i8, ptr %arrayelem, align 1
  %arrayelem.addr = getelementptr i8, ptr %Char, i32 0
  store i8 67, ptr %arrayelem.addr, align 1
  %arrayelem1 = getelementptr i8, ptr %Char, i32 1
  %arrayload2 = load i8, ptr %arrayelem1, align 1
  %arrayelem.addr3 = getelementptr i8, ptr %Char, i32 1
  store i8 68, ptr %arrayelem.addr3, align 1
  %calltmp = call ptr @_identity(ptr %Char)
  %arrayelem4 = getelementptr i8, ptr %calltmp, i32 1
  %arrayload5 = load i8, ptr %arrayelem4, align 1
  %eqtmp = icmp eq i8 %arrayload5, 68
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
