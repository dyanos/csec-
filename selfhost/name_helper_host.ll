; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [6 x i8] c"%ret.\00", align 1
@1 = private unnamed_addr constant [3 x i8] c"  \00", align 1
@2 = private unnamed_addr constant [21 x i8] c" = icmp eq i32 0, 0\0A\00", align 1
@3 = private unnamed_addr constant [10 x i8] c"  %ret.42\00", align 1

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

declare ptr @csec_llvm_name_with_number(ptr, i32)

define i32 @_main() {
entry:
  %calltmp = call ptr @csec_llvm_name_with_number(ptr @0, i32 42)
  %str.concat = call ptr @csec_string_concat(ptr @1, ptr %calltmp)
  %str.concat1 = call ptr @csec_string_concat(ptr %str.concat, ptr @2)
  %str.bool.i32 = call i32 @csec_string_starts_with(ptr %str.concat1, ptr @3)
  %str.bool = icmp ne i32 %str.bool.i32, 0
  %ifcond = icmp ne i1 %str.bool, false
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  ret i32 0

ifcont:                                           ; preds = %entry
  ret i32 1
}

declare ptr @csec_string_concat(ptr, ptr)

declare i32 @csec_string_starts_with(ptr, ptr)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
