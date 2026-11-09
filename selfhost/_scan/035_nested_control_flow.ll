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
  br label %forcond

forcond:                                          ; preds = %ifcont, %entry
  %i_ptr.0 = phi i32 [ 0, %entry ], [ %next_i, %ifcont ]
  %total.0 = phi i32 [ 0, %entry ], [ %total.1, %ifcont ]
  %cond = icmp sle i32 %i_ptr.0, 2
  br i1 %cond, label %loop, label %afterloop

loop:                                             ; preds = %forcond
  %lttmp = icmp slt i32 %i_ptr.0, 2
  br i1 %lttmp, label %then, label %else

afterloop:                                        ; preds = %forcond
  ret i32 %total.0

then:                                             ; preds = %loop
  br label %whilecond

else:                                             ; preds = %loop
  %addtmp8 = add i32 %total.0, 100
  br label %ifcont

ifcont:                                           ; preds = %else, %afterwhile
  %total.1 = phi i32 [ %total.2, %afterwhile ], [ %addtmp8, %else ]
  %result = phi i32 [ undef, %afterwhile ], [ %addtmp8, %else ]
  %next_i = add i32 %i_ptr.0, 1
  br label %forcond

whilecond:                                        ; preds = %whilebody, %then
  %total.2 = phi i32 [ %total.0, %then ], [ %addtmp5, %whilebody ]
  %lttmp1 = icmp slt i32 %total.2, 10
  br i1 %lttmp1, label %whilebody, label %afterwhile

whilebody:                                        ; preds = %whilecond
  %addtmp = add i32 %total.2, %i_ptr.0
  %addtmp5 = add i32 %addtmp, 1
  br label %whilecond

afterwhile:                                       ; preds = %whilecond
  br label %ifcont
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
