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

define i1 @_isEven(i32 %0) {
entry:
  %eqtmp = icmp eq i32 %0, 0
  br i1 %eqtmp, label %then, label %ifcont

then:                                             ; preds = %entry
  ret i1 true

ifcont:                                           ; preds = %entry
  %subtmp = sub i32 %0, 1
  %calltmp = call i1 @_isOdd(i32 %subtmp)
  ret i1 %calltmp
}

define i1 @_isOdd(i32 %0) {
entry:
  %eqtmp = icmp eq i32 %0, 0
  br i1 %eqtmp, label %then, label %ifcont

then:                                             ; preds = %entry
  ret i1 false

ifcont:                                           ; preds = %entry
  %subtmp = sub i32 %0, 1
  %calltmp = call i1 @_isEven(i32 %subtmp)
  ret i1 %calltmp
}

define i32 @_main() {
entry:
  %calltmp = call i1 @_isEven(i32 10)
  br i1 %calltmp, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  %calltmp1 = call i1 @_isOdd(i32 7)
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %and_result.0 = phi i1 [ %calltmp1, %and_rhs ], [ false, %entry ]
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
