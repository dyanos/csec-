; ModuleID = 'main'
source_filename = "main"

%Name = type { ptr }

@0 = private unnamed_addr constant [4 x i8] c"Hi \00", align 1
@1 = private unnamed_addr constant [4 x i8] c"Bob\00", align 1

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
  %prefix.init = getelementptr inbounds %Name, ptr %newobj.malloc, i32 0, i32 0
  store ptr @0, ptr %prefix.init, align 8
  %calltmp = call ptr @Name_greet(ptr %newobj.malloc, ptr @1)
  %str.length = call i64 @csec_string_length(ptr %calltmp)
  %abi.trunc = trunc i64 %str.length to i32
  ret i32 %abi.trunc
}

define ptr @Name_greet(ptr %this, ptr %who) {
entry:
  %prefix.field = getelementptr inbounds %Name, ptr %this, i32 0, i32 0
  %prefix.load = load ptr, ptr %prefix.field, align 8
  %str.concat = call ptr @csec_string_concat(ptr %prefix.load, ptr %who)
  ret ptr %str.concat
}

declare ptr @csec_string_concat(ptr, ptr)

declare i64 @csec_string_length(ptr)

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
