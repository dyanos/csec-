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

define i1 @_allEnabled() {
entry:
  %arrlit = alloca i1, i32 3, align 1
  %0 = getelementptr i1, ptr %arrlit, i32 0
  store i1 true, ptr %0, align 1
  %1 = getelementptr i1, ptr %arrlit, i32 1
  store i1 false, ptr %1, align 1
  %2 = getelementptr i1, ptr %arrlit, i32 2
  store i1 true, ptr %2, align 1
  %Boolean = alloca i1, i32 2, align 1
  %arrayelem = getelementptr i1, ptr %Boolean, i32 0
  %arrayload = load i1, ptr %arrayelem, align 1
  %arrayelem.addr = getelementptr i1, ptr %Boolean, i32 0
  store i1 true, ptr %arrayelem.addr, align 1
  %arrayelem1 = getelementptr i1, ptr %Boolean, i32 1
  %arrayload2 = load i1, ptr %arrayelem1, align 1
  %arrayelem.addr3 = getelementptr i1, ptr %Boolean, i32 1
  store i1 true, ptr %arrayelem.addr3, align 1
  ret i1 false
}

define i32 @_main() {
entry:
  %calltmp = call i1 @_allEnabled()
  br i1 %calltmp, label %then, label %ifcont

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
