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

define i32 @_start() {
entry:
  ret i32 0
}

define i32 @_limit() {
entry:
  ret i32 10
}

define i32 @_main() {
entry:
  %calltmp = call i32 @_start()
  %calltmp1 = call i32 @_limit()
  br label %forcond

forcond:                                          ; preds = %loop, %entry
  %i_ptr.0 = phi i32 [ %calltmp, %entry ], [ %next_i, %loop ]
  %total.0 = phi i32 [ 0, %entry ], [ %addtmp, %loop ]
  %cond = icmp sle i32 %i_ptr.0, %calltmp1
  br i1 %cond, label %loop, label %afterloop

loop:                                             ; preds = %forcond
  %addtmp = add i32 %total.0, %i_ptr.0
  %next_i = add i32 %i_ptr.0, 1
  br label %forcond

afterloop:                                        ; preds = %forcond
  ret i32 %total.0
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
