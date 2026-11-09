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

define i32 @_pairSum(ptr %0) {
entry:
  %arrayelem = getelementptr i32, ptr %0, i32 0
  %arrayload = load i32, ptr %arrayelem, align 4
  %arrayelem1 = getelementptr i32, ptr %0, i32 1
  %arrayload2 = load i32, ptr %arrayelem1, align 4
  %addtmp = add i32 %arrayload, %arrayload2
  ret i32 %addtmp
}

define i32 @_main() {
entry:
  %arrlit = alloca i32, i32 3, align 4
  %0 = getelementptr i32, ptr %arrlit, i32 0
  store i32 19, ptr %0, align 4
  %1 = getelementptr i32, ptr %arrlit, i32 1
  store i32 23, ptr %1, align 4
  %2 = getelementptr i32, ptr %arrlit, i32 2
  store i32 99, ptr %2, align 4
  ret i32 0
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
