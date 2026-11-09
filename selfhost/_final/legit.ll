; ModuleID = 'main'
source_filename = "main"

%Box = type { i32 }
%Wrap = type { ptr }

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
  %newobj.malloc1 = call ptr @malloc(i64 4)
  %value.init = getelementptr inbounds %Box, ptr %newobj.malloc1, i32 0, i32 0
  store i32 42, ptr %value.init, align 4
  %inner.init = getelementptr inbounds %Wrap, ptr %newobj.malloc, i32 0, i32 0
  store ptr %newobj.malloc1, ptr %inner.init, align 8
  %calltmp = call i32 @Wrap_unwrap(ptr %newobj.malloc)
  ret i32 %calltmp
}

define i32 @Box_get(ptr %this) {
entry:
  %value.field = getelementptr inbounds %Box, ptr %this, i32 0, i32 0
  %value.load = load i32, ptr %value.field, align 4
  ret i32 %value.load
}

define i32 @Wrap_unwrap(ptr %this) {
entry:
  %inner.field = getelementptr inbounds %Wrap, ptr %this, i32 0, i32 0
  %inner.load = load ptr, ptr %inner.field, align 8
  %calltmp = call i32 @Box_get(ptr %inner.load)
  ret i32 %calltmp
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
