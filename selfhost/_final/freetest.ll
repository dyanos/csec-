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
  %Int = call ptr @malloc(i64 12)
  %arrayelem = getelementptr i32, ptr %Int, i32 0
  %arrayload = load i32, ptr %arrayelem, align 4
  %arrayelem.addr = getelementptr i32, ptr %Int, i32 0
  store i32 20, ptr %arrayelem.addr, align 4
  %arrayelem1 = getelementptr i32, ptr %Int, i32 1
  %arrayload2 = load i32, ptr %arrayelem1, align 4
  %arrayelem.addr3 = getelementptr i32, ptr %Int, i32 1
  store i32 22, ptr %arrayelem.addr3, align 4
  %arrayelem4 = getelementptr i32, ptr %Int, i32 0
  %arrayload5 = load i32, ptr %arrayelem4, align 4
  %arrayelem6 = getelementptr i32, ptr %Int, i32 1
  %arrayload7 = load i32, ptr %arrayelem6, align 4
  %addtmp = add i32 %arrayload5, %arrayload7
  call void @free(ptr %Int)
  ret i32 %addtmp
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
