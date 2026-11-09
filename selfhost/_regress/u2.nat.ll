; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [4 x i8] c"pos\00", align 1
@1 = private unnamed_addr constant [4 x i8] c"neg\00", align 1
@2 = private unnamed_addr constant [5 x i8] c"zero\00", align 1
@3 = private unnamed_addr constant [4 x i8] c"pos\00", align 1
@4 = private unnamed_addr constant [5 x i8] c"zero\00", align 1

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

define ptr @_describe(i32 %0) {
entry:
  %gttmp = icmp sgt i32 %0, 0
  br i1 %gttmp, label %then, label %ifcont

then:                                             ; preds = %entry
  ret ptr @0

ifcont:                                           ; preds = %entry
  %lttmp = icmp slt i32 %0, 0
  br i1 %lttmp, label %then1, label %ifcont2

then1:                                            ; preds = %ifcont
  ret ptr @1

ifcont2:                                          ; preds = %ifcont
  ret ptr @2
}

define i32 @_main() {
entry:
  %calltmp = call ptr @_describe(i32 5)
  %calltmp1 = call ptr @_describe(i32 0)
  %str.equals = call i32 @csec_string_equals(ptr %calltmp, ptr @3)
  %str.eq = icmp ne i32 %str.equals, 0
  br i1 %str.eq, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  %str.equals2 = call i32 @csec_string_equals(ptr %calltmp1, ptr @4)
  %str.eq3 = icmp ne i32 %str.equals2, 0
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %and_result.0 = phi i1 [ %str.eq3, %and_rhs ], [ false, %entry ]
  br i1 %and_result.0, label %then, label %ifcont

then:                                             ; preds = %and_end
  ret i32 0

ifcont:                                           ; preds = %and_end
  ret i32 1
}

declare i32 @csec_string_equals(ptr, ptr)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
