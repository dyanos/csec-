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

define i32 @_dayName(i32 %0) {
entry:
  %match.cond = icmp eq i32 %0, 0
  br i1 %match.cond, label %match.case, label %match.next

match.end:                                        ; preds = %match.case19, %match.case16, %match.case13, %match.case10, %match.case7, %match.case4, %match.case1, %match.case
  %match.result = phi i32 [ 0, %match.case ], [ 10, %match.case1 ], [ 20, %match.case4 ], [ 30, %match.case7 ], [ 40, %match.case10 ], [ 50, %match.case13 ], [ 60, %match.case16 ], [ 99, %match.case19 ]
  ret i32 %match.result

match.case:                                       ; preds = %entry
  br label %match.end

match.next:                                       ; preds = %entry
  %match.cond3 = icmp eq i32 %0, 1
  br i1 %match.cond3, label %match.case1, label %match.next2

match.case1:                                      ; preds = %match.next
  br label %match.end

match.next2:                                      ; preds = %match.next
  %match.cond6 = icmp eq i32 %0, 2
  br i1 %match.cond6, label %match.case4, label %match.next5

match.case4:                                      ; preds = %match.next2
  br label %match.end

match.next5:                                      ; preds = %match.next2
  %match.cond9 = icmp eq i32 %0, 3
  br i1 %match.cond9, label %match.case7, label %match.next8

match.case7:                                      ; preds = %match.next5
  br label %match.end

match.next8:                                      ; preds = %match.next5
  %match.cond12 = icmp eq i32 %0, 4
  br i1 %match.cond12, label %match.case10, label %match.next11

match.case10:                                     ; preds = %match.next8
  br label %match.end

match.next11:                                     ; preds = %match.next8
  %match.cond15 = icmp eq i32 %0, 5
  br i1 %match.cond15, label %match.case13, label %match.next14

match.case13:                                     ; preds = %match.next11
  br label %match.end

match.next14:                                     ; preds = %match.next11
  %match.cond18 = icmp eq i32 %0, 6
  br i1 %match.cond18, label %match.case16, label %match.next17

match.case16:                                     ; preds = %match.next14
  br label %match.end

match.next17:                                     ; preds = %match.next14
  br label %match.case19

match.case19:                                     ; preds = %match.next17
  br label %match.end
}

define i32 @_grade(i32 %0) {
entry:
  %match.cond = icmp eq i32 %0, 100
  br i1 %match.cond, label %match.case, label %match.next

match.end:                                        ; preds = %match.case10, %match.case7, %match.case4, %match.case1, %match.case
  %match.result = phi i32 [ 4, %match.case ], [ 3, %match.case1 ], [ 2, %match.case4 ], [ 1, %match.case7 ], [ 0, %match.case10 ]
  ret i32 %match.result

match.case:                                       ; preds = %entry
  br label %match.end

match.next:                                       ; preds = %entry
  %match.cond3 = icmp eq i32 %0, 90
  br i1 %match.cond3, label %match.case1, label %match.next2

match.case1:                                      ; preds = %match.next
  br label %match.end

match.next2:                                      ; preds = %match.next
  %match.cond6 = icmp eq i32 %0, 80
  br i1 %match.cond6, label %match.case4, label %match.next5

match.case4:                                      ; preds = %match.next2
  br label %match.end

match.next5:                                      ; preds = %match.next2
  %match.cond9 = icmp eq i32 %0, 70
  br i1 %match.cond9, label %match.case7, label %match.next8

match.case7:                                      ; preds = %match.next5
  br label %match.end

match.next8:                                      ; preds = %match.next5
  br label %match.case10

match.case10:                                     ; preds = %match.next8
  br label %match.end
}

define i32 @_main() {
entry:
  %calltmp = call i32 @_dayName(i32 3)
  %calltmp1 = call i32 @_grade(i32 90)
  %addtmp = add i32 %calltmp, %calltmp1
  ret i32 %addtmp
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
