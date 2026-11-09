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
  store i32 1, ptr %0, align 4
  %1 = getelementptr i32, ptr %arrlit, i32 1
  store i32 2, ptr %1, align 4
  %2 = getelementptr i32, ptr %arrlit, i32 2
  store i32 3, ptr %2, align 4
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
  %arrlit4 = alloca i32, i32 2, align 4
  %9 = getelementptr i32, ptr %arrlit4, i32 0
  store i32 1, ptr %9, align 4
  %10 = getelementptr i32, ptr %arrlit4, i32 1
  store i32 2, ptr %10, align 4
  %arrlit5 = alloca ptr, i32 2, align 8
  %11 = getelementptr ptr, ptr %arrlit5, i32 0
  store ptr %arrlit4, ptr %11, align 8
  %arrlit6 = alloca i32, i32 2, align 4
  %12 = getelementptr i32, ptr %arrlit6, i32 0
  store i32 3, ptr %12, align 4
  %13 = getelementptr i32, ptr %arrlit6, i32 1
  store i32 4, ptr %13, align 4
  %14 = getelementptr ptr, ptr %arrlit5, i32 1
  store ptr %arrlit6, ptr %14, align 8
  %arrlit7 = alloca ptr, i32 2, align 8
  %15 = getelementptr ptr, ptr %arrlit7, i32 0
  store ptr %arrlit5, ptr %15, align 8
  %arrlit8 = alloca i32, i32 2, align 4
  %16 = getelementptr i32, ptr %arrlit8, i32 0
  store i32 5, ptr %16, align 4
  %17 = getelementptr i32, ptr %arrlit8, i32 1
  store i32 6, ptr %17, align 4
  %arrlit9 = alloca ptr, i32 2, align 8
  %18 = getelementptr ptr, ptr %arrlit9, i32 0
  store ptr %arrlit8, ptr %18, align 8
  %arrlit10 = alloca i32, i32 2, align 4
  %19 = getelementptr i32, ptr %arrlit10, i32 0
  store i32 7, ptr %19, align 4
  %20 = getelementptr i32, ptr %arrlit10, i32 1
  store i32 8, ptr %20, align 4
  %21 = getelementptr ptr, ptr %arrlit9, i32 1
  store ptr %arrlit10, ptr %21, align 8
  %22 = getelementptr ptr, ptr %arrlit7, i32 1
  store ptr %arrlit9, ptr %22, align 8
  %arrayelem = getelementptr i32, ptr %arrlit, i32 0
  %arrayload = load i32, ptr %arrayelem, align 4
  %arrayelem11 = getelementptr ptr, ptr %arrlit2, i32 0
  %arrayload12 = load ptr, ptr %arrayelem11, align 8
  %arrayelem13 = getelementptr i32, ptr %arrayload12, i32 1
  %arrayload14 = load i32, ptr %arrayelem13, align 4
  %arrayelem15 = getelementptr ptr, ptr %arrlit7, i32 1
  %arrayload16 = load ptr, ptr %arrayelem15, align 8
  %arrayelem17 = getelementptr ptr, ptr %arrayload16, i32 0
  %arrayload18 = load ptr, ptr %arrayelem17, align 8
  %arrayelem19 = getelementptr i32, ptr %arrayload18, i32 1
  %arrayload20 = load i32, ptr %arrayelem19, align 4
  %addtmp = add i32 %arrayload, %arrayload14
  %addtmp21 = add i32 %addtmp, %arrayload20
  ret i32 %addtmp21
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
