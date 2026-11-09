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
  call void @"O#p.Boolean"(i1 true)
  ret i32 0
}

define void @"O#p"(ptr %0) {
entry:
  call void @csec_print_string(ptr %0)
  ret void
}

declare void @csec_print_string(ptr)

define void @"O#p.Boolean"(i1 %0) {
entry:
  %print.bool = zext i1 %0 to i32
  call void @csec_print_bool(i32 %print.bool)
  ret void
}

declare void @csec_print_bool(i32)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
