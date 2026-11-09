; ModuleID = 'main'
source_filename = "main"

%Switch = type { i1 }

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
  %newobj.malloc = call ptr @malloc(i64 1)
  %enabled.init = getelementptr inbounds %Switch, ptr %newobj.malloc, i32 0, i32 0
  store i1 false, ptr %enabled.init, align 1
  %calltmp = call i1 @Switch_enable(ptr %newobj.malloc)
  %calltmp1 = call i1 @Switch_isEnabled(ptr %newobj.malloc)
  br i1 %calltmp1, label %then, label %ifcont

then:                                             ; preds = %entry
  ret i32 42

ifcont:                                           ; preds = %entry
  ret i32 0
}

define i1 @Switch_enable(ptr %this) {
entry:
  %enabled.field = getelementptr inbounds %Switch, ptr %this, i32 0, i32 0
  %enabled.load = load i1, ptr %enabled.field, align 1
  store i1 true, ptr %enabled.field, align 1
  %enabled.load1 = load i1, ptr %enabled.field, align 1
  ret i1 %enabled.load1
}

define i1 @Switch_isEnabled(ptr %this) {
entry:
  %enabled.field = getelementptr inbounds %Switch, ptr %this, i32 0, i32 0
  %enabled.load = load i1, ptr %enabled.field, align 1
  ret i1 %enabled.load
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
