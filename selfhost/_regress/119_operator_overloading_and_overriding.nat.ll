; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [6 x i8] c"base+\00", align 1
@1 = private unnamed_addr constant [8 x i8] c"scaled+\00", align 1
@2 = private unnamed_addr constant [3 x i8] c"ok\00", align 1
@3 = private unnamed_addr constant [3 x i8] c"ok\00", align 1

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
  %newobj.malloc1 = call ptr @malloc(i64 0)
  %op.call = call i32 @"Accumulator_operator+"(ptr %newobj.malloc, i32 4)
  %math.sext = sext i32 %op.call to i64
  call void @csec_print_i64(i64 %math.sext)
  call void @csec_print_newline()
  %op.call2 = call ptr @"Accumulator_operator+.1"(ptr %newobj.malloc, ptr @2)
  call void @csec_print_string(ptr %op.call2)
  call void @csec_print_newline()
  %op.call3 = call i32 @"ScaledAccumulator_operator+"(ptr %newobj.malloc1, i32 4)
  %math.sext4 = sext i32 %op.call3 to i64
  call void @csec_print_i64(i64 %math.sext4)
  call void @csec_print_newline()
  %op.call5 = call ptr @"ScaledAccumulator_operator+.2"(ptr %newobj.malloc1, ptr @3)
  call void @csec_print_string(ptr %op.call5)
  call void @csec_print_newline()
  ret i32 0
}

define i32 @"Accumulator_operator+"(ptr %this, i32 %right) {
entry:
  %addtmp = add i32 %right, 1
  ret i32 %addtmp
}

define ptr @"Accumulator_operator+.1"(ptr %this, ptr %right) {
entry:
  %str.concat = call ptr @csec_string_concat(ptr @0, ptr %right)
  ret ptr %str.concat
}

declare ptr @csec_string_concat(ptr, ptr)

define i32 @"ScaledAccumulator_operator+"(ptr %this, i32 %right) {
entry:
  %addtmp = add i32 %right, 10
  ret i32 %addtmp
}

define ptr @"ScaledAccumulator_operator+.2"(ptr %this, ptr %right) {
entry:
  %str.concat = call ptr @csec_string_concat(ptr @1, ptr %right)
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
