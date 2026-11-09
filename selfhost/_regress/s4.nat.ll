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

define i32 @_gcd(i32 %0, i32 %1) {
entry:
  %eqtmp = icmp eq i32 %1, 0
  br i1 %eqtmp, label %then, label %ifcont

then:                                             ; preds = %entry
  ret i32 %0

ifcont:                                           ; preds = %entry
  %modtmp = srem i32 %0, %1
  %calltmp = call i32 @_gcd(i32 %1, i32 %modtmp)
  ret i32 %calltmp
}

define i32 @_main() {
entry:
  %calltmp = call i32 @_gcd(i32 48, i32 36)
  %eqtmp = icmp eq i32 %calltmp, 12
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
