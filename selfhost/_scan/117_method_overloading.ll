; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [2 x i8] c"!\00", align 1
@1 = private unnamed_addr constant [3 x i8] c"ok\00", align 1

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
  %newobj.malloc = call ptr @malloc(i64 0)
  %calltmp = call i32 @Formatter_show(ptr %newobj.malloc, i32 4)
  %math.sext = sext i32 %calltmp to i64
  call void @csec_print_i64(i64 %math.sext)
  call void @csec_print_newline()
  %calltmp1 = call ptr @Formatter_show.1(ptr %newobj.malloc, ptr @1)
  call void @csec_print_string(ptr %calltmp1)
  call void @csec_print_newline()
  ret i32 0
}

define i32 @Formatter_show(ptr %this, i32 %value) {
entry:
  %addtmp = add i32 %value, 1
  ret i32 %addtmp
}

define ptr @Formatter_show.1(ptr %this, ptr %value) {
entry:
  %str.concat = call ptr @csec_string_concat(ptr %value, ptr @0)
  ret ptr %str.concat
}

declare ptr @csec_string_concat(ptr, ptr)

declare void @csec_print_i64(i64)

declare void @csec_print_newline()

declare void @csec_print_string(ptr)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
