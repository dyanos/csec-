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
  %calltmp = call i32 @"MathLib#factorial"(i32 5)
  %calltmp1 = call i32 @"MathLib#fibonacci"(i32 10)
  %calltmp2 = call i32 @"MathLib#power"(i32 2, i32 8)
  %calltmp3 = call i32 @"MathLib#gcd"(i32 48, i32 18)
  %calltmp4 = call i32 @"MathLib#sumRange"(i32 1, i32 100)
  %addtmp = add i32 %calltmp, %calltmp1
  %addtmp5 = add i32 %addtmp, %calltmp2
  %addtmp6 = add i32 %addtmp5, %calltmp3
  %addtmp7 = add i32 %addtmp6, %calltmp4
  ret i32 %addtmp7
}

define i32 @"MathLib#factorial"(i32 %0) {
entry:
  %letmp = icmp sle i32 %0, 1
  br i1 %letmp, label %then, label %else

then:                                             ; preds = %entry
  ret i32 1

else:                                             ; preds = %entry
  %subtmp = sub i32 %0, 1
  %calltmp = call i32 @"MathLib#factorial"(i32 %subtmp)
  %multmp = mul i32 %0, %calltmp
  ret i32 %multmp

ifcont:                                           ; No predecessors!
  ret i32 0
}

define i32 @"MathLib#fibonacci"(i32 %0) {
entry:
  %letmp = icmp sle i32 %0, 1
  br i1 %letmp, label %then, label %else

then:                                             ; preds = %entry
  ret i32 %0

else:                                             ; preds = %entry
  %subtmp = sub i32 %0, 1
  %calltmp = call i32 @"MathLib#fibonacci"(i32 %subtmp)
  %subtmp1 = sub i32 %0, 2
  %calltmp2 = call i32 @"MathLib#fibonacci"(i32 %subtmp1)
  %addtmp = add i32 %calltmp, %calltmp2
  ret i32 %addtmp

ifcont:                                           ; No predecessors!
  ret i32 0
}

define i32 @"MathLib#power"(i32 %0, i32 %1) {
entry:
  %eqtmp = icmp eq i32 %1, 0
  br i1 %eqtmp, label %then, label %else

then:                                             ; preds = %entry
  ret i32 1

else:                                             ; preds = %entry
  %subtmp = sub i32 %1, 1
  %calltmp = call i32 @"MathLib#power"(i32 %0, i32 %subtmp)
  %multmp = mul i32 %0, %calltmp
  ret i32 %multmp

ifcont:                                           ; No predecessors!
  ret i32 0
}

define i32 @"MathLib#gcd"(i32 %0, i32 %1) {
entry:
  %eqtmp = icmp eq i32 %1, 0
  br i1 %eqtmp, label %then, label %else

then:                                             ; preds = %entry
  ret i32 %0

else:                                             ; preds = %entry
  %modtmp = srem i32 %0, %1
  %calltmp = call i32 @"MathLib#gcd"(i32 %1, i32 %modtmp)
  ret i32 %calltmp

ifcont:                                           ; No predecessors!
  ret i32 0
}

define i32 @"MathLib#sumRange"(i32 %0, i32 %1) {
entry:
  br label %forcond

forcond:                                          ; preds = %loop, %entry
  %i_ptr.0 = phi i32 [ %0, %entry ], [ %next_i, %loop ]
  %total.0 = phi i32 [ 0, %entry ], [ %addtmp, %loop ]
  %cond = icmp sle i32 %i_ptr.0, %1
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
