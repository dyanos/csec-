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

define i32 @_score(i32 %0) {
entry:
  %match.cond = icmp eq i32 %0, 0
  br i1 %match.cond, label %match.case, label %match.next

match.end:                                        ; preds = %match.case7, %match.case4, %match.case1, %match.case
  %match.result = phi i32 [ 100, %match.case ], [ 10, %match.case1 ], [ 1, %match.case4 ], [ 0, %match.case7 ]
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
  br label %match.case7

match.case7:                                      ; preds = %match.next5
  br label %match.end
}

define i32 @_main() {
entry:
  %calltmp = call i32 @_score(i32 1)
  ret i32 %calltmp
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
