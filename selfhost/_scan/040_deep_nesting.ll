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

forcond:                                          ; preds = %afterloop3, %entry
  %i_ptr.0 = phi i32 [ 0, %entry ], [ %next_i24, %afterloop3 ]
  %total.0 = phi i32 [ 0, %entry ], [ %total.1, %afterloop3 ]
  %cond = icmp sle i32 %i_ptr.0, 3
  br i1 %cond, label %loop, label %afterloop

loop:                                             ; preds = %forcond
  %j_ptr = alloca i32, align 4
  store i32 0, ptr %j_ptr, align 4
  br label %forcond1

afterloop:                                        ; preds = %forcond
  ret i32 %total.0

forcond1:                                         ; preds = %ifcont, %loop
  %total.1 = phi i32 [ %total.0, %loop ], [ %total.2, %ifcont ]
  %j = load i32, ptr %j_ptr, align 4
  %cond4 = icmp sle i32 %j, 3
  br i1 %cond4, label %loop2, label %afterloop3

loop2:                                            ; preds = %forcond1
  %j.load = load i32, ptr %j_ptr, align 4
  %eqtmp = icmp eq i32 %i_ptr.0, %j.load
  br i1 %eqtmp, label %then, label %else

afterloop3:                                       ; preds = %forcond1
  %next_i24 = add i32 %i_ptr.0, 1
  br label %forcond

then:                                             ; preds = %loop2
  %addtmp = add i32 %total.1, 1
  br label %ifcont

else:                                             ; preds = %loop2
  %j.load7 = load i32, ptr %j_ptr, align 4
  %lttmp = icmp slt i32 %i_ptr.0, %j.load7
  br i1 %lttmp, label %then8, label %else9

ifcont:                                           ; preds = %ifcont10, %then
  %total.2 = phi i32 [ %addtmp, %then ], [ %total.3, %ifcont10 ]
  %result21 = phi i32 [ %addtmp, %then ], [ %result, %ifcont10 ]
  %j22 = load i32, ptr %j_ptr, align 4
  %next_i = add i32 %j22, 1
  store i32 %next_i, ptr %j_ptr, align 4
  br label %forcond1

then8:                                            ; preds = %else
  %addtmp13 = add i32 %total.1, 2
  br label %ifcont10

else9:                                            ; preds = %else
  %k = alloca i32, align 4
  store i32 0, ptr %k, align 4
  br label %whilecond

ifcont10:                                         ; preds = %afterwhile, %then8
  %total.3 = phi i32 [ %addtmp13, %then8 ], [ %total.4, %afterwhile ]
  %result = phi i32 [ %addtmp13, %then8 ], [ undef, %afterwhile ]
  br label %ifcont

whilecond:                                        ; preds = %whilebody, %else9
  %total.4 = phi i32 [ %total.1, %else9 ], [ %addtmp17, %whilebody ]
  %k.load = load i32, ptr %k, align 4
  %lttmp14 = icmp slt i32 %k.load, 2
  br i1 %lttmp14, label %whilebody, label %afterwhile

whilebody:                                        ; preds = %whilecond
  %addtmp17 = add i32 %total.4, 1
  %k.load18 = load i32, ptr %k, align 4
  %k.load19 = load i32, ptr %k, align 4
  %addtmp20 = add i32 %k.load19, 1
  store i32 %addtmp20, ptr %k, align 4
  br label %whilecond

afterwhile:                                       ; preds = %whilecond
  br label %ifcont10
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
