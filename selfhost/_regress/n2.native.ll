; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [1 x i8] zeroinitializer, align 1
@1 = private unnamed_addr constant [2 x i8] c"x\00", align 1

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
  br label %whilecond

whilecond:                                        ; preds = %whilebody, %entry
  %label.0 = phi ptr [ @0, %entry ], [ %str.concat, %whilebody ]
  %cursor.0 = phi i32 [ 0, %entry ], [ %addtmp, %whilebody ]
  %lttmp = icmp slt i32 %cursor.0, %0
  br i1 %lttmp, label %whilebody, label %afterwhile

whilebody:                                        ; preds = %whilecond
  %str.concat = call ptr @csec_string_concat(ptr %label.0, ptr @1)
  %addtmp = add i32 %cursor.0, 1
  br label %whilecond

afterwhile:                                       ; preds = %whilecond
  ret ptr %label.0
}

declare ptr @csec_string_concat(ptr, ptr)

define i32 @_main() {
entry:
  %calltmp = call ptr @_describe(i32 4)
  %str.length = call i64 @csec_string_length(ptr %calltmp)
  %eqtmp = icmp eq i64 %str.length, 4
  br i1 %eqtmp, label %then, label %ifcont

then:                                             ; preds = %entry
  ret i32 0

ifcont:                                           ; preds = %entry
  ret i32 1
}

declare i64 @csec_string_length(ptr)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
