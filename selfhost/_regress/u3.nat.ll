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

define i32 @_max3(i32 %0, i32 %1, i32 %2) {
entry:
  %gttmp = icmp sgt i32 %1, %0
  br i1 %gttmp, label %then, label %ifcont

then:                                             ; preds = %entry
  br label %ifcont

ifcont:                                           ; preds = %then, %entry
  %m.0 = phi i32 [ %1, %then ], [ %0, %entry ]
  %gttmp3 = icmp sgt i32 %2, %m.0
  br i1 %gttmp3, label %then4, label %ifcont5

then4:                                            ; preds = %ifcont
  br label %ifcont5

ifcont5:                                          ; preds = %then4, %ifcont
  %m.1 = phi i32 [ %2, %then4 ], [ %m.0, %ifcont ]
  ret i32 %m.1
}

define i32 @_main() {
entry:
  %calltmp = call i32 @_max3(i32 3, i32 9, i32 5)
  %eqtmp = icmp eq i32 %calltmp, 9
  br i1 %eqtmp, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  %calltmp1 = call i32 @_max3(i32 7, i32 2, i32 4)
  %eqtmp2 = icmp eq i32 %calltmp1, 7
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %and_result.0 = phi i1 [ %eqtmp2, %and_rhs ], [ false, %entry ]
  br i1 %and_result.0, label %then, label %ifcont

then:                                             ; preds = %and_end
  ret i32 0

ifcont:                                           ; preds = %and_end
  ret i32 1
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
