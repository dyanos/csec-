; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [12 x i8] c"hello world\00", align 1
@1 = private unnamed_addr constant [6 x i8] c"hello\00", align 1

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
  %str.upper = call ptr @csec_string_to_upper(ptr @0)
  %str.substring = call ptr @csec_string_substring(ptr @0, i32 0, i32 5)
  %str.length = call i64 @csec_string_length(ptr %str.upper)
  %eqtmp = icmp eq i64 %str.length, 11
  br i1 %eqtmp, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  %str.equals = call i32 @csec_string_equals(ptr %str.substring, ptr @1)
  %str.eq = icmp ne i32 %str.equals, 0
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %and_result.0 = phi i1 [ %str.eq, %and_rhs ], [ false, %entry ]
  br i1 %and_result.0, label %then, label %ifcont

then:                                             ; preds = %and_end
  ret i32 0

ifcont:                                           ; preds = %and_end
  ret i32 1
}

declare ptr @csec_string_to_upper(ptr)

declare ptr @csec_string_substring(ptr, i32, i32)

declare i64 @csec_string_length(ptr)

declare i32 @csec_string_equals(ptr, ptr)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
