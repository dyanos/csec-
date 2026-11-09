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
  %newobj.malloc = call ptr @malloc(i64 0)
  %op.call = call i32 @"Counter_operator+"(ptr %newobj.malloc, i32 41)
  %op.call1 = call i32 @"Counter_operator*"(ptr %newobj.malloc, i32 21)
  %eqtmp = icmp eq i32 %op.call, 42
  br i1 %eqtmp, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  %eqtmp2 = icmp eq i32 %op.call1, 42
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %and_result.0 = phi i1 [ %eqtmp2, %and_rhs ], [ false, %entry ]
  br i1 %and_result.0, label %then, label %ifcont

then:                                             ; preds = %and_end
  ret i32 0

ifcont:                                           ; preds = %and_end
  ret i32 1
}

define i32 @"Counter_operator+"(ptr %this, i32 %right) {
entry:
  %addtmp = add i32 %right, 1
  ret i32 %addtmp
}

define i32 @"Counter_operator*"(ptr %this, i32 %right) {
entry:
  %addtmp = add i32 %right, %right
  ret i32 %addtmp
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
