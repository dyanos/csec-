; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [7 x i8] c"value=\00", align 1
@1 = private unnamed_addr constant [2 x i8] c" \00", align 1
@2 = private unnamed_addr constant [2 x i8] c" \00", align 1
@3 = private unnamed_addr constant [5 x i8] c"done\00", align 1

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
  call void @csec_print_string(ptr @0)
  call void @csec_print_i64(i64 42)
  call void @csec_print_string(ptr @1)
  call void @csec_print_double(double 3.500000e+00)
  call void @csec_print_string(ptr @2)
  call void @csec_print_bool(i32 1)
  call void @csec_print_newline()
  call void @csec_print_string(ptr @3)
  call void @csec_print_newline()
  ret i32 0
}

declare void @csec_print_string(ptr)

declare void @csec_print_i64(i64)

declare void @csec_print_double(double)

declare void @csec_print_bool(i32)

declare void @csec_print_newline()

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
