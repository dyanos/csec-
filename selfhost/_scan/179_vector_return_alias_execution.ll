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

define ptr @_build(i32 %0) {
entry:
  %array.count = zext i32 %0 to i64
  %array.bytes = mul i64 %array.count, 4
  %Int = call ptr @malloc(i64 %array.bytes)
  %arrayelem = getelementptr i32, ptr %Int, i32 0
  %arrayload = load i32, ptr %arrayelem, align 4
  %arrayelem.addr = getelementptr i32, ptr %Int, i32 0
  store i32 40, ptr %arrayelem.addr, align 4
  %arrayelem1 = getelementptr i32, ptr %Int, i32 1
  %arrayload2 = load i32, ptr %arrayelem1, align 4
  %arrayelem.addr3 = getelementptr i32, ptr %Int, i32 1
  store i32 42, ptr %arrayelem.addr3, align 4
  ret ptr %Int
}

define i32 @_main() {
entry:
  %calltmp = call ptr @_build(i32 3)
  %arrayelem = getelementptr i32, ptr %calltmp, i32 1
  %arrayload = load i32, ptr %arrayelem, align 4
  %eqtmp = icmp eq i32 %arrayload, 42
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
