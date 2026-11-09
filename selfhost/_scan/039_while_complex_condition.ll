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
  %j.0 = phi i32 [ 100, %entry ], [ %subtmp, %whilebody ]
  %i.0 = phi i32 [ 0, %entry ], [ %addtmp, %whilebody ]
  %lttmp = icmp slt i32 %i.0, 10
  br i1 %lttmp, label %and_rhs, label %and_end

whilebody:                                        ; preds = %and_end
  %addtmp = add i32 %i.0, 1
  %subtmp = sub i32 %j.0, 5
  br label %whilecond

afterwhile:                                       ; preds = %and_end
  %x = alloca i32, align 4
  store i32 0, ptr %x, align 4
  br label %whilecond5

and_rhs:                                          ; preds = %whilecond
  %gttmp = icmp sgt i32 %j.0, 50
  br label %and_end

and_end:                                          ; preds = %and_rhs, %whilecond
  %and_result.0 = phi i1 [ %gttmp, %and_rhs ], [ false, %whilecond ]
  br i1 %and_result.0, label %whilebody, label %afterwhile

whilecond5:                                       ; preds = %ifcont, %afterwhile
  %x.load = load i32, ptr %x, align 4
  %lttmp8 = icmp slt i32 %x.load, 100
  br i1 %lttmp8, label %whilebody6, label %afterwhile7

whilebody6:                                       ; preds = %whilecond5
  %x.load9 = load i32, ptr %x, align 4
  %x.load10 = load i32, ptr %x, align 4
  %addtmp11 = add i32 %x.load10, 1
  store i32 %addtmp11, ptr %x, align 4
  %x.load12 = load i32, ptr %x, align 4
  %eqtmp = icmp eq i32 %x.load12, 50
  br i1 %eqtmp, label %then, label %ifcont

afterwhile7:                                      ; preds = %whilecond5
  %addtmp16 = add i32 %i.0, %j.0
  ret i32 %addtmp16

then:                                             ; preds = %whilebody6
  %x.load13 = load i32, ptr %x, align 4
  ret i32 %x.load13

ifcont:                                           ; preds = %whilebody6
  br label %whilecond5
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
