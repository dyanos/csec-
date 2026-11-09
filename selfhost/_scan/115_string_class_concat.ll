; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [7 x i8] c"score=\00", align 1
@1 = private unnamed_addr constant [6 x i8] c", ok=\00", align 1
@2 = private unnamed_addr constant [9 x i8] c", value=\00", align 1
@3 = private unnamed_addr constant [8 x i8] c", mark=\00", align 1

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
  %str.int.call = call ptr @csec_to_string_i64(i64 4)
  %str.concat = call ptr @csec_string_concat(ptr @0, ptr %str.int.call)
  %str.concat1 = call ptr @csec_string_concat(ptr %str.concat, ptr @1)
  %str.bool.call = call ptr @csec_to_string_bool(i32 1)
  %str.concat2 = call ptr @csec_string_concat(ptr %str.concat1, ptr %str.bool.call)
  %str.concat3 = call ptr @csec_string_concat(ptr %str.concat2, ptr @2)
  %str.double.call = call ptr @csec_to_string_double(double 3.500000e+00)
  %str.concat4 = call ptr @csec_string_concat(ptr %str.concat3, ptr %str.double.call)
  %str.concat5 = call ptr @csec_string_concat(ptr %str.concat4, ptr @3)
  %str.char.call = call ptr @csec_to_string_char(i8 65)
  %str.concat6 = call ptr @csec_string_concat(ptr %str.concat5, ptr %str.char.call)
  call void @csec_print_string(ptr %str.concat6)
  call void @csec_print_newline()
  ret i32 0
}

declare ptr @csec_to_string_i64(i64)

declare ptr @csec_string_concat(ptr, ptr)

declare ptr @csec_to_string_bool(i32)

declare ptr @csec_to_string_double(double)

declare ptr @csec_to_string_char(i8)

declare void @csec_print_string(ptr)

declare void @csec_print_newline()

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
