; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [7 x i8] c"count=\00", align 1
@1 = private unnamed_addr constant [2 x i8] c"a\00", align 1
@2 = private unnamed_addr constant [2 x i8] c"b\00", align 1
@3 = private unnamed_addr constant [8 x i8] c"count=7\00", align 1

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

define ptr @_render(i32 %0) {
entry:
  %str.sext = sext i32 %0 to i64
  %str.int.call = call ptr @csec_to_string_i64(i64 %str.sext)
  %str.concat = call ptr @csec_string_concat(ptr @0, ptr %str.int.call)
  ret ptr %str.concat
}

define i32 @_main() {
entry:
  %calltmp = call ptr @_render(i32 7)
  %str.int.call = call ptr @csec_to_string_i64(i64 1)
  %str.concat = call ptr @csec_string_concat(ptr @1, ptr %str.int.call)
  %str.concat1 = call ptr @csec_string_concat(ptr %str.concat, ptr @2)
  %str.equals = call i32 @csec_string_equals(ptr %calltmp, ptr @3)
  %str.eq = icmp ne i32 %str.equals, 0
  br i1 %str.eq, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  %str.length = call i64 @csec_string_length(ptr %str.concat1)
  %eqtmp = icmp eq i64 %str.length, 3
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %and_result.0 = phi i1 [ %eqtmp, %and_rhs ], [ false, %entry ]
  br i1 %and_result.0, label %then, label %ifcont

then:                                             ; preds = %and_end
  ret i32 0

ifcont:                                           ; preds = %and_end
  ret i32 1
}

declare ptr @csec_to_string_i64(i64)

declare ptr @csec_string_concat(ptr, ptr)

declare i32 @csec_string_equals(ptr, ptr)

declare i64 @csec_string_length(ptr)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
