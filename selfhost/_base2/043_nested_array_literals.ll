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
  %arrlit = alloca i32, i32 2, align 4
  %0 = getelementptr i32, ptr %arrlit, i32 0
  store i32 1, ptr %0, align 4
  %1 = getelementptr i32, ptr %arrlit, i32 1
  store i32 2, ptr %1, align 4
  %arrlit1 = alloca ptr, i32 2, align 8
  %2 = getelementptr ptr, ptr %arrlit1, i32 0
  store ptr %arrlit, ptr %2, align 8
  %arrlit2 = alloca i32, i32 2, align 4
  %3 = getelementptr i32, ptr %arrlit2, i32 0
  store i32 3, ptr %3, align 4
  %4 = getelementptr i32, ptr %arrlit2, i32 1
  store i32 4, ptr %4, align 4
  %5 = getelementptr ptr, ptr %arrlit1, i32 1
  store ptr %arrlit2, ptr %5, align 8
  %arrlit3 = alloca ptr, i32 2, align 8
  %6 = getelementptr ptr, ptr %arrlit3, i32 0
  store ptr %arrlit1, ptr %6, align 8
  %arrlit4 = alloca i32, i32 2, align 4
  %7 = getelementptr i32, ptr %arrlit4, i32 0
  store i32 5, ptr %7, align 4
  %8 = getelementptr i32, ptr %arrlit4, i32 1
  store i32 6, ptr %8, align 4
  %arrlit5 = alloca ptr, i32 2, align 8
  %9 = getelementptr ptr, ptr %arrlit5, i32 0
  store ptr %arrlit4, ptr %9, align 8
  %arrlit6 = alloca i32, i32 2, align 4
  %10 = getelementptr i32, ptr %arrlit6, i32 0
  store i32 7, ptr %10, align 4
  %11 = getelementptr i32, ptr %arrlit6, i32 1
  store i32 8, ptr %11, align 4
  %12 = getelementptr ptr, ptr %arrlit5, i32 1
  store ptr %arrlit6, ptr %12, align 8
  %13 = getelementptr ptr, ptr %arrlit3, i32 1
  store ptr %arrlit5, ptr %13, align 8
  %Int = call ptr @malloc(i64 32)
  ret i32 0
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
