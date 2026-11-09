; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [6 x i8] c"base=\00", align 1
@1 = private unnamed_addr constant [7 x i8] c"child=\00", align 1
@2 = private unnamed_addr constant [7 x i8] c"child=\00", align 1
@3 = private unnamed_addr constant [6 x i8] c"ready\00", align 1

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
  %calltmp = call i32 @ChildPrinter_value(ptr %newobj.malloc)
  %math.sext = sext i32 %calltmp to i64
  call void @csec_print_i64(i64 %math.sext)
  call void @csec_print_newline()
  %calltmp1 = call ptr @ChildPrinter_label(ptr %newobj.malloc, i32 7)
  call void @csec_print_string(ptr %calltmp1)
  call void @csec_print_newline()
  %calltmp2 = call ptr @ChildPrinter_label.1(ptr %newobj.malloc, ptr @3)
  call void @csec_print_string(ptr %calltmp2)
  call void @csec_print_newline()
  ret i32 0
}

define i32 @BasePrinter_value(ptr %this) {
entry:
  ret i32 1
}

define ptr @BasePrinter_label(ptr %this, i32 %value) {
entry:
  %str.sext = sext i32 %value to i64
  %str.int.call = call ptr @csec_to_string_i64(i64 %str.sext)
  %str.concat = call ptr @csec_string_concat(ptr @0, ptr %str.int.call)
  ret ptr %str.concat
}

declare ptr @csec_to_string_i64(i64)

declare ptr @csec_string_concat(ptr, ptr)

define i32 @ChildPrinter_value(ptr %this) {
entry:
  ret i32 2
}

define ptr @ChildPrinter_label(ptr %this, i32 %value) {
entry:
  %str.sext = sext i32 %value to i64
  %str.int.call = call ptr @csec_to_string_i64(i64 %str.sext)
  %str.concat = call ptr @csec_string_concat(ptr @1, ptr %str.int.call)
  ret ptr %str.concat
}

define ptr @ChildPrinter_label.1(ptr %this, ptr %value) {
entry:
  %str.concat = call ptr @csec_string_concat(ptr @2, ptr %value)
  ret ptr %str.concat
}

declare void @csec_print_i64(i64)

declare void @csec_print_newline()

declare void @csec_print_string(ptr)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
