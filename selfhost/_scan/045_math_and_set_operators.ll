; ModuleID = 'main'
source_filename = "main"

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
  %powtmp = call double @csec_math_pow(double 2.000000e+00, double 3.000000e+00)
  %power = alloca double, align 8
  store double %powtmp, ptr %power, align 8
  %setunion = or i64 20, 10
  %setintersect = and i64 %setunion, 20
  %setnotrhs = xor i64 10, -1
  %setdiff = and i64 %setunion, %setnotrhs
  %setsymdiff = xor i64 %setunion, 20
  %membermask = and i64 %setunion, 4
  %contains = icmp ne i64 %membermask, 0
  %membermask8 = and i64 %setunion, 32
  %contains9 = icmp ne i64 %membermask8, 0
  %notcontains = xor i1 %contains9, true
  %prednotrhs = xor i64 %setunion, -1
  %leftminusright = and i64 20, %prednotrhs
  %prednotlhs = xor i64 20, -1
  %rightminusleft = and i64 %setunion, %prednotlhs
  %subsettmp = icmp eq i64 %leftminusright, 0
  %supersettmp = icmp eq i64 %rightminusleft, 0
  %prednotrhs14 = xor i64 10, -1
  %leftminusright15 = and i64 %setunion, %prednotrhs14
  %prednotlhs16 = xor i64 %setunion, -1
  %rightminusleft17 = and i64 10, %prednotlhs16
  %subsettmp18 = icmp eq i64 %leftminusright15, 0
  %supersettmp19 = icmp eq i64 %rightminusleft17, 0
  %prednotrhs22 = xor i64 %setunion, -1
  %leftminusright23 = and i64 20, %prednotrhs22
  %prednotlhs24 = xor i64 20, -1
  %rightminusleft25 = and i64 %setunion, %prednotlhs24
  %subsettmp26 = icmp eq i64 %leftminusright23, 0
  %supersettmp27 = icmp eq i64 %rightminusleft25, 0
  %setnetmp = icmp ne i64 20, %setunion
  %propersubsettmp = and i1 %subsettmp26, %setnetmp
  br i1 %contains, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %and_result.0 = phi i1 [ %notcontains, %and_rhs ], [ false, %entry ]
  br i1 %subsettmp, label %and_rhs29, label %and_end30

and_rhs29:                                        ; preds = %and_end
  br label %and_end30

and_end30:                                        ; preds = %and_rhs29, %and_end
  %and_result28.0 = phi i1 [ %supersettmp19, %and_rhs29 ], [ false, %and_end ]
  %ifftmp = icmp eq i1 %and_result.0, %and_result28.0
  %equivalent = alloca i1, align 1
  store i1 %ifftmp, ptr %equivalent, align 1
  %equivalent.load = load i1, ptr %equivalent, align 1
  %notlhs = xor i1 %propersubsettmp, true
  %impliestmp = or i1 %notlhs, %equivalent.load
  %implication = alloca i1, align 1
  store i1 %impliestmp, ptr %implication, align 1
  %power.load = load ptr, ptr %power, align 8
  ret i32 1
}

declare double @csec_math_pow(double, double)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
