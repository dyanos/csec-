; ModuleID = 'main'
source_filename = "main"

%Counter = type { i64 }
%Measure = type { float, double }

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
  %newobj.malloc = call ptr @malloc(i64 8)
  %start.init = getelementptr inbounds %Counter, ptr %newobj.malloc, i32 0, i32 0
  store i64 2147483653, ptr %start.init, align 4
  %calltmp = call i64 @Counter_value(ptr %newobj.malloc)
  %newobj.malloc1 = call ptr @malloc(i64 16)
  %width.init = getelementptr inbounds %Measure, ptr %newobj.malloc1, i32 0, i32 0
  store float 1.500000e+00, ptr %width.init, align 4
  %depth.init = getelementptr inbounds %Measure, ptr %newobj.malloc1, i32 0, i32 1
  store double 2.500000e+00, ptr %depth.init, align 8
  %calltmp2 = call double @Measure_area(ptr %newobj.malloc1)
  %eqtmp = icmp eq i64 %calltmp, 2147483653
  br i1 %eqtmp, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  %gttmp = fcmp ogt double %calltmp2, 0x4003333340000000
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %and_result.0 = phi i1 [ %gttmp, %and_rhs ], [ false, %entry ]
  br i1 %and_result.0, label %and_rhs4, label %and_end5

and_rhs4:                                         ; preds = %and_end
  %lttmp = fcmp olt double %calltmp2, 0x4004CCCCC0000000
  br label %and_end5

and_end5:                                         ; preds = %and_rhs4, %and_end
  %and_result3.0 = phi i1 [ %lttmp, %and_rhs4 ], [ false, %and_end ]
  br i1 %and_result3.0, label %then, label %ifcont

then:                                             ; preds = %and_end5
  ret i32 0

ifcont:                                           ; preds = %and_end5
  ret i32 1
}

define i64 @Counter_value(ptr %this) {
entry:
  %start.field = getelementptr inbounds %Counter, ptr %this, i32 0, i32 0
  %start.load = load i64, ptr %start.field, align 4
  ret i64 %start.load
}

define double @Measure_area(ptr %this) {
entry:
  %width.field = getelementptr inbounds %Measure, ptr %this, i32 0, i32 0
  %depth.field = getelementptr inbounds %Measure, ptr %this, i32 0, i32 1
  %depth.load = load double, ptr %depth.field, align 8
  ret double %depth.load
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
