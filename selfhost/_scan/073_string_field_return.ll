; ModuleID = 'main'
source_filename = "main"

%Message = type { ptr }

@0 = private unnamed_addr constant [8 x i8] c"runtime\00", align 1

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
  %text.init = getelementptr inbounds %Message, ptr %newobj.malloc, i32 0, i32 0
  store ptr @0, ptr %text.init, align 8
  %calltmp = call ptr @Message_value(ptr %newobj.malloc)
  %str.length = call i64 @csec_string_length(ptr %calltmp)
  %abi.trunc = trunc i64 %str.length to i32
  ret i32 %abi.trunc
}

define ptr @Message_value(ptr %this) {
entry:
  %text.field = getelementptr inbounds %Message, ptr %this, i32 0, i32 0
  %text.load = load ptr, ptr %text.field, align 8
  ret ptr %text.load
}

declare i64 @csec_string_length(ptr)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
