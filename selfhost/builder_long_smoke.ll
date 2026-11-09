; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [4 x i8] c"one\00", align 1

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

declare i64 @csec_string_builder_new()

declare i32 @csec_string_builder_append(i64, ptr)

declare ptr @csec_string_builder_finish(i64)

define i64 @_makeBuilder() {
entry:
  %calltmp = call i64 @csec_string_builder_new()
  %calltmp1 = call i32 @csec_string_builder_append(i64 %calltmp, ptr @0)
  ret i64 %calltmp
}

define i32 @_main() {
entry:
  %calltmp = call i64 @_makeBuilder()
  %calltmp1 = call ptr @csec_string_builder_finish(i64 %calltmp)
  %str.length = call i64 @csec_string_length(ptr %calltmp1)
  %eqtmp = icmp eq i64 %str.length, 3
  %ifcond = icmp ne i1 %eqtmp, false
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  ret i32 0

ifcont:                                           ; preds = %entry
  ret i32 1
}

declare i64 @csec_string_length(ptr)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
