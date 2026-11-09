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

define i32 @"_\ED\95\A9\EA\B3\84"(i32 %0, i32 %1) {
entry:
  br label %forcond

forcond:                                          ; preds = %loop, %entry
  %"\ED\95\AD_ptr.0" = phi i32 [ %0, %entry ], [ %next_i, %loop ]
  %"\EA\B2\B0\EA\B3\BC.0" = phi i32 [ 0, %entry ], [ %addtmp, %loop ]
  %cond = icmp sle i32 %"\ED\95\AD_ptr.0", %1
  br i1 %cond, label %loop, label %afterloop

loop:                                             ; preds = %forcond
  %addtmp = add i32 %"\EA\B2\B0\EA\B3\BC.0", %"\ED\95\AD_ptr.0"
  %next_i = add i32 %"\ED\95\AD_ptr.0", 1
  br label %forcond

afterloop:                                        ; preds = %forcond
  ret i32 %"\EA\B2\B0\EA\B3\BC.0"
}

define i32 @_main() {
entry:
  %calltmp = call i32 @"_\ED\95\A9\EA\B3\84"(i32 1, i32 4)
  ret i32 %calltmp
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
