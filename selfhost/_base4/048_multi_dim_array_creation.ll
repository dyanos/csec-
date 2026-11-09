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
  %Int = call ptr @malloc(i64 40)
  %Float = call ptr @malloc(i64 80)
  %Double = call ptr @malloc(i64 40)
  %Int1 = call ptr @malloc(i64 36)
  %Double2 = call ptr @malloc(i64 128)
  %Int3 = call ptr @malloc(i64 96)
  %Float4 = call ptr @malloc(i64 500)
  ret i32 0
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
