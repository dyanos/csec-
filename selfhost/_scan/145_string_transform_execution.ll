; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [7 x i8] c" AbCd \00", align 1

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
  %str.trim = call ptr @csec_string_trim(ptr @0)
  %str.upper = call ptr @csec_string_to_upper(ptr %str.trim)
  %str.lower = call ptr @csec_string_to_lower(ptr %str.upper)
  %str.substring = call ptr @csec_string_substring(ptr %str.lower, i32 1, i32 2)
  %str.length = call i64 @csec_string_length(ptr %str.trim)
  %str.length3 = call i64 @csec_string_length(ptr %str.upper)
  %addtmp = add i64 %str.length, %str.length3
  %str.length4 = call i64 @csec_string_length(ptr %str.substring)
  %addtmp5 = add i64 %addtmp, %str.length4
  %abi.trunc = trunc i64 %addtmp5 to i32
  ret i32 %abi.trunc
}

declare ptr @csec_string_trim(ptr)

declare ptr @csec_string_to_upper(ptr)

declare ptr @csec_string_to_lower(ptr)

declare ptr @csec_string_substring(ptr, i32, i32)

declare i64 @csec_string_length(ptr)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
