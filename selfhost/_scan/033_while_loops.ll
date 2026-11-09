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
  br label %whilecond

whilecond:                                        ; preds = %whilebody, %entry
  %total.0 = phi i32 [ 0, %entry ], [ %addtmp, %whilebody ]
  %i.0 = phi i32 [ 0, %entry ], [ %addtmp5, %whilebody ]
  %lttmp = icmp slt i32 %i.0, 5
  br i1 %lttmp, label %whilebody, label %afterwhile

whilebody:                                        ; preds = %whilecond
  %addtmp = add i32 %total.0, %i.0
  %addtmp5 = add i32 %i.0, 1
  br label %whilecond

afterwhile:                                       ; preds = %whilecond
  ret i32 %total.0
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
