; ModuleID = 'main'
source_filename = "main"

%Dog = type { ptr, i32, ptr }
%Animal = type { ptr, i32 }

@0 = private unnamed_addr constant [4 x i8] c"Rex\00", align 1
@1 = private unnamed_addr constant [9 x i8] c"Labrador\00", align 1

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
  %newobj.malloc = call ptr @malloc(i64 24)
  %name.init = getelementptr inbounds %Dog, ptr %newobj.malloc, i32 0, i32 0
  store ptr @0, ptr %name.init, align 8
  %age.init = getelementptr inbounds %Dog, ptr %newobj.malloc, i32 0, i32 1
  store i32 3, ptr %age.init, align 4
  %breed.init = getelementptr inbounds %Dog, ptr %newobj.malloc, i32 0, i32 2
  store ptr @1, ptr %breed.init, align 8
  %calltmp = call i32 @Dog_bark(ptr %newobj.malloc)
  ret i32 %calltmp
}

define i32 @Animal_getAge(ptr %this) {
entry:
  %name.field = getelementptr inbounds %Animal, ptr %this, i32 0, i32 0
  %age.field = getelementptr inbounds %Animal, ptr %this, i32 0, i32 1
  %age.load = load i32, ptr %age.field, align 4
  ret i32 %age.load
}

define i32 @Dog_bark(ptr %this) {
entry:
  %name.field = getelementptr inbounds %Dog, ptr %this, i32 0, i32 0
  %age.field = getelementptr inbounds %Dog, ptr %this, i32 0, i32 1
  %breed.field = getelementptr inbounds %Dog, ptr %this, i32 0, i32 2
  ret i32 1
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
