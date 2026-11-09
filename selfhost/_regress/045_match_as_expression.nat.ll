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
  %match.cond = icmp eq i32 2, 0
  br i1 %match.cond, label %match.case, label %match.next

match.end:                                        ; preds = %match.case7, %match.case4, %match.case1, %match.case
  %match.result = phi i32 [ 100, %match.case ], [ 200, %match.case1 ], [ 300, %match.case4 ], [ 0, %match.case7 ]
  %result = alloca i32, align 4
  store i32 %match.result, ptr %result, align 4
  %y = alloca i32, align 4
  store i32 0, ptr %y, align 4
  %y.load = load i32, ptr %y, align 4
  %match.cond12 = icmp eq i32 %y.load, 0
  br i1 %match.cond12, label %match.case10, label %match.next11

match.case:                                       ; preds = %entry
  br label %match.end

match.next:                                       ; preds = %entry
  %match.cond3 = icmp eq i32 2, 1
  br i1 %match.cond3, label %match.case1, label %match.next2

match.case1:                                      ; preds = %match.next
  br label %match.end

match.next2:                                      ; preds = %match.next
  %match.cond6 = icmp eq i32 2, 2
  br i1 %match.cond6, label %match.case4, label %match.next5

match.case4:                                      ; preds = %match.next2
  br label %match.end

match.next5:                                      ; preds = %match.next2
  br label %match.case7

match.case7:                                      ; preds = %match.next5
  br label %match.end

match.end8:                                       ; preds = %match.case13, %match.case10
  %match.result9 = phi i32 [ 1, %match.case10 ], [ 0, %match.case13 ]
  %another = alloca i32, align 4
  store i32 %match.result9, ptr %another, align 4
  %result.load = load i32, ptr %result, align 4
  %another.load = load i32, ptr %another, align 4
  %addtmp = add i32 %result.load, %another.load
  ret i32 %addtmp

match.case10:                                     ; preds = %match.end
  br label %match.end8

match.next11:                                     ; preds = %match.end
  br label %match.case13

match.case13:                                     ; preds = %match.next11
  br label %match.end8
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
