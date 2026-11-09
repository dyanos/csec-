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
  %arrlit = alloca i32, i32 10, align 4
  %0 = getelementptr i32, ptr %arrlit, i32 0
  store i32 1, ptr %0, align 4
  %1 = getelementptr i32, ptr %arrlit, i32 1
  store i32 2, ptr %1, align 4
  %2 = getelementptr i32, ptr %arrlit, i32 2
  store i32 3, ptr %2, align 4
  %3 = getelementptr i32, ptr %arrlit, i32 3
  store i32 4, ptr %3, align 4
  %4 = getelementptr i32, ptr %arrlit, i32 4
  store i32 5, ptr %4, align 4
  %5 = getelementptr i32, ptr %arrlit, i32 5
  store i32 6, ptr %5, align 4
  %6 = getelementptr i32, ptr %arrlit, i32 6
  store i32 7, ptr %6, align 4
  %7 = getelementptr i32, ptr %arrlit, i32 7
  store i32 8, ptr %7, align 4
  %8 = getelementptr i32, ptr %arrlit, i32 8
  store i32 9, ptr %8, align 4
  %9 = getelementptr i32, ptr %arrlit, i32 9
  store i32 10, ptr %9, align 4
  ret i32 0
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
