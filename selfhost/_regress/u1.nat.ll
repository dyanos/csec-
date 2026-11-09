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
  %xortmp = xor i1 true, false
  br i1 %xortmp, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  %xortmp3 = xor i1 true, true
  %eqtmp = icmp eq i1 %xortmp3, false
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %and_result.0 = phi i1 [ %eqtmp, %and_rhs ], [ false, %entry ]
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
