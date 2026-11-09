; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [1 x i8] zeroinitializer, align 1
@1 = private unnamed_addr constant [4 x i8] c"one\00", align 1
@2 = private unnamed_addr constant [4 x i8] c"two\00", align 1
@3 = private unnamed_addr constant [6 x i8] c"three\00", align 1
@4 = private unnamed_addr constant [5 x i8] c"none\00", align 1
@5 = private unnamed_addr constant [6 x i8] c"three\00", align 1

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

define ptr @_pick(i32 %0) {
entry:
  %eqtmp = icmp eq i32 %0, 1
  br i1 %eqtmp, label %then, label %else

then:                                             ; preds = %entry
  br label %ifcont

else:                                             ; preds = %entry
  %eqtmp1 = icmp eq i32 %0, 2
  br i1 %eqtmp1, label %then2, label %else3

ifcont:                                           ; preds = %ifcont4, %then
  %result.0 = phi ptr [ @1, %then ], [ %result.1, %ifcont4 ]
  %str.length = call i64 @csec_string_length(ptr %result.0)
  %gttmp = icmp sgt i64 %str.length, 0
  br i1 %gttmp, label %then11, label %ifcont12

then2:                                            ; preds = %else
  br label %ifcont4

else3:                                            ; preds = %else
  %eqtmp6 = icmp eq i32 %0, 3
  br i1 %eqtmp6, label %then7, label %ifcont8

ifcont4:                                          ; preds = %ifcont8, %then2
  %result.1 = phi ptr [ @2, %then2 ], [ %result.2, %ifcont8 ]
  br label %ifcont

then7:                                            ; preds = %else3
  br label %ifcont8

ifcont8:                                          ; preds = %then7, %else3
  %result.2 = phi ptr [ @3, %then7 ], [ @0, %else3 ]
  br label %ifcont4

then11:                                           ; preds = %ifcont
  ret ptr %result.0

ifcont12:                                         ; preds = %ifcont
  ret ptr @4
}

declare i64 @csec_string_length(ptr)

define i32 @_main() {
entry:
  %calltmp = call ptr @_pick(i32 3)
  %eqtmp = icmp eq ptr %calltmp, @5
  br i1 %eqtmp, label %then, label %ifcont

then:                                             ; preds = %entry
  ret i32 0

ifcont:                                           ; preds = %entry
  ret i32 1
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
