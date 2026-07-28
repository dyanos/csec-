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
  %addtmp = add i32 1, 6
  %shltmp = shl i32 %addtmp, 1
  %ortmp = or i32 %shltmp, 3
  %andtmp = and i32 %ortmp, 7
  %addtmp4 = add i32 %andtmp, 1
  %subtmp = sub i32 %addtmp4, 1
  br i1 true, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  %gttmp = icmp sgt i32 %addtmp, 0
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %and_result.0 = phi i1 [ %gttmp, %and_rhs ], [ false, %entry ]
  br i1 %and_result.0, label %then, label %else

then:                                             ; preds = %and_end
  %addtmp10 = add i32 %addtmp, 0
  br label %ifcont

else:                                             ; preds = %and_end
  %addtmp13 = add i32 %addtmp, 1
  br label %ifcont

ifcont:                                           ; preds = %else, %then
  %result = phi i32 [ %addtmp10, %then ], [ %addtmp13, %else ]
  br label %whilecond

whilecond:                                        ; preds = %whilebody, %ifcont
  %flags.0 = phi i32 [ %subtmp, %ifcont ], [ %subtmp18, %whilebody ]
  %gttmp15 = icmp sgt i32 %flags.0, 0
  br i1 %gttmp15, label %whilebody, label %afterwhile

whilebody:                                        ; preds = %whilecond
  %subtmp18 = sub i32 %flags.0, 1
  br label %whilecond

afterwhile:                                       ; preds = %whilecond
  ret i32 7
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
