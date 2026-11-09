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

define i32 @_classify(i32 %0) {
entry:
  %lttmp = icmp slt i32 %0, 0
  br i1 %lttmp, label %then, label %ifcont

then:                                             ; preds = %entry
  ret i32 -1

ifcont:                                           ; preds = %entry
  %eqtmp = icmp eq i32 %0, 0
  br i1 %eqtmp, label %then1, label %ifcont2

then1:                                            ; preds = %ifcont
  ret i32 0

ifcont2:                                          ; preds = %ifcont
  %lttmp3 = icmp slt i32 %0, 10
  br i1 %lttmp3, label %then4, label %ifcont5

then4:                                            ; preds = %ifcont2
  ret i32 1

ifcont5:                                          ; preds = %ifcont2
  %lttmp6 = icmp slt i32 %0, 100
  br i1 %lttmp6, label %then7, label %ifcont8

then7:                                            ; preds = %ifcont5
  ret i32 2

ifcont8:                                          ; preds = %ifcont5
  ret i32 3
}

define i32 @_search(i32 %0) {
entry:
  br label %whilecond

whilecond:                                        ; preds = %ifcont, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %addtmp, %ifcont ]
  %lttmp = icmp slt i32 %i.0, 100
  br i1 %lttmp, label %whilebody, label %afterwhile

whilebody:                                        ; preds = %whilecond
  %eqtmp = icmp eq i32 %i.0, %0
  br i1 %eqtmp, label %then, label %ifcont

afterwhile:                                       ; preds = %whilecond
  ret i32 -1

then:                                             ; preds = %whilebody
  ret i32 %i.0

ifcont:                                           ; preds = %whilebody
  %addtmp = add i32 %i.0, 1
  br label %whilecond
}

define i32 @_main() {
entry:
  %calltmp = call i32 @_classify(i32 -5)
  %calltmp1 = call i32 @_classify(i32 0)
  %calltmp2 = call i32 @_classify(i32 5)
  %calltmp3 = call i32 @_classify(i32 50)
  %calltmp4 = call i32 @_classify(i32 500)
  %calltmp5 = call i32 @_search(i32 42)
  %addtmp = add i32 %calltmp, %calltmp1
  %addtmp6 = add i32 %addtmp, %calltmp2
  %addtmp7 = add i32 %addtmp6, %calltmp3
  %addtmp8 = add i32 %addtmp7, %calltmp4
  %addtmp9 = add i32 %addtmp8, %calltmp5
  ret i32 %addtmp9
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
