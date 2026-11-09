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
  br label %whilecond

whilecond:                                        ; preds = %afterwhile3, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %addtmp11, %afterwhile3 ]
  %total.0 = phi i32 [ 0, %entry ], [ %total.1, %afterwhile3 ]
  %lttmp = icmp slt i32 %i.0, 5
  br i1 %lttmp, label %whilebody, label %afterwhile

whilebody:                                        ; preds = %whilecond
  %j = alloca i32, align 4
  store i32 0, ptr %j, align 4
  br label %whilecond1

afterwhile:                                       ; preds = %whilecond
  %eqtmp = icmp eq i32 %total.0, 25
  br i1 %eqtmp, label %then, label %ifcont

whilecond1:                                       ; preds = %whilebody2, %whilebody
  %total.1 = phi i32 [ %total.0, %whilebody ], [ %addtmp, %whilebody2 ]
  %j.load = load i32, ptr %j, align 4
  %lttmp4 = icmp slt i32 %j.load, 5
  br i1 %lttmp4, label %whilebody2, label %afterwhile3

whilebody2:                                       ; preds = %whilecond1
  %addtmp = add i32 %total.1, 1
  %j.load6 = load i32, ptr %j, align 4
  %j.load7 = load i32, ptr %j, align 4
  %addtmp8 = add i32 %j.load7, 1
  store i32 %addtmp8, ptr %j, align 4
  br label %whilecond1

afterwhile3:                                      ; preds = %whilecond1
  %addtmp11 = add i32 %i.0, 1
  br label %whilecond

then:                                             ; preds = %afterwhile
  ret i32 0

ifcont:                                           ; preds = %afterwhile
  ret i32 1
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
