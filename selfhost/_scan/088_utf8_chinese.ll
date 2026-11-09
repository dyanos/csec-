; ModuleID = 'main'
source_filename = "main"

%"\E7\9F\A9\E5\BD\A2" = type { i32, i32 }

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

define i32 @"_\E6\B1\82\E5\92\8C"(i32 %0, i32 %1) {
entry:
  br label %forcond

forcond:                                          ; preds = %loop, %entry
  %"\E6\95\B0\E5\AD\97_ptr.0" = phi i32 [ %0, %entry ], [ %next_i, %loop ]
  %"\E7\BB\93\E6\9E\9C.0" = phi i32 [ 0, %entry ], [ %addtmp, %loop ]
  %cond = icmp sle i32 %"\E6\95\B0\E5\AD\97_ptr.0", %1
  br i1 %cond, label %loop, label %afterloop

loop:                                             ; preds = %forcond
  %addtmp = add i32 %"\E7\BB\93\E6\9E\9C.0", %"\E6\95\B0\E5\AD\97_ptr.0"
  %next_i = add i32 %"\E6\95\B0\E5\AD\97_ptr.0", 1
  br label %forcond

afterloop:                                        ; preds = %forcond
  ret i32 %"\E7\BB\93\E6\9E\9C.0"
}

define i32 @_main() {
entry:
  %calltmp = call i32 @"_\E6\B1\82\E5\92\8C"(i32 1, i32 5)
  %newobj.malloc = call ptr @malloc(i64 8)
  %"\E5\AE\BD\E5\BA\A6.init" = getelementptr inbounds %"\E7\9F\A9\E5\BD\A2", ptr %newobj.malloc, i32 0, i32 0
  store i32 3, ptr %"\E5\AE\BD\E5\BA\A6.init", align 4
  %"\E9\AB\98\E5\BA\A6.init" = getelementptr inbounds %"\E7\9F\A9\E5\BD\A2", ptr %newobj.malloc, i32 0, i32 1
  store i32 4, ptr %"\E9\AB\98\E5\BA\A6.init", align 4
  %calltmp1 = call i32 @"\E5\B7\A5\E5\85\B7#\E7\BB\9D\E5\AF\B9\E5\80\BC"(i32 -10)
  %calltmp2 = call i32 @"\E7\9F\A9\E5\BD\A2_\E9\9D\A2\E7\A7\AF"(ptr %newobj.malloc)
  %addtmp = add i32 %calltmp, %calltmp2
  %addtmp3 = add i32 %addtmp, %calltmp1
  ret i32 %addtmp3
}

define i32 @"\E7\9F\A9\E5\BD\A2_\E9\9D\A2\E7\A7\AF"(ptr %this) {
entry:
  %"\E5\AE\BD\E5\BA\A6.field" = getelementptr inbounds %"\E7\9F\A9\E5\BD\A2", ptr %this, i32 0, i32 0
  %"\E9\AB\98\E5\BA\A6.field" = getelementptr inbounds %"\E7\9F\A9\E5\BD\A2", ptr %this, i32 0, i32 1
  %"\E5\AE\BD\E5\BA\A6.load" = load i32, ptr %"\E5\AE\BD\E5\BA\A6.field", align 4
  %"\E9\AB\98\E5\BA\A6.load" = load i32, ptr %"\E9\AB\98\E5\BA\A6.field", align 4
  %multmp = mul i32 %"\E5\AE\BD\E5\BA\A6.load", %"\E9\AB\98\E5\BA\A6.load"
  ret i32 %multmp
}

define i32 @"\E5\B7\A5\E5\85\B7#\E7\BB\9D\E5\AF\B9\E5\80\BC"(i32 %0) {
entry:
  %lttmp = icmp slt i32 %0, 0
  br i1 %lttmp, label %then, label %ifcont

then:                                             ; preds = %entry
  %subtmp = sub i32 0, %0
  ret i32 %subtmp

ifcont:                                           ; preds = %entry
  ret i32 %0
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
