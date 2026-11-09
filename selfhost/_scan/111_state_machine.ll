; ModuleID = 'main'
source_filename = "main"

%StateMachine = type { i32, i32 }

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
  %initialState.init = getelementptr inbounds %StateMachine, ptr %newobj.malloc, i32 0, i32 0
  store i32 0, ptr %initialState.init, align 4
  %state.init = getelementptr inbounds %StateMachine, ptr %newobj.malloc, i32 0, i32 1
  store i32 0, ptr %state.init, align 4
  %calltmp = call i32 @StateMachine_transition(ptr %newobj.malloc, i32 1)
  %calltmp1 = call i32 @StateMachine_transition(ptr %newobj.malloc, i32 2)
  %calltmp2 = call i32 @StateMachine_transition(ptr %newobj.malloc, i32 1)
  %calltmp3 = call i32 @StateMachine_transition(ptr %newobj.malloc, i32 3)
  %calltmp4 = call i32 @StateMachine_getState(ptr %newobj.malloc)
  ret i32 %calltmp4
}

define i32 @StateMachine_getState(ptr %this) {
entry:
  %initialState.field = getelementptr inbounds %StateMachine, ptr %this, i32 0, i32 0
  %state.field = getelementptr inbounds %StateMachine, ptr %this, i32 0, i32 1
  %state.load = load i32, ptr %state.field, align 4
  ret i32 %state.load
}

define i32 @StateMachine_transition(ptr %this, i32 %event) {
entry:
  %initialState.field = getelementptr inbounds %StateMachine, ptr %this, i32 0, i32 0
  %state.field = getelementptr inbounds %StateMachine, ptr %this, i32 0, i32 1
  %state.load = load i32, ptr %state.field, align 4
  %match.cond = icmp eq i32 %state.load, 0
  br i1 %match.cond, label %match.case, label %match.next

match.end:                                        ; preds = %match.case31, %match.end22, %match.end10, %match.end1
  %match.result = phi i32 [ %match.result2, %match.end1 ], [ %match.result11, %match.end10 ], [ %match.result23, %match.end22 ], [ 3, %match.case31 ]
  %next = alloca i32, align 4
  store i32 %match.result, ptr %next, align 4
  %state.load32 = load i32, ptr %state.field, align 4
  %next.load = load i32, ptr %next, align 4
  store i32 %next.load, ptr %state.field, align 4
  %state.load33 = load i32, ptr %state.field, align 4
  ret i32 %state.load33

match.case:                                       ; preds = %entry
  %match.cond5 = icmp eq i32 %event, 1
  br i1 %match.cond5, label %match.case3, label %match.next4

match.next:                                       ; preds = %entry
  %match.cond9 = icmp eq i32 %state.load, 1
  br i1 %match.cond9, label %match.case7, label %match.next8

match.end1:                                       ; preds = %match.case6, %match.case3
  %match.result2 = phi i32 [ 1, %match.case3 ], [ 0, %match.case6 ]
  br label %match.end

match.case3:                                      ; preds = %match.case
  br label %match.end1

match.next4:                                      ; preds = %match.case
  br label %match.case6

match.case6:                                      ; preds = %match.next4
  br label %match.end1

match.case7:                                      ; preds = %match.next
  %match.cond14 = icmp eq i32 %event, 2
  br i1 %match.cond14, label %match.case12, label %match.next13

match.next8:                                      ; preds = %match.next
  %match.cond21 = icmp eq i32 %state.load, 2
  br i1 %match.cond21, label %match.case19, label %match.next20

match.end10:                                      ; preds = %match.case18, %match.case15, %match.case12
  %match.result11 = phi i32 [ 2, %match.case12 ], [ 3, %match.case15 ], [ 1, %match.case18 ]
  br label %match.end

match.case12:                                     ; preds = %match.case7
  br label %match.end10

match.next13:                                     ; preds = %match.case7
  %match.cond17 = icmp eq i32 %event, 3
  br i1 %match.cond17, label %match.case15, label %match.next16

match.case15:                                     ; preds = %match.next13
  br label %match.end10

match.next16:                                     ; preds = %match.next13
  br label %match.case18

match.case18:                                     ; preds = %match.next16
  br label %match.end10

match.case19:                                     ; preds = %match.next8
  %match.cond26 = icmp eq i32 %event, 1
  br i1 %match.cond26, label %match.case24, label %match.next25

match.next20:                                     ; preds = %match.next8
  br label %match.case31

match.end22:                                      ; preds = %match.case30, %match.case27, %match.case24
  %match.result23 = phi i32 [ 1, %match.case24 ], [ 3, %match.case27 ], [ 2, %match.case30 ]
  br label %match.end

match.case24:                                     ; preds = %match.case19
  br label %match.end22

match.next25:                                     ; preds = %match.case19
  %match.cond29 = icmp eq i32 %event, 3
  br i1 %match.cond29, label %match.case27, label %match.next28

match.case27:                                     ; preds = %match.next25
  br label %match.end22

match.next28:                                     ; preds = %match.next25
  br label %match.case30

match.case30:                                     ; preds = %match.next28
  br label %match.end22

match.case31:                                     ; preds = %match.next20
  br label %match.end
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
