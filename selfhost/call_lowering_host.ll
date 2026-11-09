; ModuleID = 'main'
source_filename = "main"

define i32 @main(i32 %0, ptr %1) {
entry:
  ret i32 0
}

declare ptr @malloc(i64)

declare void @free(ptr)

declare ptr @toString(ptr)

declare ptr @"operator+"(ptr, ptr)

declare void @print(ptr)

declare void @println(ptr)

declare i32 @csec_lex_quoted(ptr, i32)

define i32 @_wrapper(ptr %0, i32 %1) {
entry:
  %calltmp = call i32 @csec_lex_quoted(ptr %0, i32 %1)
  ret i32 %calltmp
}
