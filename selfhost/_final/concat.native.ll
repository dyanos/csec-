; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [2 x i8] c"<\00", align 1
@1 = private unnamed_addr constant [2 x i8] c"x\00", align 1
@2 = private unnamed_addr constant [2 x i8] c">\00", align 1

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

define ptr @_rep(ptr %0, i32 %1) {
entry:
  %letmp = icmp sle i32 %1, 1
  br i1 %letmp, label %then, label %ifcont

then:                                             ; preds = %entry
  ret ptr %0

ifcont:                                           ; preds = %entry
  %subtmp = sub i32 %1, 1
  %calltmp = call ptr @_rep(ptr %0, i32 %subtmp)
  %str.concat = call ptr @csec_string_concat(ptr %0, ptr %calltmp)
  ret ptr %str.concat
}

define i32 @_main() {
entry:
  %calltmp = call ptr @_rep(ptr @1, i32 2)
  %str.concat = call ptr @csec_string_concat(ptr @0, ptr %calltmp)
  %str.concat1 = call ptr @csec_string_concat(ptr %str.concat, ptr @2)
  call void @csec_print_string(ptr %str.concat1)
  call void @csec_print_newline()
  ret i32 0
}

declare ptr @csec_string_concat(ptr, ptr)

declare void @csec_print_string(ptr)

declare void @csec_print_newline()

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
