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

define i32 @_main() {
entry:
  %calltmp = call i32 @"MathUtils#max"(i32 10, i32 20)
  %calltmp1 = call i32 @"MathUtils#min"(i32 10, i32 20)
  %calltmp2 = call i32 @"MathUtils#abs"(i32 -5)
  %calltmp3 = call i32 @"MathUtils#clamp"(i32 50, i32 0, i32 100)
  %addtmp = add i32 %calltmp, %calltmp1
  %addtmp4 = add i32 %addtmp, %calltmp2
  %addtmp5 = add i32 %addtmp4, %calltmp3
  ret i32 %addtmp5
}

define i32 @"StringUtils#length"(ptr %0) {
entry:
  ret i32 0
}

define i1 @"StringUtils#isEmpty"(ptr %0) {
entry:
  ret i1 false
}

define ptr @"StringUtils#concat"(ptr %0, ptr %1) {
entry:
  ret ptr %0
}

define i32 @"MathUtils#max"(i32 %0, i32 %1) {
entry:
  %gttmp = icmp sgt i32 %0, %1
  br i1 %gttmp, label %then, label %else

then:                                             ; preds = %entry
  ret i32 %0

else:                                             ; preds = %entry
  ret i32 %1

ifcont:                                           ; No predecessors!
  ret i32 0
}

define i32 @"MathUtils#min"(i32 %0, i32 %1) {
entry:
  %lttmp = icmp slt i32 %0, %1
  br i1 %lttmp, label %then, label %else

then:                                             ; preds = %entry
  ret i32 %0

else:                                             ; preds = %entry
  ret i32 %1

ifcont:                                           ; No predecessors!
  ret i32 0
}

define i32 @"MathUtils#abs"(i32 %0) {
entry:
  %lttmp = icmp slt i32 %0, 0
  br i1 %lttmp, label %then, label %ifcont

then:                                             ; preds = %entry
  %subtmp = sub i32 0, %0
  ret i32 %subtmp

ifcont:                                           ; preds = %entry
  ret i32 %0
}

define i32 @"MathUtils#clamp"(i32 %0, i32 %1, i32 %2) {
entry:
  %lttmp = icmp slt i32 %0, %1
  br i1 %lttmp, label %then, label %ifcont

then:                                             ; preds = %entry
  ret i32 %1

ifcont:                                           ; preds = %entry
  %gttmp = icmp sgt i32 %0, %2
  br i1 %gttmp, label %then1, label %ifcont2

then1:                                            ; preds = %ifcont
  ret i32 %2

ifcont2:                                          ; preds = %ifcont
  ret i32 %0
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
