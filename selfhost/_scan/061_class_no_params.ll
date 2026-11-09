; ModuleID = 'main'
source_filename = "main"

%Singleton = type { i32 }
%Counter = type { i32 }

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
  %newobj.malloc1 = call ptr @malloc(i64 4)
  %id.init = getelementptr inbounds %Singleton, ptr %newobj.malloc1, i32 0, i32 0
  store i32 1, ptr %id.init, align 4
  %newobj.malloc2 = call ptr @malloc(i64 4)
  %count.init = getelementptr inbounds %Counter, ptr %newobj.malloc2, i32 0, i32 0
  store i32 0, ptr %count.init, align 4
  %calltmp = call i32 @Counter_increment(ptr %newobj.malloc2)
  %calltmp3 = call i32 @Counter_increment(ptr %newobj.malloc2)
  %calltmp4 = call i32 @EmptyClass_value(ptr %newobj.malloc)
  %calltmp5 = call i32 @Singleton_getId(ptr %newobj.malloc1)
  %addtmp = add i32 %calltmp4, %calltmp5
  %calltmp6 = call i32 @Counter_get(ptr %newobj.malloc2)
  %addtmp7 = add i32 %addtmp, %calltmp6
  ret i32 %addtmp7
}

define i32 @EmptyClass_value(ptr %this) {
entry:
  ret i32 0
}

define i32 @Singleton_getId(ptr %this) {
entry:
  %id.field = getelementptr inbounds %Singleton, ptr %this, i32 0, i32 0
  %id.load = load i32, ptr %id.field, align 4
  ret i32 %id.load
}

define i32 @Counter_increment(ptr %this) {
entry:
  %count.field = getelementptr inbounds %Counter, ptr %this, i32 0, i32 0
  %count.load = load i32, ptr %count.field, align 4
  %count.load1 = load i32, ptr %count.field, align 4
  %addtmp = add i32 %count.load1, 1
  store i32 %addtmp, ptr %count.field, align 4
  %count.load2 = load i32, ptr %count.field, align 4
  ret i32 %count.load2
}

define i32 @Counter_get(ptr %this) {
entry:
  %count.field = getelementptr inbounds %Counter, ptr %this, i32 0, i32 0
  %count.load = load i32, ptr %count.field, align 4
  ret i32 %count.load
}

declare void @csec_set_command_line_args(i32, ptr)

define internal i32 @__csec_jit_entry() {
entry:
  %user.main = call i32 @_main()
  ret i32 %user.main
}
