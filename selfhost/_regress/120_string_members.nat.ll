; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [15 x i8] c"  Hello CSEC  \00", align 1
@1 = private unnamed_addr constant [4 x i8] c"CSE\00", align 1
@2 = private unnamed_addr constant [3 x i8] c"He\00", align 1
@3 = private unnamed_addr constant [4 x i8] c"SEC\00", align 1
@4 = private unnamed_addr constant [2 x i8] c"C\00", align 1

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
  %str.length = call i64 @csec_string_length(ptr @0)
  call void @csec_print_i64(i64 %str.length)
  call void @csec_print_newline()
  %str.length3 = call i64 @csec_string_length(ptr @0)
  call void @csec_print_i64(i64 %str.length3)
  call void @csec_print_newline()
  call void @csec_print_string(ptr %str.trim)
  call void @csec_print_newline()
  %str.length5 = call i64 @csec_string_length(ptr %str.trim)
  call void @csec_print_i64(i64 %str.length5)
  call void @csec_print_newline()
  %str.empty.i32 = call i32 @csec_string_is_empty(ptr %str.trim)
  %str.empty = icmp ne i32 %str.empty.i32, 0
  %print.bool = zext i1 %str.empty to i32
  call void @csec_print_bool(i32 %print.bool)
  call void @csec_print_newline()
  %str.bool.i32 = call i32 @csec_string_contains(ptr %str.trim, ptr @1)
  %str.bool = icmp ne i32 %str.bool.i32, 0
  %print.bool8 = zext i1 %str.bool to i32
  call void @csec_print_bool(i32 %print.bool8)
  call void @csec_print_newline()
  %str.bool.i3210 = call i32 @csec_string_starts_with(ptr %str.trim, ptr @2)
  %str.bool11 = icmp ne i32 %str.bool.i3210, 0
  %print.bool12 = zext i1 %str.bool11 to i32
  call void @csec_print_bool(i32 %print.bool12)
  call void @csec_print_newline()
  %str.bool.i3214 = call i32 @csec_string_ends_with(ptr %str.trim, ptr @3)
  %str.bool15 = icmp ne i32 %str.bool.i3214, 0
  %print.bool16 = zext i1 %str.bool15 to i32
  call void @csec_print_bool(i32 %print.bool16)
  call void @csec_print_newline()
  %str.index = call i64 @csec_string_index_of(ptr %str.trim, ptr @4)
  call void @csec_print_i64(i64 %str.index)
  call void @csec_print_newline()
  %str.substring = call ptr @csec_string_substring(ptr %str.trim, i32 6, i32 4)
  call void @csec_print_string(ptr %str.substring)
  call void @csec_print_newline()
  %str.char = call i8 @csec_string_char_at(ptr %str.trim, i32 0)
  call void @csec_print_char(i8 %str.char)
  call void @csec_print_newline()
  %str.upper = call ptr @csec_string_to_upper(ptr %str.trim)
  call void @csec_print_string(ptr %str.upper)
  call void @csec_print_newline()
  %str.lower = call ptr @csec_string_to_lower(ptr %str.trim)
  call void @csec_print_string(ptr %str.lower)
  call void @csec_print_newline()
  call void @csec_print_string(ptr %str.trim)
  call void @csec_print_newline()
  ret i32 0
}

declare ptr @csec_string_trim(ptr)

declare i64 @csec_string_length(ptr)

declare void @csec_print_i64(i64)

declare void @csec_print_newline()

declare void @csec_print_string(ptr)

declare i32 @csec_string_is_empty(ptr)

declare void @csec_print_bool(i32)

declare i32 @csec_string_contains(ptr, ptr)

declare i32 @csec_string_starts_with(ptr, ptr)

declare i32 @csec_string_ends_with(ptr, ptr)

declare i64 @csec_string_index_of(ptr, ptr)

declare ptr @csec_string_substring(ptr, i32, i32)

declare i8 @csec_string_char_at(ptr, i32)

declare void @csec_print_char(i8)

declare ptr @csec_string_to_upper(ptr)

declare ptr @csec_string_to_lower(ptr)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
