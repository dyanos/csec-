; ModuleID = 'main'
source_filename = "main"

%Service = type { i32, i32 }

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
  %id.init = getelementptr inbounds %Service, ptr %newobj.malloc, i32 0, i32 0
  store i32 10, ptr %id.init, align 4
  %version.init = getelementptr inbounds %Service, ptr %newobj.malloc, i32 0, i32 1
  store i32 1, ptr %version.init, align 4
  %calltmp = call i32 @Service_run(ptr %newobj.malloc, i32 5)
  ret i32 %calltmp
}

define i32 @"Logger#info"(i32 %0) {
entry:
  ret i32 %0
}

define i32 @Service_run(ptr %this, i32 %x) {
entry:
  %id.field = getelementptr inbounds %Service, ptr %this, i32 0, i32 0
  %version.field = getelementptr inbounds %Service, ptr %this, i32 0, i32 1
  %id.load = load i32, ptr %id.field, align 4
  %addtmp = add i32 %id.load, %x
  %version.load = load i32, ptr %version.field, align 4
  %addtmp1 = add i32 %addtmp, %version.load
  %calltmp = call i32 @"Logger#info"(i32 %addtmp1)
  ret i32 %calltmp
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
