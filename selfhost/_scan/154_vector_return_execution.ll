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
  %arrlit = alloca i32, i32 3, align 4
  %0 = getelementptr i32, ptr %arrlit, i32 0
  store i32 7, ptr %0, align 4
  %1 = getelementptr i32, ptr %arrlit, i32 1
  store i32 11, ptr %1, align 4
  %2 = getelementptr i32, ptr %arrlit, i32 2
  store i32 13, ptr %2, align 4
  %calltmp = call ptr @_identity(ptr %arrlit)
  %arrayelem = getelementptr i32, ptr %calltmp, i32 1
  %arrayload = load i32, ptr %arrayelem, align 4
  %eqtmp = icmp eq i32 %arrayload, 11
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
