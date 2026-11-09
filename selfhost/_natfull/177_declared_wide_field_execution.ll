; ModuleID = 'main'
source_filename = "main"

%Tally = type { i64, double }

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
  %newobj.malloc = call ptr @malloc(i64 16)
  %total.init = getelementptr inbounds %Tally, ptr %newobj.malloc, i32 0, i32 0
  store i64 0, ptr %total.init, align 4
  %ratio.init = getelementptr inbounds %Tally, ptr %newobj.malloc, i32 0, i32 1
  store double 0.000000e+00, ptr %ratio.init, align 8
  %calltmp = call i64 @Tally_bump(ptr %newobj.malloc)
  %calltmp1 = call i64 @Tally_bump(ptr %newobj.malloc)
  %calltmp2 = call double @Tally_scale(ptr %newobj.malloc)
  %eqtmp = icmp eq i64 %calltmp, 2147483650
  br i1 %eqtmp, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  %eqtmp3 = icmp eq i64 %calltmp1, 4294967300
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %and_result.0 = phi i1 [ %eqtmp3, %and_rhs ], [ false, %entry ]
  br i1 %and_result.0, label %and_rhs5, label %and_end6

and_rhs5:                                         ; preds = %and_end
  %gttmp = fcmp ogt double %calltmp2, 0x3FF6666660000000
  br label %and_end6

and_end6:                                         ; preds = %and_rhs5, %and_end
  %and_result4.0 = phi i1 [ %gttmp, %and_rhs5 ], [ false, %and_end ]
  br i1 %and_result4.0, label %and_rhs9, label %and_end10

and_rhs9:                                         ; preds = %and_end6
  %lttmp = fcmp olt double %calltmp2, 0x3FF99999A0000000
  br label %and_end10

and_end10:                                        ; preds = %and_rhs9, %and_end6
  %and_result8.0 = phi i1 [ %lttmp, %and_rhs9 ], [ false, %and_end6 ]
  br i1 %and_result8.0, label %then, label %ifcont

then:                                             ; preds = %and_end10
  ret i32 0

ifcont:                                           ; preds = %and_end10
  ret i32 1
}

define i64 @Tally_bump(ptr %this) {
entry:
  %total.field = getelementptr inbounds %Tally, ptr %this, i32 0, i32 0
  %ratio.field = getelementptr inbounds %Tally, ptr %this, i32 0, i32 1
  %total.load = load i64, ptr %total.field, align 4
  %total.load1 = load i64, ptr %total.field, align 4
  %addtmp = add i64 %total.load1, 2147483650
  store i64 %addtmp, ptr %total.field, align 4
  %total.load2 = load i64, ptr %total.field, align 4
  ret i64 %total.load2
}

define double @Tally_scale(ptr %this) {
entry:
  %total.field = getelementptr inbounds %Tally, ptr %this, i32 0, i32 0
  %ratio.field = getelementptr inbounds %Tally, ptr %this, i32 0, i32 1
  %ratio.load = load double, ptr %ratio.field, align 8
  %ratio.load1 = load double, ptr %ratio.field, align 8
  %faddtmp = fadd double %ratio.load1, 1.500000e+00
  store double %faddtmp, ptr %ratio.field, align 8
  %ratio.load2 = load double, ptr %ratio.field, align 8
  ret double %ratio.load2
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
