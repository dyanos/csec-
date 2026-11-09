; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [5 x i8] c"step\00", align 1

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

define float @_scaled(i32 %0) {
entry:
  br label %whilecond

whilecond:                                        ; preds = %whilebody, %entry
  %cursor.0 = phi i32 [ 0, %entry ], [ %addtmp, %whilebody ]
  %total.0 = phi float [ 0.000000e+00, %entry ], [ %faddtmp, %whilebody ]
  %lttmp = icmp slt i32 %cursor.0, %0
  br i1 %lttmp, label %whilebody, label %afterwhile

whilebody:                                        ; preds = %whilecond
  %faddtmp = fadd float %total.0, 1.500000e+00
  %addtmp = add i32 %cursor.0, 1
  br label %whilecond

afterwhile:                                       ; preds = %whilecond
  %str.length = call i64 @csec_string_length(ptr @0)
  %eqtmp = icmp eq i64 %str.length, 4
  br i1 %eqtmp, label %then, label %ifcont

then:                                             ; preds = %afterwhile
  ret float %total.0

ifcont:                                           ; preds = %afterwhile
  ret float 0.000000e+00
}

declare i64 @csec_string_length(ptr)

define double @_scaledDouble(i32 %0) {
entry:
  br label %whilecond

whilecond:                                        ; preds = %whilebody, %entry
  %cursor.0 = phi i32 [ 0, %entry ], [ %addtmp, %whilebody ]
  %total.0 = phi double [ 0.000000e+00, %entry ], [ %faddtmp, %whilebody ]
  %lttmp = icmp slt i32 %cursor.0, %0
  br i1 %lttmp, label %whilebody, label %afterwhile

whilebody:                                        ; preds = %whilecond
  %faddtmp = fadd double %total.0, 2.500000e+00
  %addtmp = add i32 %cursor.0, 1
  br label %whilecond

afterwhile:                                       ; preds = %whilecond
  ret double %total.0
}

define i32 @_main() {
entry:
  %calltmp = call float @_scaled(i32 4)
  %calltmp1 = call double @_scaledDouble(i32 4)
  %gttmp = fcmp ogt float %calltmp, 0x40179999A0000000
  br i1 %gttmp, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  %lttmp = fcmp olt float %calltmp, 0x4018666660000000
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %and_result.0 = phi i1 [ %lttmp, %and_rhs ], [ false, %entry ]
  br i1 %and_result.0, label %and_rhs4, label %and_end5

and_rhs4:                                         ; preds = %and_end
  %gttmp6 = fcmp ogt double %calltmp1, 0x4023CCCCC0000000
  br label %and_end5

and_end5:                                         ; preds = %and_rhs4, %and_end
  %and_result3.0 = phi i1 [ %gttmp6, %and_rhs4 ], [ false, %and_end ]
  br i1 %and_result3.0, label %and_rhs9, label %and_end10

and_rhs9:                                         ; preds = %and_end5
  %lttmp12 = fcmp olt double %calltmp1, 0x4024333340000000
  br label %and_end10

and_end10:                                        ; preds = %and_rhs9, %and_end5
  %and_result8.0 = phi i1 [ %lttmp12, %and_rhs9 ], [ false, %and_end5 ]
  br i1 %and_result8.0, label %then, label %ifcont

then:                                             ; preds = %and_end10
  ret i32 0

ifcont:                                           ; preds = %and_end10
  ret i32 1
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
