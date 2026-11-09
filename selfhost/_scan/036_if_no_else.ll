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

define i32 @_abs(i32 %0) {
entry:
  %lttmp = icmp slt i32 %0, 0
  br i1 %lttmp, label %then, label %ifcont

then:                                             ; preds = %entry
  %subtmp = sub i32 0, %0
  ret i32 %subtmp

ifcont:                                           ; preds = %entry
  ret i32 %0
}

define i32 @_clamp(i32 %0) {
entry:
  %gttmp = icmp sgt i32 %0, 100
  br i1 %gttmp, label %then, label %ifcont

then:                                             ; preds = %entry
  ret i32 100

ifcont:                                           ; preds = %entry
  %lttmp = icmp slt i32 %0, 0
  br i1 %lttmp, label %then1, label %ifcont2

then1:                                            ; preds = %ifcont
  ret i32 0

ifcont2:                                          ; preds = %ifcont
  ret i32 %0
}

define i32 @_main() {
entry:
  br i1 true, label %then, label %ifcont

then:                                             ; preds = %entry
  br label %ifcont

ifcont:                                           ; preds = %then, %entry
  %calltmp = call i32 @_abs(i32 -5)
  %calltmp1 = call i32 @_clamp(i32 200)
  %addtmp = add i32 %calltmp, %calltmp1
  ret i32 %addtmp
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
