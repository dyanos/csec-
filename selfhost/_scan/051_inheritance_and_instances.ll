; ModuleID = 'main'
source_filename = "main"

%Animal = type { ptr }
%Dog = type { ptr }

@0 = private unnamed_addr constant [4 x i8] c"cat\00", align 1
@1 = private unnamed_addr constant [4 x i8] c"dog\00", align 1

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
  %name.init = getelementptr inbounds %Animal, ptr %newobj.malloc, i32 0, i32 0
  store ptr @0, ptr %name.init, align 8
  %newobj.malloc1 = call ptr @malloc(i64 8)
  %name.init2 = getelementptr inbounds %Dog, ptr %newobj.malloc1, i32 0, i32 0
  store ptr @1, ptr %name.init2, align 8
  ret i32 0
}

define i32 @Animal_id(ptr %this) {
entry:
  %name.field = getelementptr inbounds %Animal, ptr %this, i32 0, i32 0
  ret i32 1
}

define i32 @Dog_bark(ptr %this) {
entry:
  %name.field = getelementptr inbounds %Dog, ptr %this, i32 0, i32 0
  ret i32 2
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
