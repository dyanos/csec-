; ModuleID = 'main'
source_filename = "main"

%"Container$Int$String" = type { i32, ptr }
%"Container$Int$String.0" = type { i32, ptr }

@0 = private unnamed_addr constant [6 x i8] c"hello\00", align 1

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

define i32 @"Container$Int$String_getFirst"(ptr %this) {
entry:
  %first.field = getelementptr inbounds %"Container$Int$String", ptr %this, i32 0, i32 0
  %second.field = getelementptr inbounds %"Container$Int$String", ptr %this, i32 0, i32 1
  %first.load = load i32, ptr %first.field, align 4
  ret i32 %first.load
}

define ptr @"Container$Int$String_getSecond"(ptr %this) {
entry:
  %first.field = getelementptr inbounds %"Container$Int$String", ptr %this, i32 0, i32 0
  %second.field = getelementptr inbounds %"Container$Int$String", ptr %this, i32 0, i32 1
  %second.load = load ptr, ptr %second.field, align 8
  ret ptr %second.load
}

define i32 @_main() {
entry:
  %calltmp = call i32 @"_triple$Int$Float$Double"(i32 42, float 0x40091EB860000000, double 0x4005BE76C0000000)
  %newobj.malloc = call ptr @malloc(i64 16)
  %first.init = getelementptr inbounds %"Container$Int$String.0", ptr %newobj.malloc, i32 0, i32 0
  store i32 1, ptr %first.init, align 4
  %second.init = getelementptr inbounds %"Container$Int$String.0", ptr %newobj.malloc, i32 0, i32 1
  store ptr @0, ptr %second.init, align 8
  ret i32 %calltmp
}

define i32 @"_triple$Int$Float$Double"(i32 %0, float %1, double %2) {
entry:
  ret i32 %0
}

define i32 @"Container$Int$String_getFirst.1"(ptr %this) {
entry:
  %first.field = getelementptr inbounds %"Container$Int$String.0", ptr %this, i32 0, i32 0
  %second.field = getelementptr inbounds %"Container$Int$String.0", ptr %this, i32 0, i32 1
  %first.load = load i32, ptr %first.field, align 4
  ret i32 %first.load
}

define ptr @"Container$Int$String_getSecond.2"(ptr %this) {
entry:
  %first.field = getelementptr inbounds %"Container$Int$String.0", ptr %this, i32 0, i32 0
  %second.field = getelementptr inbounds %"Container$Int$String.0", ptr %this, i32 0, i32 1
  %second.load = load ptr, ptr %second.field, align 8
  ret ptr %second.load
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
