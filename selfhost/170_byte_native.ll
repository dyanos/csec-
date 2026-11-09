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

define i8 @_second(ptr %0) {
entry:
  %arrayelem = getelementptr i8, ptr %0, i32 1
  %arrayload = load i8, ptr %arrayelem, align 1
  ret i8 %arrayload
}

define i32 @_main() {
entry:
  %Byte = alloca i8, i32 2, align 1
  %arrayelem = getelementptr i8, ptr %Byte, i32 0
  %arrayload = load i8, ptr %arrayelem, align 1
  %arrayelem.addr = getelementptr i8, ptr %Byte, i32 0
  store i8 6, ptr %arrayelem.addr, align 1
  %arrayelem1 = getelementptr i8, ptr %Byte, i32 1
  %arrayload2 = load i8, ptr %arrayelem1, align 1
  %arrayelem.addr3 = getelementptr i8, ptr %Byte, i32 1
  store i8 42, ptr %arrayelem.addr3, align 1
  %calltmp = call i8 @_second(ptr %Byte)
  %num.sext = sext i8 %calltmp to i64
  %eqtmp = icmp eq i64 %num.sext, 42
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
