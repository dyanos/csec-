; ModuleID = 'main'
source_filename = "main"

%Stack = type { i32 }

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
  %newobj.malloc = call ptr @malloc(i64 4)
  %capacity.init = getelementptr inbounds %Stack, ptr %newobj.malloc, i32 0, i32 0
  store i32 21, ptr %capacity.init, align 4
  %calltmp = call i32 @Stack_doubled(ptr %newobj.malloc)
  %eqtmp = icmp eq i32 %calltmp, 42
  br i1 %eqtmp, label %and_rhs, label %and_end

and_rhs:                                          ; preds = %entry
  %calltmp1 = call i32 @Stack_plus(ptr %newobj.malloc, i32 8)
  %eqtmp2 = icmp eq i32 %calltmp1, 29
  br label %and_end

and_end:                                          ; preds = %and_rhs, %entry
  %and_result.0 = phi i1 [ %eqtmp2, %and_rhs ], [ false, %entry ]
  br i1 %and_result.0, label %then, label %ifcont

then:                                             ; preds = %and_end
  ret i32 0

ifcont:                                           ; preds = %and_end
  ret i32 1
}

define i32 @Stack_size(ptr %this) {
entry:
  %capacity.field = getelementptr inbounds %Stack, ptr %this, i32 0, i32 0
  %capacity.load = load i32, ptr %capacity.field, align 4
  ret i32 %capacity.load
}

define i32 @Stack_doubled(ptr %this) {
entry:
  %capacity.field = getelementptr inbounds %Stack, ptr %this, i32 0, i32 0
  %calltmp = call i32 @Stack_size(ptr %this)
  %calltmp1 = call i32 @Stack_size(ptr %this)
  %addtmp = add i32 %calltmp, %calltmp1
  ret i32 %addtmp
}

define i32 @Stack_plus(ptr %this, i32 %extra) {
entry:
  %capacity.field = getelementptr inbounds %Stack, ptr %this, i32 0, i32 0
  %calltmp = call i32 @Stack_size(ptr %this)
  %addtmp = add i32 %calltmp, %extra
  ret i32 %addtmp
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
