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
  %argv.count = call i32 @csec_command_line_arg_count()
  %getmp = icmp sge i32 %argv.count, 1
  %ifcond = icmp ne i1 %getmp, false
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  %argv.value = call ptr @csec_command_line_arg(i32 0)
  %name = alloca ptr, align 8
  store ptr %argv.value, ptr %name, align 8
  %name.load = load ptr, ptr %name, align 8
  %str.length = call i64 @csec_string_length(ptr %name.load)
  %getmp1 = icmp sge i64 %str.length, 0
  %ifcond2 = icmp ne i1 %getmp1, false
  br i1 %ifcond2, label %then3, label %ifcont4

ifcont:                                           ; preds = %ifcont4, %entry
  ret i32 1

then3:                                            ; preds = %then
  ret i32 0

ifcont4:                                          ; preds = %then
  br label %ifcont
}

declare i32 @csec_command_line_arg_count()

declare ptr @csec_command_line_arg(i32)

declare i64 @csec_string_length(ptr)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
