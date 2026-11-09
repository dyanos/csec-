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

define i32 @_findWhile(i32 %0) {
entry:
  br label %whilecond

whilecond:                                        ; preds = %ifcont, %entry
  %cursor.0 = phi i32 [ 0, %entry ], [ %addtmp, %ifcont ]
  %lttmp = icmp slt i32 %cursor.0, %0
  br i1 %lttmp, label %whilebody, label %afterwhile

whilebody:                                        ; preds = %whilecond
  %eqtmp = icmp eq i32 %cursor.0, 3
  br i1 %eqtmp, label %then, label %ifcont

afterwhile:                                       ; preds = %whilecond
  ret i32 -1

then:                                             ; preds = %whilebody
  ret i32 %cursor.0

ifcont:                                           ; preds = %whilebody
  %addtmp = add i32 %cursor.0, 1
  br label %whilecond
}

define i32 @_main() {
entry:
  %calltmp = call i32 @_findWhile(i32 10)
  %eqtmp = icmp eq i32 %calltmp, 3
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
