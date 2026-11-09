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

forcond:                                          ; preds = %loop, %entry
  %i_ptr.0 = phi i32 [ 0, %entry ], [ %next_i, %loop ]
  %total.0 = phi i32 [ 0, %entry ], [ %addtmp, %loop ]
  %cond = icmp sle i32 %i_ptr.0, 5
  br i1 %cond, label %loop, label %afterloop

loop:                                             ; preds = %forcond
  %addtmp = add i32 %total.0, %i_ptr.0
  %next_i = add i32 %i_ptr.0, 1
  br label %forcond

afterloop:                                        ; preds = %forcond
  %j_ptr = alloca i32, align 4
  store i32 0, ptr %j_ptr, align 4
  br label %forcond3

forcond3:                                         ; preds = %loop4, %afterloop
  %total.1 = phi i32 [ %total.0, %afterloop ], [ %addtmp9, %loop4 ]
  %j = load i32, ptr %j_ptr, align 4
  %cond6 = icmp sle i32 %j, 4
  br i1 %cond6, label %loop4, label %afterloop5

loop4:                                            ; preds = %forcond3
  %j.load = load i32, ptr %j_ptr, align 4
  %addtmp9 = add i32 %total.1, %j.load
  %j10 = load i32, ptr %j_ptr, align 4
  %next_i11 = add i32 %j10, 1
  store i32 %next_i11, ptr %j_ptr, align 4
  br label %forcond3

afterloop5:                                       ; preds = %forcond3
  ret i32 %total.1
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
