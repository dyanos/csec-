; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [2 x i8] c"!\00", align 1
@1 = private unnamed_addr constant [3 x i8] c"hi\00", align 1
@2 = private unnamed_addr constant [2 x i8] c"[\00", align 1
@3 = private unnamed_addr constant [2 x i8] c"x\00", align 1
@4 = private unnamed_addr constant [4 x i8] c"hi!\00", align 1

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
  %calltmp = call ptr @Greeter_greet(ptr %newobj.malloc, ptr @1)
  %calltmp1 = call ptr @Greeter_wrap(ptr %newobj.malloc, ptr @2, ptr @3)
  %str.equals = call i32 @csec_string_equals(ptr %calltmp, ptr @4)
  %str.eq = icmp ne i32 %str.equals, 0
  br i1 %str.eq, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  %str.length = call i64 @csec_string_length(ptr %calltmp1)
  %eqtmp = icmp eq i64 %str.length, 2
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %and_result.0 = phi i1 [ %eqtmp, %and_rhs ], [ false, %entry ]
  br i1 %and_result.0, label %then, label %ifcont

then:                                             ; preds = %and_end
  ret i32 0

ifcont:                                           ; preds = %and_end
  ret i32 1
}

define ptr @Greeter_greet(ptr %this, ptr %name) {
entry:
  %str.concat = call ptr @csec_string_concat(ptr %name, ptr @0)
  ret ptr %str.concat
}

define ptr @Greeter_wrap(ptr %this, ptr %prefix, ptr %name) {
entry:
  %str.concat = call ptr @csec_string_concat(ptr %prefix, ptr %name)
  ret ptr %str.concat
}

declare ptr @csec_string_concat(ptr, ptr)

declare i32 @csec_string_equals(ptr, ptr)

declare i64 @csec_string_length(ptr)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
