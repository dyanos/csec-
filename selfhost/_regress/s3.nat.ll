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

define i32 @_classify(i32 %0) {
entry:
  %match.cond = icmp eq i32 %0, 0
  br i1 %match.cond, label %match.case, label %match.next

match.end:                                        ; preds = %match.case4, %match.case1, %match.case
  %match.result = phi i32 [ 100, %match.case ], [ 200, %match.case1 ], [ %multmp, %match.case4 ]
  %label = alloca i32, align 4
  store i32 %match.result, ptr %label, align 4
  %label.load = load i32, ptr %label, align 4
  ret i32 %label.load

match.case:                                       ; preds = %entry
  br label %match.end

match.next:                                       ; preds = %entry
  %match.cond3 = icmp eq i32 %0, 1
  br i1 %match.cond3, label %match.case1, label %match.next2

match.case1:                                      ; preds = %match.next
  br label %match.end

match.next2:                                      ; preds = %match.next
  br label %match.case4

match.case4:                                      ; preds = %match.next2
  %multmp = mul i32 %0, 10
  br label %match.end
}

define i32 @_main() {
entry:
  %calltmp = call i32 @_classify(i32 0)
  %eqtmp = icmp eq i32 %calltmp, 100
  br i1 %eqtmp, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  %calltmp1 = call i32 @_classify(i32 5)
  %eqtmp2 = icmp eq i32 %calltmp1, 50
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %and_result.0 = phi i1 [ %eqtmp2, %and_rhs ], [ false, %entry ]
  br i1 %and_result.0, label %then, label %ifcont

then:                                             ; preds = %and_end
  ret i32 0

ifcont:                                           ; preds = %and_end
  ret i32 1
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
