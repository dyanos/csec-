; ModuleID = 'main'
source_filename = "main"

%"\E7\82\B9" = type { i32, i32 }

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

define i32 @"_\E5\90\88\E8\A8\88"(i32 %0, i32 %1) {
entry:
  br label %forcond

forcond:                                          ; preds = %loop, %entry
  %"\E6\95\B0_ptr.0" = phi i32 [ %0, %entry ], [ %next_i, %loop ]
  %"\E7\B5\90\E6\9E\9C.0" = phi i32 [ 0, %entry ], [ %addtmp, %loop ]
  %cond = icmp sle i32 %"\E6\95\B0_ptr.0", %1
  br i1 %cond, label %loop, label %afterloop

loop:                                             ; preds = %forcond
  %addtmp = add i32 %"\E7\B5\90\E6\9E\9C.0", %"\E6\95\B0_ptr.0"
  %next_i = add i32 %"\E6\95\B0_ptr.0", 1
  br label %forcond

afterloop:                                        ; preds = %forcond
  ret i32 %"\E7\B5\90\E6\9E\9C.0"
}

define i32 @_main() {
entry:
  %calltmp = call i32 @"_\E5\90\88\E8\A8\88"(i32 1, i32 10)
  %newobj.malloc = call ptr @malloc(i64 8)
  %"x\E5\BA\A7\E6\A8\99.init" = getelementptr inbounds %"\E7\82\B9", ptr %newobj.malloc, i32 0, i32 0
  store i32 3, ptr %"x\E5\BA\A7\E6\A8\99.init", align 4
  %"y\E5\BA\A7\E6\A8\99.init" = getelementptr inbounds %"\E7\82\B9", ptr %newobj.malloc, i32 0, i32 1
  store i32 4, ptr %"y\E5\BA\A7\E6\A8\99.init", align 4
  %calltmp1 = call i32 @"\E7\82\B9_\E8\B7\9D\E9\9B\A2"(ptr %newobj.malloc)
  %addtmp = add i32 %calltmp, %calltmp1
  ret i32 %addtmp
}

define i32 @"\E7\82\B9_\E8\B7\9D\E9\9B\A2"(ptr %this) {
entry:
  %"x\E5\BA\A7\E6\A8\99.field" = getelementptr inbounds %"\E7\82\B9", ptr %this, i32 0, i32 0
  %"y\E5\BA\A7\E6\A8\99.field" = getelementptr inbounds %"\E7\82\B9", ptr %this, i32 0, i32 1
  %"x\E5\BA\A7\E6\A8\99.load" = load i32, ptr %"x\E5\BA\A7\E6\A8\99.field", align 4
  %"y\E5\BA\A7\E6\A8\99.load" = load i32, ptr %"y\E5\BA\A7\E6\A8\99.field", align 4
  %addtmp = add i32 %"x\E5\BA\A7\E6\A8\99.load", %"y\E5\BA\A7\E6\A8\99.load"
  ret i32 %addtmp
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
