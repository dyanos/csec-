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
  %calltmp = call i32 @"Calculator#add"(i32 10, i32 20)
  %calltmp1 = call i32 @"Calculator#sub"(i32 50, i32 30)
  %calltmp2 = call i32 @"Calculator#mul"(i32 3, i32 4)
  %calltmp3 = call i32 @"Calculator#div"(i32 100, i32 5)
  %calltmp4 = call i32 @"Calculator#mod"(i32 17, i32 5)
  %calltmp5 = call i32 @"Calculator#abs"(i32 -42)
  %calltmp6 = call i32 @"Calculator#max"(i32 %calltmp, i32 %calltmp1)
  %calltmp7 = call i32 @"Calculator#min"(i32 %calltmp2, i32 %calltmp3)
  %addtmp = add i32 %calltmp, %calltmp1
  %addtmp11 = add i32 %addtmp, %calltmp2
  %addtmp13 = add i32 %addtmp11, %calltmp3
  %addtmp14 = add i32 %addtmp13, %calltmp4
  %addtmp15 = add i32 %addtmp14, %calltmp5
  %addtmp16 = add i32 %addtmp15, %calltmp6
  %addtmp17 = add i32 %addtmp16, %calltmp7
  ret i32 %addtmp17
}

define i32 @"Calculator#add"(i32 %0, i32 %1) {
entry:
  %addtmp = add i32 %0, %1
  ret i32 %addtmp
}

define i32 @"Calculator#sub"(i32 %0, i32 %1) {
entry:
  %subtmp = sub i32 %0, %1
  ret i32 %subtmp
}

define i32 @"Calculator#mul"(i32 %0, i32 %1) {
entry:
  %multmp = mul i32 %0, %1
  ret i32 %multmp
}

define i32 @"Calculator#div"(i32 %0, i32 %1) {
entry:
  %eqtmp = icmp eq i32 %1, 0
  br i1 %eqtmp, label %then, label %ifcont

then:                                             ; preds = %entry
  ret i32 0

ifcont:                                           ; preds = %entry
  %divtmp = sdiv i32 %0, %1
  ret i32 %divtmp
}

define i32 @"Calculator#mod"(i32 %0, i32 %1) {
entry:
  %eqtmp = icmp eq i32 %1, 0
  br i1 %eqtmp, label %then, label %ifcont

then:                                             ; preds = %entry
  ret i32 0

ifcont:                                           ; preds = %entry
  %modtmp = srem i32 %0, %1
  ret i32 %modtmp
}

define i32 @"Calculator#abs"(i32 %0) {
entry:
  %lttmp = icmp slt i32 %0, 0
  br i1 %lttmp, label %then, label %ifcont

then:                                             ; preds = %entry
  %subtmp = sub i32 0, %0
  ret i32 %subtmp

ifcont:                                           ; preds = %entry
  ret i32 %0
}

define i32 @"Calculator#max"(i32 %0, i32 %1) {
entry:
  %gttmp = icmp sgt i32 %0, %1
  br i1 %gttmp, label %then, label %ifcont

then:                                             ; preds = %entry
  ret i32 %0

ifcont:                                           ; preds = %entry
  ret i32 %1
}

define i32 @"Calculator#min"(i32 %0, i32 %1) {
entry:
  %lttmp = icmp slt i32 %0, %1
  br i1 %lttmp, label %then, label %ifcont

then:                                             ; preds = %entry
  ret i32 %0

ifcont:                                           ; preds = %entry
  ret i32 %1
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
