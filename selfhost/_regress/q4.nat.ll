; ModuleID = 'main'
source_filename = "main"

%Counter = type { i64 }

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

define i64 @Counter_value(ptr %this) {
entry:
  %start.field = getelementptr inbounds %Counter, ptr %this, i32 0, i32 0
  %start.load = load i64, ptr %start.field, align 4
  ret i64 %start.load
}

define i32 @_main() {
entry:
  %newobj.malloc = call ptr @malloc(i64 8)
  %start.init = getelementptr inbounds %Counter, ptr %newobj.malloc, i32 0, i32 0
  store i64 2147483653, ptr %start.init, align 4
  %calltmp = call i64 @Counter_value(ptr %newobj.malloc)
  %eqtmp = icmp eq i64 %calltmp, 2147483653
  br i1 %eqtmp, label %then, label %ifcont

then:                                             ; preds = %entry
  ret i32 0

ifcont:                                           ; preds = %entry
  ret i32 1
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
