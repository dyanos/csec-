; ModuleID = 'main'
source_filename = "main"

@0 = private unnamed_addr constant [6 x i8] c"ready\00", align 1
@1 = private unnamed_addr constant [5 x i8] c"done\00", align 1

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

define i32 @_adjust(i32 %0) {
entry:
  %addtmp = add i32 %0, 2
  ret i32 %addtmp
}

define i1 @_positive(i32 %0) {
entry:
  %gttmp = icmp sgt i32 %0, 0
  ret i1 %gttmp
}

define ptr @_label() {
entry:
  ret ptr @1
}

define i8 @_marker() {
entry:
  ret i8 120
}

define double @_ratio() {
entry:
  %value = alloca double, align 8
  store float 1.500000e+00, ptr %value, align 4
  %value.load = load double, ptr %value, align 8
  %value.load1 = load double, ptr %value, align 8
  %faddtmp = fadd double %value.load1, 2.000000e+00
  store double %faddtmp, ptr %value, align 8
  %value.load2 = load double, ptr %value, align 8
  ret double %value.load2
}

define i64 @_wide() {
entry:
  %total = alloca i64, align 8
  store i32 1000, ptr %total, align 4
  %total.load = load i64, ptr %total, align 4
  %total.load1 = load i64, ptr %total, align 4
  %addtmp = add i64 %total.load1, 24
  store i64 %addtmp, ptr %total, align 4
  %total.load2 = load i64, ptr %total, align 4
  ret i64 %total.load2
}

define void @_touch() {
entry:
  ret void
}

define i32 @_main() {
entry:
  %scale = alloca double, align 8
  store float 2.500000e+00, ptr %scale, align 4
  %scale.load = load double, ptr %scale, align 8
  store float 3.500000e+00, ptr %scale, align 4
  br i1 true, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  %gttmp = icmp sgt i32 3, 0
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %and_result.0 = phi i1 [ %gttmp, %and_rhs ], [ false, %entry ]
  %ifcond = icmp ne i1 %and_result.0, false
  br i1 %ifcond, label %then, label %else

then:                                             ; preds = %and_end
  %addtmp = add i32 3, 1
  br label %ifcont

else:                                             ; preds = %and_end
  %subtmp = sub i32 3, 1
  br label %ifcont

ifcont:                                           ; preds = %else, %then
  %current.0 = phi i32 [ %addtmp, %then ], [ %subtmp, %else ]
  %result = phi i32 [ %addtmp, %then ], [ %subtmp, %else ]
  br label %whilecond

whilecond:                                        ; preds = %whilebody, %ifcont
  %current.1 = phi i32 [ %current.0, %ifcont ], [ %subtmp11, %whilebody ]
  %gttmp8 = icmp sgt i32 %current.1, 1
  br i1 %gttmp8, label %whilebody, label %afterwhile

whilebody:                                        ; preds = %whilecond
  %subtmp11 = sub i32 %current.1, 1
  br label %whilecond

afterwhile:                                       ; preds = %whilecond
  %addtmp14 = add i32 %current.1, 1
  %calltmp = call i32 @_adjust(i32 %addtmp14)
  ret i32 %calltmp
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
