; ModuleID = 'main'
source_filename = "main"

%"Box$Int$10" = type { ptr }
%"Box$Int$10.0" = type { ptr }

@0 = private unnamed_addr constant [2 x i8] c"x\00", align 1

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

define i32 @"Box$Int$10_getCap"(ptr %this) {
entry:
  %name.field = getelementptr inbounds %"Box$Int$10", ptr %this, i32 0, i32 0
  ret i32 10
}

define i32 @_main() {
entry:
  %newobj.malloc = call ptr @malloc(i64 8)
  %name.init = getelementptr inbounds %"Box$Int$10.0", ptr %newobj.malloc, i32 0, i32 0
  store ptr @0, ptr %name.init, align 8
  %calltmp = call i32 @"Box$Int$10_getCap.1"(ptr %newobj.malloc)
  ret i32 %calltmp
}

define i32 @"Box$Int$10_getCap.1"(ptr %this) {
entry:
  %name.field = getelementptr inbounds %"Box$Int$10.0", ptr %this, i32 0, i32 0
  ret i32 10
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
