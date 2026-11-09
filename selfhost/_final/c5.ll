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
  %arrayelem = getelementptr [2 x i32], ptr %arrlit1, i32 0
  %arrayload = load [2 x i32], ptr %arrayelem, align 4
  %row = alloca [2 x i32], align 4
  store [2 x i32] %arrayload, ptr %row, align 4
  %arrayelem3 = getelementptr i32, ptr %row, i32 1
  %arrayload4 = load i32, ptr %arrayelem3, align 4
  ret i32 %arrayload4
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
