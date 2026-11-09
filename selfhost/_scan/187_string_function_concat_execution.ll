; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [1 x i8] zeroinitializer, align 1
@1 = private unnamed_addr constant [4 x i8] c"id-\00", align 1
@2 = private unnamed_addr constant [3 x i8] c"ab\00", align 1
@3 = private unnamed_addr constant [2 x i8] c"x\00", align 1

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

define ptr @_repeat(ptr %0, i32 %1) {
entry:
  %eqtmp = icmp eq i32 %1, 0
  br i1 %eqtmp, label %then, label %ifcont

then:                                             ; preds = %entry
  ret ptr @0

ifcont:                                           ; preds = %entry
  %subtmp = sub i32 %1, 1
  %calltmp = call ptr @_repeat(ptr %0, i32 %subtmp)
  %str.concat = call ptr @csec_string_concat(ptr %0, ptr %calltmp)
  ret ptr %str.concat
}

define ptr @_prefixed(ptr %0) {
entry:
  %str.concat = call ptr @csec_string_concat(ptr @1, ptr %0)
  ret ptr %str.concat
}

define i32 @_main() {
entry:
  %calltmp = call ptr @_repeat(ptr @2, i32 3)
  %calltmp1 = call ptr @_repeat(ptr @3, i32 2)
  %calltmp2 = call ptr @_prefixed(ptr %calltmp1)
  %str.length = call i64 @csec_string_length(ptr %calltmp)
  %eqtmp = icmp eq i64 %str.length, 6
  br i1 %eqtmp, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  %str.length3 = call i64 @csec_string_length(ptr %calltmp2)
  %eqtmp4 = icmp eq i64 %str.length3, 5
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %and_result.0 = phi i1 [ %eqtmp4, %and_rhs ], [ false, %entry ]
  br i1 %and_result.0, label %then, label %ifcont

then:                                             ; preds = %and_end
  ret i32 0

ifcont:                                           ; preds = %and_end
  ret i32 1
}

declare ptr @csec_string_concat(ptr, ptr)

declare i64 @csec_string_length(ptr)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
