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

define i32 @_addPair(i32 %0, i32 %1) {
entry:
  %addtmp = add i32 %0, %1
  ret i32 %addtmp
}

define i32 @_scale(i32 %0, i32 %1) {
entry:
  %multmp = mul i32 %0, %1
  ret i32 %multmp
}

define i32 @_main() {
entry:
  %calltmp = call i32 @_addPair(i32 1, i32 2)
  %calltmp1 = call i32 @_addPair(i32 3, i32 4)
  %calltmp2 = call i32 @_addPair(i32 %calltmp, i32 %calltmp1)
  %calltmp3 = call i32 @_addPair(i32 2, i32 3)
  %calltmp4 = call i32 @_addPair(i32 1, i32 1)
  %calltmp5 = call i32 @_scale(i32 %calltmp3, i32 %calltmp4)
  %eqtmp = icmp eq i32 %calltmp2, 10
  br i1 %eqtmp, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  %eqtmp6 = icmp eq i32 %calltmp5, 10
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %and_result.0 = phi i1 [ %eqtmp6, %and_rhs ], [ false, %entry ]
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
