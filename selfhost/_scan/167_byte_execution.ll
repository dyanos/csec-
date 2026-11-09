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

define i8 @_bump(i8 %0) {
entry:
  %num.sext = sext i8 %0 to i64
  %addtmp = add i64 %num.sext, 1
  %abi.trunc = trunc i64 %addtmp to i8
  ret i8 %abi.trunc
}

define i32 @_main() {
entry:
  %calltmp = call i8 @_bump(i8 6)
  %num.sext = sext i8 %calltmp to i64
  %eqtmp = icmp eq i64 %num.sext, 7
  br i1 %eqtmp, label %then, label %ifcont

then:                                             ; preds = %entry
  ret i32 0

ifcont:                                           ; preds = %entry
  ret i32 1
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
