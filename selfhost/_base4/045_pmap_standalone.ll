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
  %arrlit = alloca i32, i32 5, align 4
  %0 = getelementptr i32, ptr %arrlit, i32 0
  store i32 10, ptr %0, align 4
  %1 = getelementptr i32, ptr %arrlit, i32 1
  store i32 20, ptr %1, align 4
  %2 = getelementptr i32, ptr %arrlit, i32 2
  store i32 30, ptr %2, align 4
  %3 = getelementptr i32, ptr %arrlit, i32 3
  store i32 40, ptr %3, align 4
  %4 = getelementptr i32, ptr %arrlit, i32 4
  store i32 50, ptr %4, align 4
  ret i32 0
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
