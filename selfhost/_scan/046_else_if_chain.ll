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

define i32 @_classify(i32 %0) {
entry:
  %eqtmp = icmp eq i32 %0, 0
  br i1 %eqtmp, label %then, label %else

then:                                             ; preds = %entry
  ret i32 0

else:                                             ; preds = %entry
  %eqtmp1 = icmp eq i32 %0, 1
  br i1 %eqtmp1, label %then2, label %else3

ifcont:                                           ; preds = %ifcont4
  ret i32 0

then2:                                            ; preds = %else
  ret i32 1

else3:                                            ; preds = %else
  ret i32 2

ifcont4:                                          ; No predecessors!
  br label %ifcont
}

define i32 @_main() {
entry:
  %calltmp = call i32 @_classify(i32 1)
  ret i32 %calltmp
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
