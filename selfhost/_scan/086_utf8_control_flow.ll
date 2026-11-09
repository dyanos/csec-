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

define i32 @"_\ED\94\BC\EB\B3\B4\EB\82\98\EC\B9\98"(i32 %0) {
entry:
  %letmp = icmp sle i32 %0, 1
  br i1 %letmp, label %then, label %else

then:                                             ; preds = %entry
  ret i32 %0

else:                                             ; preds = %entry
  %subtmp = sub i32 %0, 1
  %calltmp = call i32 @"_\ED\94\BC\EB\B3\B4\EB\82\98\EC\B9\98"(i32 %subtmp)
  %subtmp1 = sub i32 %0, 2
  %calltmp2 = call i32 @"_\ED\94\BC\EB\B3\B4\EB\82\98\EC\B9\98"(i32 %subtmp1)
  %addtmp = add i32 %calltmp, %calltmp2
  ret i32 %addtmp

ifcont:                                           ; No predecessors!
  ret i32 0
}

define i32 @_main() {
entry:
  br label %forcond

forcond:                                          ; preds = %loop, %entry
  %"\EC\88\AB\EC\9E\90_ptr.0" = phi i32 [ 1, %entry ], [ %next_i, %loop ]
  %"\ED\95\A9.0" = phi i32 [ 0, %entry ], [ %addtmp, %loop ]
  %cond = icmp sle i32 %"\EC\88\AB\EC\9E\90_ptr.0", 10
  br i1 %cond, label %loop, label %afterloop

loop:                                             ; preds = %forcond
  %addtmp = add i32 %"\ED\95\A9.0", %"\EC\88\AB\EC\9E\90_ptr.0"
  %next_i = add i32 %"\EC\88\AB\EC\9E\90_ptr.0", 1
  br label %forcond

afterloop:                                        ; preds = %forcond
  %"\EC\B9\B4\EC\9A\B4\ED\84\B0" = alloca i32, align 4
  store i32 0, ptr %"\EC\B9\B4\EC\9A\B4\ED\84\B0", align 4
  br label %whilecond

whilecond:                                        ; preds = %whilebody, %afterloop
  %"\EC\B9\B4\EC\9A\B4\ED\84\B0.load" = load i32, ptr %"\EC\B9\B4\EC\9A\B4\ED\84\B0", align 4
  %lttmp = icmp slt i32 %"\EC\B9\B4\EC\9A\B4\ED\84\B0.load", 5
  br i1 %lttmp, label %whilebody, label %afterwhile

whilebody:                                        ; preds = %whilecond
  %"\EC\B9\B4\EC\9A\B4\ED\84\B0.load3" = load i32, ptr %"\EC\B9\B4\EC\9A\B4\ED\84\B0", align 4
  %"\EC\B9\B4\EC\9A\B4\ED\84\B0.load4" = load i32, ptr %"\EC\B9\B4\EC\9A\B4\ED\84\B0", align 4
  %addtmp5 = add i32 %"\EC\B9\B4\EC\9A\B4\ED\84\B0.load4", 1
  store i32 %addtmp5, ptr %"\EC\B9\B4\EC\9A\B4\ED\84\B0", align 4
  br label %whilecond

afterwhile:                                       ; preds = %whilecond
  %calltmp = call i32 @"_\ED\94\BC\EB\B3\B4\EB\82\98\EC\B9\98"(i32 10)
  %"\ED\94\BC\EB\B3\B4\EA\B0\92" = alloca i32, align 4
  store i32 %calltmp, ptr %"\ED\94\BC\EB\B3\B4\EA\B0\92", align 4
  %"\EC\B9\B4\EC\9A\B4\ED\84\B0.load7" = load i32, ptr %"\EC\B9\B4\EC\9A\B4\ED\84\B0", align 4
  %addtmp8 = add i32 %"\ED\95\A9.0", %"\EC\B9\B4\EC\9A\B4\ED\84\B0.load7"
  %"\ED\94\BC\EB\B3\B4\EA\B0\92.load" = load i32, ptr %"\ED\94\BC\EB\B3\B4\EA\B0\92", align 4
  %addtmp9 = add i32 %addtmp8, %"\ED\94\BC\EB\B3\B4\EA\B0\92.load"
  ret i32 %addtmp9
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
