; ModuleID = 'main'
source_filename = "main"

%Holder = type { i32 }

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
  %newobj.malloc = call ptr @malloc(i64 0)
  %newobj.malloc1 = call ptr @malloc(i64 0)
  %newobj.malloc2 = call ptr @malloc(i64 4)
  %x.init = getelementptr inbounds %Holder, ptr %newobj.malloc2, i32 0, i32 0
  store i32 4, ptr %x.init, align 4
  ret i32 0
}

define i32 @Empty_value(ptr %this) {
entry:
  ret i32 1
}

define i32 @Holder_get(ptr %this) {
entry:
  %x.field = getelementptr inbounds %Holder, ptr %this, i32 0, i32 0
  %x.load = load i32, ptr %x.field, align 4
  ret i32 %x.load
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
