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
  %newobj.malloc = call ptr @malloc(i64 0)
  %calltmp = call float @BasicMath_abs(ptr %newobj.malloc, float -7.500000e+00)
  %calltmp1 = call float @BasicMath_sign(ptr %newobj.malloc, float -9.000000e+00)
  %calltmp2 = call float @BasicMath_sign(ptr %newobj.malloc, float 0.000000e+00)
  %calltmp3 = call float @BasicMath_sign(ptr %newobj.malloc, float 1.200000e+01)
  %calltmp4 = call float @BasicMath_floor(ptr %newobj.malloc, float 0x400F333340000000)
  %calltmp5 = call float @BasicMath_floor(ptr %newobj.malloc, float 0xC008CCCCC0000000)
  %calltmp6 = call float @BasicMath_ceil(ptr %newobj.malloc, float 0x4008CCCCC0000000)
  %calltmp7 = call float @BasicMath_ceil(ptr %newobj.malloc, float 0xC00F333340000000)
  %calltmp8 = call float @BasicMath_round(ptr %newobj.malloc, float 0x400CCCCCC0000000)
  %calltmp9 = call float @BasicMath_round(ptr %newobj.malloc, float 0xC00CCCCCC0000000)
  %calltmp10 = call float @BasicMath_clamp(ptr %newobj.malloc, float 1.200000e+01, float 0.000000e+00, float 1.000000e+01)
  %calltmp11 = call i1 @BasicMath_between(ptr %newobj.malloc, float 5.000000e+00, float 1.000000e+00, float 9.000000e+00)
  %calltmp12 = call i1 @BasicMath_approxEq(ptr %newobj.malloc, float 0x3FD3333340000000, float 0x3FD3333340000000, float 0x3EB0C6F7A0000000)
  %eqtmp = fcmp oeq float %calltmp, 7.500000e+00
  br i1 %eqtmp, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  %eqtmp13 = fcmp oeq float %calltmp1, -1.000000e+00
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %and_result.0 = phi i1 [ %eqtmp13, %and_rhs ], [ false, %entry ]
  br i1 %and_result.0, label %and_rhs15, label %and_end16

and_rhs15:                                        ; preds = %and_end
  %eqtmp17 = fcmp oeq float %calltmp2, 0.000000e+00
  br label %and_end16

and_end16:                                        ; preds = %and_rhs15, %and_end
  %and_result14.0 = phi i1 [ %eqtmp17, %and_rhs15 ], [ false, %and_end ]
  br i1 %and_result14.0, label %and_rhs20, label %and_end21

and_rhs20:                                        ; preds = %and_end16
  %eqtmp22 = fcmp oeq float %calltmp3, 1.000000e+00
  br label %and_end21

and_end21:                                        ; preds = %and_rhs20, %and_end16
  %and_result19.0 = phi i1 [ %eqtmp22, %and_rhs20 ], [ false, %and_end16 ]
  br i1 %and_result19.0, label %and_rhs25, label %and_end26

and_rhs25:                                        ; preds = %and_end21
  %eqtmp27 = fcmp oeq float %calltmp4, 3.000000e+00
  br label %and_end26

and_end26:                                        ; preds = %and_rhs25, %and_end21
  %and_result24.0 = phi i1 [ %eqtmp27, %and_rhs25 ], [ false, %and_end21 ]
  br i1 %and_result24.0, label %and_rhs30, label %and_end31

and_rhs30:                                        ; preds = %and_end26
  %eqtmp32 = fcmp oeq float %calltmp5, -4.000000e+00
  br label %and_end31

and_end31:                                        ; preds = %and_rhs30, %and_end26
  %and_result29.0 = phi i1 [ %eqtmp32, %and_rhs30 ], [ false, %and_end26 ]
  br i1 %and_result29.0, label %and_rhs35, label %and_end36

and_rhs35:                                        ; preds = %and_end31
  %eqtmp37 = fcmp oeq float %calltmp6, 4.000000e+00
  br label %and_end36

and_end36:                                        ; preds = %and_rhs35, %and_end31
  %and_result34.0 = phi i1 [ %eqtmp37, %and_rhs35 ], [ false, %and_end31 ]
  br i1 %and_result34.0, label %and_rhs40, label %and_end41

and_rhs40:                                        ; preds = %and_end36
  %eqtmp42 = fcmp oeq float %calltmp7, -3.000000e+00
  br label %and_end41

and_end41:                                        ; preds = %and_rhs40, %and_end36
  %and_result39.0 = phi i1 [ %eqtmp42, %and_rhs40 ], [ false, %and_end36 ]
  br i1 %and_result39.0, label %and_rhs45, label %and_end46

and_rhs45:                                        ; preds = %and_end41
  %eqtmp47 = fcmp oeq float %calltmp8, 4.000000e+00
  br label %and_end46

and_end46:                                        ; preds = %and_rhs45, %and_end41
  %and_result44.0 = phi i1 [ %eqtmp47, %and_rhs45 ], [ false, %and_end41 ]
  br i1 %and_result44.0, label %and_rhs50, label %and_end51

and_rhs50:                                        ; preds = %and_end46
  %eqtmp52 = fcmp oeq float %calltmp9, -4.000000e+00
  br label %and_end51

and_end51:                                        ; preds = %and_rhs50, %and_end46
  %and_result49.0 = phi i1 [ %eqtmp52, %and_rhs50 ], [ false, %and_end46 ]
  br i1 %and_result49.0, label %and_rhs55, label %and_end56

and_rhs55:                                        ; preds = %and_end51
  %calltmp57 = call float @BasicMath_min(ptr %newobj.malloc, float 2.000000e+00, float 5.000000e+00)
  %eqtmp58 = fcmp oeq float %calltmp57, 2.000000e+00
  br label %and_end56

and_end56:                                        ; preds = %and_rhs55, %and_end51
  %and_result54.0 = phi i1 [ %eqtmp58, %and_rhs55 ], [ false, %and_end51 ]
  br i1 %and_result54.0, label %and_rhs61, label %and_end62

and_rhs61:                                        ; preds = %and_end56
  %calltmp63 = call float @BasicMath_max(ptr %newobj.malloc, float 2.000000e+00, float 5.000000e+00)
  %eqtmp64 = fcmp oeq float %calltmp63, 5.000000e+00
  br label %and_end62

and_end62:                                        ; preds = %and_rhs61, %and_end56
  %and_result60.0 = phi i1 [ %eqtmp64, %and_rhs61 ], [ false, %and_end56 ]
  br i1 %and_result60.0, label %and_rhs67, label %and_end68

and_rhs67:                                        ; preds = %and_end62
  %eqtmp69 = fcmp oeq float %calltmp10, 1.000000e+01
  br label %and_end68

and_end68:                                        ; preds = %and_rhs67, %and_end62
  %and_result66.0 = phi i1 [ %eqtmp69, %and_rhs67 ], [ false, %and_end62 ]
  br i1 %and_result66.0, label %and_rhs72, label %and_end73

and_rhs72:                                        ; preds = %and_end68
  br label %and_end73

and_end73:                                        ; preds = %and_rhs72, %and_end68
  %and_result71.0 = phi i1 [ %calltmp11, %and_rhs72 ], [ false, %and_end68 ]
  br i1 %and_result71.0, label %and_rhs76, label %and_end77

and_rhs76:                                        ; preds = %and_end73
  br label %and_end77

and_end77:                                        ; preds = %and_rhs76, %and_end73
  %and_result75.0 = phi i1 [ %calltmp12, %and_rhs76 ], [ false, %and_end73 ]
  br i1 %and_result75.0, label %then, label %ifcont

then:                                             ; preds = %and_end77
  ret i32 0

ifcont:                                           ; preds = %and_end77
  ret i32 1
}

define float @BasicMath_abs(ptr %this, float %x) {
entry:
  %lttmp = fcmp olt float %x, 0.000000e+00
  br i1 %lttmp, label %then, label %ifcont

then:                                             ; preds = %entry
  %fsubtmp = fsub float 0.000000e+00, %x
  ret float %fsubtmp

ifcont:                                           ; preds = %entry
  ret float %x
}

define float @BasicMath_sign(ptr %this, float %x) {
entry:
  %lttmp = fcmp olt float %x, 0.000000e+00
  br i1 %lttmp, label %then, label %ifcont

then:                                             ; preds = %entry
  ret float -1.000000e+00

ifcont:                                           ; preds = %entry
  %gttmp = fcmp ogt float %x, 0.000000e+00
  br i1 %gttmp, label %then1, label %ifcont2

then1:                                            ; preds = %ifcont
  ret float 1.000000e+00

ifcont2:                                          ; preds = %ifcont
  ret float 0.000000e+00
}

define float @BasicMath_floor(ptr %this, float %x) {
entry:
  %getmp = fcmp oge float %x, 0.000000e+00
  br i1 %getmp, label %then, label %ifcont

then:                                             ; preds = %entry
  br label %whilecond

ifcont:                                           ; preds = %entry
  br label %whilecond5

whilecond:                                        ; preds = %whilebody, %then
  %whole.0 = phi float [ 0.000000e+00, %then ], [ %faddtmp3, %whilebody ]
  %faddtmp = fadd float %whole.0, 1.000000e+00
  %letmp = fcmp ole float %faddtmp, %x
  br i1 %letmp, label %whilebody, label %afterwhile

whilebody:                                        ; preds = %whilecond
  %faddtmp3 = fadd float %whole.0, 1.000000e+00
  br label %whilecond

afterwhile:                                       ; preds = %whilecond
  ret float %whole.0

whilecond5:                                       ; preds = %whilebody6, %ifcont
  %whole.1 = phi float [ 0.000000e+00, %ifcont ], [ %fsubtmp, %whilebody6 ]
  %gttmp = fcmp ogt float %whole.1, %x
  br i1 %gttmp, label %whilebody6, label %afterwhile7

whilebody6:                                       ; preds = %whilecond5
  %fsubtmp = fsub float %whole.1, 1.000000e+00
  br label %whilecond5

afterwhile7:                                      ; preds = %whilecond5
  ret float %whole.1
}

define float @BasicMath_ceil(ptr %this, float %x) {
entry:
  %getmp = fcmp oge float %x, 0.000000e+00
  br i1 %getmp, label %then, label %ifcont

then:                                             ; preds = %entry
  br label %whilecond

ifcont:                                           ; preds = %entry
  br label %whilecond4

whilecond:                                        ; preds = %whilebody, %then
  %whole.0 = phi float [ 0.000000e+00, %then ], [ %faddtmp, %whilebody ]
  %lttmp = fcmp olt float %whole.0, %x
  br i1 %lttmp, label %whilebody, label %afterwhile

whilebody:                                        ; preds = %whilecond
  %faddtmp = fadd float %whole.0, 1.000000e+00
  br label %whilecond

afterwhile:                                       ; preds = %whilecond
  ret float %whole.0

whilecond4:                                       ; preds = %whilebody5, %ifcont
  %whole.1 = phi float [ 0.000000e+00, %ifcont ], [ %fsubtmp11, %whilebody5 ]
  %fsubtmp = fsub float %whole.1, 1.000000e+00
  %getmp8 = fcmp oge float %fsubtmp, %x
  br i1 %getmp8, label %whilebody5, label %afterwhile6

whilebody5:                                       ; preds = %whilecond4
  %fsubtmp11 = fsub float %whole.1, 1.000000e+00
  br label %whilecond4

afterwhile6:                                      ; preds = %whilecond4
  ret float %whole.1
}

define float @BasicMath_round(ptr %this, float %x) {
entry:
  %getmp = fcmp oge float %x, 0.000000e+00
  br i1 %getmp, label %then, label %ifcont

then:                                             ; preds = %entry
  %faddtmp = fadd float %x, 5.000000e-01
  %target = alloca float, align 4
  store float %faddtmp, ptr %target, align 4
  br label %whilecond

ifcont:                                           ; preds = %entry
  %fsubtmp = fsub float %x, 5.000000e-01
  %target6 = alloca float, align 4
  store float %fsubtmp, ptr %target6, align 4
  br label %whilecond7

whilecond:                                        ; preds = %whilebody, %then
  %whole.0 = phi float [ 0.000000e+00, %then ], [ %faddtmp4, %whilebody ]
  %faddtmp1 = fadd float %whole.0, 1.000000e+00
  %target.load = load float, ptr %target, align 4
  %letmp = fcmp ole float %faddtmp1, %target.load
  br i1 %letmp, label %whilebody, label %afterwhile

whilebody:                                        ; preds = %whilecond
  %faddtmp4 = fadd float %whole.0, 1.000000e+00
  br label %whilecond

afterwhile:                                       ; preds = %whilecond
  ret float %whole.0

whilecond7:                                       ; preds = %whilebody8, %ifcont
  %whole.1 = phi float [ 0.000000e+00, %ifcont ], [ %fsubtmp16, %whilebody8 ]
  %fsubtmp11 = fsub float %whole.1, 1.000000e+00
  %target.load12 = load float, ptr %target6, align 4
  %getmp13 = fcmp oge float %fsubtmp11, %target.load12
  br i1 %getmp13, label %whilebody8, label %afterwhile9

whilebody8:                                       ; preds = %whilecond7
  %fsubtmp16 = fsub float %whole.1, 1.000000e+00
  br label %whilecond7

afterwhile9:                                      ; preds = %whilecond7
  ret float %whole.1
}

define float @BasicMath_min(ptr %this, float %left, float %right) {
entry:
  %lttmp = fcmp olt float %left, %right
  br i1 %lttmp, label %then, label %ifcont

then:                                             ; preds = %entry
  ret float %left

ifcont:                                           ; preds = %entry
  ret float %right
}

define float @BasicMath_max(ptr %this, float %left, float %right) {
entry:
  %gttmp = fcmp ogt float %left, %right
  br i1 %gttmp, label %then, label %ifcont

then:                                             ; preds = %entry
  ret float %left

ifcont:                                           ; preds = %entry
  ret float %right
}

define float @BasicMath_clamp(ptr %this, float %value, float %low, float %high) {
entry:
  %lttmp = fcmp olt float %value, %low
  br i1 %lttmp, label %then, label %ifcont

then:                                             ; preds = %entry
  ret float %low

ifcont:                                           ; preds = %entry
  %gttmp = fcmp ogt float %value, %high
  br i1 %gttmp, label %then1, label %ifcont2

then1:                                            ; preds = %ifcont
  ret float %high

ifcont2:                                          ; preds = %ifcont
  ret float %value
}

define i1 @BasicMath_between(ptr %this, float %value, float %low, float %high) {
entry:
  %getmp = fcmp oge float %value, %low
  br i1 %getmp, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  %letmp = fcmp ole float %value, %high
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %and_result.0 = phi i1 [ %letmp, %and_rhs ], [ false, %entry ]
  ret i1 %and_result.0
}

define i1 @BasicMath_approxEq(ptr %this, float %left, float %right, float %epsilon) {
entry:
  %fsubtmp = fsub float %left, %right
  %lttmp = fcmp olt float %fsubtmp, 0.000000e+00
  br i1 %lttmp, label %then, label %ifcont

then:                                             ; preds = %entry
  %fsubtmp3 = fsub float 0.000000e+00, %fsubtmp
  br label %ifcont

ifcont:                                           ; preds = %then, %entry
  %diff.0 = phi float [ %fsubtmp3, %then ], [ %fsubtmp, %entry ]
  %letmp = fcmp ole float %diff.0, %epsilon
  ret i1 %letmp
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
