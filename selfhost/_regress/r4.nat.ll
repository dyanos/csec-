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
  %divtmp = sdiv i32 7, 3
  %modtmp = srem i32 7, 3
  %eqtmp = icmp eq i32 %divtmp, 2
  br i1 %eqtmp, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  %eqtmp3 = icmp eq i32 %modtmp, 1
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %and_result.0 = phi i1 [ %eqtmp3, %and_rhs ], [ false, %entry ]
  br i1 %and_result.0, label %and_rhs5, label %and_end6

and_rhs5:                                         ; preds = %and_end
  %eqtmp7 = icmp eq i32 -5, -5
  br label %and_end6

and_end6:                                         ; preds = %and_rhs5, %and_end
  %and_result4.0 = phi i1 [ %eqtmp7, %and_rhs5 ], [ false, %and_end ]
  br i1 %and_result4.0, label %then, label %ifcont

then:                                             ; preds = %and_end6
  ret i32 0

ifcont:                                           ; preds = %and_end6
  ret i32 1
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
