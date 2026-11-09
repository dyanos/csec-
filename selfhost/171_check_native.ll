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

define i64 @_second(ptr %0) {
entry:
  %arrayelem = getelementptr i64, ptr %0, i32 1
  %arrayload = load i64, ptr %arrayelem, align 4
  ret i64 %arrayload
}

define i32 @_main() {
entry:
  %Long = alloca i64, i32 2, align 8
  %arrayelem = getelementptr i64, ptr %Long, i32 0
  %arrayload = load i64, ptr %arrayelem, align 4
  %arrayelem.addr = getelementptr i64, ptr %Long, i32 0
  store i64 2147483648, ptr %arrayelem.addr, align 4
  %arrayelem1 = getelementptr i64, ptr %Long, i32 1
  %arrayload2 = load i64, ptr %arrayelem1, align 4
  %arrayelem.addr3 = getelementptr i64, ptr %Long, i32 1
  store i64 2147483653, ptr %arrayelem.addr3, align 4
  %calltmp = call i64 @_second(ptr %Long)
  %eqtmp = icmp eq i64 %calltmp, 2147483653
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
