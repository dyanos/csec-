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
  %readline = call ptr @csec_read_line()
  %readchar = call i8 @csec_read_char()
  %readint = call i32 @csec_read_int()
  %readdouble = call double @csec_read_double()
  call void @csec_print_string(ptr %readline)
  call void @csec_print_newline()
  call void @csec_print_char(i8 %readchar)
  call void @csec_print_newline()
  %math.sext = sext i32 %readint to i64
  call void @csec_print_i64(i64 %math.sext)
  call void @csec_print_newline()
  call void @csec_print_double(double %readdouble)
  call void @csec_print_newline()
  ret i32 0
}

declare ptr @csec_read_line()

declare i8 @csec_read_char()

declare i32 @csec_read_int()

declare double @csec_read_double()

declare void @csec_print_string(ptr)

declare void @csec_print_newline()

declare void @csec_print_char(i8)

declare void @csec_print_i64(i64)

declare void @csec_print_double(double)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
