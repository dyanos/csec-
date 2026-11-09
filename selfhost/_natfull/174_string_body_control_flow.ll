; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [1 x i8] zeroinitializer, align 1
@1 = private unnamed_addr constant [4 x i8] c"one\00", align 1
@2 = private unnamed_addr constant [4 x i8] c"two\00", align 1
@3 = private unnamed_addr constant [6 x i8] c"three\00", align 1
@4 = private unnamed_addr constant [5 x i8] c"none\00", align 1
@5 = private unnamed_addr constant [1 x i8] zeroinitializer, align 1
@6 = private unnamed_addr constant [2 x i8] c"x\00", align 1

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

define ptr @_describe(i32 %0) {
entry:
  br label %whilecond

whilecond:                                        ; preds = %whilebody, %entry
  %label.0 = phi ptr [ @5, %entry ], [ %str.concat, %whilebody ]
  %cursor.0 = phi i32 [ 0, %entry ], [ %addtmp, %whilebody ]
  %lttmp = icmp slt i32 %cursor.0, %0
  br i1 %lttmp, label %whilebody, label %afterwhile

whilebody:                                        ; preds = %whilecond
  %str.concat = call ptr @csec_string_concat(ptr %label.0, ptr @6)
  %addtmp = add i32 %cursor.0, 1
  br label %whilecond

afterwhile:                                       ; preds = %whilecond
  ret ptr %label.0
}

define i32 @_main() {
entry:
  %calltmp = call ptr @_pick(i32 3)
  %calltmp1 = call ptr @_pick(i32 9)
  %calltmp2 = call ptr @_describe(i32 4)
  %str.length = call i64 @csec_string_length(ptr %calltmp)
  %eqtmp = icmp eq i64 %str.length, 5
  br i1 %eqtmp, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  %str.length3 = call i64 @csec_string_length(ptr %calltmp1)
  %eqtmp4 = icmp eq i64 %str.length3, 4
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %and_result.0 = phi i1 [ %eqtmp4, %and_rhs ], [ false, %entry ]
  br i1 %and_result.0, label %and_rhs6, label %and_end7

and_rhs6:                                         ; preds = %and_end
  %str.length8 = call i64 @csec_string_length(ptr %calltmp2)
  %eqtmp9 = icmp eq i64 %str.length8, 4
  br label %and_end7

and_end7:                                         ; preds = %and_rhs6, %and_end
  %and_result5.0 = phi i1 [ %eqtmp9, %and_rhs6 ], [ false, %and_end ]
  br i1 %and_result5.0, label %then, label %ifcont

then:                                             ; preds = %and_end7
  ret i32 0

ifcont:                                           ; preds = %and_end7
  ret i32 1
}

declare i64 @csec_string_length(ptr)

declare ptr @csec_string_concat(ptr, ptr)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
