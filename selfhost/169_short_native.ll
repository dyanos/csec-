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

define i16 @_second(ptr %0) {
entry:
  %arrayelem = getelementptr i16, ptr %0, i32 1
  %arrayload = load i16, ptr %arrayelem, align 2
  ret i16 %arrayload
}

define i32 @_main() {
entry:
  %Short = alloca i16, i32 2, align 2
  %arrayelem = getelementptr i16, ptr %Short, i32 0
  %arrayload = load i16, ptr %arrayelem, align 2
  %arrayelem.addr = getelementptr i16, ptr %Short, i32 0
  store i16 1024, ptr %arrayelem.addr, align 2
  %arrayelem1 = getelementptr i16, ptr %Short, i32 1
  %arrayload2 = load i16, ptr %arrayelem1, align 2
  %arrayelem.addr3 = getelementptr i16, ptr %Short, i32 1
  store i16 2048, ptr %arrayelem.addr3, align 2
  %calltmp = call ptr @_identity(ptr %Short)
  %calltmp4 = call i16 @_second(ptr %calltmp)
  %num.sext = sext i16 %calltmp4 to i64
  %eqtmp = icmp eq i64 %num.sext, 2048
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
