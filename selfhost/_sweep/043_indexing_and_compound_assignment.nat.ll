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
  %arrlit = alloca i32, i32 3, align 4
  %0 = getelementptr i32, ptr %arrlit, i32 0
  store i32 10, ptr %0, align 4
  %1 = getelementptr i32, ptr %arrlit, i32 1
  store i32 20, ptr %1, align 4
  %2 = getelementptr i32, ptr %arrlit, i32 2
  store i32 30, ptr %2, align 4
  %arrlit1 = alloca i32, i32 2, align 4
  %3 = getelementptr i32, ptr %arrlit1, i32 0
  store i32 1, ptr %3, align 4
  %4 = getelementptr i32, ptr %arrlit1, i32 1
  store i32 2, ptr %4, align 4
  %arrlit2 = alloca ptr, i32 2, align 8
  %5 = getelementptr ptr, ptr %arrlit2, i32 0
  store ptr %arrlit1, ptr %5, align 8
  %arrlit3 = alloca i32, i32 2, align 4
  %6 = getelementptr i32, ptr %arrlit3, i32 0
  store i32 3, ptr %6, align 4
  %7 = getelementptr i32, ptr %arrlit3, i32 1
  store i32 4, ptr %7, align 4
  %8 = getelementptr ptr, ptr %arrlit2, i32 1
  store ptr %arrlit3, ptr %8, align 8
  ret i32 0
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
